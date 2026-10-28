return function(Util,Schema,Inventory)
 local Preview={};Preview.__index=Preview
 function Preview.new(parent)
  local viewport=Instance.new('ViewportFrame');viewport.Name='SchematicPreview';viewport.Size=UDim2.new(1,0,0,270);viewport.BackgroundColor3=Color3.fromRGB(12,17,28);viewport.BorderSizePixel=0;viewport.Ambient=Color3.fromRGB(160,170,190);viewport.LightColor=Color3.fromRGB(255,245,230);viewport.Parent=parent
  local world=Instance.new('WorldModel');world.Parent=viewport;local camera=Instance.new('Camera');camera.FieldOfView=45;camera.Parent=viewport;viewport.CurrentCamera=camera
  return setmetatable({viewport=viewport,world=world,camera=camera,yaw=35,pitch=15,zoom=1,parts={},schema=nil,lastRender=-math.huge},Preview)
 end
 function Preview:clear()for _,p in ipairs(self.parts) do p:Destroy() end;self.parts={}end
 function Preview:view(kind)
  if kind=='TOP' then self.yaw=0;self.pitch=89 elseif kind=='SIDE' then self.yaw=90;self.pitch=0 else self.yaw=35;self.pitch=15 end;self:updateCamera()
 end
 function Preview:orbit(dx,dy)self.yaw=self.yaw+dx;self.pitch=math.clamp(self.pitch+dy,-80,89);self:updateCamera()end
 function Preview:changeZoom(v)self.zoom=math.clamp(self.zoom*v,.35,4);self:updateCamera()end
 function Preview:updateCamera()
  if not self.bounds then return end
  local size=self.bounds.size;local center=Vector3.new(table.unpack(self.bounds.center));local d=math.max(size[1],size[2],size[3],8)*1.7*self.zoom
  local y,p=math.rad(self.yaw),math.rad(self.pitch);local offset=Vector3.new(math.cos(y)*math.cos(p),math.sin(p),math.sin(y)*math.cos(p))*d
  self.camera.CFrame=CFrame.lookAt(center+offset,center)
 end
 function Preview:set(schema,snapshot,options)
  self:clear();self.schema=schema;options=options or {};self.bounds=Schema.bounds(schema,options.yaw);local limit=options.limit or 350;local layer=options.layer or 0
  local eligible=0;for _,e in ipairs(schema.elements) do if layer==0 or e.layer==layer then eligible=eligible+1 end end
  local used={};local stride=math.max(1,math.ceil(eligible/limit));local shown=0;local filteredIndex=0
  for i,e in ipairs(schema.elements) do
   used[e.material]=(used[e.material] or 0)+Inventory.cost(e)
   local item=snapshot and snapshot.items[e.material];local missing=item and item.known and used[e.material]>item.count;local unknown=not item or not item.known
   local visible=layer==0 or e.layer==layer;if visible then filteredIndex=filteredIndex+1 end
   if visible and (filteredIndex-1)%stride==0 then
    local p=Instance.new(e.class=='WedgePart' and 'WedgePart' or 'Part');p.Name=e.id;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Size=Vector3.new(table.unpack(e.size))
    p.CFrame=CFrame.Angles(0,math.rad(options.yaw or 0),0)*CFrame.new(table.unpack(e.position))*CFrame.Angles(math.rad(e.rotation[1]),math.rad(e.rotation[2]),math.rad(e.rotation[3]));p.Color=missing and Color3.fromRGB(245,80,100) or unknown and Color3.fromRGB(220,160,60) or e.color and Color3.new(table.unpack(e.color)) or Color3.fromRGB(82,134,245);p.Material=Enum.Material.SmoothPlastic
    if e.material=='Dynamite' then p.Shape=Enum.PartType.Cylinder;p.Size=Vector3.new(3,.7,.7);p.CFrame=p.CFrame*CFrame.Angles(0,0,math.pi/2) end
    p.Parent=self.world;self.parts[#self.parts+1]=p;shown=shown+1
   end
  end
  self.shown=shown;self:updateCamera();return shown
 end
 function Preview:destroy()self:clear();self.viewport:Destroy()end
 return Preview
end
