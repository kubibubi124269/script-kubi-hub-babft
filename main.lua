-- KUBI HUB V3.6 STARTUP FIX
-- Load screen is created before extra features so errors stay visible.
local bootPlayers = game:GetService('Players')
local bootPlayer = bootPlayers.LocalPlayer
if not bootPlayer then warn('[KUBI HUB] No LocalPlayer available'); return end
local bootPG = bootPlayer:WaitForChild('PlayerGui', 10)
if not bootPG then warn('[KUBI HUB] PlayerGui not available'); return end

-- Clean old diagnostic UI before creating a new one.
local oldDiagnostic = bootPG:FindFirstChild('KubiHubDiagnostics')
if oldDiagnostic then oldDiagnostic:Destroy() end
local bootScreen = Instance.new('ScreenGui')
bootScreen.Name = 'KubiHubDiagnostics'
bootScreen.ResetOnSpawn = false
bootScreen.Parent = bootPG
local bootBox = Instance.new('Frame')
bootBox.Size = UDim2.fromOffset(350, 145)
bootBox.Position = UDim2.new(.5, -175, .5, -72)
bootBox.BackgroundColor3 = Color3.fromRGB(23,28,43)
bootBox.Parent = bootScreen
local bootCorner=Instance.new('UICorner')
bootCorner.CornerRadius=UDim.new(0,12)
bootCorner.Parent=bootBox
local bootLabel=Instance.new('TextLabel')
bootLabel.Size=UDim2.new(1,-20,1,-20)
bootLabel.Position=UDim2.fromOffset(10,10)
bootLabel.BackgroundTransparency=1
bootLabel.Font=Enum.Font.GothamBold
bootLabel.TextSize=15
bootLabel.TextWrapped=true
bootLabel.TextColor3=Color3.fromRGB(235,240,255)
bootLabel.Text='KUBI HUB V3.6 - starting...'
bootLabel.Parent=bootBox
local BOOT_OK, BOOT_ERR = xpcall(function()
-- KUBI HUB V3.6 | BABFT | Fixed startup and error diagnostics
-- AutoFarm, player movement, auto inventory, blueprint placement, Discord
local Players = game:GetService('Players')
local player = Players.LocalPlayer
assert(player, 'Kubi Hub must be run as a client LocalScript')
local pg = player:WaitForChild('PlayerGui', 10)
assert(pg, 'PlayerGui not found after 10 seconds')
if _G.KubiHubV3Stop then pcall(_G.KubiHubV3Stop) end
local alive, farming, autoRestart, safeMode = true, false, true, false
local speeds = {{'TURTLE',4},{'SAFE',3},{'NORMAL',2.2},{'FAST',1.5},{'TURBO',1},{'ULTRA',.65},{'HYPER',.35},{'LIGHTNING',.15},{'SONIC',.075},{'INSTANT',.02}}
local selected, custom, customDelay = 4, false, 1.5
local rounds, attempts, stage, started = 0,0,0,os.clock()
-- Inventory is read from replicated player.Data. Missing Data = UNKNOWN, never fake zeros.
local activeFloors = {}
local gui=Instance.new('ScreenGui');gui.Name='KubiHubV3';gui.ResetOnSpawn=false;gui.Parent=pg
_G.KubiHubBootGui = gui
local function new(class,props,parent)
 local obj=Instance.new(class)
 for k,v in pairs(props or {}) do obj[k]=v end
 obj.Parent=parent;return obj
end
local function rounded(o,r) new('UICorner',{CornerRadius=UDim.new(0,r or 9)},o) end
local navy=Color3.fromRGB(18,22,36);local blue=Color3.fromRGB(55,105,225)
local frame=new('Frame',{Size=UDim2.fromOffset(380,455),Position=UDim2.new(.5,-190,.5,-227),BackgroundColor3=navy,Active=true,Draggable=true},gui)
rounded(frame,14);new('UIStroke',{Thickness=2,Color=blue},frame)
local title=new('TextLabel',{Size=UDim2.new(1,-55,0,40),Position=UDim2.fromOffset(12,5),BackgroundTransparency=1,Text='KUBI HUB V3.6  |  BABFT',Font=Enum.Font.GothamBold,TextSize=20,TextColor3=Color3.fromRGB(130,190,255),TextXAlignment=Enum.TextXAlignment.Left},frame)
local function text(parent,str,y,height,size)
 return new('TextLabel',{Size=UDim2.new(1,-20,0,height or 27),Position=UDim2.fromOffset(10,y),BackgroundTransparency=1,Text=str,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=size or 14,TextColor3=Color3.fromRGB(240,243,255)},parent)
end
local function button(parent,str,y,callback)
 local b=new('TextButton',{Size=UDim2.new(1,-20,0,36),Position=UDim2.fromOffset(10,y),BackgroundColor3=blue,Font=Enum.Font.GothamBold,TextSize=14,Text=str,TextColor3=Color3.new(1,1,1)},parent)
 rounded(b);b.MouseButton1Click:Connect(callback);return b
end
local close=new('TextButton',{Size=UDim2.fromOffset(32,30),Position=UDim2.new(1,-40,0,9),Text='X',BackgroundColor3=Color3.fromRGB(178,55,72),TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold},frame);rounded(close)
local pageNames={'FARM','BUILDER','SETTINGS','PLAYER','STATS','DISCORD'}
local pages={}
for i,name in ipairs(pageNames) do
 local b=new('TextButton',{Position=UDim2.new((i-1)/6+0.005,0,0,52),Size=UDim2.new(.158,0,0,34),Text=name,TextSize=11,Font=Enum.Font.GothamBold,TextColor3=Color3.new(1,1,1),BackgroundColor3=blue},frame);rounded(b,5)
 local p=new('Frame',{Position=UDim2.fromOffset(8,94),Size=UDim2.new(1,-16,1,-116),BackgroundTransparency=1,Visible=i==1},frame);pages[name]=p
 b.MouseButton1Click:Connect(function() for k,v in pairs(pages) do v.Visible=k==name end end)
end
local footer=text(frame,'KUBI HUB  •  by Kubi  •  V3.6',432,17,11)
local function delay() return math.max(safeMode and 2 or .01,custom and customDelay or speeds[selected][2]) end
local function root() local char=player.Character;return char and char:FindFirstChild('HumanoidRootPart') end
local function teleport(cf) local r=root();if not r then return false end;r.CFrame=cf;r.AssemblyLinearVelocity=Vector3.zero;return true end
local function pause(t)
 local start=os.clock();while alive and farming and os.clock()-start<t do task.wait(math.max(.01,math.min(.1,t-(os.clock()-start)))) end
 return alive and farming
end
local farmPage=pages.FARM
text(farmPage,'Automatic stage traversal',4,29,16)
local state=text(farmPage,'Status: Stopped',46,30)
local stageText=text(farmPage,'Stage 0/10',79,30)
local toggle
local function status(s) state.Text='Status: '..s;stageText.Text='Stage '..stage..'/10' end
local function updateToggle() toggle.Text=farming and 'STOP FARM' or 'START FARM';toggle.BackgroundColor3=farming and Color3.fromRGB(180,60,70) or blue end
toggle=button(farmPage,'START FARM',116,function() farming=not farming;updateToggle();status(farming and 'Starting' or 'Stopped') end)
local speedBtn
speedBtn=button(farmPage,'SPEED: FAST',162,function() custom=false;selected=selected%#speeds+1;speedBtn.Text='SPEED: '..speeds[selected][1] end)
text(farmPage,'Use SETTINGS for timing. Very high speeds may skip rewards.',217,53,13)
local farmUnload=button(farmPage,'UNLOAD HUB',285,function()
 if _G.KubiHubV3Stop then _G.KubiHubV3Stop() end
end)
farmUnload.BackgroundColor3=Color3.fromRGB(180,60,72)
local settings=pages.SETTINGS
text(settings,'Speed and reliability',4,30,16)
local info=text(settings,'',39,35,14)
local function refreshInfo()info.Text=string.format('Mode: %s | %.0f ms/stage',custom and 'CUSTOM' or speeds[selected][1],delay()*1000) end
button(settings,'PREVIOUS SPEED',82,function() selected=math.max(1,selected-1);custom=false;speedBtn.Text='SPEED: '..speeds[selected][1];refreshInfo() end)
button(settings,'NEXT SPEED',124,function() selected=math.min(#speeds,selected+1);custom=false;speedBtn.Text='SPEED: '..speeds[selected][1];refreshInfo() end)
button(settings,'CUSTOM DELAY - 0.01s',166,function()custom=true;customDelay=math.max(.01,math.floor((customDelay-.01)*1000+.5)/1000);refreshInfo() end)
button(settings,'CUSTOM DELAY + 0.01s',208,function()custom=true;customDelay=math.min(10,math.floor((customDelay+.01)*1000+.5)/1000);refreshInfo() end)
local safeBtn
safeBtn=button(settings,'SAFE MODE: OFF',250,function()safeMode=not safeMode;safeBtn.Text='SAFE MODE: '..(safeMode and 'ON' or 'OFF');refreshInfo() end)
local restartBtn
restartBtn=button(settings,'AUTO RESTART: ON',292,function()autoRestart=not autoRestart;restartBtn.Text='AUTO RESTART: '..(autoRestart and 'ON' or 'OFF') end)
refreshInfo()
local stats=pages.STATS
local statLabel=text(stats,'',8,170,17)
button(stats,'RESET STATISTICS',199,function() rounds=0;attempts=0;started=os.clock() end)
local discord=pages.DISCORD
text(discord,'KUBI HUB COMMUNITY',8,40,19)
text(discord,'discord.gg/qmWGb4Q9p',60,40,16)
local discStatus=text(discord,'',110,40,13)
button(discord,'COPY DISCORD INVITE',162,function()
 if type(setclipboard)=='function' then
  local ok=pcall(setclipboard,'https://discord.gg/qmWGb4Q9p')
  discStatus.Text=ok and 'Copied to clipboard!' or 'Could not copy link.'
 else discStatus.Text='Clipboard not supported by this environment.' end
end)
-- Local blueprints; inventory read from player.Data; BUILD attempts real placement using the game BuildingTool.
local kinds={'Wood','Metal','Titanium','Glass','Seat'}
local blueprints={}
local function add(name)blueprints[name]={} end
local function put(name,x,y,z,kind)
 table.insert(blueprints[name],{x=x,y=y,z=z,kind=kind or 'Wood'})
end
add('WORM')
for z=0,13 do
 put('WORM',0,0,z,'Metal')
 if z%2==0 then put('WORM',-1,0,z);put('WORM',1,0,z) end
 if z%3==0 then put('WORM',0,1,z,'Glass') end
end
put('WORM',0,1,2,'Seat')
add('SPEEDBOAT')
for z=0,7 do
 for x=-1,1 do if x==0 or z>0 then put('SPEEDBOAT',x,0,z) end end
end
for z=2,6 do put('SPEEDBOAT',-2,1,z,'Metal');put('SPEEDBOAT',2,1,z,'Metal') end
put('SPEEDBOAT',0,1,5,'Seat')
add('MINI TANK')
for z=0,5 do
 for x=-2,2 do put('MINI TANK',x,0,z,'Metal') end
end
for z=1,4 do for x=-1,1 do put('MINI TANK',x,1,z,'Metal') end end
for z=0,3 do put('MINI TANK',0,2,z,'Metal') end
put('MINI TANK',0,2,4,'Seat')
add('SPACESHIP')
for z=0,9 do
 for x=-4,4 do
  if math.abs(x)<=math.min(4,1+math.floor(math.min(z,9-z)/2)) then
   put('SPACESHIP',x,0,z,'Metal')
  end
 end
end
for z=3,6 do put('SPACESHIP',0,1,z,'Glass') end
put('SPACESHIP',0,2,4,'Seat')
add('SUBMARINE')
for z=0,8 do
 for x=-1,1 do put('SUBMARINE',x,0,z,'Metal') end
 for x=-1,1 do if z>=2 and z<=6 then put('SUBMARINE',x,1,z,'Glass') end end
end
put('SUBMARINE',0,2,4,'Seat')
add('BRIDGE')
for z=0,15 do
 for x=-1,1 do put('BRIDGE',x,0,z) end
 if z%3==0 then put('BRIDGE',-1,-1,z,'Metal');put('BRIDGE',1,-1,z,'Metal') end
end
add('FORTRESS')
for z=0,8 do
 for x=-4,4 do
  if x==-4 or x==4 or z==0 or z==8 then
   put('FORTRESS',x,0,z,'Metal')
   put('FORTRESS',x,1,z,'Metal')
  end
 end
end
put('FORTRESS',0,0,4,'Seat')
add('JET')
for z=0,9 do put('JET',0,0,z,'Metal') end
for x=-5,5 do
 put('JET',x,0,4,'Metal')
 if math.abs(x)<=2 then put('JET',x,0,6,'Metal') end
end
for z=2,4 do put('JET',0,1,z,'Glass') end
put('JET',0,1,5,'Seat')
add('ROBOT')
for y=0,5 do
 for x=-1,1 do put('ROBOT',x,y,0,y>=4 and 'Glass' or 'Metal') end
end
for y=1,4 do put('ROBOT',-2,y,0,'Metal');put('ROBOT',2,y,0,'Metal') end
put('ROBOT',0,2,1,'Seat')
add('DRAGON')
for z=0,13 do
 put('DRAGON',0,0,z,'Metal')
 if z%2==0 then put('DRAGON',-1,0,z);put('DRAGON',1,0,z) end
 if z>=3 and z<=8 then
  for x=-3,3 do put('DRAGON',x,1,z,'Wood') end
 end
end
put('DRAGON',0,1,1,'Glass')
put('DRAGON',0,1,3,'Seat')
add('RAFT')
for x=-2,2 do for z=0,6 do put('RAFT',x,0,z) end end
put('RAFT',0,1,3,'Seat')
add('HOVERCRAFT')
for x=-3,3 do for z=0,5 do
 if math.abs(x)<=2 or z==2 or z==3 then put('HOVERCRAFT',x,0,z,'Metal') end
end end
for z=2,3 do put('HOVERCRAFT',0,1,z,'Glass') end
put('HOVERCRAFT',0,2,3,'Seat')

local builder=pages.BUILDER
local scroll=new('ScrollingFrame',{
 Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.fromOffset(0,735),
 ScrollBarThickness=5,BackgroundTransparency=1,BorderSizePixel=0
},builder)
text(scroll,'BLUEPRINT LIBRARY (12 PROJECTS)',0,26,16)
local names={'WORM','SPEEDBOAT','MINI TANK','SPACESHIP','SUBMARINE','BRIDGE','FORTRESS','JET','ROBOT','DRAGON','RAFT','HOVERCRAFT'}
local idx,building,buildToken=1,false,0
-- MetalBlock and TitaniumBlock are distinct BABFT inventory items.
-- Most 'metal' parts in the sample blueprints can be substituted.
local metalIsTitanium = true
local choice=button(scroll,'SCHEME: '..names[idx],30,function() end)
local metalModeButton
local requirementsLabel=text(scroll,'',120,84,14)
local inventoryLabel=text(scroll,'Loading inventory...',210,90,13)
local shortageLabel=text(scroll,'Checking materials...',300,92,13)
local progressLabel=text(scroll,'',394,42,12)
local buildBtn
local previewFolder
local function previewClear()
 if previewFolder then previewFolder:Destroy();previewFolder=nil end
end
local function requirements(name)
 local result={Wood=0,Metal=0,Titanium=0,Glass=0,Seat=0}
 for _,part in ipairs(blueprints[name]) do
  local kind=(part.kind=='Metal' and metalIsTitanium) and 'Titanium' or part.kind
  result[kind]=result[kind]+1
 end
 return result
end

-- These are the original BABFT inventory value names, not renamed labels.
local dataNames={
 Wood={'WoodBlock','Wood'},
 Metal={'MetalBlock','Metal'},
 Titanium={'TitaniumBlock','Titanium'},
 Glass={'GlassBlock','Glass'},
 Seat={'Seat'}
}
local function readInventory()
 local folder=player:FindFirstChild('Data')
 if not folder then return nil,'player.Data not found' end
 local result,matched={},0
 for _,kind in ipairs(kinds) do
  local count=0
  for _,name in ipairs(dataNames[kind]) do
   local v=folder:FindFirstChild(name)
   if v and (v:IsA('IntValue') or v:IsA('NumberValue')) then
    count=math.max(0,math.floor(v.Value))
    matched=matched+1
    break
   end
  end
  if not (folder:FindFirstChild(dataNames[kind][1]) or folder:FindFirstChild(dataNames[kind][2])) then
   result[kind]=nil
  else
   result[kind]=count
  end
 end
 if matched==0 then return nil,'No recognized inventory values in player.Data' end
 return result,nil
end
local inventoryReady=false
local function calculate()
 local need=requirements(names[idx]);local have,err=readInventory()
 if not have then return need,nil,nil,err end
 local missing={};local ok=true
 for _,kind in ipairs(kinds) do
  if need[kind]>0 and have[kind]==nil then
   return need,nil,nil,'Inventory item '..kind..' not found in player.Data'
  end
  local amount=math.max(0,need[kind]-(have[kind] or 0));missing[kind]=amount
  if amount>0 then ok=false end
 end
 return need,have,missing,nil,ok
end
local function refreshBuilder()
 if not alive or not gui.Parent then return end
 local need,have,missing,err,ok=calculate()
 requirementsLabel.Text=string.format('NEED: Wood %d | Metal %d | Titanium %d\nGlass %d | Seat %d | Total: %d',need.Wood,need.Metal,need.Titanium,need.Glass,need.Seat,#blueprints[names[idx]])
 if not have then
  inventoryLabel.Text='INVENTORY: UNKNOWN\n'..tostring(err)
  shortageLabel.Text='BUILD disabled: inventory cannot be verified. Check F9.'
 else
  inventoryLabel.Text=string.format('YOU HAVE: Wood %s | Metal %s | Titanium %s\nGlass %s | Seat %s',tostring(have.Wood or '?'),tostring(have.Metal or '?'),tostring(have.Titanium or '?'),tostring(have.Glass or '?'),tostring(have.Seat or '?'))
  local lines={}
  for _,kind in ipairs(kinds) do if (missing[kind] or 0)>0 then table.insert(lines,kind..' - '..missing[kind]..' missing') end end
  shortageLabel.Text=ok and 'READY! All materials accounted for.' or ('MISSING:\n'..table.concat(lines,'\n'))
 end
 inventoryReady=(ok==true)
 if buildBtn then
  buildBtn.Text=building and 'BUILDING... (CANCEL BELOW)' or (inventoryReady and 'BUILD: '..names[idx] or 'BUILD: NEED MATERIALS')
  buildBtn.BackgroundColor3=(inventoryReady and not building) and Color3.fromRGB(28,142,78) or Color3.fromRGB(69,77,94)
  buildBtn.AutoButtonColor=inventoryReady and not building
 end
end
metalModeButton=button(scroll,'SCHEME METAL: TITANIUM BLOCK',77,function()
 if building then return end
 metalIsTitanium=not metalIsTitanium
 metalModeButton.Text='SCHEME METAL: '..(metalIsTitanium and 'TITANIUM BLOCK' or 'METAL BLOCK')
 previewClear()
 refreshBuilder()
end)
choice.MouseButton1Click:Connect(function()
 if building then return end
 idx=idx%#names+1
 choice.Text='SCHEME: '..names[idx]
 progressLabel.Text=''
 refreshBuilder()
end)
local function makePreview(name)
 previewClear()
 local r=root()
 if not r then progressLabel.Text='Character not spawned.';return end
 previewFolder=Instance.new('Folder');previewFolder.Name='KubiHubPreview';previewFolder.Parent=workspace
 local base=r.CFrame*CFrame.new(0,-1,-34)
 local colors={Wood=Color3.fromRGB(180,125,72),Metal=Color3.fromRGB(120,125,125),Titanium=Color3.fromRGB(100,160,210),Glass=Color3.fromRGB(45,225,210),Seat=Color3.fromRGB(255,190,50)}
 for _,p in ipairs(blueprints[name]) do
  local part=Instance.new('Part')
  local kind=(p.kind=='Metal' and metalIsTitanium) and 'Titanium' or p.kind
  part.Name='GHOST_'..kind
  part.Size=Vector3.new(2,2,2)
  part.CFrame=base*CFrame.new(p.x*2,p.y*2,p.z*2)
  part.Anchored=true;part.CanCollide=false;part.CanTouch=false;pcall(function()part.CanQuery=false end)
  part.Transparency=.65;part.Material=Enum.Material.Neon;part.Color=colors[kind]
  part.Parent=previewFolder
 end
 progressLabel.Text='Preview only: '..#blueprints[name]..' ghost blocks'
end

-- BABFT build tool uses a RemoteFunction named RF. When it is missing,
-- never claim a build succeeded and never create fake server blocks.
local function findZone()
 for _,zone in ipairs(workspace:GetChildren()) do
  local teamValue=zone:FindFirstChild('TeamColor')
  if zone:IsA('BasePart') and teamValue and teamValue:IsA('BrickColorValue')
     and teamValue.Value==player.TeamColor then return zone end
 end
 -- Other versions can store TeamColor as a different ValueBase.
 for _,zone in ipairs(workspace:GetChildren()) do
  local v=zone:FindFirstChild('TeamColor')
  if zone:IsA('BasePart') and v then
   local success,result=pcall(function()return v.Value==player.TeamColor end)
   if success and result then return zone end
  end
 end
 return nil
end
local function findBuildingTool()
 local character=player.Character
 if not character then return nil,'Character not found' end
 local tool=character:FindFirstChild('BuildingTool')
 if not tool then
  local backpack=player:FindFirstChildOfClass('Backpack')
  tool=backpack and backpack:FindFirstChild('BuildingTool')
  local hum=character:FindFirstChildOfClass('Humanoid')
  if tool and hum then hum:EquipTool(tool);task.wait(.2) end
 end
 if not tool then return nil,'BuildingTool not found (equip it first)' end
 local rf=tool:FindFirstChild('RF')
 if not rf or not rf:IsA('RemoteFunction') then return nil,'BuildingTool.RF not available' end
 return rf,nil
end
local function blockName(kind)
 return ({Wood='WoodBlock',Metal='MetalBlock',Titanium='TitaniumBlock',Glass='GlassBlock',Seat='Seat'})[kind]
end
local function existingBlockCount()
 local blocks=workspace:FindFirstChild('Blocks')
 local own=blocks and blocks:FindFirstChild(player.Name)
 return own and #own:GetChildren() or nil
end
local function buildSelected()
 if building then return end
 local need,have,missing,err,ok=calculate()
 if not ok then
  progressLabel.Text=err or 'Not enough inventory blocks.'
  refreshBuilder()
  return
 end
 local zone=findZone()
 if not zone then progressLabel.Text='Your build zone not found.';return end
 local rf,rfErr=findBuildingTool()
 if not rf then progressLabel.Text=rfErr;return end
 farming=false;stage=0;updateToggle()
 previewClear()
 local blueprint=blueprints[names[idx]]
 local selectedName=names[idx]
 building=true;buildToken=buildToken+1
 local myToken=buildToken
 refreshBuilder()
 local before=existingBlockCount()
 local maxZ=0
 for _,p in ipairs(blueprint) do maxZ=math.max(maxZ,p.z) end
 local placedRequests,failed=0,0
 -- Offset relative to the player's build area. Server may reject placements
 -- that overlap, exceed the team's plot or reference an unavailable item.
 task.spawn(function()
  local buildOK, buildErr=pcall(function()
  for i,p in ipairs(blueprint) do
   if not alive or buildToken~=myToken then break end
   local material=(p.kind=='Metal' and metalIsTitanium) and 'Titanium' or p.kind
   local name=blockName(material)
   local value=player:FindFirstChild('Data')
   value=value and value:FindFirstChild(name)
   if not value or not (value:IsA('IntValue') or value:IsA('NumberValue')) then
    failed=failed+1
   else
    local pos=zone.CFrame*CFrame.new(
      p.x*2,zone.Size.Y/2+3+p.y*2,(p.z-maxZ/2)*2
    )
    -- This is the BABFT RF signature (may change with game updates).
    local localCFrame=zone.CFrame:ToObjectSpace(pos)
    local callOk,returnValue=pcall(function()
     return rf:InvokeServer(name,value.Value,zone,localCFrame,true,pos,false)
    end)
    if callOk and returnValue~=false then
     placedRequests=placedRequests+1
    else
     failed=failed+1
    end
   end
   progressLabel.Text=string.format('%s: %d/%d requests | errors %d',selectedName,i,#blueprint,failed)
   task.wait(.15)
  end
  if buildToken==myToken and alive then
   task.wait(.5)
   local after=existingBlockCount()
   if before and after then
    progressLabel.Text=string.format('Requests %d/%d | plot blocks: +%d | errors %d',placedRequests,#blueprint,after-before,failed)
   else
    progressLabel.Text=string.format('Sent %d/%d | cannot verify server blocks',placedRequests,#blueprint)
   end
  end
  end)
  if not buildOK then progressLabel.Text='Build error: '..tostring(buildErr);warn(buildErr) end
  if buildToken==myToken then building=false;pcall(refreshBuilder) end
 end)
end
buildBtn=button(scroll,'BUILD: WAITING FOR INVENTORY',446,function()
 buildSelected()
end)
button(scroll,'PREVIEW 3D',488,function()
 local ok,err=pcall(makePreview,names[idx])
 if not ok then progressLabel.Text='Preview failed: '..tostring(err);warn(err) end
end)
button(scroll,'CLEAR PREVIEW',530,function()previewClear();progressLabel.Text='Preview cleared' end)
button(scroll,'CANCEL BUILD',572,function()
 buildToken=buildToken+1;building=false;progressLabel.Text='Build canceled';refreshBuilder()
end)
local unload=button(scroll,'UNLOAD HUB',563,function()
 if _G.KubiHubV3Stop then _G.KubiHubV3Stop() end
end)
unload.BackgroundColor3=Color3.fromRGB(182,62,75)
text(scroll,'BUILD uses game BuildingTool (not guaranteed). Check your plot.',660,45,12)
local initOK, initError=pcall(refreshBuilder)
if not initOK then
 warn('[KUBI HUB V3.6] Builder init: '..tostring(initError))
 progressLabel.Text='Builder waiting - check F9 console'
end

-- PLAYER CONTROLS: movement is client-side and can be overridden by server.
local playerPage=pages.PLAYER
local UserInputService=game:GetService('UserInputService')
local RunService=game:GetService('RunService')
local vuOK, VirtualUser = pcall(function() return game:GetService('VirtualUser') end)
if not vuOK then VirtualUser = nil end
local connections={}
local flyEnabled,flySpeed= false,50
local walkSpeed=16
local antiAfkEnabled=false
local flyBody,flyGyro
local flyConn
local normalSpeed=16
local function stopFly()
 if flyConn then flyConn:Disconnect();flyConn=nil end
 if flyBody then flyBody:Destroy();flyBody=nil end
 if flyGyro then flyGyro:Destroy();flyGyro=nil end
 local char=player.Character;local h=char and char:FindFirstChildOfClass('Humanoid')
 if h then h.PlatformStand=false end
end
local function applyWalk()
 local char=player.Character;local h=char and char:FindFirstChildOfClass('Humanoid')
 if h then h.WalkSpeed=walkSpeed end
end
local flyToggle
local function startFly()
 stopFly()
 if not flyEnabled then return end
 local r=root();local h=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
 if not r or not h then flyEnabled=false;return end
 flyBody=Instance.new('BodyVelocity');flyBody.MaxForce=Vector3.new(1e6,1e6,1e6);flyBody.Velocity=Vector3.zero;flyBody.Parent=r
 flyGyro=Instance.new('BodyGyro');flyGyro.MaxTorque=Vector3.new(1e6,1e6,1e6);flyGyro.P=6000;flyGyro.Parent=r
 h.PlatformStand=true
 flyConn=RunService.RenderStepped:Connect(function()
  if not alive or not flyEnabled or not r.Parent then return end
  local camera=workspace.CurrentCamera
  if not camera then return end
  local move=Vector3.zero
  if UserInputService:IsKeyDown(Enum.KeyCode.W) then move=move+camera.CFrame.LookVector end
  if UserInputService:IsKeyDown(Enum.KeyCode.S) then move=move-camera.CFrame.LookVector end
  if UserInputService:IsKeyDown(Enum.KeyCode.D) then move=move+camera.CFrame.RightVector end
  if UserInputService:IsKeyDown(Enum.KeyCode.A) then move=move-camera.CFrame.RightVector end
  if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
  if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move=move-Vector3.new(0,1,0) end
  flyBody.Velocity=move.Magnitude>.01 and move.Unit*flySpeed or Vector3.zero
  flyGyro.CFrame=camera.CFrame
 end)
end
local walkInfo=text(playerPage,'WalkSpeed: 16',5,27,15)
button(playerPage,'WALK SPEED + 10',37,function()walkSpeed=math.min(150,walkSpeed+10);applyWalk();walkInfo.Text='WalkSpeed: '..walkSpeed end)
button(playerPage,'WALK SPEED - 10',79,function()walkSpeed=math.max(16,walkSpeed-10);applyWalk();walkInfo.Text='WalkSpeed: '..walkSpeed end)
local flyInfo=text(playerPage,'FlySpeed: 50 | WASD + Space + CTRL',122,35,14)
local flyButton
flyButton=button(playerPage,'FLY: OFF',164,function()
 flyEnabled=not flyEnabled
 if flyEnabled then startFly() else stopFly() end
 flyButton.Text='FLY: '..(flyEnabled and 'ON' or 'OFF')
end)
button(playerPage,'FLY SPEED + 20',206,function()flySpeed=math.min(250,flySpeed+20);flyInfo.Text='FlySpeed: '..flySpeed end)
button(playerPage,'FLY SPEED - 20',248,function()flySpeed=math.max(10,flySpeed-20);flyInfo.Text='FlySpeed: '..flySpeed end)
local afkButton
local idleSupported=false
if VirtualUser then
 local okIdle, idleConnection=pcall(function()
  return player.Idled:Connect(function()
   if antiAfkEnabled and alive then
    pcall(function()
     VirtualUser:CaptureController()
     VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
   end
  end)
 end)
 if okIdle and idleConnection then
  idleSupported=true
  table.insert(connections,idleConnection)
 end
end
afkButton=button(playerPage,idleSupported and 'ANTI AFK: OFF' or 'ANTI AFK: UNAVAILABLE',290,function()
 if not idleSupported then return end
 antiAfkEnabled=not antiAfkEnabled
 afkButton.Text='ANTI AFK: '..(antiAfkEnabled and 'ON' or 'OFF')
end)
local charConn=player.CharacterAdded:Connect(function()
 task.wait(.8)
 if not alive then return end
 applyWalk()
 if flyEnabled then startFly() end
end)
table.insert(connections,charConn)

local function farmOnce()
 attempts=attempts+1;local stages=workspace:FindFirstChild('BoatStages')
 stages=stages and stages:FindFirstChild('NormalStages')
 if not stages then status('Stages not found');farming=false;updateToggle();return end
 for i=1,10 do
  if not farming or not alive then return end
  stage=i;status('Traversing')
  local s=stages:FindFirstChild('CaveStage'..i)
  local part=s and s:FindFirstChild('DarknessPart')
  if not part or not part:IsA('BasePart') then status('Stage missing: '..i);farming=false;updateToggle();return end
  local floor=Instance.new('Part');floor.Anchored=true;floor.CanCollide=true;floor.Transparency=1;floor.Size=Vector3.new(6,1,6);floor.CFrame=part.CFrame*CFrame.new(0,-4,0);floor.Parent=workspace;activeFloors[floor]=true
  local moved=teleport(part.CFrame)
  if moved then pause(delay()) end
  floor:Destroy();activeFloors[floor]=nil
  if not moved then status('Character missing');farming=false;updateToggle();return end
 end
 local ending=stages:FindFirstChild('TheEnd');local chest=ending and ending:FindFirstChild('GoldenChest');local trigger=chest and chest:FindFirstChild('Trigger')
 if not trigger or not trigger:IsA('BasePart') then status('Chest trigger missing');farming=false;updateToggle();return end
 local oldChar=player.Character
 for i=1,10 do
  if not farming or not alive or player.Character~=oldChar then break end
  if not teleport(trigger.CFrame) then break end
  if not pause(1) then break end
 end
 local start=os.clock()
 while farming and alive and player.Character==oldChar and os.clock()-start<30 do task.wait(.2) end
 if farming and player.Character~=oldChar then rounds=rounds+1;stage=0;status('Respawn detected');pause(4)
 else farming=false;status('Respawn timeout / stopped');updateToggle() end
end
local tasks={}
tasks[#tasks+1]=task.spawn(function()
 while alive do
  if pages.BUILDER.Visible and not building then pcall(refreshBuilder) end
  task.wait(1)
 end
end)
tasks[#tasks+1]=task.spawn(function()
 while alive do
  if farming then
   local ok,err=pcall(farmOnce)
   if not ok then warn('[KubiHub V3]',err);farming=false;status('Error');updateToggle() end
   if not autoRestart then farming=false;updateToggle();status('Auto restart OFF') end
  end
  task.wait(.25)
 end
end)
tasks[#tasks+1]=task.spawn(function()
 while alive do
  local elapsed=math.max(1,os.clock()-started)
  statLabel.Text=string.format('Rounds (respawn): %d\nAttempts: %d\nSession: %02d:%02d:%02d\nEstimated rounds/hour: %.1f\nStage: %d/10',rounds,attempts,math.floor(elapsed/3600),math.floor(elapsed/60)%60,math.floor(elapsed)%60,rounds*3600/elapsed,stage)
  task.wait(1)
 end
end)
_G.KubiHubV3Stop=function()
 alive=false;farming=false;buildToken=buildToken+1;building=false;flyEnabled=false
 stopFly()
 for _,conn in ipairs(connections) do pcall(function()conn:Disconnect()end) end
 walkSpeed=normalSpeed;applyWalk()
 previewClear()
 for floor in pairs(activeFloors) do pcall(function()floor:Destroy()end) end
 for floor in pairs(activeFloors) do activeFloors[floor]=nil end
 if gui then gui:Destroy() end
 _G.KubiHubV3Stop=nil
end
close.MouseButton1Click:Connect(_G.KubiHubV3Stop)
print('[KUBI HUB V3.6] Loaded: auto inventory, 12 blueprints, BUILD, FARM, FLY, ANTI AFK')

end, function(err)
 local errorText=tostring(err)
 local okTrace,trace=pcall(function()
  return debug and debug.traceback and debug.traceback(errorText,2)
 end)
 if okTrace and trace then return trace end
 return errorText
end)
if BOOT_OK then
 if bootScreen then bootScreen:Destroy() end
else
 warn('[KUBI HUB V3.6] STARTUP ERROR: '..tostring(BOOT_ERR))
 pcall(function()
  if _G.KubiHubBootGui then
   _G.KubiHubBootGui:Destroy()
   _G.KubiHubBootGui = nil
  end
 end)
 bootLabel.Text='KUBI HUB STARTUP ERROR\n\n'..string.sub(tostring(BOOT_ERR),1,260)..'\n\nPress F9 to see the full error.'
 bootLabel.TextSize=13
 bootBox.Size=UDim2.fromOffset(400,235)
 bootBox.Position=UDim2.new(.5,-200,.5,-117)
end
