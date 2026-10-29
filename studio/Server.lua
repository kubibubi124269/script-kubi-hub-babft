-- This adapter belongs in a place YOU own. It never contacts BABFT remotes.
return function(M)
 local Players=game:GetService('Players');local RS=game:GetService('ReplicatedStorage');local Run=game:GetService('RunService');local Http=game:GetService('HttpService')
 local ALLOWED_USER_IDS={} -- Explicit server-side opt-in outside Studio. The public client key is unrelated.
 local function allowed(player)return Run:IsStudio() or ALLOWED_USER_IDS[player.UserId]==true end
 if not Run:IsStudio() and not next(ALLOWED_USER_IDS) then warn('KubiHub test adapter disabled outside Studio.');return end
 assert(not RS:FindFirstChild('KubiHubAuthorizedBridgeV1'),'Only one KubiHub adapter may run.')
 local remote=Instance.new('RemoteFunction');remote.Name='KubiHubAuthorizedBridgeV1';remote.Parent=RS
 local cancelRemote=Instance.new('RemoteEvent');cancelRemote.Name='KubiHubCancelV1';cancelRemote.Parent=RS
 local root=Instance.new('Folder');root.Name='KubiHubOwnedTestEnvironment';root.Parent=workspace
 local sessions={};local slot=0
 local function failure(message)return {ok=false,error=message} end
 local function vec(v)return Vector3.new(v[1],v[2],v[3]) end
 local function restoreMovement(s)
  local old=s.movement;if old and old.hum.Parent then old.hum.WalkSpeed=old.walk;old.hum.JumpPower=old.jump;old.hum.JumpHeight=old.height end;s.movement=nil
 end
 local function cancelBuild(s,id)
  local tx=s.transactions[id];if not tx or tx.state~='open' then return end
  tx.state='cancelled';tx.model:Destroy();for material,n in pairs(tx.cost) do s.budget[material]=s.budget[material]+n end
 end
 local function stop(s,what)
  if what=='all' or what=='farm' then s.stage=0 end
  if what=='all' or what=='movement' then restoreMovement(s) end
  if what=='all' then for id in pairs(s.transactions) do cancelBuild(s,id) end;if s.rig then s.rig.stopped=true;s.rig.root.AssemblyLinearVelocity=Vector3.zero end
  elseif s.transactions[what] then cancelBuild(s,what) end
 end
 local function destroySession(s)
  stop(s,'all');s.folder:Destroy();if s.connection then s.connection:Disconnect() end
 end
 local function newSession(player)
  if sessions[player] then destroySession(sessions[player]) end
  slot=slot+1;local folder=Instance.new('Folder');folder.Name='Owner_'..player.UserId;folder.Parent=root
  local origin=Vector3.new(slot*180,8,0);local ground=Instance.new('Part');ground.Name='OwnZone';ground.Size=Vector3.new(120,2,120);ground.Position=origin-Vector3.new(0,7,0);ground.Anchored=true;ground.Color=Color3.fromRGB(45,62,78);ground.Parent=folder
  local s={token=Http:GenerateGUID(false),folder=folder,origin=origin,budget={},transactions={},cache={},cacheOrder={},stage=0,lastFarm=-math.huge,lastCall=-math.huge,checkpoints={},rig=nil}
  for id in pairs(M.Inventory.definitions) do s.budget[id]=50000 end
  for i=1,10 do local p=Instance.new('Part');p.Name='Checkpoint_'..i;p.Size=Vector3.new(5,1,5);p.Position=origin+Vector3.new(-45+(i-1)*10,-5,48);p.Anchored=true;p.Color=Color3.fromRGB(55,170,210);p.Parent=folder;s.checkpoints[i]=p end
  sessions[player]=s;s.connection=player.CharacterAdded:Connect(function()stop(s,'all')end);return s
 end
 local function begin(s,p)
  if not M.Util.id(p.id) then return failure('Invalid build request ID') end
  if s.transactions[p.id] then local tx=s.transactions[p.id];return {ok=true,transaction=p.id,state=tx.state} end
  local count=0;for _,tx in pairs(s.transactions) do count=count+1;if tx.state=='open' then return failure('Another transaction is open') end end
  if count>=16 then return failure('Session build limit reached; restart the adapter session') end
  local schema,errors=M.Schema.validate(p.schema);if not schema then return failure(table.concat(errors,'; ')) end
  if schema.assistantOnly or schema.importedMechanics or schema.intentionalOverlap then return failure('Assistant-only or unsupported mechanism') end
  for _,e in ipairs(schema.elements) do if e.material=='Dynamite' or e.material=='TNT' or e.material=='SpikeTrap' then return failure('Explosives and destructive parts are not supported by this test adapter') end end
  if not M.Util.finite(p.yaw) or math.abs(p.yaw)>360 then return failure('Invalid rotation') end
  local bounds=M.Schema.bounds(schema,p.yaw);if bounds.min[1]<-59 or bounds.max[1]>59 or bounds.min[3]<-59 or bounds.max[3]>59 or bounds.min[2]<-6 or bounds.max[2]>200 then return failure('Outside own zone') end
  local cost=M.Inventory.requirements(schema);for material,n in pairs(cost) do if not s.budget[material] or s.budget[material]<n then return failure('Missing material '..material) end end
  local model=Instance.new('Model');model.Name=schema.name;model:SetAttribute('OwnerUserId',s.ownerId);model.Parent=s.folder
  local base=CFrame.new(s.origin)*CFrame.Angles(0,math.rad(p.yaw),0)
  local tx={state='open',model=model,schema=schema,cost=cost,base=base,yaw=p.yaw,parts={},next=1,touched=os.clock()};s.transactions[p.id]=tx
  for material,n in pairs(cost) do s.budget[material]=s.budget[material]-n end
  return {ok=true,transaction=p.id}
 end
 local function place(s,p)
  local tx=s.transactions[p.transaction];if not tx or tx.state~='open' then return failure('Transaction is not open') end
  if not M.Util.finite(p.first) or p.first%1~=0 or p.first~=tx.next or not M.Util.finite(p.count) or p.count%1~=0 or p.count<1 or p.count>16 or p.first+p.count-1>#tx.schema.elements then return failure('Invalid or duplicate batch') end
  local ids={}
  for i=p.first,p.first+p.count-1 do
   local e=tx.schema.elements[i];local part=Instance.new(e.class);part.Name=e.id;part.Size=vec(e.size);part.CFrame=tx.base*CFrame.new(vec(e.position))*CFrame.Angles(math.rad(e.rotation[1]),math.rad(e.rotation[2]),math.rad(e.rotation[3]));part.Anchored=true;part.CanCollide=true
   if e.color then part.Color=Color3.new(table.unpack(e.color)) end
   part:SetAttribute('MaterialId',e.material);part:SetAttribute('OwnerUserId',s.ownerId);part.Parent=tx.model;tx.parts[e.id]=part;ids[#ids+1]=e.id
  end
  tx.next=tx.next+p.count;tx.touched=os.clock();return {ok=true,ids=ids}
 end
 local function nativeConnections(tx)
  local hinges={}
  for _,c in ipairs(tx.schema.connections) do
   local a,b=tx.parts[c.a],tx.parts[c.b]
   if c.kind=='Weld' then local weld=Instance.new('WeldConstraint');weld.Name=c.id;weld.Part0=a;weld.Part1=b;weld.Parent=a
   else
    local pivot=tx.base:PointToWorldSpace(vec(c.pivot));local axis=tx.base:VectorToWorldSpace(vec(c.axis));local up=math.abs(axis:Dot(Vector3.yAxis))>.95 and Vector3.zAxis or Vector3.yAxis;local z=axis:Cross(up).Unit;local y=z:Cross(axis).Unit;local world=CFrame.fromMatrix(pivot,axis,y,z)
    local aa=Instance.new('Attachment');aa.Name=c.id..'_A';aa.CFrame=a.CFrame:ToObjectSpace(world);aa.Parent=a
    local ab=Instance.new('Attachment');ab.Name=c.id..'_B';ab.CFrame=b.CFrame:ToObjectSpace(world);ab.Parent=b
    local h=Instance.new('HingeConstraint');h.Name=c.id;h.Attachment0=aa;h.Attachment1=ab;h.ActuatorType=Enum.ActuatorType.Servo;h.AngularSpeed=3;h.AngularResponsiveness=15;h.ServoMaxTorque=200000;h.LimitsEnabled=true;h.LowerAngle=c.lower;h.UpperAngle=c.upper;h.TargetAngle=0;h:SetAttribute('Role',c.role or '');h.Parent=a;hinges[#hinges+1]=h
   end
  end
  return hinges
 end
 local function commit(s,p)
  local tx=s.transactions[p.transaction];if not tx then return failure('Unknown transaction') end
  if tx.state=='committed' then return {ok=true,count=#tx.schema.elements,connected=true} end
  if tx.state~='open' or tx.next~=#tx.schema.elements+1 then return failure('Build is incomplete or cancelled') end
  local hinges=nativeConnections(tx)
  if tx.schema.mechanical then
   for _,part in pairs(tx.parts) do part.CanCollide=false;part.Anchored=false end
   local rootPart=tx.parts[tx.schema.root];rootPart.CanCollide=true;rootPart.CustomPhysicalProperties=PhysicalProperties.new(1,.7,0)
   local attachment=Instance.new('Attachment');attachment.Name='DriveAttachment';attachment.Parent=rootPart
   local orientation=Instance.new('AlignOrientation');orientation.Mode=Enum.OrientationAlignmentMode.OneAttachment;orientation.Attachment0=attachment;orientation.MaxTorque=150000;orientation.Responsiveness=8;orientation.CFrame=rootPart.CFrame.Rotation;orientation.Parent=rootPart
   s.rig={root=rootPart,seat=tx.parts[tx.schema.driver],hinges=hinges,mouth=false,heading=select(2,rootPart.CFrame:ToOrientation()),orientation=orientation,stopped=false}
   rootPart:SetNetworkOwner(nil)
  end
  tx.state='committed';tx.model:SetAttribute('BuildCommitted',true);s.lastSchema=assert(M.Schema.bakeYaw(tx.schema,tx.yaw));return {ok=true,count=#tx.schema.elements,connected=true}
 end
 local function dispatch(player,s,kind,p)
  if kind=='inventory' then return {ok=true,values=M.Util.copy(s.budget),source='Budżet własnego zestawu testowego — nie ekwipunek BABFT'}
  elseif kind=='beginBuild' then return begin(s,p)
  elseif kind=='placeChunk' then return place(s,p)
  elseif kind=='commitBuild' then return commit(s,p)
  elseif kind=='buildStatus' then local tx=s.transactions[p.transaction];if p.cancel then cancelBuild(s,p.transaction) end;return {ok=true,state=tx and tx.state or 'cancelled',count=tx and tx.state=='committed' and #tx.schema.elements or 0}
  elseif kind=='snapshot' then return s.lastSchema and {ok=true,schema=M.Util.copy(s.lastSchema)} or failure('No own committed build')
  elseif kind=='movement' then
   local hum=player.Character and player.Character:FindFirstChildOfClass('Humanoid');if not hum or hum.Health<=0 then return failure('Character unavailable') end
   if not M.Util.finite(p.walk) or p.walk<8 or p.walk>60 or not M.Util.finite(p.jump) or p.jump<20 or p.jump>120 then return failure('Movement outside allowed range') end
   if not s.movement then s.movement={hum=hum,walk=hum.WalkSpeed,jump=hum.JumpPower,height=hum.JumpHeight} end;hum.WalkSpeed=p.walk;if hum.UseJumpPower then hum.JumpPower=p.jump else hum.JumpHeight=p.jump*p.jump/(2*workspace.Gravity) end;return {ok=true}
  elseif kind=='rig' then
   local r=s.rig;local hum=player.Character and player.Character:FindFirstChildOfClass('Humanoid');if not r or not hum or r.seat.Occupant~=hum or p.action~='mouth' then return failure('Sit in the driver seat of your own WORM') end;r.mouth=not r.mouth;r.stopped=false;return {ok=true,open=r.mouth}
  elseif kind=='farmStep' then
   if not M.Util.finite(p.stage) or p.stage%1~=0 or p.stage<1 or p.stage>10 or p.stage~=1 and p.stage~=s.stage+1 then return failure('Invalid checkpoint order') end
   if os.clock()-s.lastFarm<.3 then return failure('Server minimum interval is 0.3s') end
   local char=player.Character;local hum=char and char:FindFirstChildOfClass('Humanoid');local checkpoint=s.checkpoints[p.stage];if not hum or hum.Health<=0 or not checkpoint.Parent then return failure('Character or checkpoint missing') end
   char:PivotTo(checkpoint.CFrame+Vector3.new(0,4,0));s.lastFarm=os.clock();s.stage=p.stage;return {ok=true,stage=p.stage,completed=p.stage==10}
  end
  return failure('Unsupported command')
 end
 remote.OnServerInvoke=function(player,packet)
  if not allowed(player) then return failure('This server did not authorize this player') end
  local encodedOK,encoded=pcall(function()return Http:JSONEncode(packet)end);if not encodedOK or #encoded>2000000 or type(packet)~='table' or packet.protocol~=1 or not M.Util.id(packet.id) then return failure('Invalid packet') end
  local s=sessions[player]
  if packet.kind=='hello' then
   if not s then s=newSession(player);s.ownerId=player.UserId end
   return {ok=true,authorized=true,userId=player.UserId,placeId=game.PlaceId,protocol=1,session=s.token,label='Własny test Studio / dozwolony serwer',capabilities={build=true,mechanics=true,inventory=true,farm=true,movement=true},zone={size={120,200,120},min={-59,-6,-59},max={59,200,59}},minFarmInterval=.3}
  end
  if not s or packet.session~=s.token then return failure('Invalid session') end
  if s.cache[packet.id] then return s.cache[packet.id] end
  if os.clock()-s.lastCall<.025 then return failure('Slow down') end;s.lastCall=os.clock()
  local ok,result=xpcall(function()return dispatch(player,s,packet.kind,packet.payload or {})end,debug.traceback)
  if not ok then warn('KubiHub adapter: '..tostring(result));stop(s,'all');result=failure('Server error; own pending build cancelled') end
  s.cache[packet.id]=result;s.cacheOrder[#s.cacheOrder+1]=packet.id;if #s.cacheOrder>64 then s.cache[table.remove(s.cacheOrder,1)]=nil end
  return result
 end
 cancelRemote.OnServerEvent:Connect(function(player,p)local s=sessions[player];if allowed(player) and s and type(p)=='table' and p.session==s.token and type(p.transaction)=='string' then stop(s,p.transaction) end end)
 Players.PlayerRemoving:Connect(function(player)local s=sessions[player];if s then destroySession(s);sessions[player]=nil end end)
 local lastSweep=0
 Run.Heartbeat:Connect(function(dt)
  local now=os.clock()
  for player,s in pairs(sessions) do
   if now-lastSweep>1 then for id,tx in pairs(s.transactions) do if tx.state=='open' and now-tx.touched>30 then cancelBuild(s,id) end end end
   local r=s.rig
   if r and r.root.Parent and r.seat.Parent then
    local hum=player.Character and player.Character:FindFirstChildOfClass('Humanoid');local occupied=hum and r.seat.Occupant==hum and not r.stopped
    local out=math.abs(r.root.Position.X-s.origin.X)>55 or math.abs(r.root.Position.Z-s.origin.Z)>55
    local throttle=occupied and not out and r.seat.ThrottleFloat or 0;local steer=occupied and r.seat.SteerFloat or 0
    r.heading=r.heading-steer*dt;local forward=CFrame.Angles(0,r.heading,0).LookVector;local v=r.root.AssemblyLinearVelocity;r.root.AssemblyLinearVelocity=Vector3.new(forward.X*throttle*20,v.Y,forward.Z*throttle*20);r.orientation.CFrame=CFrame.Angles(0,r.heading,0)
    for i,h in ipairs(r.hinges) do local role=h:GetAttribute('Role');h.TargetAngle=role=='mouth' and (r.mouth and math.min(65,h.UpperAngle) or 0) or role=='spine' and math.sin(now*2-i*.55)*math.abs(throttle)*15 or role=='neck' and steer*20 or 0 end
   end
  end
  if now-lastSweep>1 then lastSweep=now end
 end)
 return {remote=remote,root=root}
end
