return function(Util,Schema,Inventory)
 local B={};B.__index=B
 function B.new(context,platform)
  return setmetatable({context=context,platform=platform,mode='BABFT',capabilities={},serial=0,pending=nil,transactions={},chunkSize=1,minFarmInterval=.3,label='BABFT — oczekiwanie na test narzędzia',buildVerified=false},B)
 end
 function B:newId(prefix)self.serial+=1;return prefix..'_'..self.context.userId..'_'..self.serial end
 function B:connect()
  local info=self.platform:inspect();self.zone=info.zone;self.diagnostics=info.text
  self.capabilities={build=self.buildVerified and info.build,inventory=true,mechanics=false,movement=false,farm=info.farm==true}
  self.toolAvailable=info.build==true;return self.toolAvailable or self.capabilities.farm,self.diagnostics
 end
 function B:invoke(remote,args)
  if self.pending then return {ok=false,error='Poprzednie żądanie narzędzia nadal trwa. Nie ponawiam go.'} end
  local job={done=false};self.pending=job;local start=self.context.clock()
  self.context.spawn(function()job.ok,job.value=pcall(function()return remote:InvokeServer(table.unpack(args,1,args.n or #args))end);job.done=true;if self.pending==job then self.pending=nil end end)
  while not job.done and self.context.alive() and self.context.clock()-start<7 do self.context.wait(.03) end
  self.lastLatency=(self.context.clock()-start)*1000
  if not job.done then return {ok=false,error='Narzędzie nie odpowiedziało w 7 s. Żądanie może jeszcze postawić blok; nie ponawiam.'} end
  if not job.ok or job.value==false then return {ok=false,error=job.ok and 'Narzędzie odrzuciło żądanie.' or tostring(job.value)} end
  return {ok=true,value=job.value}
 end
 function B:inventory()return {ok=true,values=self.platform:inventory(),source='BABFT / odczyt danych gracza'} end
 function B:testBuild()
  for _,tx in pairs(self.transactions) do if tx.state=='building' then return {ok=false,error='Zakończ bieżącą budowę przed testem.'} end end
  if self.pending then return {ok=false,error='Poprzednie żądanie jeszcze trwa.'} end
  self:connect();if not self.toolAvailable then return {ok=false,error=self.diagnostics} end
  local e={id='probe',material='WoodBlock',class='Part',position={0,2,0},rotation={0,0,0},size={2,2,2}}
  local ok,err=self.platform:preflight({elements={e}},0);if not ok then return {ok=false,error=err} end
  local generation=self.probeGeneration or 0
  local function cancelled()return not self.context.alive() or generation~=(self.probeGeneration or 0) end
  local result=self.platform:place(e,0,function(remote,args)return self:invoke(remote,args)end,cancelled)
  if cancelled() then return {ok=false,error='Test zatrzymany. Wysłany wcześniej blok może pozostać na działce.'} end
  if not result.ok then self.buildVerified=false;self.capabilities.build=false;return result end
  self.buildVerified=true;self.capabilities.build=true;self.label='BABFT — test bloku potwierdzony'
  return {ok=true,message='Test potwierdzony: jeden drewniany blok jest w Twojej budowli. Możesz uruchomić BUILD dla planów statycznych. Blok testowy pozostaje na działce.'}
 end
 function B:beginBuild(id,raw,yaw)
  if not self.buildVerified then return {ok=false,error='Najpierw uruchom TEST 1 BLOKU w Builderze.'} end
  if self.transactions[id] then return {ok=false,error='Ten identyfikator budowy był już użyty.'} end
  for _,tx in pairs(self.transactions) do if tx.state=='building' then return {ok=false,error='Inna budowa nadal trwa.'} end end
  local schema,errors=Schema.validate(raw);if not schema then return {ok=false,error=table.concat(errors,'; ')} end
  if schema.mechanical or schema.importedMechanics or schema.assistantOnly or #schema.connections>0 then return {ok=false,error='BABFT: obsługa statycznej geometrii. Ten projekt wymaga nieobsługiwanych połączeń lub jest tylko podglądem.'} end
  local ok,err=self.platform:preflight(schema,yaw);if not ok then return {ok=false,error=err} end
  self.order=self.order or {};while #self.order>=3 do local old=table.remove(self.order,1);self.transactions[old]=nil end;self.order[#self.order+1]=id
  local tx={schema=schema,yaw=yaw or 0,state='building',next=1,objects={}};self.transactions[id]=tx;self.active=id;return {ok=true,transaction=id}
 end
 function B:placeChunk(id,first,count)
  local tx=self.transactions[id];if not tx or tx.state~='building' or first~=tx.next or count~=1 then return {ok=false,error='Nieprawidłowa kolejność lub zatrzymana budowa.'} end
  local e=tx.schema.elements[first];if not e then return {ok=false,error='Brak części w planie.'} end
  local result=self.platform:place(e,tx.yaw,function(remote,args)return self:invoke(remote,args)end,function()return tx.state~='building' or not self.context.alive() end)
  if not result.ok then return result end
  tx.objects[#tx.objects+1]=result.object;tx.next+=1
  return {ok=true,ids={e.id}}
 end
 function B:commitBuild(id)
  local tx=self.transactions[id];if not tx or tx.state~='building' or #tx.objects~=#tx.schema.elements then return {ok=false,error='Brak potwierdzenia wszystkich części.'} end
  for _,object in ipairs(tx.objects) do if not self.platform:stillOwned(object) then return {ok=false,error='Jedna z postawionych części zniknęła z Twojej budowli.'} end end
  tx.state='committed';return {ok=true,count=#tx.objects,connected=true}
 end
 function B:cancel(id)
  if id=='all' then self.probeGeneration=(self.probeGeneration or 0)+1 end
  if id=='farm' or id=='all' then self.farmGeneration=(self.farmGeneration or 0)+1;self.farmState=nil;if self.platform.stopFarm then self.platform:stopFarm() end end
  for key,tx in pairs(self.transactions) do if tx.state=='building' and (id=='all' or id==key) then tx.state='cancelled' end end
 end
 function B:buildStatus(id,cancel)
  if cancel then self:cancel(id) end;local tx=self.transactions[id]
  if not tx then return {ok=false,error='Nie znaleziono budowy.'} end
  return {ok=true,state=tx.state,count=#tx.objects}
 end
 function B:farmStep(stage)
  if not self.platform.farmStep then return {ok=false,error='Brak obsługi farmy w tym środowisku.'} end
  local generation=self.farmGeneration or 0
  return self.platform:farmStep(stage,function()return not self.context.alive() or generation~=(self.farmGeneration or 0) end)
 end
 function B:rig()return {ok=false,error='Mechanika WORM-a nie jest obsługiwana przez narzędzia zgodności BABFT.'} end
 function B:movement()return {ok=false,error='Ten tryb nie zmienia ustawień ruchu.'} end
 function B:snapshot()return {ok=false,error='Eksport budowli BABFT nie jest jeszcze obsługiwany. Eksportuj wybrany plan.'} end
 return B
end
