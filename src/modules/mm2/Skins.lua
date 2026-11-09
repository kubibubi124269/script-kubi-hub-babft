return function(M)
 local S={};S.__index=S
 local styles={
  {name='Zorza',main={85,239,195},edge={137,94,250}},
  {name='Rubin',main={223,49,86},edge={255,164,139}},
  {name='Złoty',main={245,189,65},edge={255,241,180}},
  {name='Lód',main={111,204,250},edge={224,250,255}},
  {name='Obsydian',main={70,62,99},edge={199,151,255}},
  {name='Laser',main={235,72,206},edge={156,251,94}},
 }
 local names,styleByName={},{}
 for _,style in ipairs(styles)do names[#names+1]=style.name;styleByName[style.name]=style end
 local models={
  Knife={
   {'Part','Rękojeść',{-1.63,0,0},{1.24,.48,.48},'grip'},
   {'Part','Nasada',{-2.23,0,0},{.18,.55,.55},'edge'},
   {'Part','Jelec',{-.92,0,0},{.16,.92,.55},'edge'},
   {'Part','Ostrze',{.16,0,0},{1.98,.58,.24},'main'},
   {'WedgePart','Czubek',{1.64,0,0},{.24,.58,.98},'main',{0,90,0}},
   {'Part','Grzbiet',{.16,.19,.13},{1.74,.09,.045},'edge'},
  },
  Gun={
   {'Part','Zamek',{.28,.48,0},{3.05,.57,.62},'main'},
   {'Part','Lufa',{1.87,.48,0},{.25,.38,.40},'grip'},
   {'Part','Szkielet',{-.21,.10,0},{2.13,.32,.53},'edge'},
   {'Part','Uchwyt',{-.99,-.54,0},{.66,1.38,.52},'grip',{0,0,-14}},
   {'Part','Kabłąk',{-.03,-.47,0},{1.04,.13,.35},'edge'},
   {'Part','Koniec kabłąka',{.43,-.24,0},{.12,.51,.35},'edge'},
   {'Part','Muszka',{1.35,.84,0},{.16,.13,.20},'edge'},
  },
 }
 local labels={Knife='Nóż',Gun='Pistolet'}
 local kinds={['Nóż']='Knife',['Pistolet']='Gun'}
 local grip=Color3.fromRGB(32,38,52)

 function S:clearTint()
  if self.folder then self.folder:Destroy();self.folder=nil end
  table.clear(self.tint)
 end
 function S:reset()
  self.enabled=false;self:clearTint()
  if self.status then self:updateLabel()end
  self.app.ui:refreshFeatures()
 end
 function S:Destroy()self:clearTint()end

 function S:updateCamera()
  local angle=math.rad(self.angle)
  self.camera.CFrame=CFrame.lookAt(Vector3.new(math.sin(angle)*8,1.9,math.cos(angle)*8),Vector3.new(0,.05,0))
 end
 function S:updatePreview()
  local style=styleByName[self.style]
  local colors={grip=grip,main=Color3.fromRGB(table.unpack(style.main)),edge=Color3.fromRGB(table.unpack(style.edge))}
  if self.previewKind~=self.kind then
   for _,part in ipairs(self.world:GetChildren())do part:Destroy()end
   self.previewParts={}
   for _,spec in ipairs(models[self.kind])do
    local part=Instance.new(spec[1]);part.Name=spec[2];part.Size=Vector3.new(table.unpack(spec[4]))
    part.CFrame=CFrame.new(table.unpack(spec[3]))
    if spec[6] then local x,y,z=table.unpack(spec[6]);part.CFrame=part.CFrame*CFrame.Angles(math.rad(x),math.rad(y),math.rad(z))end
    part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
    part.Material=spec[5]=='grip' and Enum.Material.SmoothPlastic or Enum.Material.Metal
    part.Parent=self.world;self.previewParts[#self.previewParts+1]={part=part,color=spec[5]}
   end
   self.previewKind=self.kind
  end
  for _,row in ipairs(self.previewParts)do row.part.Color=colors[row.color]end
 end
 function S:updateLabel()
  local platform=self.app.platform
  local character=platform:character()
  local tool=platform:tool(self.kind)
  local held=character and tool and tool.Parent==character
  local available=held and 'w dłoni' or tool and 'w plecaku tej rundy' or 'brak w tej rundzie'
  local effect=self.enabled and (next(self.tint) and 'włączona' or 'czeka na widoczną broń w dłoni') or 'wyłączona'
  self.status.Text=labels[self.kind]..': '..available..'\nPrzymiarka: '..effect
  return held and tool or nil
 end
 function S:refresh()
  local tool=self:updateLabel()
  if not self.enabled or not tool or not self.app.platform.allowed then self:clearTint();self:updateLabel();return end
  local style=styleByName[self.style]
  local main=Color3.fromRGB(table.unpack(style.main));local edge=Color3.fromRGB(table.unpack(style.edge))
  local keep={};local count=0
  local function add(part)
   if not part or keep[part] or not part:IsA('BasePart') or part.Transparency>=1 or part.LocalTransparencyModifier>=1 or count>=6 then return end
   keep[part]=true;count+=1
   if not self.folder then
    self.folder=Instance.new('Folder');self.folder.Name='KubiHubLocalWeaponStyle';self.folder.Parent=workspace
   end
   local effect=self.tint[part]
   if not effect or effect.Parent~=self.folder then
    effect=Instance.new('Highlight');effect.Name='Podgląd stylu';effect.Adornee=part
    effect.DepthMode=Enum.HighlightDepthMode.Occluded;effect.FillTransparency=.21;effect.OutlineTransparency=.36
    self.tint[part]=effect;effect.Parent=self.folder
   end
   effect.FillColor=main;effect.OutlineColor=edge
  end
  add(tool:FindFirstChild('Handle'))
  for _,part in ipairs(tool:GetDescendants())do if count>=6 then break end;add(part)end
  for part,effect in pairs(self.tint)do if not keep[part] then effect:Destroy();self.tint[part]=nil end end
  if not next(self.tint) then self:clearTint()end
  self:updateLabel()
 end
 function S:setStyle(style)
  if not styleByName[style] then return false,'Nieznany styl.' end
  self.style=style;self:updatePreview();self:refresh();return true
 end

 return function(app,page)
  local ui=app.ui
  local self=setmetatable({app=app,kind='Knife',style=names[1],angle=15,enabled=false,tint={}},S)
  app.runtime:own(self)
  local card=ui:card(page,'Studio skórek MM2','Zobacz własne wzory na modelach 3D i przymierz kolor na broni z rundy. Wzory huba są widoczne tylko u Ciebie.')
  ui:label(card,'Podgląd 3D i przymiarka nie zmieniają ekwipunku. Wymienialne skórki przekażesz w oknie wymiany MM2.')
  local viewport=ui:create('ViewportFrame',{Name='WeaponSkinPreview',Size=UDim2.new(1,0,0,165),BackgroundColor3=ui.palette.bg,BorderSizePixel=0,Ambient=Color3.fromRGB(179,188,211),LightColor=Color3.fromRGB(252,247,233),LightDirection=Vector3.new(-1,-1,-1)},card)
  ui:corner(viewport,8)
  self.world=ui:create('WorldModel',{},viewport)
  self.camera=ui:create('Camera',{FieldOfView=42},viewport);viewport.CurrentCamera=self.camera;self:updateCamera()
  self.status=ui:label(card,'')
  ui:cycle(card,'Model',{'Nóż','Pistolet'},function()return labels[self.kind]end,function(label)
   self.kind=kinds[label];self:updatePreview();self:refresh()
  end)
  ui:cycle(card,'Styl',names,function()return self.style end,function(style)return self:setStyle(style)end)
  ui:button(card,'Obróć podgląd',function()self.angle=(self.angle+45)%360;self:updateCamera()end)
  ui:button(card,'Losuj styl',function()
   local choices={};for _,name in ipairs(names)do if name~=self.style then choices[#choices+1]=name end end
   self:setStyle(choices[math.random(#choices)]);ui:refreshControls()
  end)
  ui:feature(card,'Przymierz styl — lokalnie',function()return self.enabled end,function()self.enabled=not self.enabled;self:refresh()end,function(panel)
   ui:label(panel,'Efekt nakłada wybrany kolor na widoczną broń w Twojej dłoni. Oryginalna skórka pozostaje bez zmian.')
  end)
  ui:button(card,'Załóż broń z tej rundy',function()
   local tool,err=app.platform:equip(self.kind)
   if not tool then return false,err end
   self:refresh();return true
  end)
  ui:button(card,'Zdejmij lokalny styl',function()self:reset()end)
  self:updatePreview();self:refresh()
  app.runtime:schedule('MM2Skins',.25,function()
   if not self.enabled then return end
   local ok,err=pcall(self.refresh,self)
   if not ok then self:reset();app.runtime.errors('Skórki',err)end
  end)
  return self
 end
end
