-- Run in Studio SERVER command bar after building WORM MK2 through the included adapter.
-- Structural checks execute in the real engine. They are not a driving/animation acceptance test.
local container=workspace:FindFirstChild('KubiHubOwnedTestEnvironment');assert(container,'Insert the test kit and press Play first')
local found
for _,o in ipairs(container:GetDescendants()) do if o:IsA('Model') and o:GetAttribute('BuildCommitted') and o:FindFirstChild('driver') then found=o end end
assert(found,'Build WORM MK2 first')
local hinges,seats,parts=0,0,0
for _,o in ipairs(found:GetDescendants()) do
 if o:IsA('HingeConstraint') then hinges+=1;assert(o.Attachment0 and o.Attachment1,'Missing hinge attachment');assert((o.Attachment0.WorldPosition-o.Attachment1.WorldPosition).Magnitude<.15,'Separated hinge anchors');assert(o.Attachment0.WorldAxis:Dot(o.Attachment1.WorldAxis)>.98,'Misaligned hinge axes')
 elseif o:IsA('VehicleSeat') then seats+=1
 end
 if o:IsA('BasePart') then parts+=1;assert(not o.Anchored,'Mechanical part still anchored') end
end
assert(hinges==14 and seats==1,'Expected 14 native hinges and exactly one driver')
print('Native STRUCTURE checks passed: '..parts..' parts / '..hinges..' hinges / '..seats..' driver. Driving, mouth motion, stability and multiplayer replication must still be observed.')
