return function(Util)
 local C={};C.__index=C
 function C.new(runtime,platform,clock)
  return setmetatable({runtime=runtime,p=platform,clock=clock,farming=false,paused=false,state='STOPPED',kind='BOTH',speed='TURBO',nextAt=0,coins={},cooldown=setmetatable({},{__mode='k'}),scannedAt=-math.huge,attempts=0,disappeared=0,aimbot=false,autoShot=false,autoGun=false,aura=false,esp=false,lastShot=-math.huge,lastKnife=-math.huge,nextGunAt=0,lastError='',shots=0,stabs=0,settings={target='MURDERER',selected='',fov=200,prediction=.08,smooth=35,wallCheck=true,shotInterval=.7}},C)
 end
 C.speeds={NORMAL=.5,FAST=.25,TURBO=.12}
 function C:startFarm()
  if not self.p.allowed then return false,'Najpierw dołącz do Murder Mystery 2.' end
  if self.farming then return false,'Autofarma już działa.' end
  local ok,err=self.runtime:acquire('MM2Farm');if not ok then return false,err end
  self.farming=true;self.paused=false;self.state='SEARCHING';self.lastError='';self.nextAt=0;self.scannedAt=-math.huge;return true
 end
 function C:stopFarm()
  self.farming=false;self.paused=false;self.state='STOPPED';self.current=nil;self.coins={};self.runtime:release('MM2Farm');return true
 end
 function C:pauseFarm()if not self.farming then return false,'Najpierw uruchom autofarmę.' end;self.paused=not self.paused;self.state=self.paused and 'PAUSED' or 'SEARCHING';return true end
 function C:setFilter(kind)
  if kind~='BOTH' and kind~='COIN' and kind~='CANDY' then return false,'Nieznany filtr.' end
  self.kind=kind;self.current=nil;self.coins={};self.scannedAt=-math.huge;return true
 end
 function C:resetStats()if self.farming or self.combat then return false,'Najpierw zatrzymaj aktywne moduły.' end;self.attempts=0;self.disappeared=0;self.shots=0;self.stabs=0;self.lastError='';return true end
 function C:farmTick(now)
  if not self.farming or self.paused or now<self.nextAt then return end
  local _,_,root=self.p:character();if not root then self.current=nil;self.state='WAIT_CHARACTER';self.nextAt=now+.25;return end
  if self.p:bagFull() then self.current=nil;self.state='BAG_FULL';self.nextAt=now+.5;return end
  if self.current then
   if not self.p:present(self.current) then self.disappeared+=1;self.current=nil
   elseif now-self.arrivedAt<.65 then self.state='PICKUP';return
   else self.cooldown[self.current.object]=now+4;self.current=nil end
  end
  if now-self.scannedAt>=.75 then self.coins=self.p:coins(self.kind);self.scannedAt=now end
  local best,distance=nil,math.huge
  for _,coin in ipairs(self.coins) do if self.p:present(coin) and (self.cooldown[coin.object] or 0)<=now then local d=(coin.part.Position-root.Position).Magnitude;if d<distance then best=coin;distance=d end end end
  if not best then self.state='WAIT_ITEMS';self.nextAt=now+.12;return end
  local ok,err=self.p:teleport(CFrame.new(best.part.Position+Vector3.new(0,1,0)));if not ok then self.lastError=err;self:stopFarm();return end
  self.current=best;self.arrivedAt=now;self.attempts+=1;self.state='PICKUP';self.nextAt=now+(C.speeds[self.speed] or .5)
 end
 function C:startKillAll()
  if not self.p.allowed then return false,'Najpierw dołącz do Murder Mystery 2.' end
  if self.p:role(self.p.player)~='Murderer' then return false,'Kill all wymaga własnego noża Murderera w aktywnej rundzie.' end
  if self.combat then return false,'Akcja walki już trwa.' end
  local ok,err=self.runtime:acquire('MM2Combat');if not ok then return false,err end
  local _,_,root=self.p:character();if not root then self.runtime:release('MM2Combat');return false,'Brak postaci.' end
  self.combat={kind='KILL_ALL',started=self.clock(),nextAt=0,index=1,targets=self.p:people(),origin=root.CFrame,root=root};return true
 end
 function C:startFling()
  if not self.p.allowed then return false,'Najpierw dołącz do Murder Mystery 2.' end
  if self.combat then return false,'Akcja walki już trwa.' end
  local target
  if self.settings.selected~='' then target=self.p:selected(self.settings.selected) else for _,person in ipairs(self.p:people()) do if person.role=='Murderer' then target=person;break end end end
  if not target then return false,'Nie wykryto Murderera. Możesz wpisać dokładny nick celu.' end
  local ok,err=self.runtime:acquire('MM2Combat');if not ok then return false,err end
  ok,err=self.p:beginFling(target,self.clock());if not ok then self.runtime:release('MM2Combat');return false,err end
  self.combat={kind='FLING',started=self.clock()};return true
 end
 function C:stopCombat()
  local action=self.combat;self.combat=nil;self.p:endFling()
  if action and action.kind=='KILL_ALL' then local _,_,root=self.p:character();if root==action.root then self.p:teleport(action.origin) end end
  self.runtime:release('MM2Combat');return true
 end
 function C:combatTick(now)
  local action=self.combat;if not action then return end
  if action.kind=='FLING' then if not self.p:tickFling(now) then self:stopCombat() end;return end
  if now-action.started>25 or self.p:role(self.p.player)~='Murderer' then self:stopCombat();return end
  if now<action.nextAt then return end
  local target=action.targets[action.index];if not target then self:stopCombat();return end
  if not target.root.Parent or target.humanoid.Health<=0 then action.index+=1;return end
  local ok,err=self.p:teleport(target.root.CFrame*CFrame.new(0,0,1.8));if not ok then self.lastError=err;self:stopCombat();return end
  ok,err=self.p:activate('Knife');if ok then self.stabs+=1 else self.lastError=err end
  action.index+=1;action.nextAt=now+.45
 end
 function C:tick(dt)
  local now=self.clock();self:farmTick(now);self:combatTick(now)
  if self.p.allowed and not self.farming and not self.combat then
   if self.autoGun and not self.runtime.lock and now>=self.nextGunAt and not self.p:tool('Gun') and not self.p:tool('Knife') then self.nextGunAt=now+1.25;self.p:pickupGun() end
   if self.aura and now-self.lastKnife>=.45 and self.p:tool('Knife') then
    local _,_,root=self.p:character();if root then for _,person in ipairs(self.p:people()) do if (root.Position-person.root.Position).Magnitude<=6 then self.lastKnife=now;local ok,err=self.p:activate('Knife');if ok then self.stabs+=1 else self.lastError=err end;break end end end
   end
  end
 end
 function C:aimTick(dt)
  local now=self.clock()
  if self.p.allowed and (self.aimbot or self.autoShot) and not self.combat then
   local target=self.p:target(self.settings)
   if target then self.p:aim(target,self.settings,dt)
    if self.autoShot and now-self.lastShot>=self.settings.shotInterval and self.p:tool('Gun') then self.lastShot=now;local ok,err=self.p:activate('Gun');if ok then self.shots+=1 else self.lastError=err end end
   end
  end
 end
 function C:stopAll()self:stopFarm();self:stopCombat();self.aimbot=false;self.autoShot=false;self.autoGun=false;self.aura=false;self.esp=false;self.p:close()end
 return C
end
