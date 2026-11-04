 local T={};T.__index=T
 function T.new(runtime,player,allowed)return setmetatable({runtime=runtime,player=player,allowed=allowed,slots={},slot=1,offset=3},T)end
 function T:character()
  local c=self.player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local r=c and c:FindFirstChild('HumanoidRootPart')
  if not c or not h or not r or h.Health<=0 then return nil,nil,nil,'Poczekaj na aktywną postać.' end;return c,h,r
 end
 function T:save()
  local _,_,r,err=self:character();if not r then return false,err end;self.slots[self.slot]=r.CFrame;return true
 end
 function T:go(cf)
  if not self.allowed then return false,'Teleport działa w BABFT i MM2.' end
  if not cf then return false,'Najpierw zapisz punkt.' end
  local ok,err=self.runtime:acquire('Teleport');if not ok then return false,err end
  local c,h,r,why=self:character();if not r then self.runtime:release('Teleport');return false,why end
  local origin=r.CFrame;local moved,message=pcall(function()h.Sit=false;r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero;c:PivotTo(cf*r.CFrame:ToObjectSpace(c:GetPivot()))end)
  self.runtime:release('Teleport');if not moved then return false,tostring(message) end;self.previous={character=c,cf=origin};return true
 end
 function T:back()
  if not self.previous or self.previous.character~=self.player.Character then return false,'Brak powrotu dla obecnej postaci.' end;return self:go(self.previous.cf)
 end
 return T
