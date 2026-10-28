return function(Shape)

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
legacy.HEART=Shape.heart()
legacy.DOUBLE_HELIX=Shape.doubleHelix()
legacy.OBSERVATION_TOWER=Shape.observationTower()
for _,spec in ipairs(Shape.catalogSpecs) do legacy[spec[1]]=Shape.catalog(spec[1]) end

local AssetIndex={WORM_FILE={file="worm-red.json",title="Czerwony robak • plik z mechaniką",count=2830,need=4184},SHREDDER={file="shredder.json",title="Working Shredder • plik z mechaniką",count=960,need=973}}
legacy.WORM_FILE={}
legacy.SHREDDER={}

return legacy,AssetIndex
end
