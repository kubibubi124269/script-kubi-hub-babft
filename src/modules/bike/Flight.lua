return function(M)
 local F={};F.__index=F
 local keys=Enum.KeyCode
 local bindings={keys.W,keys.A,keys.S,keys.D,keys.Space,keys.LeftControl}
 local action='KubiHubDeluxeBikeFlight'
 local function flat(v)return Vector3.new(v.X,0,v.Z)end

 function F.new(app)
  return setmetatable({app=app,active=false,speed=36,pressed={}},F)
 end
 function F:stop()
  self.active=false;table.clear(self.pressed)
  if self.controls then self.controls:UnbindAction(action);self.controls=nil end
  if self.velocity then self.velocity:Destroy();self.velocity=nil end
  if self.align then self.align:Destroy();self.align=nil end
  if self.anchor then self.anchor:Destroy();self.anchor=nil end
  self.root=nil;self.seat=nil;self.character=nil
 end
 F.Destroy=F.stop
 function F:input(state,input)
  if not self.active then return Enum.ContextActionResult.Pass end
  if state==Enum.UserInputState.Cancel then table.clear(self.pressed)
  elseif state==Enum.UserInputState.End then self.pressed[input.KeyCode]=nil end
  if self.app.input:GetFocusedTextBox() then
   table.clear(self.pressed);return Enum.ContextActionResult.Pass
  end
  if state==Enum.UserInputState.Begin then self.pressed[input.KeyCode]=true end
  return Enum.ContextActionResult.Sink
 end
 function F:start()
  local app=self.app
  if app.riding or app.highway.active or app.routeIndex or next(app.held) then return false,'Najpierw zatrzymaj jazdę.' end
  local character,_,seat=app:seat()
  if not seat then return false,'Najpierw wsiądź na rower.' end
  local root=seat.AssemblyRootPart
  if not root or root.Anchored or not root:IsDescendantOf(workspace) then return false,'Nie rozpoznano ruchomego roweru.' end
  local facing=flat(seat.CFrame.LookVector)
  if facing.Magnitude<.2 or seat.CFrame.UpVector.Y<.35 then return false,'Najpierw ustaw rower na kołach.' end
  local ok,err=pcall(function()
   self.root=root;self.seat=seat;self.character=character
   local anchor=Instance.new('Attachment');self.anchor=anchor;anchor.Name='KubiHubBikeFlightAnchor'
   anchor.CFrame=root.CFrame:ToObjectSpace(seat.CFrame).Rotation
   anchor.Parent=root
   local velocity=Instance.new('LinearVelocity');self.velocity=velocity
   velocity.Name='KubiHubBikeFlightVelocity';velocity.Attachment0=anchor
   velocity.RelativeTo=Enum.ActuatorRelativeTo.World;velocity.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
   velocity.ForceLimitsEnabled=true;velocity.ForceLimitMode=Enum.ForceLimitMode.Magnitude
   velocity.MaxForce=math.max(1,root.AssemblyMass)*(workspace.Gravity+140)
   velocity.VectorVelocity=Vector3.zero;velocity.Parent=root
   local align=Instance.new('AlignOrientation');self.align=align;align.Name='KubiHubBikeFlightOrientation'
   align.Mode=Enum.OrientationAlignmentMode.OneAttachment;align.Attachment0=anchor
   align.MaxTorque=math.clamp(root.AssemblyMass*4500,5000,350000);align.Responsiveness=12
   align.CFrame=CFrame.lookAt(Vector3.zero,facing.Unit);align.Parent=root
   self.controls=game:GetService('ContextActionService');self.active=true
   self.controls:BindActionAtPriority(action,function(_,state,input)return self:input(state,input)end,false,Enum.ContextActionPriority.High.Value,table.unpack(bindings))
  end)
  if not ok then self:stop();return false,tostring(err)end
  return true
 end
 function F:update()
  local character,_,seat=self.app:seat()
  local root=self.root
  if character~=self.character or seat~=self.seat or not root:IsDescendantOf(workspace) or root.Anchored or seat.AssemblyRootPart~=root or self.velocity.Parent~=root or self.anchor.Parent~=root or self.align.Parent~=root then
   self:stop();self.app.ui:refreshFeatures();return
  end
  local camera=workspace.CurrentCamera
  if not camera or self.app.input:GetFocusedTextBox() then
   table.clear(self.pressed);self.velocity.VectorVelocity=Vector3.zero;return
  end
  local forward=flat(camera.CFrame.LookVector)
  if forward.Magnitude<.1 then forward=flat(seat.CFrame.LookVector)end
  if forward.Magnitude<.1 then forward=Vector3.new(0,0,-1)end
  forward=forward.Unit
  local right=Vector3.new(-forward.Z,0,forward.X)
  local function axis(positive,negative)return (self.pressed[positive] and 1 or 0)-(self.pressed[negative] and 1 or 0)end
  local horizontal=forward*axis(keys.W,keys.S)+right*axis(keys.D,keys.A)
  local climb=axis(keys.Space,keys.LeftControl)
  if horizontal.Magnitude>1 then horizontal=horizontal.Unit end
  self.velocity.VectorVelocity=horizontal*self.speed+Vector3.new(0,climb*self.speed*.65,0)
  if horizontal.Magnitude>.1 then self.align.CFrame=CFrame.lookAt(Vector3.zero,forward)end
 end
 function F:page(page)
  local ui=self.app.ui
  local card=ui:card(page,'Lot na motorze')
  ui:label(card,'Wsiądź na motor. WASD — kierunek, Spacja — w górę, lewy Ctrl — w dół, F8 — STOP.')
  ui:feature(card,'Fly na motorze',function()return self.active end,function()
   if self.active then self:stop();return true end
   return self:start()
  end,function(panel)
   ui:slider(panel,'Prędkość lotu',function()return self.speed end,function(v)self.speed=v end,12,80,1)
  end)
 end
 return F
end
