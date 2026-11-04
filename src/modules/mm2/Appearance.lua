return function(Util)
 local A={};A.__index=A
 function A.new(platform,runtime)
  return setmetatable({p=platform,runtime=runtime,enabled={headless=false,korblox=false,mini=false,hitbox=false,noAccessories=false,noFace=false,ghost=false,lamp=false},settings={scale=.6,rootFactor=.6,hideHats=false,lampRange=24,lampBrightness=2},hidden={},headOpacity={}},A)
 end
 function A:bind(runService)
  if self.bound then return end;self.bound=true
  local name='KubiHubAvatarVisibility'
  runService:BindToRenderStep(name,Enum.RenderPriority.Last.Value+1,function()
   if not self.runtime.alive then return end
   local ok,err=pcall(function()self:render()end);if not ok then self:reset();self.runtime.errors('Postać',err)end
  end)
  self.runtime:own({Destroy=function()runService:UnbindFromRenderStep(name)end})
 end
 function A:restoreHead()
  for object,row in pairs(self.headOpacity)do
   self.runtime:disconnect(row.connection)
   if object.Parent then pcall(function()object.Transparency=row.value end)end
  end;self.headOpacity={}
 end
 function A:restoreVisuals()
  self:restoreHead()
  for object,row in pairs(self.hidden) do if object.Parent then pcall(function()object[row.field]=row.value end)end end;self.hidden={}
 end
 function A:hideHead(object)
  self:hide(object)
  if not object:IsA('BasePart') then return end
  if not self.headOpacity[object] then
   local row={value=object.Transparency};self.headOpacity[object]=row
   row.connection=self.runtime:connect(object:GetPropertyChangedSignal('Transparency'),function()
    if self.enabled.headless and self.headOpacity[object]==row and object.Parent and object.Transparency~=1 then object.Transparency=1 end
   end,'Headless')
  end
  object.Transparency=1
 end
 function A:hide(object)
  local field=object:IsA('BasePart') and 'LocalTransparencyModifier' or (object:IsA('Decal') or object:IsA('Texture')) and 'Transparency'
  if not field then return end
  if not self.hidden[object] then self.hidden[object]={field=field,value=object[field]} end
  object[field]=1
 end
 function A:clearLeg()if self.legFolder then self.legFolder:Destroy();self.legFolder=nil;self.legPart=nil end end
 function A:leg(character)
  return character:FindFirstChild('RightUpperLeg') or character:FindFirstChild('Right Leg')
 end
 function A:makeLeg(character,leg)
  self:clearLeg();local folder=Instance.new('Folder');folder.Name='KubiHubFakeKorblox';self.legFolder=folder;self.legPart=leg;folder.Parent=character
  -- Procedural local imitation. No paid asset is downloaded, granted or equipped.
  local function piece(class,name,size,offset,color,material)
   local part=Instance.new(class);part.Name=name;part.Size=size;part.Color=color;part.Material=material;part.Anchored=false;part.Massless=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.CastShadow=false;part.CFrame=leg.CFrame*offset;part.Parent=folder
   local weld=Instance.new('WeldConstraint');weld.Part0=leg;weld.Part1=part;weld.Parent=part
  end
  local s=leg.Size
  piece('WedgePart','KubiHubLegShape',Vector3.new(s.X*.65,s.Y*.85,s.Z*.7),CFrame.new(0,s.Y*.05,0)*CFrame.Angles(0,math.rad(90),math.rad(180)),Color3.fromRGB(28,35,54),Enum.Material.SmoothPlastic)
  piece('Part','KubiHubLegGlow',Vector3.new(s.X*.25,s.Y*.12,s.Z*.3),CFrame.new(0,-s.Y*.35,0),Color3.fromRGB(73,135,246),Enum.Material.Neon)
 end
 function A:visuals(rebuildLeg)
  local b=self.base;if not b then return end
  self:restoreVisuals();local c=b.character;local head=c:FindFirstChild('Head')
  if self.enabled.headless and head then
   self:hideHead(head);for _,object in ipairs(head:GetDescendants())do self:hideHead(object)end
   if self.settings.hideHats then for _,accessory in ipairs(c:GetChildren())do if accessory:IsA('Accessory') then local handle=accessory:FindFirstChild('Handle');local attached=false
    if handle then for _,attachment in ipairs(handle:GetChildren())do if attachment:IsA('Attachment') and ({HatAttachment=true,HairAttachment=true,FaceFrontAttachment=true,FaceCenterAttachment=true})[attachment.Name] then attached=true;break end end end
    if attached then for _,object in ipairs(accessory:GetDescendants())do self:hide(object)end end
   end end end
  end
  if self.enabled.noFace and head then for _,object in ipairs(head:GetDescendants())do if object:IsA('Decal') or object:IsA('Texture') then self:hide(object)end end end
  if self.enabled.noAccessories then for _,accessory in ipairs(c:GetChildren())do if accessory:IsA('Accessory') then for _,object in ipairs(accessory:GetDescendants())do self:hide(object)end end end end
  if self.enabled.korblox then
   local leg=self:leg(c);if not leg then error('Brak prawej nogi R6 / R15.')end
   for _,name in ipairs({'RightUpperLeg','RightLowerLeg','RightFoot','Right Leg'})do local part=c:FindFirstChild(name);if part then self:hide(part);for _,object in ipairs(part:GetDescendants())do self:hide(object)end end end
   if rebuildLeg or not self.legFolder or not self.legFolder.Parent or self.legPart~=leg then self:makeLeg(c,leg)end
  else self:clearLeg()end
  if self.enabled.ghost then for _,object in ipairs(c:GetDescendants())do self:hide(object)end end
  if self.enabled.lamp then
   if not self.lamp or not self.lamp.Parent then self.lamp=Instance.new('PointLight');self.lamp.Name='KubiHubLocalLamp';self.lamp.Parent=b.root end
   self.lamp.Range=self.settings.lampRange;self.lamp.Brightness=self.settings.lampBrightness;self.lamp.Shadows=false
  elseif self.lamp then self.lamp:Destroy();self.lamp=nil end
 end
 function A:apply(resize)
  local b=self.base;local ratio=self.enabled.mini and self.settings.scale or 1;local wanted=b.scale*ratio
  local changed=false
  if resize and (self.enabled.mini or self.enabled.hitbox or self.resized) then
   changed=math.abs(b.character:GetScale()-wanted)>.0001
   if self.enabled.mini then b.humanoid.AutomaticScalingEnabled=false end
   if changed then b.character:ScaleTo(wanted)end
   -- This edits only the local root part. It does not confirm a server hitbox change.
   b.root.Size=b.rootSize*ratio*(self.enabled.hitbox and self.settings.rootFactor or 1)
   b.humanoid.HipHeight=b.hipHeight*ratio
   if not self.enabled.mini then b.humanoid.AutomaticScalingEnabled=b.automatic end
   self.resized=self.enabled.mini or self.enabled.hitbox
  end
  self:visuals(changed)
 end
 function A:set(feature,value)
  if self.enabled[feature]==nil or type(value)~='boolean' then return false,'Nieznany efekt postaci.'end
  if not self.p.allowed then return false,'Efekty tej zakładki działają w MM2.'end
  local c,h,r=self.p:character();if not c then return false,'Poczekaj na aktywną postać.'end
  if self.base and self.base.character~=c then self:reset()end
  if feature=='headless' and value and not c:FindFirstChild('Head') then return false,'Brak głowy w obecnym modelu.'end
  if feature=='korblox' and value and not self:leg(c) then return false,'Model nie ma prawej nogi R6 / R15.'end
  local resize=feature=='mini' or feature=='hitbox';if resize then local ok,err=self.runtime:acquire('Avatar');if not ok then return false,err end end
  local ok,err=pcall(function()
   if not self.base then self.base={character=c,humanoid=h,root=r,scale=c:GetScale(),rootSize=r.Size,hipHeight=h.HipHeight,automatic=h.AutomaticScalingEnabled}
   elseif resize and value and not self.resized then self.base.scale=c:GetScale();self.base.rootSize=r.Size;self.base.hipHeight=h.HipHeight;self.base.automatic=h.AutomaticScalingEnabled end
   self.enabled[feature]=value
   local active=false;for _,enabled in pairs(self.enabled)do if enabled then active=true;break end end
   if active then self:apply(resize)else self:reset()end
  end)
  if resize then self.runtime:release('Avatar')end
  if not ok then self:reset();return false,'Nie udało się zastosować efektu: '..tostring(err)end;return true
 end
 function A:option(key,value)
  local feature
  if key=='scale' then value=Util.number(value,.6,.35,1);feature='mini'
  elseif key=='rootFactor' then value=Util.number(value,.6,.3,1);feature='hitbox'
  elseif key=='hideHats' and type(value)=='boolean' then feature='headless'
  elseif key=='lampRange' then value=Util.number(value,24,8,60);feature='lamp'
  elseif key=='lampBrightness' then value=Util.number(value,2,.5,5);feature='lamp'
  else return false,'Nieznane ustawienie postaci.'end
  local previous=self.settings[key];self.settings[key]=value
  if self.enabled[feature] then local ok,err=self:set(feature,true);if not ok then self.settings[key]=previous;return false,err end end;return true
 end
 function A:refresh()
  if not self.base then return true end
  local c=self.p:character();if c~=self.base.character then self:reset();return true end
  local ok,err=pcall(function()self:visuals(false)end);if not ok then self:reset();return false,tostring(err)end;return true
 end
 function A:render()
  -- Camera scripts may change LocalTransparencyModifier; reapply only hidden visuals.
  for object,row in pairs(self.hidden)do if object.Parent and object[row.field]~=1 then object[row.field]=1 end end
  for object in pairs(self.headOpacity)do if object.Parent and object.Transparency~=1 then object.Transparency=1 end end
 end
 function A:reset()
  self:restoreVisuals();self:clearLeg();local b=self.base;self.base=nil
  if self.lamp then self.lamp:Destroy();self.lamp=nil end
  for feature in pairs(self.enabled)do self.enabled[feature]=false end
  if b and self.resized then
   pcall(function()if math.abs(b.character:GetScale()-b.scale)>.0001 then b.character:ScaleTo(b.scale)end end)
   if b.root.Parent then pcall(function()b.root.Size=b.rootSize end)end
   if b.humanoid.Parent then pcall(function()b.humanoid.HipHeight=b.hipHeight;b.humanoid.AutomaticScalingEnabled=b.automatic end)end
  end
  self.resized=false
  self.runtime:release('Avatar');return true
 end
 A.Destroy=A.reset
 return A
end
