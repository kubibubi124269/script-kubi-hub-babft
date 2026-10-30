return function(Util,Schema,Inventory)
 local E={};E.__index=E
 function E.new(player,world,wait,clock,alive)
  return setmetatable({player=player,world=world,wait=wait,clock=clock,alive=alive,used=setmetatable({},{__mode='k'})},E)
 end
 function E:findTool(name)
  local aliases=({BuildingTool={'BuildingTool','BuildTool'},ScalingTool={'ScalingTool','ScaleTool'},PaintingTool={'PaintingTool','PaintTool'}})[name] or {name}
  local backpack=self.player:FindFirstChildOfClass('Backpack');local ch=self.player.Character
  for _,alias in ipairs(aliases) do local t=ch and ch:FindFirstChild(alias) or backpack and backpack:FindFirstChild(alias);if t and t:IsA('Tool') then return t end end
 end
 function E:remote(tool)
  if not tool then return end
  for _,r in ipairs(tool:GetDescendants()) do if r.Name=='RF' and r:IsA('RemoteFunction') then return r end end
 end
 function E:equip(name)
  local t=self:findTool(name);local h=self.player.Character and self.player.Character:FindFirstChildOfClass('Humanoid')
  if not t or not h or h.Health<=0 then return nil,'Brak narzędzia '..name..' lub aktywnej postaci.' end
  if t.Parent~=self.player.Character then h:EquipTool(t);self.wait(.1) end
  local r=self:remote(t);if not r then return nil,'Brak RF w '..name end;return r
 end
 function E:plot()
  for _,o in ipairs(self.world:GetChildren()) do local c=o:FindFirstChild('TeamColor');if o:IsA('BasePart') and c and c.Value==self.player.TeamColor then return o end end
 end
 function E:ownFolder()
  local blocks=self.world:FindFirstChild('Blocks');return blocks and blocks:FindFirstChild(self.player.Name)
 end
 function E:stillOwned(object)local folder=self:ownFolder();return object and folder and object:IsDescendantOf(folder) or false end
 function E:part(object)
  if object:IsA('BasePart') then return object end
  return object:FindFirstChild('PPart') or object:FindFirstChildWhichIsA('BasePart',true)
 end
 function E:inventory()return Inventory.readPlayer(self.player) end
 function E:inspect()
  local zone=self:plot();local build=self:remote(self:findTool('BuildingTool'))~=nil
  local stages=self.world:FindFirstChild('BoatStages');stages=stages and stages:FindFirstChild('NormalStages')
  local lines={'Tryb: BABFT','Działka drużyny: '..(zone and zone.Name or 'BRAK'),'BuildingTool.RF: '..(build and 'wykryto' or 'BRAK'),'ScalingTool.RF: '..(self:remote(self:findTool('ScalingTool')) and 'wykryto' or 'BRAK'),'PaintingTool.RF: '..(self:remote(self:findTool('PaintingTool')) and 'wykryto' or 'BRAK'),'Etapy trasy: '..(stages and 'wykryto' or 'BRAK'),'Mechanika WORM: nieobsługiwana przez ten tryb'}
  return {build=build and zone~=nil,farm=false,zone=zone and {size={zone.Size.X,200,zone.Size.Z},min={-zone.Size.X/2+1,-6,-zone.Size.Z/2+1},max={zone.Size.X/2-1,200,zone.Size.Z/2-1}},text=table.concat(lines,'\n')}
 end
 function E:preflight(schema,yaw)
  local info=self:inspect();if not info.build then return false,info.text..'\nDołącz do drużyny i sprawdź, czy masz narzędzie budowania.' end
  local bounds=Schema.bounds(schema,yaw);for i=1,3 do if bounds.min[i]<info.zone.min[i] or bounds.max[i]>info.zone.max[i] then return false,'Plan wychodzi poza działkę. Użyj Dopasuj do obszaru.' end end
  local comparison=Inventory.compare(schema,Inventory.snapshot(self:inventory(),'BABFT / dane gracza'));if not comparison.enough then return false,Inventory.describe(comparison) end
  for _,e in ipairs(schema.elements) do
   if e.class=='WedgePart' then return false,'Ten plan wymaga nieobsługiwanego kształtu klina.' end
   if Inventory.definitions[e.material].volume and (math.abs(e.size[1]-2)>.001 or math.abs(e.size[2]-2)>.001 or math.abs(e.size[3]-2)>.001) then if not self:remote(self:findTool('ScalingTool')) then return false,'Plan wymaga narzędzia ScalingTool.' end end
   if e.color and not self:remote(self:findTool('PaintingTool')) then return false,'Plan ma kolory i wymaga narzędzia PaintingTool.' end
  end
  return true
 end
 function E:place(e,yaw,invoke,cancelled)
  if cancelled() then return {ok=false,error='Zatrzymano przed wysłaniem bloku.'} end
  local zone=self:plot();if not zone then return {ok=false,error='Działka zniknęła.'} end
  local have=self:inventory()[e.material];if not have or have<Inventory.cost(e) then return {ok=false,error='Brak materiału '..e.material} end
  local remote,err=self:equip('BuildingTool');if not remote then return {ok=false,error=err} end
  if cancelled() then return {ok=false,error='Zatrzymano przed wysłaniem bloku.'} end
  local cf=zone.CFrame*CFrame.new(0,zone.Size.Y/2+1,0)*CFrame.Angles(0,math.rad(yaw or 0),0)*CFrame.new(table.unpack(e.position))*CFrame.Angles(math.rad(e.rotation[1]),math.rad(e.rotation[2]),math.rad(e.rotation[3]))
  local before={};local folder=self:ownFolder();if folder then for _,o in ipairs(folder:GetChildren()) do before[o]=true end end
  local reply=invoke(remote,{e.material,have,zone,zone.CFrame:ToObjectSpace(cf),true,cf,false});if not reply.ok then return reply end
  local deadline=self.clock()+4;local object
  repeat
   folder=self:ownFolder()
   if folder then for _,o in ipairs(folder:GetChildren()) do if not before[o] and not self.used[o] and o.Name==e.material then local p=self:part(o);if p and (p.Position-cf.Position).Magnitude<.5 then object=o;break end end end end
   if object then break end;self.wait(.04)
  until self.clock()>=deadline or not self.alive()
  if not object then return {ok=false,error='Nie potwierdzono nowego bloku w Twojej budowli. Kolejka zatrzymana; nie ponawiam żądania.'} end
  self.used[object]=true
  if cancelled() then return {ok=true,object=object} end
  if Inventory.definitions[e.material].volume and (math.abs(e.size[1]-2)>.001 or math.abs(e.size[2]-2)>.001 or math.abs(e.size[3]-2)>.001) then
   remote,err=self:equip('ScalingTool');if not remote then return {ok=false,error=err} end
   if cancelled() then return {ok=true,object=object} end
   reply=invoke(remote,{object,Vector3.new(table.unpack(e.size)),cf});if not reply.ok then return reply end
  end
  if e.color then
   remote,err=self:equip('PaintingTool');if not remote then return {ok=false,error=err} end
   if cancelled() then return {ok=true,object=object} end
   reply=invoke(remote,{{{object,Color3.new(table.unpack(e.color))}}});if not reply.ok then return reply end
  end
  deadline=self.clock()+3
  repeat
   if not self:stillOwned(object) then return {ok=false,error='Postawiony blok zniknął.'} end
   local p=self:part(object);local size=p and p.Size;local color=p and p.Color
   local sizeOK=not Inventory.definitions[e.material].volume or size and math.abs(size.X-e.size[1])<.05 and math.abs(size.Y-e.size[2])<.05 and math.abs(size.Z-e.size[3])<.05
   local colorOK=not e.color or color and math.abs(color.R-e.color[1])<.04 and math.abs(color.G-e.color[2])<.04 and math.abs(color.B-e.color[3])<.04
   local _,angle;if p then _,angle=p.CFrame:ToObjectSpace(cf):ToAxisAngle() end
   if sizeOK and colorOK and angle and math.abs(angle)<math.rad(3) and (p.Position-cf.Position).Magnitude<.2 then return {ok=true,object=object} end
   self.wait(.04)
  until self.clock()>=deadline or not self.alive()
  return {ok=false,error='Blok powstał, ale nie potwierdzono wymiarów, koloru lub pozycji. Pozostaje na działce; kolejka zatrzymana.'}
 end
 return E
end
