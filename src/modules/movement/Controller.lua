return function(Util)
 local Movement={};Movement.__index=Movement
 function Movement.new(runtime,adapter,player,input,log,settings)
  return setmetatable({runtime=runtime,adapter=adapter,player=player,input=input,log=log,settings=settings,fly=false,saved=nil,objects={}},Movement)
 end
 function Movement:character()
  local ch=self.player.Character;return ch,ch and ch:FindFirstChildOfClass('Humanoid'),ch and ch:FindFirstChild('HumanoidRootPart')
 end
 function Movement:available()
  if not self.adapter.capabilities.movement then return false,'Zmiana ruchu wymaga autoryzowanego środowiska testowego.' end
  local _,h,r=self:character();if not h or not r or h.Health<=0 then return false,'Postać jest niedostępna.' end;return true
 end
 function Movement:capture(h)
  if self.saved and self.saved.humanoid==h then return end
  self.saved={humanoid=h,WalkSpeed=h.WalkSpeed,JumpPower=h.JumpPower,JumpHeight=h.JumpHeight,UseJumpPower=h.UseJumpPower,PlatformStand=h.PlatformStand,AutoRotate=h.AutoRotate}
 end
 function Movement:apply()
  local ok,err=self:available();if not ok then return false,err end
  local _,h=self:character();self:capture(h)
  local response=self.adapter:movement({walk=Util.number(self.settings.walk,16,8,60),jump=Util.number(self.settings.jump,50,20,120)})
  if not response.ok then return false,response.error end
  self.log:add('Movement','Serwer potwierdził ustawienia własnej postaci.');return true
 end
 function Movement:startFly()
  local ok,err=self:available();if not ok then return false,err end
  if self.fly then return false,'Fly już działa.' end
  ok,err=self.runtime:acquire('Fly');if not ok then return false,err end
  local _,h,r=self:character();self:capture(h);h.PlatformStand=true;h.AutoRotate=false
  local a=Instance.new('Attachment');a.Name='KubiHubFlyAttachment';a.Parent=r
  local velocity=Instance.new('LinearVelocity');velocity.Attachment0=a;velocity.RelativeTo=Enum.ActuatorRelativeTo.World;velocity.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector;velocity.MaxForce=math.max(10000,r.AssemblyMass*workspace.Gravity*8);velocity.VectorVelocity=Vector3.zero;velocity.Parent=r
  local align=Instance.new('AlignOrientation');align.Mode=Enum.OrientationAlignmentMode.OneAttachment;align.Attachment0=a;align.MaxTorque=200000;align.Responsiveness=15;align.CFrame=r.CFrame;align.Parent=r
  self.objects={velocity,align,a};self.velocity=velocity;self.align=align;self.fly=true;return true
 end
 function Movement:stopFly()
  self.fly=false;for _,o in ipairs(self.objects) do o:Destroy() end;self.objects={};self.velocity=nil;self.align=nil
  if self.saved and self.saved.humanoid.Parent then self.saved.humanoid.PlatformStand=self.saved.PlatformStand;self.saved.humanoid.AutoRotate=self.saved.AutoRotate end;self.runtime:release('Fly')
 end
 function Movement:reset()
  self:stopFly();self.adapter:cancel('movement');local s=self.saved
  if s and s.humanoid.Parent then for _,key in ipairs({'WalkSpeed','JumpPower','JumpHeight','UseJumpPower','PlatformStand','AutoRotate'}) do s.humanoid[key]=s[key] end end
  self.saved=nil;return true
 end
 function Movement:tick()
  if not self.fly then return end
  local _,h,r=self:character();local c=workspace.CurrentCamera
  if not h or not r or h.Health<=0 or not self.velocity or not self.velocity.Parent then self:reset();return end
  local move=Vector3.zero
  if c and not self.input:GetFocusedTextBox() then
   for _,s in ipairs({{Enum.KeyCode.W,c.CFrame.LookVector},{Enum.KeyCode.S,-c.CFrame.LookVector},{Enum.KeyCode.D,c.CFrame.RightVector},{Enum.KeyCode.A,-c.CFrame.RightVector},{Enum.KeyCode.Space,Vector3.yAxis},{Enum.KeyCode.LeftControl,-Vector3.yAxis}}) do if self.input:IsKeyDown(s[1]) then move=move+s[2] end end
   if self.input.TouchEnabled then move=move+h.MoveDirection end
  end
  self.velocity.VectorVelocity=move.Magnitude>.01 and move.Unit*Util.number(self.settings.flySpeed,40,10,100) or Vector3.zero
  if c then self.align.CFrame=c.CFrame.Rotation end
 end
 return Movement
end
