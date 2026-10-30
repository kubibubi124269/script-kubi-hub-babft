return function(Util,Schema,Inventory)
 local Builder={};Builder.__index=Builder
 function Builder.new(runtime,adapter,log,spawn)
  return setmetatable({runtime=runtime,adapter=adapter,log=log,spawn=spawn,state='IDLE',generation=0,revision=0,pending=nil,placed=0,total=0,history={},future={},options={yaw=0,material='ORIGINAL',mirrorX=false,mirrorZ=false,scale=1,offsetX=0,offsetY=0,offsetZ=0},transaction=nil},Builder)
 end
 function Builder:select(raw,reset)
  if self:isBusy() then return false,'Najpierw zakończ lub anuluj budowę.' end
  local schema,errors=Schema.validate(raw);if not schema then return false,table.concat(errors,'; ') end
  local options=reset and {yaw=0,material='ORIGINAL',mirrorX=false,mirrorZ=false,previewLayer=0,scale=1,offsetX=0,offsetY=0,offsetZ=0} or Util.copy(self.options);if schema.mechanical then options.mirrorX=false;options.mirrorZ=false;options.scale=1 end
  local transformed,transformErrors=Schema.transform(schema,options);if not transformed then return false,table.concat(transformErrors,'; ') end
  self.source=schema;self.schema=transformed;self.options=options;self.bounds=Schema.bounds(transformed,options.yaw);self.history={};self.future={};self.state='PREVIEW';self.error=nil;self.revision=self.revision+1;return true
 end
 function Builder:isBusy()return self.state=='BUILDING' or self.state=='BEGINNING' or self.state=='PAUSED' or self.state=='COMMITTING' or self.state=='CANCELLING' end
 function Builder:edit(options,record)
  if self:isBusy() then return false,'Edycja jest zablokowana podczas budowania.' end
  if not self.source then return false,'Wybierz schemat.' end
  local nextOptions=Util.copy(options);nextOptions.yaw=Util.number(nextOptions.yaw,0,-360,360)
  local schema,errors=Schema.transform(self.source,nextOptions);if not schema then return false,table.concat(errors,'; ') end
  if record~=false then self.history[#self.history+1]=Util.copy(self.options);if #self.history>30 then table.remove(self.history,1) end;self.future={} end
  self.options=nextOptions;self.schema=schema;self.bounds=Schema.bounds(schema,nextOptions.yaw);self.state='PREVIEW';self.error=nil;self.revision=self.revision+1;return true
 end
 function Builder:undo()
  if self:isBusy() then return false,'Nie można cofać podczas budowania.' end
  local previous=table.remove(self.history);if not previous then return false,'Brak wcześniejszej edycji.' end
  self.future[#self.future+1]=Util.copy(self.options);return self:edit(previous,false)
 end
 function Builder:redo()
  if self:isBusy() then return false,'Nie można ponawiać podczas budowania.' end
  local nextOptions=table.remove(self.future);if not nextOptions then return false,'Brak edycji do ponowienia.' end
  self.history[#self.history+1]=Util.copy(self.options);return self:edit(nextOptions,false)
 end
 function Builder:assistant(snapshot)
  if not self.schema then return nil,'Wybierz schemat.' end
  return {bounds=self.bounds,materials=Inventory.compare(self.schema,snapshot),elements=#self.schema.elements,connections=#self.schema.connections,mechanical=self.schema.mechanical==true}
 end
 function Builder:start(snapshot)
  if self:isBusy() or self.pending and not self.pending.done or self.adapter.pending then return false,'Budowa albo jej zatrzymywanie już trwa.' end
  if not self.schema then return false,'Wybierz schemat.' end
  local valid,errors=Schema.validate(self.schema);if not valid then return false,table.concat(errors,'; ') end
  if valid.assistantOnly or valid.importedMechanics then return false,'Ten schemat jest dostępny jako podgląd / asystent. Nie uruchamiam eksplozji ani nie pomijam nieobsługiwanych połączeń.' end
  if not self.adapter.capabilities.build then return false,'Brak uprawnionego API budowania w tej grze. Podgląd i lista kroków są dostępne; lokalne części nie są budowlą serwerową.' end
  if valid.mechanical and not self.adapter.capabilities.mechanics then return false,'Adapter nie obsługuje wymaganych zawiasów i sterowania.' end
  local check=Inventory.compare(valid,snapshot);if not check.enough then return false,Inventory.describe(check) end
  local zone=self.adapter.zone;if not zone then return false,'Brak własnego obszaru budowania.' end
  local low=zone.min or {-zone.size[1]/2,-math.huge,-zone.size[3]/2};local high=zone.max or {zone.size[1]/2,math.huge,zone.size[3]/2}
  for i=1,3 do if self.bounds.min[i]<low[i]-1e-6 or self.bounds.max[i]>high[i]+1e-6 then return false,'Konstrukcja wychodzi poza własny obszar. Wyśrodkuj projekt, zmień obrót albo wybierz mniejszy.' end end
  local ok,err=self.runtime:acquire('Builder');if not ok then return false,err end
  self.generation=self.generation+1;self.state='BEGINNING';self.error=nil;self.placed=0;self.total=#valid.elements;self.transaction=nil;self.nextIndex=1
  local generation=self.generation;local requestId=self.adapter:newId('build');self.requestId=requestId
  self.pending=self.runtime:job('Builder',function()return self.adapter:beginBuild(requestId,valid,self.options.yaw)end,self.spawn);self.pending.generation=generation;self.pending.phase='begin'
  self.log:add('Builder','Sprawdzono plan i materiały. Oczekiwanie na autoryzację serwera.');return true
 end
 function Builder:pause()if self.state~='BUILDING' then return false,'Budowa nie jest w stanie BUILDING.' end;self.state='PAUSED';return true end
 function Builder:resume()if self.state~='PAUSED' then return false,'Budowa nie jest wstrzymana.' end;self.state='BUILDING';return true end
 function Builder:cancel(reason)
  if not self:isBusy() then return true end
  self.generation=self.generation+1;self.adapter:cancel(self.transaction or self.requestId);self.state='CANCELLING';self.log:add('Builder',reason or 'Zatrzymano kolejkę; oczekiwanie na potwierdzenie anulowania / końca zatwierdzania.');return true
 end
 function Builder:fail(err)
  self.adapter:cancel(self.transaction or self.requestId);self.state='ERROR';self.error=tostring(err);self.runtime:release('Builder');self.log:error('Builder',err)
 end
 function Builder:tick()
  if self.pending then
   if not self.pending.done then return end
   local j=self.pending;self.pending=nil;if j.generation~=self.generation then return end
   if not j.ok or type(j.result)~='table' or not j.result.ok then self:fail(j.ok and j.result and j.result.error or j.result);return end
   local r=j.result
   if j.phase=='begin' then
    if type(r.transaction)~='string' then self:fail('Brak identyfikatora transakcji w odpowiedzi serwera.');return end
    self.transaction=r.transaction;self.state='BUILDING'
   elseif j.phase=='place' then
    if type(r.ids)~='table' or #r.ids~=j.expected then self:fail('Niepełne potwierdzenie partii. Nie ponawiam jej automatycznie.');return end
    for i,id in ipairs(r.ids) do if id~=self.schema.elements[self.nextIndex+i-1].id then self:fail('Odpowiedź zawiera niewłaściwy identyfikator bloku.');return end end
    self.placed=self.placed+#r.ids;self.nextIndex=self.nextIndex+#r.ids
   elseif j.phase=='commit' then
    if r.count~=self.total or r.connected~=true then self:fail('Serwer nie potwierdził całej konstrukcji i połączeń.');return end
    self.state='COMPLETED';self.runtime:release('Builder');self.log:add('Builder',self.adapter.mode=='BABFT' and ('Odczytano '..self.total..' nowych części w Twojej budowli BABFT. Plan statyczny; nie odtwarzano mechaniki.') or ('Serwer potwierdził '..self.total..' części i połączenia. Fizyka wymaga testu integracyjnego.'));return
   elseif j.phase=='cancel' then
    if r.state~='committed' and r.state~='cancelled' or r.state=='committed' and r.count~=self.total then self:fail('Brak poprawnego potwierdzenia anulowania lub zakończenia budowy.');return end
    self.state=r.state=='committed' and 'COMPLETED' or 'CANCELLED';if r.state=='committed' then self.placed=r.count or self.placed;self.log:add('Builder','Zatwierdzanie zakończyło się przed anulowaniem. Konstrukcja pozostaje na serwerze.','WARN') elseif self.adapter.mode=='BABFT' then self.placed=r.count or self.placed;self.log:add('Builder','Zatrzymano wysyłanie bloków. Już postawione części pozostają na działce.','WARN') end;self.runtime:release('Builder');return
   end
  end
  if self.state=='CANCELLING' then
   if self.adapter.pending then return end
   local generation=self.generation;self.pending=self.runtime:job('Builder',function()return self.adapter:buildStatus(self.transaction or self.requestId,true)end,self.spawn);self.pending.phase='cancel';self.pending.generation=generation;return
  end
  if self.state~='BUILDING' then return end
  local generation=self.generation
  if self.nextIndex>self.total then
   self.state='COMMITTING';self.pending=self.runtime:job('Builder',function()return self.adapter:commitBuild(self.transaction)end,self.spawn);self.pending.phase='commit'
  else
   local first=self.nextIndex;local count=math.min(self.adapter.chunkSize or 16,self.total-first+1)
   self.pending=self.runtime:job('Builder',function()return self.adapter:placeChunk(self.transaction,first,count)end,self.spawn);self.pending.phase='place';self.pending.expected=count
  end
  self.pending.generation=generation
 end
 function Builder:export()if not self.schema then return nil,{'Wybierz schemat.'} end;return Schema.bakeYaw(self.schema,self.options.yaw) end
 function Builder:center()
  if not self.schema then return false,'Wybierz schemat.' end
  local options=Util.copy(self.options);local d=Util.rotate({-self.bounds.center[1],0,-self.bounds.center[3]},{0,-options.yaw,0})
  options.offsetX=(options.offsetX or 0)+d[1];options.offsetZ=(options.offsetZ or 0)+d[3];return self:edit(options)
 end
 function Builder:fit(zone)
  if self:isBusy() then return false,'Zatrzymaj budowę przed dopasowaniem.' end
  if not self.source then return false,'Wybierz schemat.' end
  if type(zone)~='table' or not Util.vector(zone.size,10000) or zone.size[1]<=2 or zone.size[3]<=2 then return false,'Brak poprawnych wymiarów obszaru.' end
  local low=zone.min or {-zone.size[1]/2,-math.huge,-zone.size[3]/2};local high=zone.max or {zone.size[1]/2,math.huge,zone.size[3]/2}
  local factor=1;for i=1,3 do local available=high[i]-low[i];if available<=0 then return false,'Nieprawidłowe granice obszaru.' end;factor=math.min(factor,available/self.bounds.size[i]) end
  local options=Util.copy(self.options);options.scale=(options.scale or 1)*factor
  if options.scale<.1 then return false,'Plan wymaga skali poniżej 10%. Wybierz większy obszar lub prostszy schemat.' end
  local schema,errors=Schema.transform(self.source,options);if not schema then return false,table.concat(errors,'; ') end
  local bounds=Schema.bounds(schema,options.yaw);local desiredX=(low[1]+high[1])/2;local desiredZ=(low[3]+high[3])/2
  local dy=math.clamp(0,low[2]-bounds.min[2],high[2]-bounds.max[2]);local d=Util.rotate({desiredX-bounds.center[1],dy,desiredZ-bounds.center[3]},{0,-options.yaw,0})
  options.offsetX=(options.offsetX or 0)+d[1];options.offsetY=(options.offsetY or 0)+d[2];options.offsetZ=(options.offsetZ or 0)+d[3]
  return self:edit(options)
 end
 return Builder
end
