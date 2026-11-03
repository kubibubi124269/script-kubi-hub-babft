return function(Util)
 local Farm={};Farm.__index=Farm
 Farm.profiles={NORMAL=2,FAST=1.4,TURBO=1,HYPER=.7,LIGHTNING=.5,SONIC=.3}
 function Farm.new(runtime,adapter,settings,log,spawn)
  return setmetatable({runtime=runtime,adapter=adapter,settings=settings,log=log,spawn=spawn,state='STOPPED',generation=0,stage=0,retries=0,nextAt=0,stats={started=runtime.clock(),completed=0,failed=0,totalCycleTime=0,lastError='',lastCycleTime=nil},pending=nil},Farm)
 end
 function Farm:availability()
  if self.adapter.mode=='BABFT' and self.adapter.farmReason then return self.adapter.capabilities.farm==true,self.adapter.farmReason end
  if self.adapter.capabilities.farm then return true,'Autofarma: dostępna w połączonym środowisku.' end
  if self.adapter.mode=='BABFT' then return false,'Brak kompletnej trasy autofarmy BABFT. Odśwież trasę i sprawdź etapy oraz skrzynię.' end
  return false,'Ten serwer nie udostępnia kontrolera autofarmy. Kontroler V5 działa z dodatkiem do własnej gry w Roblox Studio.'
 end
 function Farm:start()
  if self.state~='STOPPED' and self.state~='ERROR' then return false,'Farm już działa lub jest wstrzymana.' end
  if self.pending and not self.pending.done or self.adapter.pending then return false,'Oczekiwanie na zakończenie poprzedniego żądania.' end
  if self.adapter.mode=='BABFT' then self.adapter:connect() end
  local available,reason=self:availability();if not available then self.stats.lastError=reason;return false,reason end
  local ok,err=self.runtime:acquire('Farm');if not ok then return false,err end
  self.generation=self.generation+1;self.stage=0;self.retries=0;self.stats.lastError='';self.cycleStarted=self.runtime.clock();self.nextAt=self.runtime.clock();self.state='RUNNING';self.log:add('Farm','START');return true
 end
 function Farm:pause()if self.state~='RUNNING' and self.state~='RETRY' then return false,'Brak aktywnej farmy.' end;self.beforePause=self.state;self.state='PAUSED';self.log:add('Farm','PAUZA');return true end
 function Farm:resume()if self.state~='PAUSED' then return false,'Farm nie jest wstrzymana.' end;self.state=self.beforePause or 'RUNNING';self.log:add('Farm','WZNÓW');return true end
 function Farm:stop(reason)
  self.generation=self.generation+1;self.state='STOPPED';self.runtime:release('Farm');self.adapter:cancel('farm');self.log:add('Farm',reason or 'Zadanie zatrzymane przez użytkownika.');return true
 end
 function Farm:reset()
  if self.state~='STOPPED' or self.pending and not self.pending.done then return false,'Zatrzymaj Farm i poczekaj na koniec żądania.' end
  self.stats={started=self.runtime.clock(),completed=0,failed=0,totalCycleTime=0,lastError='',lastCycleTime=nil};self.stage=0;return true
 end
 function Farm:fail(err)
  self.adapter:cancel('farm')
  self.stats.failed=self.stats.failed+1;self.stats.lastError=tostring(err);self.log:error('Farm',err);self.retries=self.retries+1
  if self.retries>self.settings.retryLimit then self.state='ERROR';self.runtime:release('Farm');return end
  self.state='RETRY';self.stage=0;self.nextAt=self.runtime.clock()+2^(self.retries-1);self.cycleStarted=self.nextAt
 end
 function Farm:tick()
  if self.pending then
   if not self.pending.done then return end
   local j=self.pending;self.pending=nil
   if j.generation~=self.generation then return end
   if not j.ok or type(j.result)~='table' or not j.result.ok then local paused=self.state=='PAUSED';self:fail(j.ok and j.result and j.result.error or j.result);if paused and self.state=='RETRY' then self.beforePause='RETRY';self.state='PAUSED' end;return end
   local reply=j.result
   if reply.stage~=self.stage+1 then self:fail('Serwer potwierdził inny etap.');return end
   self.stage=reply.stage
   if reply.completed==true then
    local duration=self.runtime.clock()-self.cycleStarted;self.stats.completed=self.stats.completed+1;self.stats.totalCycleTime=self.stats.totalCycleTime+duration;self.stats.lastCycleTime=duration;self.retries=0;self.stage=0;self.cycleStarted=self.runtime.clock()
    self.log:add('Farm',self.adapter.mode=='BABFT' and 'Zaobserwowano powrót postaci po trasie i skrzyni. Nagrody nie zostały zmierzone.' or 'Cykl potwierdzony przez uprawniony serwer. Nagrody nie są symulowane.')
    if self.settings.stopAfter>0 and self.stats.completed>=self.settings.stopAfter then self:stop('Osiągnięto limit cykli.');return end
   end
   self.nextAt=self.runtime.clock()+math.max(Farm.profiles[self.settings.profile] or 2,self.adapter.minFarmInterval or 0)
  end
  if self.state=='RETRY' and self.runtime.clock()>=self.nextAt then self.state='RUNNING' end
  if self.state~='RUNNING' or self.runtime.clock()<self.nextAt then return end
  local generation=self.generation;local stage=self.stage+1
  self.pending=self.runtime:job('Farm',function()return self.adapter:farmStep(stage,function()return self.state=='PAUSED' end)end,self.spawn);self.pending.generation=generation
 end
 function Farm:summary()
  local elapsed=math.max(0,self.runtime.clock()-self.stats.started);local count=self.stats.completed
  return {state=self.state,elapsed=elapsed,completed=count,failed=self.stats.failed,average=count>0 and self.stats.totalCycleTime/count or nil,cyclesPerHour=count>0 and elapsed>0 and count*3600/elapsed or nil,lastError=self.stats.lastError,stage=self.stage}
 end
 return Farm
end
