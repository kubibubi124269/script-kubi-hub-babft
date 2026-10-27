-- KUBI HUB V4.0 | one stable loader, no external Lua dependencies
-- Geometry is kept independent of Roblox so its material counts and placement can be checked offline.
local Shape = {}
function Shape.number(value, fallback, low, high, integer)
 local n=tonumber(value)
 if not n or n~=n or n==math.huge or n==-math.huge then n=fallback end
 n=math.max(low,math.min(high,n))
 return integer and math.floor(n+0.5) or n
end
function Shape.add(out,kind,x,y,z,extra)
 local p={kind=kind,x=x,y=y,z=z}
 for k,v in pairs(extra or {}) do p[k]=v end
 out[#out+1]=p
 return p
end
function Shape.circle(o)
 local out={}
 local radius=Shape.number(o.radius,12,2,100)
 local segments=Shape.number(o.segments,40,8,240,true)
 local layers=Shape.number(o.layers,1,1,40,true)
 local thick=math.min(Shape.number(o.thickness,1,1,12,true),math.max(1,math.floor((radius-1)/2)+1))
 local step=Shape.number(o.layerGap,2,0.5,10)
 local arc=Shape.number(o.arc,360,15,360)
 local axis=o.axis or 'XZ'
 local function point(u,v,w)
  if axis=='XY' then return u,v,w elseif axis=='YZ' then return w,v,u end
  return u,w,v
 end
 local function emit(u,v,w,angle)
  local x,y,z=point(u,v,w)
  return Shape.add(out,o.kind or 'WoodBlock',x,y,z,{ry=axis=='XZ' and -angle or 0})
 end
 if o.filled then
  -- A disk uses one lattice cell per block; its centre is never duplicated.
  for layer=0,layers-1 do
   for u=-math.floor(radius/2),math.floor(radius/2) do
    for v=-math.floor(radius/2),math.floor(radius/2) do
     local x,y=u*2,v*2
     local a=(math.deg(math.atan2 and math.atan2(y,x) or math.atan(y,x))+360)%360
     if x*x+y*y<=radius*radius+0.000001 and (arc==360 or a<=arc) then emit(x,y,layer*step,0) end
    end
   end
  end
 else
  for layer=0,layers-1 do
   for ring=0,thick-1 do
    local r=math.max(1,radius-ring*2)
    -- A closed ring omits the endpoint; an open arc includes both ends.
    local count=arc==360 and segments or segments+1
    for i=0,count-1 do
     local angle=arc*i/segments
     local rad=math.rad(angle)
     emit(math.cos(rad)*r,math.sin(rad)*r,layer*step,angle)
    end
   end
  end
 end
 return out
end
function Shape.sphere(o)
 local out={};local r=Shape.number(o.radius,10,2,28);local n=math.ceil(r/2)
 for x=-n,n do for y=-n,n do for z=-n,n do
  local d=math.sqrt((x*2)^2+(y*2)^2+(z*2)^2)
  if d<=r and (o.filled or d>=r-2) and (not o.dome or y>=0) then Shape.add(out,o.kind or 'WoodBlock',x*2,y*2,z*2) end
 end end end
 return out
end
function Shape.wall(o)
 local out={};local width=Shape.number(o.width,12,1,80,true);local height=Shape.number(o.height,6,1,50,true)
 for x=0,width-1 do for y=0,height-1 do
  if not o.checker or (x+y)%2==0 then Shape.add(out,o.kind or 'WoodBlock',(x-(width-1)/2)*2,y*2,0) end
 end end
 return out
end
function Shape.spiral(o)
 local out={};local r=Shape.number(o.radius,10,2,50);local turns=Shape.number(o.turns,3,1,12,true);local steps=Shape.number(o.segments,32,8,100,true)
 for i=0,turns*steps do local a=i/steps*math.pi*2
  Shape.add(out,o.kind or 'WoodBlock',math.cos(a)*r,i/steps*4,math.sin(a)*r,{ry=-math.deg(a)})
 end
 return out
end
function Shape.bomb(count)
 local out={};count=Shape.number(count,3000,1,3000,true)
 Shape.add(out,'TNT',0,0,0,{group='charge'})
 Shape.add(out,'Seat',0,0,2,{group='seat'})
 for i=1,count do Shape.add(out,'WoodBlock',0,2,0,{group='payload'}) end
 return out
end
function Shape.worm(o)
 local out={};local n=Shape.number(o.segments,9,4,14,true)
 local red={0.82,0.035,0.06};local dark={0.28,0.015,0.025};local white={0.95,0.95,0.88}
 -- A five-petal monster built from ordinary blocks. Animation below is a local preview.
 for section=0,n-1 do
  local z=section*6;local r=section==n-1 and 3 or 4
  for i=0,11 do local a=i*math.pi/6
   Shape.add(out,'PlasticBlock',math.cos(a)*r,math.sin(a)*r+6,z,{color=section%2==0 and red or dark,group='body',section=section})
  end
 end
 for i=0,15 do local a=i*math.pi/8
  Shape.add(out,'PlasticBlock',math.cos(a)*4,math.sin(a)*4+6,-2,{color=dark,group='head'})
  if i%2==0 then Shape.add(out,'PlasticBlock',math.cos(a)*3,math.sin(a)*3+6,-3,{color=white,group='teeth'}) end
 end
 for petal=0,4 do
  local a=petal*math.pi*2/5+math.pi/2
  for row=0,3 do
   local r=5+row*1.7;local half=row==3 and 0 or 1
   for side=-half,half do
    local x=math.cos(a)*r-math.sin(a)*side*1.5
    local y=math.sin(a)*r+math.cos(a)*side*1.5+6
    Shape.add(out,'PlasticBlock',x,y,-3-row,{color=red,group='petal',petal=petal})
    if math.abs(side)==half and row<3 then Shape.add(out,'PlasticBlock',x*0.88,(y-6)*0.88+6,-4-row,{color=white,group='petal',petal=petal}) end
   end
  end
 end
 Shape.add(out,'Seat',0,9,5,{group='seat'})
 return out
end
function Shape.count(parts)
 local counts={};for _,p in ipairs(parts) do counts[p.kind]=(counts[p.kind] or 0)+1 end;return counts
end
function Shape.boat(o)
 local out={};local half=Shape.number(o.halfWidth,5,3,8,true);local length=Shape.number(o.length,26,18,40,true);local kind=o.kind or 'WoodBlock'
 for z=0,length-1 do
  local width=math.min(half,z+1,length-z+1)
  for x=-width,width do
   Shape.add(out,kind,x*2,0,z*2)
   if math.abs(x)==width or z==0 or z==length-1 then for y=1,3 do Shape.add(out,kind,x*2,y*2,z*2) end end
  end
 end
 for _,z in ipairs({8,16,24,32}) do if z<length*2-4 then for x=-half+1,half-1 do Shape.add(out,kind,x*2,2,z) end;Shape.add(out,'Seat',0,4,z) end end
 for x=-half+1,half-1 do Shape.add(out,'GlassBlock',x*2,6,6) end
 Shape.add(out,'CarSeat',0,4,10)
 return out
end
function Shape.fortress(o)
 local out={};local half=Shape.number(o.halfWidth,10,7,14,true);local depth=Shape.number(o.depth,16,12,24,true);local height=Shape.number(o.height,7,5,12,true)
 for x=-half,half do for z=-depth,depth do
  Shape.add(out,'WoodBlock',x*2,0,z*2)
  if math.abs(x)==half or math.abs(z)==depth then
   for y=0,height do
    local doorway=z==-depth and math.abs(x)<=2 and y<=3
    local window=y==4 and (x%4==0 or z%4==0)
    if not doorway and not window and (y<height or (x+z)%2==0) then Shape.add(out,'StoneBlock',x*2,y*2+2,z*2) end
   end
  end
 end end
 for _,cx in ipairs({-half,half}) do for _,cz in ipairs({-depth,depth}) do for y=height+1,height+5 do
  for x=-1,1 do for z=-1,1 do if math.abs(x)==1 or math.abs(z)==1 then Shape.add(out,'StoneBlock',(cx+x)*2,y*2+2,(cz+z)*2) end end end
 end end end
 Shape.add(out,'Seat',0,2,0)
 return out
end
function Shape.bridge(o)
 local out={};local length=Shape.number(o.length,38,20,52,true)
 for z=0,length-1 do
  for x=-3,3 do Shape.add(out,'WoodBlock',x*2,8,z*2) end
  for _,x in ipairs({-4,4}) do Shape.add(out,'MetalBlock',x*2,10,z*2);if z%6==0 then for y=0,4 do Shape.add(out,'StoneBlock',x*2,y*2,z*2) end;for y=6,9 do Shape.add(out,'MetalBlock',x*2,y*2,z*2) end end end
 end
 return out
end
function Shape.tank()
 local out={}
 for z=0,15 do for x=-5,5 do Shape.add(out,'MetalBlock',x*2,3,z*2);if math.abs(x)==5 or z==0 or z==15 then for y=1,2 do Shape.add(out,'MetalBlock',x*2,3+y*2,z*2) end end end end
 for z=5,10 do for x=-3,3 do if math.abs(x)==3 or z==5 or z==10 then for y=4,6 do Shape.add(out,'MetalBlock',x*2,y*2,z*2) end end;Shape.add(out,'MetalBlock',x*2,14,z*2) end end
 for _,x in ipairs({-13,13}) do for _,z in ipairs({4,12,20,28}) do Shape.add(out,z==4 and 'FrontWheel' or 'BackWheel',x,0,z,{rz=x<0 and 90 or -90}) end end
 Shape.add(out,'CarSeat',0,5,16);Shape.add(out,'Cannon',0,10,8)
 return out
end
function Shape.aircraft(o)
 local out={};local kind=o.kind or 'MetalBlock'
 for z=0,21 do for x=-2,2 do
  if z>3 or math.abs(x)<=math.floor(z/2) then Shape.add(out,kind,x*2,0,z*2);if math.abs(x)==2 and z>4 then Shape.add(out,kind,x*2,2,z*2) end end
 end end
 for side=-1,1,2 do for x=3,15 do for z=10,14 do
  if z>=10+math.floor((x-3)/4) then Shape.add(out,kind,x*2*side,0,z*2,{ry=side*12}) end
 end end end
 for z=4,8 do for x=-1,1 do Shape.add(out,'GlassBlock',x*2,4,z*2) end end
 for z=17,21 do for y=1,5 do if y<6-(21-z) then Shape.add(out,kind,0,y*2,z*2) end end end
 for _,x in ipairs({-6,6}) do Shape.add(out,'Thruster',x,0,44,{ry=180}) end
 Shape.add(out,'PilotSeat',0,2,14)
 return out
end
function Shape.submarine()
 local out={};local r=7
 for z=0,23 do for i=0,15 do local a=i*math.pi/8;Shape.add(out,'MetalBlock',math.cos(a)*r,math.sin(a)*r+8,z*2) end end
 for _,z in ipairs({0,46}) do for x=-3,3 do for y=-3,3 do if x*x+y*y<=12 then Shape.add(out,z==0 and 'GlassBlock' or 'MetalBlock',x*2,y*2+8,z) end end end end
 for z=2,21 do for x=-2,2 do Shape.add(out,'WoodBlock',x*2,4,z*2) end end
 for y=8,11 do for x=-1,1 do for z=10,12 do if math.abs(x)==1 or z==10 or z==12 then Shape.add(out,'MetalBlock',x*2,y*2,z*2) end end end end
 Shape.add(out,'PilotSeat',0,6,8);Shape.add(out,'Seat',0,6,18);Shape.add(out,'Thruster',0,8,48,{ry=180})
 return out
end
function Shape.robot()
 local out={}
 for _,side in ipairs({-1,1}) do
  for x=1,4 do for z=-2,3 do Shape.add(out,'MetalBlock',x*side*2,0,z*2) end end
  for y=1,7 do for z=-1,1 do Shape.add(out,'MetalBlock',side*5,y*2,z*2) end end
  for y=8,13 do for z=-1,1 do Shape.add(out,'MetalBlock',side*12,y*2,z*2) end end
 end
 for y=8,13 do for x=-4,4 do for z=-2,2 do if math.abs(x)==4 or math.abs(z)==2 or y==8 or y==13 then Shape.add(out,'MetalBlock',x*2,y*2,z*2) end end end end
 for y=14,18 do for x=-3,3 do for z=-2,2 do if math.abs(x)==3 or math.abs(z)==2 or y==18 then Shape.add(out,z==-2 and y>=15 and 'GlassBlock' or 'MetalBlock',x*2,y*2,z*2) end end end end
 Shape.add(out,'Seat',0,18,0)
 return out
end
function Shape.dragon()
 local out={};local red={.6,.055,.07};local dark={.15,.025,.035};local white={.95,.9,.76}
 for z=0,25 do local r=z<19 and 4 or math.max(1,4-(z-19)*.45)
  for i=0,9 do local a=i*math.pi/5;Shape.add(out,'PlasticBlock',math.cos(a)*r,math.sin(a)*r+8,z*2,{color=z%3==0 and dark or red}) end
 end
 for _,side in ipairs({-1,1}) do
  for x=3,16 do for z=8,19 do if z>=8+math.floor(x*.35) and z<=19-math.floor(x*.2) then Shape.add(out,'PlasticBlock',x*2*side,12-math.floor(x/4),z*2,{color=(z+x)%4==0 and dark or red}) end end end
  for _,z in ipairs({10,34}) do for y=0,3 do Shape.add(out,'PlasticBlock',side*5,y*2,z,{color=dark}) end;for x=2,5 do Shape.add(out,'PlasticBlock',side*x*2,0,z-2,{color=dark}) end end
 end
 for x=-2,2 do for y=2,5 do Shape.add(out,'PlasticBlock',x*2,y*2,-4,{color=y==2 and white or red}) end end
 for _,x in ipairs({-3,3}) do Shape.add(out,'GlassBlock',x,10,-6,{color={1,.7,.02}}) end
 for x=-2,2 do if x%2==0 then Shape.add(out,'PlasticBlock',x*2,5,-6,{color=white}) end end
 Shape.add(out,'Seat',0,14,18)
 return out
end

if _G.KUBI_HUB_GEOMETRY_TEST then return Shape end

local legacy={}
local function add(name) legacy[name]={} end
local materialMap={Wood='WoodBlock',Metal='MetalBlock',Titanium='TitaniumBlock',Glass='GlassBlock',Seat='Seat'}
local function put(name,x,y,z,kind) Shape.add(legacy[name],materialMap[kind or 'Wood'],x*2,y*2,z*2) end
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


-- Original compact templates are retained alongside the new generators.
legacy.WORM=Shape.worm({segments=9})
legacy.SPEEDBOAT=Shape.boat({halfWidth=5,length=28})
legacy.RAFT=Shape.boat({halfWidth=4,length=22})
legacy.FORTRESS=Shape.fortress({halfWidth=10,depth=16,height=7})
legacy.BRIDGE=Shape.bridge({length=38})
legacy['MINI TANK']=Shape.tank()
legacy.SPACESHIP=Shape.aircraft({kind='MetalBlock'})
legacy.JET=Shape.aircraft({kind='MetalBlock'})
legacy.SUBMARINE=Shape.submarine()
legacy.ROBOT=Shape.robot()
legacy.DRAGON=Shape.dragon()
legacy.HOVERCRAFT=Shape.boat({halfWidth=6,length=24,kind='MetalBlock'})
Shape.add(legacy.HOVERCRAFT,'Thruster',-7,2,50,{ry=180})
Shape.add(legacy.HOVERCRAFT,'Thruster',7,2,50,{ry=180})
legacy.PORTAL=Shape.circle({radius=12,segments=40,layers=2,axis='XY',kind='MetalBlock'})
legacy.UFO=Shape.circle({radius=16,segments=48,layers=2,filled=true,kind='MetalBlock'})
Shape.add(legacy.UFO,'PilotSeat',0,4,0)
for _,x in ipairs({-10,10}) do Shape.add(legacy.UFO,'Thruster',x,2,10,{ry=180}) end
legacy.DOME=Shape.sphere({radius=10,dome=true,kind='GlassBlock'})
legacy.SPIRAL=Shape.spiral({radius=8,turns=3,segments=28,kind='WoodBlock'})
legacy.TOWER=Shape.circle({radius=6,segments=20,layers=12,kind='StoneBlock'})
legacy.FLOOR={}
for x=-5,5 do for z=-5,5 do Shape.add(legacy.FLOOR,'WoodBlock',x*2,0,z*2) end end
legacy.STAIRS={}
for i=0,15 do for x=-1,1 do Shape.add(legacy.STAIRS,'WoodBlock',x*2,i*2,i*2) end end
legacy.PYRAMID={}
for y=0,7 do local r=7-y;for x=-r,r do for z=-r,r do if math.abs(x)==r or math.abs(z)==r then Shape.add(legacy.PYRAMID,'StoneBlock',x*2,y*2,z*2) end end end end
legacy.RAINBOW_GATE={}
for i=0,30 do local a=i*math.pi/30;Shape.add(legacy.RAINBOW_GATE,'PlasticBlock',math.cos(a)*14,math.sin(a)*14,0,{color={math.max(0,math.sin(i*.18)),math.max(0,math.sin(i*.18+2)),math.max(0,math.sin(i*.18+4))}}) end
legacy.TNT_STACK=Shape.bomb(3000)

local AssetIndex={WORM_FILE={file="worm-red.json",title="Czerwony robak • plik z mechaniką",count=2830,need=4184},SHREDDER={file="shredder.json",title="Working Shredder • plik z mechaniką",count=960,need=973}}
legacy.WORM_FILE={}
legacy.SHREDDER={}
-- KUBI HUB V4.0. No downloaded UI libraries or third-party Lua are executed.
local H={version='4.0',alive=true,connections={},effects={},previewParts={},created={},log={},pending=nil}
local bootOK,bootError=xpcall(function()
 H.Players=game:GetService('Players');H.UIS=game:GetService('UserInputService');H.Run=game:GetService('RunService');H.Http=game:GetService('HttpService');H.Tween=game:GetService('TweenService')
 H.player=H.Players.LocalPlayer;assert(H.player,'Run KUBI HUB on the client')
 H.pg=H.player:WaitForChild('PlayerGui',10);assert(H.pg,'PlayerGui unavailable')
 if type(_G.KubiHubV4Stop)=='function' then pcall(_G.KubiHubV4Stop) end
 if type(_G.KubiHubV3Stop)=='function' then pcall(_G.KubiHubV3Stop) end
 local oldDiagnostic=H.pg:FindFirstChild('KubiHubDiagnostics');if oldDiagnostic then oldDiagnostic:Destroy() end
 H.s={farm=false,autoRestart=true,farmDelay=1.5,safeFarm=false,rounds=0,attempts=0,stage=0,started=os.clock(),stopAfter=0,goldGoal=0,buildDelay=.04,buildPause=false,buildToken=0,building=false,livePreview=false,scheme='WORM',titanium=true,walk=16,jump=50,fly=false,flySpeed=50,antiAfk=false,spin=false,bounce=false,orbit=false,follow=false,orbitRadius=10,targetIndex=1,ghost=false,disco=false,noclip=false,infiniteJump=false,previewMotion=true,circle={radius=12,segments=40,layers=1,thickness=1,layerGap=2,arc=360,axis='XZ',kind='WoodBlock',filled=false,yaw=0},other={radius=10,width=12,height=6,turns=3,segments=32,kind='WoodBlock',filled=false,dome=false},bombCount=3000,theme=1,opacity=.02}
 H.palette={bg=Color3.fromRGB(13,17,29),panel=Color3.fromRGB(21,27,43),card=Color3.fromRGB(28,35,53),input=Color3.fromRGB(14,20,34),text=Color3.fromRGB(233,239,255),muted=Color3.fromRGB(151,166,193),accent=Color3.fromRGB(75,136,255),green=Color3.fromRGB(74,205,155),red=Color3.fromRGB(245,100,119)}
 H.accentItems={};H.assetCache={};H.toggleUpdates={};H.pages={};H.navButtons={};H.savedCharacter={};H.countCallbacks={};H.materials={'WoodBlock','PlasticBlock','MetalBlock','TitaniumBlock','GlassBlock','ConcreteBlock','StoneBlock','MarbleBlock','GoldBlock','IceBlock'}
 function H.connect(signal,callback) local c=signal:Connect(callback);H.connections[#H.connections+1]=c;return c end
 function H.new(class,props,parent) local obj=Instance.new(class);for k,v in pairs(props or {}) do obj[k]=v end;obj.Parent=parent;return obj end
 function H.corner(obj,r) H.new('UICorner',{CornerRadius=UDim.new(0,r or 10)},obj) end
 function H.tone(obj,property) obj[property or 'BackgroundColor3']=H.palette.accent;H.accentItems[#H.accentItems+1]={obj,property or 'BackgroundColor3'} end
 function H.message(message,bad)
  local value=tostring(message);H.log[#H.log+1]=os.date('%H:%M:%S')..'  '..value;if #H.log>40 then table.remove(H.log,1) end
  if H.status then H.status.Text=value;H.status.TextColor3=bad and H.palette.red or H.palette.muted end
  if bad then warn('[KUBI HUB V4] '..value) end
 end
 function H.run(fn) local ok,err=pcall(fn);if not ok then H.message(err,true) end end
 function H.root(p) local ch=(p or H.player).Character;return ch and ch:FindFirstChild('HumanoidRootPart') end
 function H.humanoid() local ch=H.player.Character;return ch and ch:FindFirstChildOfClass('Humanoid') end
 function H.ownFolder() local b=workspace:FindFirstChild('Blocks');return b and b:FindFirstChild(H.player.Name) end
 function H.zone()
  for _,v in ipairs(workspace:GetChildren()) do
   local color=v:FindFirstChild('TeamColor')
   if v:IsA('BasePart') and color then local ok,same=pcall(function()return color.Value==H.player.TeamColor end);if ok and same then return v end end
  end
 end
 function H.inventory(kind)
  local data=H.player:FindFirstChild('Data');if not data then return nil end
  local v=data:FindFirstChild(kind)
  if not v then local alias=kind:gsub('Block$','');v=data:FindFirstChild(alias) end
  if v and (v:IsA('IntValue') or v:IsA('NumberValue')) then return math.max(0,math.floor(v.Value)),v end
 end
 function H.gold()
  for _,folderName in ipairs({'Data','leaderstats'}) do
   local folder=H.player:FindFirstChild(folderName)
   if folder then for _,name in ipairs({'Gold','GoldCount','Coins'}) do local v=folder:FindFirstChild(name);if v and (v:IsA('IntValue') or v:IsA('NumberValue')) then return v.Value end end end
  end
 end
 H.startGold=H.gold()
 function H.readable(kind) return kind:gsub('Block$',''):gsub('CarSeat','Car Seat') end
 function H.summary(parts)
  local counts=Shape.count(parts);local names={};for kind in pairs(counts) do names[#names+1]=kind end;table.sort(names)
  local lines={};local enough=true
  for _,kind in ipairs(names) do local have=H.inventory(kind);if not have or have<counts[kind] then enough=false end
   lines[#lines+1]=string.format('%s: %d / %s',H.readable(kind),counts[kind],have and tostring(have) or '?')
  end
  return table.concat(lines,'   |   '),enough,counts
 end
 function H.teleport(cf) local r=H.root();if not r then H.message('Postać jeszcze się nie pojawiła.',true);return false end;r.CFrame=cf;r.AssemblyLinearVelocity=Vector3.zero;return true end
 function H.defaultOrigin()
  local zone=H.zone();if zone then return zone.CFrame*CFrame.new(0,zone.Size.Y/2+1,0) end
  local r=H.root();return r and CFrame.new(r.Position+Vector3.new(0,-3,-18)) or CFrame.new(0,5,0)
 end
 H.origin=H.defaultOrigin()
 H.gui=H.new('ScreenGui',{Name='KubiHubV4',ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=90},H.pg)
 H.frame=H.new('Frame',{Name='Window',Size=UDim2.fromOffset(760,550),Position=UDim2.new(.5,-380,.5,-275),BackgroundColor3=H.palette.bg,BorderSizePixel=0,Active=true},H.gui);H.corner(H.frame,16)
 H.new('UIStroke',{Color=Color3.fromRGB(58,75,107),Thickness=1},H.frame)
 H.scale=H.new('UIScale',{Scale=1},H.frame)
 H.top=H.new('Frame',{Name='Header',Size=UDim2.new(1,0,0,64),BackgroundColor3=H.palette.panel,BorderSizePixel=0,Active=true},H.frame);H.corner(H.top,16)
 H.new('Frame',{Position=UDim2.fromOffset(0,49),Size=UDim2.new(1,0,0,15),BackgroundColor3=H.palette.panel,BorderSizePixel=0},H.top)
 H.new('TextLabel',{Position=UDim2.fromOffset(19,9),Size=UDim2.fromOffset(420,28),BackgroundTransparency=1,Text='KUBI  HUB',Font=Enum.Font.GothamBold,TextSize=24,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=H.palette.text},H.top)
 H.new('TextLabel',{Position=UDim2.fromOffset(20,38),Size=UDim2.fromOffset(500,17),BackgroundTransparency=1,Text='V4.0  /  BUILD A BOAT FOR TREASURE',Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=H.palette.muted},H.top)
 H.nav=H.new('ScrollingFrame',{Position=UDim2.fromOffset(10,76),Size=UDim2.new(0,140,1,-118),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},H.frame)
 H.new('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},H.nav)
 H.content=H.new('Frame',{Position=UDim2.fromOffset(164,76),Size=UDim2.new(1,-177,1,-118),BackgroundTransparency=1},H.frame)
 H.status=H.new('TextLabel',{Position=UDim2.new(0,18,1,-32),Size=UDim2.new(1,-36,0,23),BackgroundTransparency=1,Text='Gotowy. Prawy Ctrl: pokaż / ukryj.',Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextColor3=H.palette.muted},H.frame)
 function H.label(parent,value,height,muted)
  return H.new('TextLabel',{Size=UDim2.new(1,0,0,height or 32),BackgroundTransparency=1,Text=value,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,Font=Enum.Font.Gotham,TextSize=12,TextColor3=muted and H.palette.muted or H.palette.text},parent)
 end
 function H.button(parent,value,callback,style)
  local b=H.new('TextButton',{Size=UDim2.new(1,0,0,35),BackgroundColor3=style=='danger' and H.palette.red or H.palette.accent,BorderSizePixel=0,Text=value,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=true},parent);H.corner(b,8)
  if style~='danger' then H.tone(b) end
  H.connect(b.Activated,function()H.run(callback)end);return b
 end
 function H.field(parent,title,value,callback,numeric)
  local row=H.new('Frame',{Size=UDim2.new(1,0,0,37),BackgroundTransparency=1},parent)
  H.new('TextLabel',{Size=UDim2.new(.59,-8,1,0),BackgroundTransparency=1,Text=title,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=H.palette.text,Font=Enum.Font.Gotham,TextSize=12},row)
  local box=H.new('TextBox',{Position=UDim2.new(.59,0,0,1),Size=UDim2.new(.41,0,1,-2),BackgroundColor3=H.palette.input,BorderSizePixel=0,Text=tostring(value),PlaceholderText=title,TextColor3=H.palette.text,PlaceholderColor3=H.palette.muted,Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false},row);H.corner(box,7)
  H.connect(box.FocusLost,function()H.run(function()local output=callback(numeric and tonumber(box.Text) or box.Text);if output~=nil then box.Text=tostring(output) end end)end)
  return box
 end
 function H.cycle(parent,title,values,get,set)
  local b
  b=H.button(parent,title..': '..tostring(get()),function()local current=get();local index=1;for i,v in ipairs(values) do if v==current then index=i%#values+1;break end end;set(values[index]);b.Text=title..': '..tostring(get())end)
  return b
 end
 function H.toggle(parent,title,get,set)
  local b
  local function update() b.Text=title..': '..(get() and 'ON' or 'OFF');b.BackgroundColor3=get() and H.palette.green or H.palette.card end
  b=H.button(parent,'',function()set(not get());update()end);H.toggleUpdates[#H.toggleUpdates+1]=update;update();return b,update
 end
 function H.card(page,title,subtitle)
  local box=H.new('Frame',{Size=UDim2.new(1,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=H.palette.card,BorderSizePixel=0},page);H.corner(box,11)
  H.new('UIPadding',{PaddingLeft=UDim.new(0,13),PaddingRight=UDim.new(0,13),PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,12)},box)
  H.new('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},box)
  local heading=H.label(box,title,25);heading.Font=Enum.Font.GothamBold;heading.TextSize=15
  if subtitle then H.label(box,subtitle,43,true) end
  return box
 end
 function H.page(name,title)
  local page=H.new('ScrollingFrame',{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=H.palette.accent,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},H.content)
  H.new('UIListLayout',{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},page);H.pages[name]=page
  local b=H.button(H.nav,title,function()H.showPage(name)end);b.TextSize=11;H.navButtons[name]=b
  return page
 end
 function H.showPage(name)H.currentPage=name;for k,p in pairs(H.pages) do p.Visible=k==name;H.navButtons[k].BackgroundColor3=k==name and H.palette.accent or H.palette.panel end end
 function H.fit()local camera=workspace.CurrentCamera;if not camera then return end;local v=camera.ViewportSize;H.scale.Scale=math.min(1,(v.X-20)/760,(v.Y-20)/550) end
 H.fit()
 H.connect(H.Run.RenderStepped,function()if H.alive then H.fit() end end)
 do
  local dragging,start,position
  H.connect(H.top.InputBegan,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=input;start=input.Position;position=H.frame.Position end end)
  H.connect(H.UIS.InputChanged,function(input)if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input==dragging) then local d=(input.Position-start)/H.scale.Scale;H.frame.Position=UDim2.new(position.X.Scale,position.X.Offset+d.X,position.Y.Scale,position.Y.Offset+d.Y) end end)
  H.connect(H.UIS.InputEnded,function(input)if input==dragging then dragging=nil end end)
 end
 function H.previewClear()if H.previewFolder then H.previewFolder:Destroy();H.previewFolder=nil end;H.previewParts={};H.previewMode=nil end
 function H.preview(parts,origin,moving)
  H.previewClear();H.previewFolder=H.new('Folder',{Name='KubiHubV4Preview'},workspace);H.previewMode=moving and 'worm' or nil;H.previewOrigin=origin
  local seen={};local displayed=0
  for _,p in ipairs(parts) do
   local key=p.kind..string.format(':%.3f:%.3f:%.3f',p.x,p.y,p.z)
   if not seen[key] and displayed<1400 and (p.transparency or 0)<.99 then
    seen[key]=true;displayed=displayed+1
    local color=p.color and Color3.new(p.color[1],p.color[2],p.color[3]) or (p.kind=='TNT' and Color3.fromRGB(235,55,65) or H.palette.accent)
    local q=H.new('Part',{Name=p.kind,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Size=p.size and Vector3.new(p.size[1],p.size[2],p.size[3]) or Vector3.new(2,2,2),Material=Enum.Material.SmoothPlastic,Color=color,Transparency=.35,CFrame=origin*CFrame.new(p.x,p.y,p.z)*CFrame.Angles(math.rad(p.rx or 0),math.rad(p.ry or 0),math.rad(p.rz or 0))},H.previewFolder)
    H.previewParts[#H.previewParts+1]={part=q,data=p}
   end
  end
  H.message(string.format('Podgląd lokalny: %d obiektów; plan budowy: %d bloków.',displayed,#parts))
 end
 function H.tool(name)
  local ch=H.player.Character;local backpack=H.player:FindFirstChildOfClass('Backpack');local tool=ch and ch:FindFirstChild(name) or backpack and backpack:FindFirstChild(name)
  if not tool then return nil,'Brak narzędzia '..name end
  if backpack and tool.Parent==backpack then local hum=H.humanoid();if not hum then return nil,'Brak Humanoid' end;hum:EquipTool(tool);task.wait(.1) end
  return tool
 end
 function H.invoke(remote,args,timeout)
  if H.pending then return false,'Poprzednie żądanie serwera jeszcze trwa.' end
  if not remote or not remote:IsA('RemoteFunction') then return false,'Brak zgodnego narzędzia RF.' end
  local ticket={done=false};H.pending=ticket
  task.spawn(function()ticket.ok,ticket.result=pcall(function()return remote:InvokeServer(table.unpack(args))end);ticket.done=true;if H.pending==ticket then H.pending=nil end end)
  local deadline=os.clock()+(timeout or 7)
  while H.alive and not ticket.done and os.clock()<deadline do task.wait(.01) end
  if not ticket.done then return false,'TIMEOUT: serwer nie potwierdził żądania; kolejka zatrzymana.' end
  if not ticket.ok then return false,tostring(ticket.result) end
  if ticket.result==false then return false,'Serwer odrzucił blok.' end
  return true,ticket.result
 end
 function H.part(model)if not model then return nil end;if model:IsA('BasePart') then return model end;return model:FindFirstChild('PPart') or model:FindFirstChildWhichIsA('BasePart',true) end
 function H.originFor(parts,yaw)
  local minY=math.huge;for _,p in ipairs(parts) do minY=math.min(minY,p.y) end
  return H.origin*CFrame.Angles(0,math.rad(yaw or 0),0)*CFrame.new(0,minY<0 and -minY or 0,0)
 end
 function H.validateBuild(parts,origin)
  if H.s.building or H.pending then return false,'Poczekaj na zakończenie bieżącego żądania.' end
  if #parts==0 or #parts>6000 then return false,'Plan musi zawierać od 1 do 6000 bloków.' end
  local zone=H.zone();if not zone then return false,'Nie znaleziono Twojej działki.' end
  local summary,enough=H.summary(parts);if not enough then return false,'Brakuje materiałów lub nie można odczytać stanu: '..summary end
  local backpack=H.player:FindFirstChildOfClass('Backpack');local ch=H.player.Character
  for _,p in ipairs(parts) do
   local pos=zone.CFrame:PointToObjectSpace((origin*CFrame.new(p.x,p.y,p.z)).Position)
   if math.abs(pos.X)>zone.Size.X/2+1 or math.abs(pos.Z)>zone.Size.Z/2+1 then return false,'Plan wychodzi poza Twoją działkę. Zmień środek lub rozmiar.' end
   for _,toolName in ipairs({p.size and 'ScalingTool' or '',p.color and 'PaintingTool' or ''}) do
    if toolName~='' and not (ch and ch:FindFirstChild(toolName) or backpack and backpack:FindFirstChild(toolName)) then return false,'Ten plan wymaga '..toolName end
   end
  end
  local tool,err=H.tool('BuildingTool');if not tool then return false,err end
  if not tool:FindFirstChild('RF') then return false,'Brak BuildingTool.RF.' end
  return true,zone
 end
 function H.build(parts,origin,title)
  local valid,zone=H.validateBuild(parts,origin);if not valid then H.message(zone,true);return end
  H.s.farm=false;H.s.follow=false;H.s.orbit=false;H.s.building=true;H.s.buildPause=false;H.s.buildToken=H.s.buildToken+1
  local token=H.s.buildToken;H.previewClear();H.lastBuilt={};H.buildStats={sent=0,verified=0,failed=0,total=#parts,title=title}
  task.spawn(function()
   local ok,err=pcall(function()
    local streak=0;local paintQueue={}
    for i,p in ipairs(parts) do
     if not H.alive or token~=H.s.buildToken then break end
     while H.s.buildPause and H.alive and token==H.s.buildToken do task.wait(.1) end
     if not H.alive or token~=H.s.buildToken then break end
     local have=H.inventory(p.kind);if not have or have<1 then error('Zabrakło materiału: '..p.kind) end
     local tool,toolErr=H.tool('BuildingTool');if not tool then error(toolErr) end
     local before={};local folder=H.ownFolder();if folder then for _,m in ipairs(folder:GetChildren()) do before[m]=true end end
     local cf=origin*CFrame.new(p.x,p.y,p.z)*CFrame.Angles(math.rad(p.rx or 0),math.rad(p.ry or 0),math.rad(p.rz or 0))
     local called,result=H.invoke(tool:FindFirstChild('RF'),{p.kind,have,zone,zone.CFrame:ToObjectSpace(cf),true,cf,false})
     if H.pending then error(result) end
     H.buildStats.sent=H.buildStats.sent+1
     local model
     if called and typeof(result)=='Instance' then local own=H.ownFolder();if own and result:IsDescendantOf(own) then model=result end end
     if called and not model then
      local deadline=os.clock()+.65
      repeat folder=H.ownFolder();if folder then for _,m in ipairs(folder:GetChildren()) do if not before[m] and not H.created[m] then local mp=H.part(m);if mp and (mp.Position-cf.Position).Magnitude<5 then model=m;break end end end end
       if not model then task.wait(.04) end
      until model or os.clock()>deadline or not H.alive
     end
     if model then
      H.created[model]=true;H.lastBuilt[#H.lastBuilt+1]=model;H.buildStats.verified=H.buildStats.verified+1;streak=0
      if p.size then local scale,scaleErr=H.tool('ScalingTool');if not scale then error(scaleErr) end;local good,msg=H.invoke(scale:FindFirstChild('RF'),{model,Vector3.new(p.size[1],p.size[2],p.size[3]),cf});if not good then error('Skalowanie: '..tostring(msg)) end end
      if p.color then paintQueue[#paintQueue+1]={model,Color3.new(p.color[1],p.color[2],p.color[3])} end
     else H.buildStats.failed=H.buildStats.failed+1;streak=streak+1;if streak>=3 then error(called and 'Trzy żądania bez potwierdzonego bloku. Budowa zatrzymana.' or tostring(result)) end end
     if H.buildProgress then H.buildProgress.Text=string.format('%s\nŻądania %d/%d • potwierdzone %d • niepotwierdzone %d',title,i,#parts,H.buildStats.verified,H.buildStats.failed) end
     task.wait(H.s.buildDelay)
    end
    H.buildStats.painted=0;H.buildStats.paintUnverified=0
    if H.alive and token==H.s.buildToken then
     for start=1,#paintQueue,32 do
      if not H.alive or token~=H.s.buildToken then break end
      local batch={};for j=start,math.min(#paintQueue,start+31) do if paintQueue[j][1].Parent then batch[#batch+1]=paintQueue[j] end end
      local paint,paintErr=H.tool('PaintingTool');if not paint then error(paintErr) end
      local good,msg=H.invoke(paint:FindFirstChild('RF'),{batch});if not good then error('Malowanie: '..tostring(msg)) end
      task.wait(.08)
      for _,entry in ipairs(batch) do local part=H.part(entry[1]);local color=part and part.Color;local wanted=entry[2]
       if color and math.abs(color.R-wanted.R)<.03 and math.abs(color.G-wanted.G)<.03 and math.abs(color.B-wanted.B)<.03 then H.buildStats.painted=H.buildStats.painted+1 else H.buildStats.paintUnverified=H.buildStats.paintUnverified+1 end
      end
      if H.buildProgress then H.buildProgress.Text=string.format('%s\nPostawione %d/%d • malowanie %d/%d potwierdzone',title,H.buildStats.verified,#parts,H.buildStats.painted,#paintQueue) end
      task.wait(H.s.buildDelay)
     end
    end
   end)
   H.s.building=false;H.s.buildPause=false
   local summary=string.format('%s: %d/%d bloków potwierdzonych.',title,H.buildStats.verified,#parts)
   if (H.buildStats.paintUnverified or 0)>0 then summary=summary..' Kolory niepotwierdzone: '..H.buildStats.paintUnverified end
   if not ok then H.message(tostring(err),true);if H.buildProgress then H.buildProgress.Text=summary..'\n'..tostring(err) end else H.message(token==H.s.buildToken and summary or 'Budowa przerwana. '..summary) end
  end)
 end
 function H.confirmBuild(parts,origin,title)
  if #parts<500 then H.build(parts,origin,title);return end
  if H.modal then H.modal:Destroy() end
  H.modal=H.new('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.18,ZIndex=30},H.frame);H.corner(H.modal,16)
  local box=H.new('Frame',{Position=UDim2.new(.5,-250,.5,-130),Size=UDim2.fromOffset(500,260),BackgroundColor3=H.palette.card,ZIndex=31},H.modal);H.corner(box,12)
  H.new('UIPadding',{PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16),PaddingTop=UDim.new(0,15)},box);H.new('UIListLayout',{Padding=UDim.new(0,8)},box)
  local text=H.label(box,string.format('%s • %d bloków\nSzacowany minimalny czas: %.1f min.\nDuży plan może obniżyć FPS. Wszystkie bloki musisz mieć w ekwipunku.',title,#parts,#parts*H.s.buildDelay/60),95);text.ZIndex=32
  local detail=H.label(box,H.summary(parts),48,true);detail.ZIndex=32
  local yes=H.button(box,'BUDUJ '..#parts..' BLOKÓW',function()H.modal:Destroy();H.modal=nil;H.build(parts,origin,title)end);yes.ZIndex=32
  local no=H.button(box,'Wróć do ustawień',function()H.modal:Destroy();H.modal=nil end,'danger');no.ZIndex=32
 end
 function H.actions(card,get,title,moving)
  H.button(card,'PODGLĄD 3D  •  tylko u Ciebie',function()local parts,origin=get();H.preview(parts,origin,moving)end)
  H.button(card,'BUDUJ NA MOJEJ DZIAŁCE',function()local parts,origin,meta=get();if meta and meta.mechanical then H.message('Ten plik zawiera mechanikę. Dostępny jest podgląd; odtwarzanie połączeń w BABFT wymaga dalszej integracji.',true);return end;H.confirmBuild(parts,origin,title)end)
 end
 function H.decodeAsset(source)
  assert(type(source)=='string' and #source<=2000000,'Limit pliku: 2 MB')
  local marker=source:find('LP_BUILD',1,true);if marker then source=source:sub(marker+8) end
  local document=H.Http:JSONDecode(source);assert(type(document)=='table','Nieprawidłowy JSON')
  local data=document.blocks or document;local out={};local complex=document.mechanical==true
  for kind,rows in pairs(data) do if type(kind)=='string' and type(rows)=='table' then for _,item in ipairs(rows) do
   if type(item)=='table' and type(item.Position)=='table' then
    assert(#out<6000,'Limit podglądu: 6000 bloków');local pos=item.Position;local rot=item.Rotation or {0,0,0}
    for i=1,3 do assert(type(pos[i])=='number' and pos[i]==pos[i] and math.abs(pos[i])<100000,'Nieprawidłowa pozycja');assert(type(rot[i])=='number' and rot[i]==rot[i] and math.abs(rot[i])<100000,'Nieprawidłowy obrót') end
    local extra={rx=rot[1],ry=rot[2],rz=rot[3]}
    if item.Size then for i=1,3 do assert(type(item.Size[i])=='number' and item.Size[i]>0 and item.Size[i]<1000,'Nieprawidłowy rozmiar') end;extra.size=item.Size end
    if item.Color then for i=1,3 do assert(type(item.Color[i])=='number' and item.Color[i]>=0 and item.Color[i]<=1,'Nieprawidłowy kolor') end;extra.color=item.Color end
    if type(item.Transparency)=='number' then extra.transparency=math.max(0,math.min(1,item.Transparency)) end
    Shape.add(out,kind,pos[1],pos[2],pos[3],extra)
    if item.BindTable or item.SecondaryPartPosition or kind=='Servo' or kind=='Piston' then complex=true end
   end
  end end end
  assert(#out>0,'Nie znaleziono bloków w obsługiwanym formacie LP_BUILD')
  return out,{mechanical=complex,source=document.source,requiredBlocks=document.requiredBlocks}
 end
 function H.schemeParts()
  local name=H.s.scheme;local asset=AssetIndex[name]
  if asset then
   if not H.assetCache[name] then
    H.message('Wczytywanie danych '..asset.title..'...')
    local source=game:HttpGet('https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/'..asset.file)
    local parts,meta=H.decodeAsset(source);meta.mechanical=true;H.assetCache[name]={parts=parts,meta=meta}
   end
   local cached=H.assetCache[name];local minX,minY,minZ,maxX,maxZ=math.huge,math.huge,math.huge,-math.huge,-math.huge
   for _,p in ipairs(cached.parts) do minX=math.min(minX,p.x);maxX=math.max(maxX,p.x);minY=math.min(minY,p.y);minZ=math.min(minZ,p.z);maxZ=math.max(maxZ,p.z) end
   return cached.parts,H.origin*CFrame.new(-(minX+maxX)/2,-minY,-(minZ+maxZ)/2),cached.meta
  end
  local original=legacy[name];local parts={}
  for _,p in ipairs(original) do local copy={};for k,v in pairs(p) do copy[k]=v end;if H.s.titanium and copy.kind=='MetalBlock' then copy.kind='TitaniumBlock' end;parts[#parts+1]=copy end
  return parts,H.originFor(parts)
 end
 function H.refreshScheme()
  if not H.schemeInfo then return end
  local asset=AssetIndex[H.s.scheme]
  if asset then H.schemeInfo.Text=string.format('%s\n%d elementów / %d wymaganych bloków. Podgląd pliku; mechanika w przygotowaniu.',asset.title,asset.count,asset.need)
  else local p=H.schemeParts();H.schemeInfo.Text=#p..' bloków\n'..H.summary(p) end
 end
 function H.circleData()local parts=Shape.circle(H.s.circle);return parts,H.origin*CFrame.Angles(0,math.rad(H.s.circle.yaw),0) end
 function H.refreshCircle(rebuildPreview)if H.circleCount then local parts=Shape.circle(H.s.circle);H.circleCount.Text=string.format('%d bloków • średnica %.1f studów\n%s',#parts,H.s.circle.radius*2,H.summary(parts)) end;if rebuildPreview~=false and H.s.livePreview and not H.s.building then local p,o=H.circleData();H.preview(p,o) end end
 function H.originFields(card)
  H.originBoxes={}
  for _,axis in ipairs({'X','Y','Z'}) do
   local key=axis
   H.originBoxes[key]=H.field(card,'Środek '..key,H.origin.Position[key],function(value)local n=tonumber(value);if not n or n~=n or math.abs(n)>100000 then return H.origin.Position[key] end;local pos=H.origin.Position;H.origin=CFrame.new(key=='X' and n or pos.X,key=='Y' and n or pos.Y,key=='Z' and n or pos.Z);H.refreshCircle();return n end,true)
  end
 end
 function H.updateOriginBoxes()for key,box in pairs(H.originBoxes or {}) do box.Text=string.format('%.2f',H.origin.Position[key]) end;H.refreshCircle() end
 H.connect(H.UIS.InputBegan,function(input,processed)
  if not H.alive then return end
  if input.KeyCode==Enum.KeyCode.RightControl and not H.UIS:GetFocusedTextBox() then H.frame.Visible=not H.frame.Visible;H.bubble.Visible=not H.frame.Visible end
  if H.picking and not processed and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
   local camera=workspace.CurrentCamera;if not camera then return end
   local pos=input.Position;local ray=camera:ScreenPointToRay(pos.X,pos.Y);local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
   local ignore={};if H.player.Character then ignore[#ignore+1]=H.player.Character end;if H.previewFolder then ignore[#ignore+1]=H.previewFolder end;params.FilterDescendantsInstances=ignore
   local hit=workspace:Raycast(ray.Origin,ray.Direction*2000,params)
   if hit then H.origin=CFrame.new(hit.Position+Vector3.new(0,1,0));H.picking=false;H.updateOriginBoxes();H.message('Środek ustawiony w klikniętym miejscu.') end
  end
  if H.s.infiniteJump and input.KeyCode==Enum.KeyCode.Space and not processed then local hum=H.humanoid();if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
 end)
 do
  local home=H.page('HOME','START')
  local card=H.card(home,'Twój warsztat, jedno miejsce','Circle Maker, 22 plany budowy + 2 pliki z mechaniką do podglądu, generator kształtów, farmienie i narzędzia postaci.')
  H.button(card,'OTWÓRZ CIRCLE MAKER',function()H.showPage('CIRCLE')end)
  H.button(card,'SCHEMATY I WORM',function()H.showPage('SCHEMATY')end)
  H.button(card,'PANEL TROLLI',function()H.showPage('TROLLE')end)
  H.overview=H.label(card,'',75,true)
  local queue=H.card(home,'Kolejka budowania','Podglądy są lokalne. Licznik „potwierdzone” rośnie dopiero po znalezieniu rzeczywistego bloku na działce.')
  H.buildProgress=H.label(queue,'Nie rozpoczęto budowy.',80)
  H.button(queue,'PAUZA / WZNÓW',function()if not H.s.building then H.message('Brak aktywnej budowy.');return end;H.s.buildPause=not H.s.buildPause;H.message(H.s.buildPause and 'Budowa wstrzymana.' or 'Budowa wznowiona.')end)
  H.button(queue,'ANULUJ KOLEJKĘ',function()H.s.buildToken=H.s.buildToken+1;H.s.buildPause=false;H.message('Anulowano kolejne bloki. Trwające żądanie musi się zakończyć.')end,'danger')
  H.button(queue,'WYCZYŚĆ PODGLĄD',H.previewClear)
 end
 do
  local page=H.page('CIRCLE','CIRCLE MAKER')
  local card=H.card(page,'Circle Maker','Promień i odstępy podawane są w studach. Pełne koło ma siatkę klocków; pierścień układa bloki po obwodzie.')
  H.cycle(card,'Materiał',H.materials,function()return H.s.circle.kind end,function(v)H.s.circle.kind=v;H.refreshCircle()end)
  for _,field in ipairs({{'Promień','radius',2,100,false},{'Bloki na obwodzie','segments',8,240,true},{'Liczba warstw','layers',1,40,true},{'Grubość pierścienia','thickness',1,12,true},{'Odstęp warstw','layerGap',.5,10,false},{'Łuk w stopniach','arc',15,360,false},{'Obrót Y','yaw',-360,360,false}}) do
   local f=field;H.field(card,f[1],H.s.circle[f[2]],function(v)H.s.circle[f[2]]=Shape.number(v,H.s.circle[f[2]],f[3],f[4],f[5]);H.refreshCircle();return H.s.circle[f[2]] end,true)
  end
  H.cycle(card,'Płaszczyzna',{'XZ','XY','YZ'},function()return H.s.circle.axis end,function(v)H.s.circle.axis=v;H.refreshCircle()end)
  H.toggle(card,'Wypełnij środek',function()return H.s.circle.filled end,function(v)H.s.circle.filled=v;H.refreshCircle()end)
  H.toggle(card,'Podgląd po zmianach',function()return H.s.livePreview end,function(v)H.s.livePreview=v;H.refreshCircle()end)
  H.circleCount=H.label(card,'',65,true);H.actions(card,H.circleData,'CIRCLE MAKER')
  local place=H.card(page,'Miejsce budowy','Wybierz punkt na swojej działce lub wpisz współrzędne. Poza działką dostępny jest podgląd.')
  H.button(place,'WYBIERZ PUNKT KLIKNIĘCIEM W ŚWIECIE',function()H.picking=true;H.message('Kliknij punkt na działce. Esc anuluje wybieranie.')end)
  H.button(place,'ŚRODEK MOJEJ DZIAŁKI',function()H.origin=H.defaultOrigin();H.updateOriginBoxes()end)
  H.button(place,'MIEJSCE POD MOJĄ POSTACIĄ',function()local r=H.root();if r then H.origin=CFrame.new(r.Position-Vector3.new(0,2,0));H.updateOriginBoxes()end end)
  H.originFields(place)
  H.button(place,'ZAPISZ USTAWIENIA DO SCHOWKA',function()if type(setclipboard)~='function' then H.message('Schowek niedostępny.',true);return end;setclipboard(H.Http:JSONEncode({circle=H.s.circle,position={H.origin.X,H.origin.Y,H.origin.Z}}));H.message('Skopiowano preset Circle Maker.')end)
 end
 do
  local page=H.page('SCHEMATY','SCHEMATY')
  local card=H.card(page,'Biblioteka schematów','WORM ma nową paszczę z pięcioma płatami. Ruch ciała i paszczy jest obecnie animacją podglądu lokalnego; budowa stawia nieruchomą geometrię.')
  H.schemeNames={};for name in pairs(legacy) do H.schemeNames[#H.schemeNames+1]=name end;table.sort(H.schemeNames)
  H.schemeChoice=H.cycle(card,'Schemat',H.schemeNames,function()return H.s.scheme end,function(v)H.s.scheme=v;H.refreshScheme()end)
  H.field(card,'Szukaj schematu','',function(v)local q=v:upper();for _,name in ipairs(H.schemeNames) do if name:find(q,1,true) then H.s.scheme=name;H.schemeChoice.Text='Schemat: '..name;H.refreshScheme();return v end end;H.message('Nie znaleziono schematu: '..v,true);return v end)
  H.schemeInfo=H.label(card,'',100,true)
  H.toggle(card,'Metal zastąp tytanem',function()return H.s.titanium end,function(v)H.s.titanium=v;H.refreshScheme()end)
  H.toggle(card,'Animacja podglądu WORM',function()return H.s.previewMotion end,function(v)H.s.previewMotion=v end)
  H.actions(card,H.schemeParts,'SCHEMAT',true)
  local bomb=H.card(page,'BOMBA • TNT + stos drewna','1 TNT, 1 siedzenie przy TNT i do 3000 drewnianych bloków w jednym punkcie nad TNT. Odpalanie i rozrzut obsługuje fizyka oraz narzędzia gry.')
  H.field(bomb,'Drewno w stosie',3000,function(v)H.s.bombCount=Shape.number(v,H.s.bombCount,1,3000,true);H.bombInfo.Text=(H.s.bombCount+2)..' bloków\n'..H.summary(Shape.bomb(H.s.bombCount));return H.s.bombCount end,true)
  H.bombInfo=H.label(bomb,'3002 bloki\n'..H.summary(Shape.bomb(3000)),65,true)
  H.actions(bomb,function()return Shape.bomb(H.s.bombCount),H.origin end,'BOMBA TNT')
  H.label(bomb,'Bloki budują się zakotwiczone. Zwolnij kotwicę / uruchom łódź narzędziami BABFT, a TNT odpal w grze. Serwer może odrzucać nakładające się klocki.',70,true)
 end
 do
  local page=H.page('SHAPES','KSZTAŁTY')
  local card=H.card(page,'Shape Lab','Kula, kopuła, ściana, szachownica i spirala. Używają środka ustawionego w Circle Makerze.')
  H.s.shape='SPHERE';H.cycle(card,'Kształt',{'SPHERE','DOME','WALL','CHECKER','SPIRAL'},function()return H.s.shape end,function(v)H.s.shape=v end)
  H.cycle(card,'Materiał',H.materials,function()return H.s.other.kind end,function(v)H.s.other.kind=v end)
  for _,f0 in ipairs({{'Promień','radius',2,28},{'Szerokość ściany','width',1,80},{'Wysokość ściany','height',1,50},{'Zwoje spirali','turns',1,12},{'Bloki na zwój','segments',8,100}}) do local f=f0;H.field(card,f[1],H.s.other[f[2]],function(v)H.s.other[f[2]]=Shape.number(v,H.s.other[f[2]],f[3],f[4],true);return H.s.other[f[2]] end,true) end
  H.toggle(card,'Pełna kula',function()return H.s.other.filled end,function(v)H.s.other.filled=v end)
  H.actions(card,function()local o={};for k,v in pairs(H.s.other) do o[k]=v end;o.dome=H.s.shape=='DOME';o.checker=H.s.shape=='CHECKER';local p;if H.s.shape=='SPIRAL' then p=Shape.spiral(o) elseif H.s.shape=='WALL' or H.s.shape=='CHECKER' then p=Shape.wall(o) else p=Shape.sphere(o) end;return p,H.originFor(p)end,'SHAPE LAB')
 end
 function H.selectedPlayer()local list={};for _,p in ipairs(H.Players:GetPlayers()) do if p~=H.player then list[#list+1]=p end end;table.sort(list,function(a,b)return a.Name<b.Name end);if #list==0 then return nil end;H.s.targetIndex=(H.s.targetIndex-1)%#list+1;return list[H.s.targetIndex] end
 function H.selectTarget()local p=H.selectedPlayer();if H.targetLabel then H.targetLabel.Text=p and ('Gracz: '..p.DisplayName..' (@'..p.Name..')') or 'Brak innych graczy.' end;return p end
 function H.restoreCamera()local c=workspace.CurrentCamera;local hum=H.humanoid();if c and hum then c.CameraType=Enum.CameraType.Custom;c.CameraSubject=hum end;H.s.spectate=false end
 function H.stopFly()
  if H.flyVelocity then H.flyVelocity:Destroy();H.flyVelocity=nil end;if H.flyGyro then H.flyGyro:Destroy();H.flyGyro=nil end
  if H.flyHum and H.flyHum.Parent then H.flyHum.PlatformStand=H.flyPlatformBefore or false end;H.flyHum=nil
 end
 function H.startFly()
  H.stopFly();local r=H.root();local hum=H.humanoid();if not r or not hum then H.s.fly=false;return end
  H.flyHum=hum;H.flyPlatformBefore=hum.PlatformStand;hum.PlatformStand=true
  H.flyVelocity=H.new('BodyVelocity',{MaxForce=Vector3.new(1e6,1e6,1e6),Velocity=Vector3.zero},r)
  H.flyGyro=H.new('BodyGyro',{MaxTorque=Vector3.new(1e6,1e6,1e6),P=6000,CFrame=r.CFrame},r)
 end
 function H.disco(enabled)
  if H.discoEffect then H.discoEffect:Destroy();H.discoEffect=nil end
  H.s.disco=enabled;if enabled then H.discoEffect=H.new('ColorCorrectionEffect',{Name='KubiHubLocalDisco',Saturation=.3},game:GetService('Lighting')) end
 end
 function H.ghost()
  local ch=H.player.Character;if not ch then return end;local before=ch.Archivable;ch.Archivable=true;local clone=ch:Clone();ch.Archivable=before
  for _,obj in ipairs(clone:GetDescendants()) do if obj:IsA('BasePart') then obj.Anchored=true;obj.CanCollide=false;obj.CanTouch=false;obj.CanQuery=false;obj.Transparency=math.max(obj.Transparency,.25);obj.Color=H.palette.accent elseif obj:IsA('Script') or obj:IsA('LocalScript') then obj:Destroy() end end
  clone.Name='KubiHubLocalGhost';clone.Parent=workspace;clone:PivotTo(ch:GetPivot()*CFrame.new(4,0,0));H.effects[#H.effects+1]=clone;task.delay(12,function()if clone.Parent then clone:Destroy() end end)
 end
 function H.confetti()
  local r=H.root();if not r then return end
  local a=H.new('Attachment',{},r);local e=H.new('ParticleEmitter',{Rate=0,Lifetime=NumberRange.new(1,2.5),Speed=NumberRange.new(10,20),SpreadAngle=Vector2.new(180,180),Color=ColorSequence.new({ColorSequenceKeypoint.new(0,H.palette.accent),ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,100,160)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,220,90))}),Size=NumberSequence.new(.35),Acceleration=Vector3.new(0,-15,0),LightEmission=.6},a);e:Emit(65);H.effects[#H.effects+1]=a;task.delay(4,function()if a.Parent then a:Destroy() end end)
 end
 function H.clearEffects()for _,o in ipairs(H.effects) do pcall(function()o:Destroy()end) end;H.effects={};H.disco(false) end
 function H.restoreCollision()for p,value in pairs(H.savedCollision or {}) do if p.Parent then p.CanCollide=value end end;H.savedCollision={} end
 function H.panic()
  H.s.farm=false;H.s.buildToken=H.s.buildToken+1;H.s.buildPause=false;H.s.fly=false;H.s.spin=false;H.s.bounce=false;H.s.orbit=false;H.s.follow=false;H.s.noclip=false;H.picking=false
  H.stopFly();H.restoreCamera();H.restoreCollision();H.previewClear();H.clearEffects();H.message('STOP: kolejka, farmienie, ruch i efekty zatrzymane.')
 end
 do
  local page=H.page('TROLLE','TROLLE / FUN')
  local target=H.card(page,'Wybór gracza','Ruch dotyczy Twojej postaci; serwer może go skorygować. Efekty oznaczone LOKALNE widzisz tylko Ty.')
  H.targetLabel=H.label(target,'',36);H.selectTarget()
  H.button(target,'NASTĘPNY GRACZ',function()H.s.targetIndex=H.s.targetIndex+1;H.selectTarget()end)
  H.field(target,'Znajdź gracza','',function(v)local query=v:lower();local players=H.Players:GetPlayers();local filtered={};for _,p in ipairs(players) do if p~=H.player then filtered[#filtered+1]=p end end;table.sort(filtered,function(a,b)return a.Name<b.Name end);for i,p in ipairs(filtered) do if p.Name:lower():find(query,1,true) or p.DisplayName:lower():find(query,1,true) then H.s.targetIndex=i;H.selectTarget();break end end;return v end)
  H.button(target,'PODEJDŹ DO GRACZA',function()local p=H.selectTarget();local r=p and H.root(p);local hum=H.humanoid();if r and hum then hum:MoveTo(r.Position+r.CFrame.RightVector*5) else H.message('Gracz nie ma aktywnej postaci.',true) end end)
  H.toggle(target,'Podążaj za graczem',function()return H.s.follow end,function(v)H.s.follow=v;if v then H.s.farm=false;H.s.orbit=false end end)
  H.toggle(target,'Orbituj graczem',function()return H.s.orbit end,function(v)H.s.orbit=v;if v then H.s.farm=false;H.s.follow=false;H.s.fly=false;H.stopFly() end end)
  H.field(target,'Promień orbity',10,function(v)H.s.orbitRadius=Shape.number(v,10,5,35);return H.s.orbitRadius end,true)
  H.button(target,'OBSERWUJ GRACZA • LOKALNIE',function()local p=H.selectTarget();local hum=p and p.Character and p.Character:FindFirstChildOfClass('Humanoid');local camera=workspace.CurrentCamera;if hum and camera then H.s.spectate=true;camera.CameraSubject=hum end end)
  H.button(target,'WRÓĆ DO SWOJEJ KAMERY',H.restoreCamera)
  local fun=H.card(page,'Zabawa i efekty','Obrót i skoki sterują Twoją postacią. Duch, konfetti i dyskoteka to efekty lokalne.')
  H.toggle(fun,'Obrót postaci',function()return H.s.spin end,function(v)H.s.spin=v end)
  H.toggle(fun,'Sprężynowe skoki',function()return H.s.bounce end,function(v)H.s.bounce=v end)
  H.button(fun,'TĘCZOWY DUCH • LOKALNY, 12 s',H.ghost)
  H.button(fun,'KONFETTI • LOKALNE',H.confetti)
  H.toggle(fun,'Dyskoteka • lokalna',function()return H.s.disco end,H.disco)
  H.button(fun,'WYCZYŚĆ EFEKTY',H.clearEffects)
  H.button(fun,'STOP WSZYSTKO',H.panic,'danger')
 end
 do
  local page=H.page('PLAYER','POSTAĆ')
  local card=H.card(page,'Ruch postaci','WASD / ruch joystickiem: lot. Spacja w górę, Ctrl w dół. Prawy Ctrl pokazuje GUI.')
  H.field(card,'Prędkość chodzenia',16,function(v)H.s.walk=Shape.number(v,16,8,150);local hum=H.humanoid();if hum then hum.WalkSpeed=H.s.walk end;return H.s.walk end,true)
  H.field(card,'Siła skoku',50,function(v)H.s.jump=Shape.number(v,50,20,180);local hum=H.humanoid();if hum then if hum.UseJumpPower then hum.JumpPower=H.s.jump else hum.JumpHeight=H.s.jump^2/(2*workspace.Gravity) end end;return H.s.jump end,true)
  H.toggle(card,'Lot',function()return H.s.fly end,function(v)H.s.fly=v;if v then H.s.orbit=false;H.s.follow=false;H.s.farm=false;H.startFly() else H.stopFly() end end)
  H.field(card,'Prędkość lotu',50,function(v)H.s.flySpeed=Shape.number(v,50,10,250);return H.s.flySpeed end,true)
  H.toggle(card,'Nieskończony skok',function()return H.s.infiniteJump end,function(v)H.s.infiniteJump=v end)
  H.toggle(card,'Noclip • moja postać',function()return H.s.noclip end,function(v)H.s.noclip=v;if not v then H.restoreCollision() end end)
  H.toggle(card,'Anti AFK',function()return H.s.antiAfk end,function(v)if not H.idleAvailable and v then H.message('VirtualUser niedostępny w tym środowisku.',true);return end;H.s.antiAfk=v end)
  H.button(card,'WRÓĆ NA DZIAŁKĘ',function()local z=H.zone();if z then H.teleport(z.CFrame*CFrame.new(0,z.Size.Y/2+5,0)) end end)
  H.button(card,'ZAPAMIĘTAJ MIEJSCE',function()local r=H.root();if r then H.bookmark=r.CFrame;H.message('Zapamiętano pozycję.') end end)
  H.button(card,'WRÓĆ DO ZAPAMIĘTANEGO MIEJSCA',function()if H.bookmark then H.teleport(H.bookmark) end end)
 end
 function H.farmStatus(value)H.farmStatusText=value;if H.farmInfo then H.farmInfo.Text='Status: '..value..'\nEtap '..H.s.stage..'/10' end end
 function H.farmWait(seconds)
  local deadline=os.clock()+seconds;while H.alive and H.s.farm and os.clock()<deadline do task.wait(.08) end;return H.alive and H.s.farm
 end
 function H.farmOnce()
  H.s.attempts=H.s.attempts+1
  local stages=workspace:FindFirstChild('BoatStages');stages=stages and stages:FindFirstChild('NormalStages')
  if not stages then error('Nie znaleziono etapów BABFT.') end
  for i=1,10 do
   if not H.alive or not H.s.farm then return end
   local cave=stages:FindFirstChild('CaveStage'..i);local part=cave and cave:FindFirstChild('DarknessPart')
   if not part or not part:IsA('BasePart') then error('Brak CaveStage'..i) end
   H.s.stage=i;H.farmStatus('Przelot')
   local floor=H.new('Part',{Anchored=true,CanCollide=true,Transparency=1,Size=Vector3.new(6,1,6),CFrame=part.CFrame*CFrame.new(0,-4,0)},workspace);H.floor=floor
   if not H.teleport(part.CFrame) then floor:Destroy();H.floor=nil;error('Brak postaci.') end
   H.farmWait(math.max(H.s.safeFarm and 2 or .05,H.s.farmDelay));floor:Destroy();H.floor=nil
  end
  if not H.alive or not H.s.farm then return end
  local ending=stages:FindFirstChild('TheEnd');local chest=ending and ending:FindFirstChild('GoldenChest');local trigger=chest and chest:FindFirstChild('Trigger')
  if not trigger or not trigger:IsA('BasePart') then error('Brak końcowej skrzyni.') end
  local character=H.player.Character;H.farmStatus('Skrzynia / oczekiwanie na respawn')
  for i=1,10 do if not H.s.farm or H.player.Character~=character then break end;H.teleport(trigger.CFrame);H.farmWait(1) end
  local deadline=os.clock()+25;while H.alive and H.s.farm and H.player.Character==character and os.clock()<deadline do task.wait(.15) end
  if not H.s.farm then return end
  if H.player.Character==character then error('Brak respawnu po skrzyni. Zatrzymano farmę.') end
  H.s.rounds=H.s.rounds+1;H.s.stage=0;H.farmStatus('Respawn potwierdzony');H.farmWait(4)
  local gold=H.gold()
  if not H.s.autoRestart or H.s.stopAfter>0 and H.s.rounds>=H.s.stopAfter or H.s.goldGoal>0 and gold and gold>=H.s.goldGoal then H.s.farm=false;H.farmStatus('Cel osiągnięty / koniec przebiegu') end
 end
 do
  local page=H.page('FARM','AUTO FARM')
  local card=H.card(page,'Auto Farm','Licznik rund opiera się na respawnie po skrzyni. Rzeczywiste złoto jest odczytywane z danych gry, jeśli są dostępne.')
  H.farmInfo=H.label(card,'Status: zatrzymana\nEtap 0/10',50)
  H.button(card,'START / STOP FARM',function()if H.s.building then H.message('Najpierw zakończ budowanie.',true);return end;H.s.farm=not H.s.farm;H.s.orbit=false;H.s.follow=false;H.s.fly=false;H.stopFly();H.farmStatus(H.s.farm and 'Start' or 'Zatrzymana')end)
  H.field(card,'Sekundy na etap',1.5,function(v)H.s.farmDelay=Shape.number(v,1.5,.05,10);return H.s.farmDelay end,true)
  H.toggle(card,'Tryb spokojny • min. 2 s',function()return H.s.safeFarm end,function(v)H.s.safeFarm=v end)
  H.toggle(card,'Automatyczny restart',function()return H.s.autoRestart end,function(v)H.s.autoRestart=v end)
  H.field(card,'Stop po rundach • 0 = bez limitu',0,function(v)H.s.stopAfter=Shape.number(v,0,0,10000,true);return H.s.stopAfter end,true)
  H.field(card,'Docelowe złoto • 0 = bez limitu',0,function(v)H.s.goldGoal=Shape.number(v,0,0,100000000,true);return H.s.goldGoal end,true)
  H.stats=H.label(card,'',100,true)
  H.button(card,'WYZERUJ STATYSTYKI',function()H.s.rounds=0;H.s.attempts=0;H.s.started=os.clock();H.startGold=H.gold()end)
 end
 do
  local page=H.page('FILES','PLIKI / WORM')
  local card=H.card(page,'Pliki .Build • podgląd danych','Znaleziony czerwony robak ma 6 serw i 8 tłoków. To podobny model, a nie potwierdzony oryginał WORM 9. Odtwarzanie jego mechaniki na serwerze nie jest jeszcze obsługiwane.')
  H.button(card,'KOPIUJ LINK DO ZNALEZIONEGO ROBAKA',function()if type(setclipboard)=='function' then setclipboard('https://luau.pro/catalog/build/70329a6b-4b82-4fd4-b0dd-aa89fcb5a44a');H.message('Skopiowano link do pliku.') end end)
  H.button(card,'KOPIUJ LINK DO WORKING SHREDDER',function()if type(setclipboard)=='function' then setclipboard('https://luau.pro/catalog/build/8e8ea8d2-08d3-487e-8a31-298b2361bb3d');H.message('Skopiowano link do pliku SHREDDER.') end end)
  H.label(card,'SHREDDER jest dostępny w Schematach jako plik do podglądu. Koła, połączenia i rozrywanie łodzi nie są jeszcze zaimplementowane w KUBI HUB.',60,true)
  local box=H.new('TextBox',{Size=UDim2.new(1,0,0,140),BackgroundColor3=H.palette.input,BorderSizePixel=0,Text='',PlaceholderText='Wklej zawartość pliku .Build lub JSON. To są dane, nie kod Lua.',TextColor3=H.palette.text,PlaceholderColor3=H.palette.muted,MultiLine=true,ClearTextOnFocus=false,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Font=Enum.Font.Code,TextSize=11},card);H.corner(box,8)
  H.fileInfo=H.label(card,'Nie wczytano pliku.',65,true)
  H.button(card,'SPRAWDŹ PLIK I POKAŻ GEOMETRIĘ',function()
   local parts,meta=H.decodeAsset(box.Text);H.fileParts=parts
   H.fileInfo.Text=string.format('%d bloków; %s.\nPodgląd lokalny pokazuje geometrię, nie działanie połączeń.',#parts,meta.mechanical and 'plik zawiera mechanikę / powiązania' or 'geometria')
   local minX,minY,minZ,maxX,maxZ=math.huge,math.huge,math.huge,-math.huge,-math.huge
   for _,p in ipairs(parts) do minX=math.min(minX,p.x);maxX=math.max(maxX,p.x);minY=math.min(minY,p.y);minZ=math.min(minZ,p.z);maxZ=math.max(maxZ,p.z) end
   H.preview(parts,H.origin*CFrame.new(-(minX+maxX)/2,-minY,-(minZ+maxZ)/2))
  end)
  H.label(card,'Do przeglądania plików nie są pobierane ani uruchamiane zewnętrzne skrypty. Format .Build jest czytany wyłącznie jako JSON.',55,true)
 end
 do
  local page=H.page('SETTINGS','USTAWIENIA')
  local card=H.card(page,'Wygląd i kolejka','Ukrywanie GUI: prawy Ctrl lub pływający przycisk K. Kolejka buduje pojedynczo i zatrzymuje się przy niepotwierdzonych blokach.')
  H.cycle(card,'Akcent',{'BLUE','PURPLE','RED','GREEN'},function()return H.accentName or 'BLUE' end,function(v)H.accentName=v;H.palette.accent=({BLUE=Color3.fromRGB(75,136,255),PURPLE=Color3.fromRGB(158,105,255),RED=Color3.fromRGB(240,80,105),GREEN=Color3.fromRGB(40,180,140)})[v];for _,entry in ipairs(H.accentItems) do if entry[1].Parent then entry[1][entry[2]]=H.palette.accent end end;H.showPage(H.currentPage)end)
  H.field(card,'Odstęp między blokami • s',.04,function(v)H.s.buildDelay=Shape.number(v,.04,.02,2);return H.s.buildDelay end,true)
  H.cycle(card,'Tempo budowy',{'FAST','TURBO','SAFE'},function()return H.buildMode or 'FAST' end,function(v)H.buildMode=v;H.s.buildDelay=({FAST=.04,TURBO=.02,SAFE=.18})[v];H.message('Odstęp '..H.s.buildDelay..' s. Serwer nadal decyduje o przyjmowaniu żądań.')end)
  H.button(card,'SKOPIUJ LOG DIAGNOSTYCZNY',function()if type(setclipboard)=='function' then setclipboard('KUBI HUB V4.0\n'..table.concat(H.log,'\n'));H.message('Skopiowano log.') end end)
  H.button(card,'SPRAWDŹ NARZĘDZIA BABFT',function()
   local lines={};for _,folderName in ipairs({'Backpack','Character'}) do local folder=folderName=='Character' and H.player.Character or H.player:FindFirstChildOfClass('Backpack');if folder then for _,tool in ipairs(folder:GetChildren()) do if tool:IsA('Tool') then local remotes={};for _,obj in ipairs(tool:GetDescendants()) do if obj:IsA('RemoteFunction') or obj:IsA('RemoteEvent') then remotes[#remotes+1]=obj.Name..' ('..obj.ClassName..')' end end;table.sort(remotes);lines[#lines+1]=tool.Name..': '..table.concat(remotes,', ') end end end end;table.sort(lines);for _,line in ipairs(lines) do H.message(line) end;H.message('Lista narzędzi jest w logu diagnostycznym.')
  end)
  H.button(card,'SKOPIUJ STAŁY LOADER',function()if type(setclipboard)=='function' then setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/main.lua"))()');H.message('Skopiowano stały loader.') end end)
  H.button(card,'SKOPIUJ DISCORD KUBI HUB',function()if type(setclipboard)=='function' then setclipboard('https://discord.gg/qmWGb4Q9p');H.message('Skopiowano zaproszenie.') end end)
  H.button(card,'STOP WSZYSTKO',H.panic,'danger')
  H.button(card,'ZAMKNIJ I PRZYWRÓĆ POSTAĆ',function()_G.KubiHubV4Stop()end,'danger')
 end
 function H.captureCharacter()
  local hum=H.humanoid();if not hum then return end
  H.savedCharacter={hum=hum,walk=hum.WalkSpeed,jump=hum.JumpPower,jumpHeight=hum.JumpHeight,platform=hum.PlatformStand}
  hum.WalkSpeed=H.s.walk;if hum.UseJumpPower then hum.JumpPower=H.s.jump else hum.JumpHeight=H.s.jump^2/(2*workspace.Gravity) end
  if H.s.fly then H.startFly() end
 end
 H.captureCharacter()
 H.connect(H.player.CharacterAdded,function()H.stopFly();H.savedCollision={};task.wait(.9);if H.alive then H.captureCharacter();if not H.s.spectate then H.restoreCamera() end end end)
 H.connect(H.Players.PlayerRemoving,function(p)if p==H.selectedPlayer() then H.s.follow=false;H.s.orbit=false;H.restoreCamera() end end)
 H.connect(H.UIS.InputBegan,function(input,processed)if input.KeyCode==Enum.KeyCode.Escape then H.picking=false end end)
 do
  local ok,vu=pcall(function()return game:GetService('VirtualUser')end)
  if ok and vu then H.idleAvailable=true;H.connect(H.player.Idled,function()if H.s.antiAfk and H.alive then pcall(function()vu:CaptureController();vu:ClickButton2(Vector2.zero)end) end end) end
 end
 H.savedCollision={};H.lastSlow=0;H.lastFollow=0;H.lastPreview=0
 H.connect(H.Run.Stepped,function()
  if not H.alive or not H.s.noclip then return end
  local ch=H.player.Character;if ch then for _,p in ipairs(ch:GetDescendants()) do if p:IsA('BasePart') then if H.savedCollision[p]==nil then H.savedCollision[p]=p.CanCollide end;p.CanCollide=false end end end
 end)
 H.connect(H.Run.RenderStepped,function(dt)
  if not H.alive then return end
  local now=os.clock();local r=H.root();local hum=H.humanoid();local camera=workspace.CurrentCamera
  if H.s.fly and H.flyVelocity and r and camera and hum then
   local move=Vector3.zero
   if not H.UIS:GetFocusedTextBox() then
    if H.UIS:IsKeyDown(Enum.KeyCode.W) then move=move+camera.CFrame.LookVector end;if H.UIS:IsKeyDown(Enum.KeyCode.S) then move=move-camera.CFrame.LookVector end
    if H.UIS:IsKeyDown(Enum.KeyCode.D) then move=move+camera.CFrame.RightVector end;if H.UIS:IsKeyDown(Enum.KeyCode.A) then move=move-camera.CFrame.RightVector end
    if H.UIS:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.yAxis end;if H.UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move=move-Vector3.yAxis end
    if H.UIS.TouchEnabled and hum.MoveDirection.Magnitude>0 then move=move+hum.MoveDirection end
   end
   H.flyVelocity.Velocity=move.Magnitude>.01 and move.Unit*H.s.flySpeed or Vector3.zero;H.flyGyro.CFrame=camera.CFrame
  end
  if H.s.spin and r then r.CFrame=r.CFrame*CFrame.Angles(0,dt*6,0) end
  if H.s.orbit and r then local p=H.selectedPlayer();local target=p and H.root(p);if target then local offset=Vector3.new(math.cos(now)*H.s.orbitRadius,2,math.sin(now)*H.s.orbitRadius);r.CFrame=CFrame.lookAt(target.Position+offset,target.Position);r.AssemblyLinearVelocity=Vector3.zero else H.s.orbit=false end end
  if H.s.disco and H.discoEffect then H.discoEffect.TintColor=Color3.fromHSV(now*.12%1,.38,1) end
  if now-H.lastSlow>.4 then H.lastSlow=now;if H.s.bounce and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
  if H.s.follow and now-H.lastFollow>.6 then H.lastFollow=now;local p=H.selectedPlayer();local target=p and H.root(p);if hum and target then hum:MoveTo(target.Position+target.CFrame.RightVector*5) end end
  if H.previewMode=='worm' and H.s.previewMotion and now-H.lastPreview>.04 then H.lastPreview=now
   for _,entry in ipairs(H.previewParts) do local p=entry.data;local pos=Vector3.new(p.x,p.y,p.z)
    if p.group=='body' then pos=pos+Vector3.new(math.sin((p.section or 0)*.8-now*2)*1.4,math.cos((p.section or 0)*.7-now*2)*.65,0)
    elseif p.group=='petal' then local factor=.58+.42*(math.sin(now*1.8)*.5+.5);pos=Vector3.new(p.x*factor,(p.y-6)*factor+6,p.z-(1-factor)*6) end
    if entry.part.Parent then entry.part.CFrame=H.previewOrigin*CFrame.new(pos)*CFrame.Angles(math.rad(p.rx or 0),math.rad(p.ry or 0),math.rad(p.rz or 0)) end
   end
  end
 end)
 H.bubble=H.new('TextButton',{Name='Reopen',Size=UDim2.fromOffset(46,46),Position=UDim2.new(0,14,.5,-23),BackgroundColor3=H.palette.accent,Text='K',TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=21,Visible=false,BorderSizePixel=0},H.gui);H.corner(H.bubble,14);H.tone(H.bubble)
 H.connect(H.bubble.Activated,function()H.frame.Visible=true;H.bubble.Visible=false end)
 do
  local hide=H.new('TextButton',{Position=UDim2.new(1,-86,0,17),Size=UDim2.fromOffset(30,30),BackgroundColor3=H.palette.card,Text='—',TextColor3=H.palette.text,Font=Enum.Font.GothamBold,TextSize=17,BorderSizePixel=0},H.top);H.corner(hide,8)
  H.connect(hide.Activated,function()H.frame.Visible=false;H.bubble.Visible=true end)
  local close=H.new('TextButton',{Position=UDim2.new(1,-47,0,17),Size=UDim2.fromOffset(30,30),BackgroundColor3=H.palette.red,Text='X',TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=13,BorderSizePixel=0},H.top);H.corner(close,8)
  H.connect(close.Activated,function()_G.KubiHubV4Stop()end)
 end
 _G.KubiHubV4Stop=function()
  if not H.alive then return end;H.panic();H.alive=false
  for _,c in ipairs(H.connections) do pcall(function()c:Disconnect()end) end
  if H.floor then H.floor:Destroy() end
  local saved=H.savedCharacter;if saved.hum and saved.hum.Parent then pcall(function()saved.hum.WalkSpeed=saved.walk;saved.hum.JumpPower=saved.jump;saved.hum.JumpHeight=saved.jumpHeight;saved.hum.PlatformStand=saved.platform end) end
  if H.gui then H.gui:Destroy() end;_G.KubiHubV4Stop=nil
 end
 H.showPage('HOME');H.refreshCircle();H.refreshScheme()
 task.spawn(function()
  while H.alive do
   if H.s.farm then local ok,err=pcall(H.farmOnce);if not ok then H.s.farm=false;if H.floor then H.floor:Destroy();H.floor=nil end;H.farmStatus('Błąd: '..tostring(err));H.message(err,true) end end
   task.wait(.2)
  end
 end)
 task.spawn(function()
  while H.alive do
   local elapsed=math.max(1,os.clock()-H.s.started);local gold=H.gold();local gain=gold and H.startGold and gold-H.startGold
   H.stats.Text=string.format('Rundy po respawnie: %d • próby: %d\nSesja: %02d:%02d:%02d • rund/h: %.1f\nZłoto: %s • zmiana w sesji: %s',H.s.rounds,H.s.attempts,math.floor(elapsed/3600),math.floor(elapsed/60)%60,math.floor(elapsed)%60,H.s.rounds*3600/elapsed,gold and tostring(gold) or '?',gain and tostring(gain) or '?')
   H.overview.Text=string.format('Gracz: %s\nDziałka: %s • złoto: %s\nSchematy: %d • GUI: prawy Ctrl',H.player.DisplayName,H.zone() and 'wykryta' or 'niewykryta',gold and tostring(gold) or '?',#H.schemeNames)
   if H.currentPage=='CIRCLE' and not H.s.building then H.refreshCircle(false) end
   for _,update in ipairs(H.toggleUpdates) do update() end
   task.wait(1)
  end
 end)
 if _G.KUBI_HUB_RUNTIME_TEST then _G.KUBI_HUB_TEST_HOOK=H;_G.KUBI_HUB_LEGACY_TEST=legacy end
 print('[KUBI HUB V4.0] GUI, Circle Maker, Shape Lab, blueprints, TNT payload, farm and player tools loaded.')
end,function(err)return tostring(err)..'\n'..(debug and debug.traceback and debug.traceback() or '')end)
if not bootOK then
 warn('[KUBI HUB V4.0 STARTUP] '..tostring(bootError))
 pcall(function()
  if type(_G.KubiHubV4Stop)=='function' then _G.KubiHubV4Stop() else H.alive=false;for _,c in ipairs(H.connections) do pcall(function()c:Disconnect()end) end;if H.previewFolder then H.previewFolder:Destroy() end;if H.gui then H.gui:Destroy() end end
  local player=game:GetService('Players').LocalPlayer;local pg=player and player:FindFirstChild('PlayerGui');if not pg then return end
  local gui=Instance.new('ScreenGui');gui.Name='KubiHubDiagnostics';gui.ResetOnSpawn=false;gui.Parent=pg
  local label=Instance.new('TextLabel');label.Size=UDim2.fromOffset(440,210);label.Position=UDim2.new(.5,-220,.5,-105);label.BackgroundColor3=Color3.fromRGB(22,26,39);label.TextColor3=Color3.fromRGB(255,130,140);label.Font=Enum.Font.Code;label.TextSize=13;label.TextWrapped=true;label.Text='KUBI HUB V4.0\nBłąd uruchamiania. Szczegóły: F9.\n\n'..string.sub(tostring(bootError),1,350);label.Parent=gui
 end)
end
