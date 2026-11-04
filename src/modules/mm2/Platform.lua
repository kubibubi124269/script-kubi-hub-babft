return function(Util)
 local P={};P.__index=P
 function P.new(player,players,world,placeId,gameId)
  return setmetatable({player=player,players=players,world=world,allowed=placeId==142823291 or gameId==66654135,highlights={}},P)
 end
 function P:character(player)
  local c=(player or self.player).Character;local h=c and c:FindFirstChildOfClass('Humanoid');local r=c and c:FindFirstChild('HumanoidRootPart')
  if not h or not r or h.Health<=0 then return end;return c,h,r
 end
 function P:tool(name,player)
  player=player or self.player;local c=player.Character;local b=player:FindFirstChildOfClass('Backpack')
  local t=c and c:FindFirstChild(name) or b and b:FindFirstChild(name);return t and t:IsA('Tool') and t or nil
 end
 function P:role(player)
  if self:tool('Knife',player) then return 'Murderer' elseif self:tool('Gun',player) then return 'Sheriff' end;return 'Nieznana / bez broni'
 end
 function P:people()
  local out={};for _,player in ipairs(self.players:GetPlayers()) do
   local c,h,r=self:character(player)
   if player~=self.player and c and player:GetAttribute('InGame')~=false and player:GetAttribute('Alive')~=false then out[#out+1]={player=player,character=c,humanoid=h,root=r,role=self:role(player)} end
  end;return out
 end
 function P:selected(name)
  for _,p in ipairs(self:people()) do if p.player.Name:lower()==tostring(name):lower() then return p end end
 end
 function P:visible(person,position)
  local camera=self.world.CurrentCamera;if not camera then return false end
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={self.player.Character};params.IgnoreWater=true
  local hit=self.world:Raycast(camera.CFrame.Position,position-camera.CFrame.Position,params)
  return not hit or hit.Instance:IsDescendantOf(person.character)
 end
 function P:target(settings)
  local camera=self.world.CurrentCamera;if not self.allowed or not camera then return end
  local center=camera.ViewportSize/2;local best,bestDistance=nil,settings.fov
  for _,p in ipairs(self:people()) do
   local matches=settings.target=='NEAREST' or settings.target=='MURDERER' and p.role=='Murderer' or settings.target=='SELECTED' and p.player.Name:lower()==settings.selected:lower()
   local part=p.character:FindFirstChild('Head') or p.root
   local point,onScreen=camera:WorldToViewportPoint(part.Position)
   local distance=math.sqrt((point.X-center.X)^2+(point.Y-center.Y)^2)
   if matches and onScreen and point.Z>0 and distance<=bestDistance and (not settings.wallCheck or self:visible(p,part.Position)) then best=p;best.part=part;bestDistance=distance end
  end;return best
 end
 function P:aim(person,settings,dt)
  local camera=self.world.CurrentCamera;if not self.allowed or not camera or not person or not person.part.Parent then return false end
  local velocity=person.root.AssemblyLinearVelocity;local prediction=Util.number(settings.prediction,.08,0,.3)
  local position=person.part.Position+velocity*prediction
  local goal=CFrame.lookAt(camera.CFrame.Position,position);camera.CFrame=camera.CFrame:Lerp(goal,math.clamp(1-math.exp(-settings.smooth*math.min(dt or .016,.1)),0,1));return true
 end
 function P:equip(name)
  if not self.allowed then return nil,'Ten moduł działa w Murder Mystery 2.' end
  local c,h=self:character();if not c then return nil,'Poczekaj na aktywną postać.' end
  local t=self:tool(name);if not t then return nil,'Brak własnej broni '..name..' w tej rundzie.' end
  if t.Parent~=c then h:EquipTool(t) end
  if t.Enabled==false then return nil,'Broń jest w trakcie odnowienia.' end;return t
 end
 function P:activate(name)
  local tool,err=self:equip(name);if not tool then return false,err end
  local ok,err=pcall(function()tool:Activate()end);if not ok then return false,tostring(err) end;return true
 end
 function P:teleport(cf)
  if not self.allowed then return false,'Ten moduł działa w Murder Mystery 2.' end
  local _,_,root=self:character();if not root then return false,'Poczekaj na aktywną postać.' end
  local character,h=self:character();h.Sit=false;root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;character:PivotTo(cf*root.CFrame:ToObjectSpace(character:GetPivot()));return true
 end
 function P:part(object)
  if object:IsA('BasePart') then return object end
  if object:IsA('Model') then return object.PrimaryPart or object:FindFirstChildWhichIsA('BasePart',true) end
 end
 function P:coinKind(object)
  local raw=object:GetAttribute('CoinType') or object:GetAttribute('CurrencyType') or object:GetAttribute('Currency')
  local value=object:FindFirstChild('CoinType');if not raw and value and value:IsA('StringValue') then raw=value.Value end
  local text=tostring(raw or object.Name):lower()
  if text:find('candy',1,true) or text:find('halloween',1,true) then return 'CANDY' end
  if raw and (text:find('coin',1,true) or text=='gold') then return 'COIN' end
  return 'UNKNOWN'
 end
 function P:coins(kind)
  if not self.allowed then return {} end
  local containers={};local seen={}
  local function add(c)if c and not seen[c] then containers[#containers+1]=c;seen[c]=true end end
  add(self.world:FindFirstChild('CoinContainer'))
  for _,map in ipairs(self.world:GetChildren()) do
   add(map:FindFirstChild('CoinContainer'))
   if map.Name=='Maps' or map.Name=='CurrentMap' or map.Name=='Map' then for _,child in ipairs(map:GetChildren()) do add(child:FindFirstChild('CoinContainer')) end end
  end
  local out={}
  for _,container in ipairs(containers) do for _,object in ipairs(container:GetChildren()) do
   if #out>=1000 then break end
   local p=self:part(object);local touch=object:FindFirstChildWhichIsA('TouchTransmitter',true);local currency=self:coinKind(object)
   local visual=object:FindFirstChild('CoinVisual',true)
   local candidate={object=object,part=p,touch=touch,visual=visual,kind=currency}
   if p and touch and self:present(candidate) and (kind=='BOTH' or currency=='UNKNOWN' or currency==kind) then out[#out+1]=candidate end
  end end;return out
 end
 function P:present(coin)
  if not coin.object.Parent or not coin.part or not coin.part.Parent or not coin.touch or not coin.touch.Parent then return false end
  if coin.object:GetAttribute('Collected')==true then return false end
  if coin.visual then
   if not coin.visual.Parent or not coin.visual:IsDescendantOf(coin.object) or coin.visual:GetAttribute('Collected')==true then return false end
   local part=self:part(coin.visual);return part~=nil and part.Transparency<1
  end
  return coin.part.Transparency<1
 end
 function P:bagFull()
  local gui=self.player:FindFirstChildOfClass('PlayerGui');local main=gui and gui:FindFirstChild('MainGUI');local screen=main and main:FindFirstChild('Game');local bags=screen and screen:FindFirstChild('CoinBags')
  if bags then for _,o in ipairs(bags:GetDescendants()) do if o.Name=='FullBagIcon' and o:IsA('GuiObject') and o.Visible then
   local visible=true;local at=o.Parent;while at and at~=gui do if at:IsA('GuiObject') and not at.Visible or at:IsA('ScreenGui') and at.Enabled==false then visible=false;break end;at=at.Parent end
   if visible then return true end
  end end end;return false
 end
 function P:pickupGun()
  local drop=self.world:FindFirstChild('GunDrop');local p=drop and self:part(drop);if not p then return false,'Brak upuszczonego pistoletu na mapie.' end
  return self:teleport(CFrame.new(p.Position+Vector3.new(0,1,0)))
 end
 function P:updateESP(enabled)
  local keep={}
  if self.allowed and enabled then for _,p in ipairs(self:people()) do
   local key=p.player.UserId;local row=self.highlights[key]
   if not row or row.Adornee~=p.character then if row then row:Destroy() end;row=Instance.new('Highlight');row.Name='KubiHubRoleESP';row.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;row.FillTransparency=.65;row.OutlineTransparency=0;row.Adornee=p.character;row.Parent=p.character;self.highlights[key]=row end
   row.FillColor=p.role=='Murderer' and Color3.fromRGB(255,65,85) or p.role=='Sheriff' and Color3.fromRGB(60,140,255) or Color3.fromRGB(240,190,65);row.OutlineColor=row.FillColor;keep[key]=true
  end end
  for key,row in pairs(self.highlights) do if not keep[key] then row:Destroy();self.highlights[key]=nil end end
 end
 function P:beginFling(person,now)
  if not self.allowed or not person then return false,'Brak celu.' end
  local c,h,r=self:character();if not r then return false,'Brak aktywnej postaci.' end
  self.fling={character=c,humanoid=h,root=r,target=person.root,started=now,cf=r.CFrame,velocity=r.AssemblyLinearVelocity,angular=r.AssemblyAngularVelocity,rotate=h.AutoRotate};h.AutoRotate=false;return true
 end
 function P:tickFling(now)
  local f=self.fling;if not f then return false end
  local c,h,r=self:character();if c~=f.character or not f.target.Parent or now-f.started>=1.5 then self:endFling();return false end
  r.CFrame=f.target.CFrame*CFrame.new(math.sin(now*35)*1.5,0,math.cos(now*35)*1.5);r.AssemblyAngularVelocity=Vector3.new(0,1800,0);r.AssemblyLinearVelocity=Vector3.new(0,15,0);return true
 end
 function P:endFling()
  local f=self.fling;self.fling=nil;if not f then return end
  if f.root.Parent then f.root.AssemblyAngularVelocity=f.angular;f.root.AssemblyLinearVelocity=f.velocity;if self.player.Character==f.character then f.root.CFrame=f.cf end end
  if f.humanoid.Parent then f.humanoid.AutoRotate=f.rotate end
 end
 function P:watch(name)
  if not self.allowed then return false,'Podgląd gracza działa w MM2.' end
  local person=self:selected(name);local camera=self.world.CurrentCamera
  if not person or not camera then return false,'Wybierz aktywnego gracza w ustawieniach tej funkcji.' end
  if not self.spectating then self.savedCamera={camera=camera,subject=camera.CameraSubject} end
  self.spectating=person;camera.CameraSubject=person.humanoid;return true
 end
 function P:stopWatch()
  local saved=self.savedCamera;self.savedCamera=nil;self.spectating=nil
  if saved then local _,h=self:character();saved.camera.CameraSubject=saved.subject and saved.subject.Parent and saved.subject or h end
 end
 function P:updateWatch()
  local p=self.spectating;if p and (not p.root.Parent or p.humanoid.Health<=0 or p.player.Character~=p.character) then self:stopWatch()end
 end
 function P:nearestMurderer()
  local _,_,root=self:character();if not root then return end
  local nearest,distance=nil,math.huge
  for _,p in ipairs(self:people()) do if p.role=='Murderer' then local d=(root.Position-p.root.Position).Magnitude;if d<distance then nearest=p;distance=d end end end
  return nearest,distance
 end
 function P:close()self:stopWatch();self:endFling();self:updateESP(false)end
 return P
end
