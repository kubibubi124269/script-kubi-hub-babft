return function(Util)
 local Adapter={};Adapter.__index=Adapter
 function Adapter.new(context)
  return setmetatable({context=context,capabilities={},pending=nil,serial=0,session=nil,zone=nil,label='Asystent — brak autoryzowanego adaptera',chunkSize=16,minFarmInterval=0,lastLatency=nil},Adapter)
 end
 function Adapter:newId(prefix)self.serial=self.serial+1;return prefix..'_'..self.context.userId..'_'..self.serial..'_'..math.floor(self.context.clock()*1000) end
 function Adapter:call(kind,payload)
  if not self.remote then return {ok=false,error='Brak autoryzowanego adaptera.'} end
  if self.pending then return {ok=false,error='Poprzednie żądanie adaptera nadal trwa. Nie ponawiam automatycznie.'} end
  local ticket={done=false};self.pending=ticket;local started=self.context.clock()
  local packet={protocol=1,session=self.session,id=self:newId(kind),kind=kind,payload=payload or {}}
  self.context.spawn(function()
   ticket.ok,ticket.result=pcall(function()return self.remote:InvokeServer(packet)end);ticket.done=true
   if self.pending==ticket then self.pending=nil end
  end)
  while not ticket.done and self.context.clock()-started<5 and self.context.alive() do self.context.wait(.025) end
  if not ticket.done then return {ok=false,error='Adapter: timeout. Żądanie może nadal kończyć się na serwerze; czekam przed następnym.'} end
  self.lastLatency=(self.context.clock()-started)*1000
  if not ticket.ok then return {ok=false,error=tostring(ticket.result)} end
  if type(ticket.result)~='table' or type(ticket.result.ok)~='boolean' then return {ok=false,error='Nieprawidłowa odpowiedź adaptera.'} end
  return ticket.result
 end
 function Adapter:connect(replica)
  local r=replica:FindFirstChild('KubiHubAuthorizedBridgeV1');local cancel=replica:FindFirstChild('KubiHubCancelV1')
  if not r or not r:IsA('RemoteFunction') or not cancel or not cancel:IsA('RemoteEvent') then return false,self.label end
  self.remote=r;self.cancelRemote=cancel;local reply=self:call('hello')
  if not reply.ok or reply.authorized~=true or reply.userId~=self.context.userId or reply.placeId~=self.context.placeId or reply.protocol~=1 or type(reply.session)~='string' then self.remote=nil;return false,reply.error or 'Serwer nie potwierdził uprawnień.' end
  self.session=reply.session;self.capabilities={};for _,cap in ipairs({'build','mechanics','inventory','farm','movement'}) do self.capabilities[cap]=type(reply.capabilities)=='table' and reply.capabilities[cap]==true end
  if type(reply.zone)=='table' and Util.vector(reply.zone.size,10000) and reply.zone.size[1]>0 and reply.zone.size[2]>0 and reply.zone.size[3]>0 then self.zone={size=Util.copy(reply.zone.size)} end
  self.minFarmInterval=Util.number(reply.minFarmInterval,.5,.1,10);self.label=tostring(reply.label or 'Autoryzowany adapter'):sub(1,120);return true
 end
 function Adapter:cancel(transaction)
  if self.session and self.cancelRemote then self.cancelRemote:FireServer({protocol=1,session=self.session,transaction=transaction or 'all'}) end
 end
 function Adapter:inventory()return self:call('inventory')end
 function Adapter:beginBuild(id,schema,yaw)return self:call('beginBuild',{id=id,schema=schema,yaw=yaw})end
 function Adapter:placeChunk(id,first,count)return self:call('placeChunk',{transaction=id,first=first,count=count})end
 function Adapter:commitBuild(id)return self:call('commitBuild',{transaction=id})end
 function Adapter:buildStatus(id,cancel)return self:call('buildStatus',{transaction=id,cancel=cancel==true})end
 function Adapter:farmStep(stage)return self:call('farmStep',{stage=stage})end
 function Adapter:movement(values)return self:call('movement',values)end
 function Adapter:rig(action)return self:call('rig',{action=action})end
 function Adapter:snapshot()return self:call('snapshot')end
 return Adapter
end
