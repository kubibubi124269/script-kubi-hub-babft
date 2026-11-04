-- Deliberately small UI contract mock. It cannot render Roblox or simulate constraints.
local _G={};local tick=0;local os=table.clone(os);os.clock=function()return tick end
local game,workspace,Instance,Enum,Vector3,Vector2,CFrame,Color3,UDim,UDim2,RaycastParams
local task={spawn=function(fn)fn()end,defer=function(fn)fn()end}
task.wait=function(dt)tick+=dt or .03;if task.onWait then task.onWait(dt) end end
local function warn(message)print('MOCK WARN '..message)end
local readfile,writefile,isfile,isfolder,makefolder,setclipboard
local function signal()
 local s={rows={}}
 function s:Connect(fn)local c={Connected=true,fn=fn};function c:Disconnect()self.Connected=false end;self.rows[#self.rows+1]=c;return c end
 function s:Fire(...)for _,c in ipairs(table.clone(self.rows))do if c.Connected then c.fn(...)end end end
 return s
end
local vm={};vm.__index=function(v,k)if k=='Magnitude' then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z)elseif k=='Unit'then return v/math.max(.0001,v.Magnitude)end end
vm.__add=function(a,b)return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end;vm.__sub=function(a,b)return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
vm.__mul=function(a,b)if type(a)=='number'then a,b=b,a end;return Vector3.new(a.X*b,a.Y*b,a.Z*b)end;vm.__div=function(a,b)return Vector3.new(a.X/b,a.Y/b,a.Z/b)end
vm.__unm=function(v)return Vector3.new(-v.X,-v.Y,-v.Z)end
Vector3={new=function(x,y,z)return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vm)end};Vector3.zero=Vector3.new();Vector3.yAxis=Vector3.new(0,1,0)
local v2m={__div=function(v,n)return Vector2.new(v.X/n,v.Y/n)end}
Vector2={new=function(x,y)return setmetatable({X=x or 0,Y=y or 0},v2m)end};Vector2.zero=Vector2.new()
local cm={};cm.__index=function(c,k)if k=='Position'then return c.pos elseif k=='Rotation'then return c elseif k=='LookVector'then return Vector3.new(0,0,-1)elseif k=='ToObjectSpace' then return function(a,b)return CFrame.new(b.pos-a.pos)end elseif k=='ToAxisAngle'then return function()return Vector3.yAxis,0 end end end;cm.__mul=function(a,b)return CFrame.new(a.pos+b.pos)end
CFrame={new=function(x,y,z)return setmetatable({pos=type(x)=='table' and x or Vector3.new(x,y,z)},cm)end,Angles=function()return CFrame.new()end,lookAt=function(p)return CFrame.new(p)end}
local originalCFrameIndex=cm.__index;cm.__index=function(c,k)if k=='RightVector' then return Vector3.new(1,0,0) elseif k=='Lerp' then return function(a,b,t)return CFrame.new(a.pos+(b.pos-a.pos)*t)end end;return originalCFrameIndex(c,k)end
RaycastParams={new=function()return {}end}
Color3={new=function(r,g,b)return {R=r,G=g,B=b}end,fromRGB=function(r,g,b)return {R=r/255,G=g/255,B=b/255}end,fromHSV=function()return {}end}
UDim={new=function(s,o)return {Scale=s or 0,Offset=o or 0}end};UDim2={new=function(a,b,c,d)return {X=UDim.new(a,b),Y=UDim.new(c,d)}end};UDim2.fromOffset=function(x,y)return UDim2.new(0,x,0,y)end;UDim2.fromScale=function(x,y)return UDim2.new(x,0,y,0)end
Enum=setmetatable({},{__index=function(t,k)local group=setmetatable({},{__index=function(g,v)local item={Name=v};rawset(g,v,item);return item end});rawset(t,k,group);return group end})
Enum.RenderPriority.Camera.Value=200;Enum.RenderPriority.Last.Value=2000
local methods={};local im={};local events={Activated=true,FocusLost=true,InputBegan=true,InputChanged=true,InputEnded=true,MouseEnter=true,MouseLeave=true,ChildAdded=true,ChildRemoved=true,Changed=true,CharacterAdded=true,Heartbeat=true,RenderStepped=true}
im.__index=function(o,k)
 if methods[k] then return methods[k]end
 if o.props[k]~=nil then return o.props[k]end
 if events[k] then local s=signal();o.props[k]=s;return s end
 if k=='AbsoluteSize' then return Vector2.new(800,500)elseif k=='AbsolutePosition'then return Vector2.new(30,30)elseif k=='Position' and o.props.CFrame then return o.props.CFrame.Position end
 for _,c in ipairs(o.children)do if c.Parent==o and c.Name==k then return c end end
end
im.__newindex=function(o,k,v)
 local previous=o.props[k];o.props[k]=v
 if k=='Parent'and v and v~=previous then v.children[#v.children+1]=o end
 if o.signals[k] and previous~=v then o.signals[k]:Fire()end
end
Instance={new=function(class)return setmetatable({props={Name=class,ClassName=class,Visible=true,CanvasPosition=Vector2.zero,Transparency=0,LocalTransparencyModifier=0,Size=Vector3.new(2,2,1),CFrame=CFrame.new(),HipHeight=2,AutomaticScalingEnabled=true,AssemblyMass=10,AssemblyLinearVelocity=Vector3.zero,AssemblyAngularVelocity=Vector3.zero,Attributes={}},children={},signals={}},im)end}
function methods:IsA(c)return self.ClassName==c or c=='GuiObject'and ({Frame=true,TextButton=true,TextLabel=true,TextBox=true,ScrollingFrame=true,ViewportFrame=true})[self.ClassName]==true or c=='BasePart'and(self.ClassName=='Part'or self.ClassName=='WedgePart'or self.ClassName=='MeshPart')end
function methods:GetChildren()local out={};for _,c in ipairs(self.children)do if c.Parent==self then out[#out+1]=c end end;return out end
function methods:GetDescendants()local out={};local function walk(o)for _,c in ipairs(o:GetChildren())do out[#out+1]=c;walk(c)end end;walk(self);return out end
function methods:FindFirstChild(name,recursive)
 assert(type(name)=='string','FindFirstChild name must be a string')
 assert(recursive==nil or type(recursive)=='boolean','FindFirstChild recursive must be a boolean')
 for _,c in ipairs(recursive and self:GetDescendants()or self:GetChildren())do if c.Name==name then return c end end
end
function methods:FindFirstChildOfClass(name)for _,c in ipairs(self:GetChildren())do if c:IsA(name)then return c end end end
function methods:FindFirstChildWhichIsA(name,recursive)for _,c in ipairs(recursive and self:GetDescendants()or self:GetChildren())do if c:IsA(name)then return c end end end
function methods:IsDescendantOf(parent)local p=self.Parent;while p do if p==parent then return true end;p=p.Parent end;return false end
function methods:EquipTool(tool)tool.Parent=self.Parent end
function methods:GetPivot()local r=self:FindFirstChild('HumanoidRootPart') or self.PrimaryPart or self:FindFirstChildWhichIsA('BasePart',true);return r and r.CFrame or CFrame.new()end
function methods:PivotTo(cf)local old=self:GetPivot();local delta=cf.Position-old.Position;for _,part in ipairs(self:GetDescendants())do if part:IsA('BasePart')then part.CFrame=CFrame.new(part.Position+delta)end end;self.PivotMoves=(self.PivotMoves or 0)+1 end
function methods:GetScale()return self.MockScale or 1 end
function methods:ScaleTo(value)
 if self.ScaleError then error(self.ScaleError)end
 assert(type(value)=='number'and value>0);local ratio=value/self:GetScale();local pivot=self:GetPivot().Position
 for _,part in ipairs(self:GetDescendants())do if part:IsA('BasePart')then part.Size=part.Size*ratio;part.CFrame=CFrame.new(pivot+(part.Position-pivot)*ratio)end end
 self.MockScale=value;self.ScaleCalls=(self.ScaleCalls or 0)+1
end
function methods:Activate()self.Activations=(self.Activations or 0)+1;if self.ActivateError then error(self.ActivateError)end end
function methods:GetAttribute(name)return self.Attributes[name]end
function methods:SetAttribute(name,value)self.Attributes[name]=value end
function methods:GetPlayers()return self:GetChildren()end
function methods:IsStudio()return game.PlaceId==10 end
function methods:WorldToViewportPoint(position)return Vector3.new(self.ViewportSize.X/2+position.X,self.ViewportSize.Y/2-position.Y,10),true end
function methods:Raycast()return self.raycastHit end
function methods:BindToRenderStep(name,priority,fn)self.RenderBindings=self.RenderBindings or {};self.RenderBindings[name]={priority=priority,fn=fn}end
function methods:UnbindFromRenderStep(name)if self.RenderBindings then self.RenderBindings[name]=nil end end
function methods:WaitForChild(name)return self:FindFirstChild(name)end
function methods:GetPropertyChangedSignal(name)if not self.signals[name]then self.signals[name]=signal()end;return self.signals[name]end
function methods:Destroy()for _,c in ipairs(self:GetChildren())do c:Destroy()end;self.Parent=nil;self.Destroyed=true end
function methods:GetFocusedTextBox()return nil end;function methods:IsKeyDown()return false end;function methods:GetState()return {Name='Running'}end
local function child(p,c,n)local o=Instance.new(c);o.Name=n or c;o.Parent=p;return o end
workspace=Instance.new('Workspace');workspace.Gravity=196.2;workspace.CurrentCamera=Instance.new('Camera');workspace.CurrentCamera.ViewportSize=Vector2.new(1280,720);workspace.CurrentCamera.CFrame=CFrame.new();workspace.CurrentCamera.FieldOfView=70
local services={};for _,name in ipairs({'Players','UserInputService','RunService','HttpService','ReplicatedStorage','Lighting'})do services[name]=Instance.new(name)end
services.Lighting.Brightness=1;services.Lighting.ClockTime=19;services.Lighting.Ambient=Color3.new(.2,.2,.2);services.Lighting.OutdoorAmbient=Color3.new(.3,.3,.3);services.Lighting.FogEnd=500;services.Lighting.GlobalShadows=true
local player=child(services.Players,'Player','Tester');player.UserId=123;player.DisplayName='Tester';player.CameraMinZoomDistance=.5;player.CameraMaxZoomDistance=12;player.CameraMode=Enum.CameraMode.Classic;services.Players.LocalPlayer=player;child(player,'PlayerGui','PlayerGui')
local data=child(player,'Folder','Data');for _,name in ipairs({'WoodBlock','TitaniumBlock','MetalBlock','Seat','Dynamite'})do child(data,'IntValue',name).Value=10000 end
local ch=Instance.new('Model');player.Character=ch;local hum=child(ch,'Humanoid');hum.Health=100;hum.MaxHealth=100;hum.WalkSpeed=21;hum.JumpPower=56;hum.JumpHeight=8;hum.UseJumpPower=true;hum.AutoRotate=true;hum.PlatformStand=false
local root=child(ch,'Part','HumanoidRootPart');root.AssemblyLinearVelocity=Vector3.zero;root.CFrame=CFrame.new()
local encoded={};function services.HttpService:JSONEncode(v)local key='json_'..(#encoded+1);encoded[#encoded+1]=v;encoded[key]=v;return key end
function services.HttpService:JSONDecode(s)assert(encoded[s],'Invalid mock JSON');return encoded[s]end
game={PlaceId=10,GameId=0,GetService=function(_,name)assert(services[name],name);return services[name]end}
