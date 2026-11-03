 local Route={};Route.__index=Route
 function Route.new(player,world,wait,clock,alive)
  return setmetatable({player=player,world=world,wait=wait,clock=clock,alive=alive},Route)
 end
 function Route:stages()
  local folder=self.world:FindFirstChild('BoatStages');return folder and folder:FindFirstChild('NormalStages')
 end
 function Route:target(stage)
  local stages=self:stages();if not stages then return nil,'Brak trasy BoatStages / NormalStages.' end
  local target
  if stage<=10 then local cave=stages:FindFirstChild('CaveStage'..stage);target=cave and cave:FindFirstChild('DarknessPart')
  else local ending=stages:FindFirstChild('TheEnd');local chest=ending and ending:FindFirstChild('GoldenChest');target=chest and chest:FindFirstChild('Trigger') end
  if not target or not target:IsA('BasePart') then return nil,stage<=10 and ('Brak punktu CaveStage'..stage..' / DarknessPart.') or 'Brak końcowej skrzyni / Trigger.' end
  return target
 end
 function Route:inspect()
  for stage=1,11 do local target,err=self:target(stage);if not target then return false,err end end
  return true,'Autofarma BABFT: przywrócona trasa 10 etapów i skrzynia. Licznik potwierdza powrót postaci, nie przyznanie złota.'
 end
 function Route:character()
  local c=self.player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local r=c and c:FindFirstChild('HumanoidRootPart')
  if not h or not r or h.Health<=0 then return nil,nil,'Poczekaj na aktywną postać.' end;return c,r
 end
 function Route:stop()
  self.expectedCharacter=nil
  if self.floor then self.floor:Destroy();self.floor=nil end
  local origin=self.origin;self.origin=nil
  if origin and self.player.Character==origin.character and origin.root.Parent then local h=origin.character:FindFirstChildOfClass('Humanoid');if h and h.Health>0 then origin.root.AssemblyLinearVelocity=Vector3.zero;origin.root.AssemblyAngularVelocity=Vector3.zero;origin.root.CFrame=origin.cf end end
 end
 function Route:expectingRespawn()return self.expectedCharacter~=nil end
 function Route:step(stage,cancelled,paused)
  if type(stage)~='number' or stage%1~=0 or stage<1 or stage>11 then return {ok=false,error='Nieprawidłowy etap trasy.'} end
  if cancelled() then return {ok=false,error='Zatrzymano trasę.'} end
  local target,err=self:target(stage);if not target then self:stop();return {ok=false,error=err} end
  local character,root,characterError=self:character();if not root then self:stop();return {ok=false,error=characterError} end
  if stage<=10 then
   if stage==1 and not self.origin then self.origin={character=character,root=root,cf=root.CFrame} end
   if not self.floor then self.floor=Instance.new('Part');self.floor.Name='KubiHubFarmSupport';self.floor.Anchored=true;self.floor.CanCollide=true;self.floor.CanTouch=false;self.floor.CanQuery=false;self.floor.Transparency=1;self.floor.Size=Vector3.new(6,1,6);self.floor.Parent=self.world end
   self.floor.CFrame=target.CFrame*CFrame.new(0,-4,0)
   root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;root.CFrame=target.CFrame
   return {ok=true,stage=stage,completed=false,confirmation='local-route-position'}
  end
  self.expectedCharacter=character
  local elapsed=0;local last=self.clock();local nextTeleport=0;local wasPaused=paused and paused() or false
  while elapsed<35 and self.alive() and not cancelled() do
   local current=self.player.Character
   if current and current~=character then
    local h=current:FindFirstChildOfClass('Humanoid');local r=current:FindFirstChild('HumanoidRootPart')
    if h and r and h.Health>0 then self:stop();return {ok=true,stage=11,completed=true,confirmation='observed-respawn'} end
   end
   local now=self.clock();local isPaused=paused and paused() or false
   if not isPaused then
    if not wasPaused then elapsed+=math.max(0,now-last) end
    if elapsed<10 and elapsed>=nextTeleport and current==character then
     local r=character:FindFirstChild('HumanoidRootPart');local h=character:FindFirstChildOfClass('Humanoid')
     if r and h and h.Health>0 then r.AssemblyLinearVelocity=Vector3.zero;r.CFrame=target.CFrame end;nextTeleport=elapsed+1
    end
   end
   last=now;wasPaused=isPaused;self.wait(.05)
  end
  self:stop();return {ok=false,error=cancelled() and 'Zatrzymano oczekiwanie przy skrzyni.' or 'Brak powrotu postaci po skrzyni w 35 s. Zatrzymaj i sprawdź trasę; nagrody nie zostały potwierdzone.'}
 end
 return Route
