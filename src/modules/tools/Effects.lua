local Effects={};Effects.__index=Effects
function Effects.new(clock) return setmetatable({clock=clock,objects={},rainbow=nil,clones=0},Effects) end
function Effects:own(object,ttl)self.objects[#self.objects+1]={object=object,expires=self.clock()+ttl};return object end
function Effects:confetti(root)
 assert(root,'Brak postaci.');local a=self:own(Instance.new('Attachment'),4);a.Parent=root
 local e=Instance.new('ParticleEmitter');e.Texture='rbxasset://textures/particles/sparkles_main.dds';e.Rate=0;e.Lifetime=NumberRange.new(1,2);e.Speed=NumberRange.new(10,22);e.SpreadAngle=Vector2.new(180,180);e.Size=NumberSequence.new(.3);e.Color=ColorSequence.new(Color3.fromRGB(70,130,255),Color3.fromRGB(180,80,255));e.Parent=a;e:Emit(60)
end
function Effects:trail(root)
 if self.rainbow then self:clear();return end;assert(root,'Brak postaci.')
 local a=self:own(Instance.new('Attachment'),600);a.Position=Vector3.new(-1,0,0);a.Parent=root;local b=self:own(Instance.new('Attachment'),600);b.Position=Vector3.new(1,0,0);b.Parent=root
 local t=self:own(Instance.new('Trail'),600);t.Attachment0=a;t.Attachment1=b;t.Lifetime=.8;t.LightEmission=1;t.FaceCamera=true;t.Parent=root;self.rainbow=t
end
function Effects:clone(character,scale)
 assert(character,'Brak postaci.');assert(self.clones<5,'Limit pięciu lokalnych kopii. Wyczyść efekty lub poczekaj 12 s.')
 local old=character.Archivable;character.Archivable=true;local ok,clone=pcall(function()return character:Clone()end);character.Archivable=old;assert(ok and clone,'Nie można skopiować postaci.')
 for _,o in ipairs(clone:GetDescendants()) do if o:IsA('Script') or o:IsA('LocalScript') or o:IsA('Tool') then o:Destroy() elseif o:IsA('BasePart') then o.Anchored=true;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false end end
 clone.Name='KubiHubLocalClone';clone.Parent=workspace;clone:ScaleTo(scale);clone:PivotTo(character:GetPivot()*CFrame.new(5+self.clones*3,0,0));self:own(clone,12);self.clones=self.clones+1
end
function Effects:tick()
 local now=self.clock();for i=#self.objects,1,-1 do local row=self.objects[i];if not row.object.Parent or now>=row.expires then if row.object==self.rainbow then self.rainbow=nil end;if row.object.Name=='KubiHubLocalClone' then self.clones=math.max(0,self.clones-1) end;row.object:Destroy();table.remove(self.objects,i) end end
 if self.rainbow then self.rainbow.Color=ColorSequence.new(Color3.fromHSV(now*.1%1,.8,1),Color3.fromHSV((now*.1+.3)%1,.8,1)) end
end
function Effects:clear()for _,row in ipairs(self.objects) do row.object:Destroy() end;self.objects={};self.clones=0;self.rainbow=nil end
return Effects
