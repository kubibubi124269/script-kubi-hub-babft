return function(Util,Tempo)
 local C={};C.__index=C
 function C.new(runtime,platform,clock)
  return setmetatable({runtime=runtime,p=platform,clock=clock,farming=false,paused=false,state='STOPPED',kind='BOTH',farmMotion='Lot',farmRange=32,nextAt=0,coins={},cooldown=setmetatable({},{__mode='k'}),scannedAt=-math.huge,attempts=0,disappeared=0,aimbot=false,autoShot=false,autoGun=false,aura=false,esp=false,lastShot=-math.huge,lastKnife=-math.huge,nextGunAt=0,lastError='',shots=0,stabs=0,pickupTimeout=.8,lastScanCount=0,settings={target='MURDERER',selected='',fov=200,prediction=.08,smooth=35,wallCheck=true,shotInterval=.7}},C)
 end
 local function horizontal(delta)return Vector3.new(delta.X,0,delta.Z)end
 function C:stopFarmMotion()
  local h=self.walkHumanoid;self.walkHumanoid=nil
  if h and h.Parent and h.Health>0 then pcall(function()h:Move(Vector3.zero,false)end)end
  if self.p.endPickupFlight then self.p:endPickupFlight()end
 end
 function C:clearFarmTarget()
  self.current=nil;self.farmCharacter=nil;self.arrivedAt=nil;self:stopFarmMotion()
 end
 function C:refreshFarm()
  self:clearFarmTarget();self.coins={};self.scannedAt=-math.huge;self.nextAt=0
 end
 function C:startFarm()
  if not self.p.allowed then return false,'Najpierw dołącz do Murder Mystery 2.' end
  if self.farming then return false,'Autofarma już działa.' end
  local ok,err=self.runtime:acquire('MM2Farm');if not ok then return false,err end
  self:refreshFarm();self.farming=true;self.paused=false;self.manual=false;self.state='SEARCHING';self.lastError='';return true
 end
 function C:stopFarm()
  self.farming=false;self.paused=false;self.manual=false;self.state='STOPPED';self:clearFarmTarget();self.coins={};self.lastScanCount=0;self.runtime:release('MM2Farm');return true
 end
 function C:pauseFarm()if not self.farming then return false,'Najpierw uruchom autofarmę.' end;self:refreshFarm();self.paused=not self.paused;self.state=self.paused and 'PAUSED' or 'SEARCHING';return true end
 function C:setFilter(kind)
  if kind~='BOTH' and kind~='COIN' and kind~='CANDY' then return false,'Nieznany filtr.' end
  self.kind=kind;self:refreshFarm();return true
 end
 function C:setFarmMotion(mode)
  if mode~='Lot' and mode~='Chód' then return false,'Nieznany tryb ruchu.' end
  self.farmMotion=mode;self:refreshFarm();return true
 end
 function C:setTempo(mode)
  if not Tempo.mm2[mode] then return false,'Nieznany profil.' end
  self.farmTempo=mode;return true
 end
 function C:arrival(delta)
  return horizontal(delta).Magnitude<=.65 and (self.farmMotion=='Chód' or math.abs(delta.Y)<=2.75)
 end
 function C:farmDistance(delta)
  return self.farmMotion=='Lot' and delta.Magnitude or horizontal(delta).Magnitude
 end
 function C:farmReachable(delta)
  return horizontal(delta).Magnitude<=self.farmRange and math.abs(delta.Y)<=(self.farmMotion=='Lot' and 10 or 5)
 end
 function C:resetStats()if self.farming or self.combat then return false,'Najpierw zatrzymaj aktywne moduły.' end;self.attempts=0;self.disappeared=0;self.shots=0;self.stabs=0;self.lastError='';return true end
 function C:farmTick(now)
  if not self.farming or self.paused or now<self.nextAt then return end
  if self.manual then self:clearFarmTarget();self.state='MANUAL';return end
  local model,h,root=self.p:character()
  if not root or h.Sit or h.PlatformStand or h.WalkSpeed<=0 then self:clearFarmTarget();self.state='WAIT_CHARACTER';self.nextAt=now+.25;return end
  if self.p:bagFull() then self:clearFarmTarget();self.state='BAG_FULL';self.nextAt=now+.5;return end
  if self.current then
   local coin=self.current
   if self.farmCharacter~=model then self:clearFarmTarget()
   elseif not self.p:present(coin) then self.disappeared+=1;self:clearFarmTarget()
   else
    local delta=coin.part.Position-root.Position;local distance=self:farmDistance(delta)
    if self:farmReachable(delta) and now-self.approachStarted<8 then
     if self:arrival(delta) then
      self:stopFarmMotion();self.arrivedAt=self.arrivedAt or now
      if now-self.arrivedAt<self.pickupTimeout then self.state='PICKUP';return end
     else
      self.arrivedAt=nil
      if distance<self.bestDistance-.25 then self.bestDistance=distance;self.lastProgress=now end
      if now-self.lastProgress<2 then self.state='APPROACH';return end
     end
    end
    self.cooldown[coin.object]=now+5;self:clearFarmTarget()
   end
  end
  if now-self.scannedAt>=(Tempo.mm2[self.farmTempo] or Tempo.mm2.NORMAL).scan then self.coins=self.p:coins(self.kind);self.scannedAt=now;self.lastScanCount=#self.coins end
  local best,distance=nil,math.huge
  for _,coin in ipairs(self.coins) do
   if self.p:present(coin) and (self.cooldown[coin.object] or 0)<=now then
    local delta=coin.part.Position-root.Position;local d=self:farmDistance(delta)
    if self:farmReachable(delta) and d<distance then best=coin;distance=d end
   end
  end
  if not best then self.state='WAIT_ITEMS';self.nextAt=now+.25;return end
  self.current=best;self.farmCharacter=model;self.approachStarted=now;self.lastProgress=now;self.bestDistance=distance;self.takeoffY=root.Position.Y
  self.attempts+=1;self.state='APPROACH'
 end
 function C:farmMotionTick(manual)
  if not self.farming or self.paused then return end
  self.manual=manual
  if manual then self.walkHumanoid=nil;self:stopFarmMotion();return end
  local coin=self.current
  if not coin or self.state~='APPROACH' then return end
  local model,h,root=self.p:character()
  if not root or model~=self.farmCharacter or h.Sit or h.PlatformStand or h.WalkSpeed<=0 or not self.p:present(coin) then self:stopFarmMotion();return end
  local delta=coin.part.Position-root.Position;local flat=horizontal(delta);local distance=flat.Magnitude
  if not self:farmReachable(delta) or self:arrival(delta) then self:stopFarmMotion();return end
  local pace=Tempo.mm2[self.farmTempo] or Tempo.mm2.NORMAL
  if self.farmMotion=='Lot' then
   local targetY=coin.part.Position.Y+(distance>5 and 2.5 or .6)
   if distance>5 then targetY=math.max(targetY,self.takeoffY+1.75)end
   local drift=distance>.15 and flat.Unit*math.min(pace.flight,distance*3) or Vector3.zero
   self.p:pickupFlight(root,drift+Vector3.new(0,math.clamp((targetY-root.Position.Y)*4,-pace.vertical,pace.vertical),0))
   return
  end
  self.walkHumanoid=h
  h:Move(flat.Unit*math.clamp(distance/3,.25,pace.walk),false)
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
  self.flingSettings=self.flingSettings or {target='NEAREST',selected='',duration=1.5}
  local settings=self.flingSettings;local target;local _,_,root=self.p:character();if not root then return false,'Poczekaj na aktywną postać.'end
  if settings.target=='SELECTED' then target=self.p:selected(settings.selected)
  else local distance=math.huge;for _,person in ipairs(self.p:people())do if settings.target=='NEAREST' or settings.target=='MURDERER' and person.role=='Murderer' then local d=(root.Position-person.root.Position).Magnitude;if d<distance then target=person;distance=d end end end end
  if not target then return false,'Brak aktywnego celu Fling. Wybierz tryb lub dokładny nick pod PPM.' end
  local ok,err=self.runtime:acquire('MM2Combat');if not ok then return false,err end
  ok,err=self.p:beginFling(target,self.clock(),settings);if not ok then self.runtime:release('MM2Combat');return false,err end
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
  if self.p.spectating then return end
  local now=self.clock()
  if self.p.allowed and (self.aimbot or self.autoShot) and not self.combat then
   local target=self.p:target(self.settings)
   if target then self.p:aim(target,self.settings,dt)
    if self.autoShot and now-self.lastShot>=self.settings.shotInterval and self.p:tool('Gun') then self.lastShot=now;local ok,err=self.p:activate('Gun');if ok then self.shots+=1 else self.lastError=err end end
   end
  end
 end
 function C:stopAll()self:stopFarm();self:stopCombat();if self.avatar then self.avatar:reset()end;if self.itemESP then self.itemESP.coins=false;self.itemESP.gun=false end;self.aimbot=false;self.autoShot=false;self.autoGun=false;self.aura=false;self.esp=false;self.p:close()end
 return C
end
