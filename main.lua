-- KUBI HUB V4.1 | building repairs, community key and 100 workshop actions
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

function Shape.bounds(parts)
 local b={minX=math.huge,minY=math.huge,minZ=math.huge,maxX=-math.huge,maxY=-math.huge,maxZ=-math.huge}
 for _,p in ipairs(parts) do
  local s=p.size or {2,2,2};local ax,ay,az=math.rad(p.rx or 0),math.rad(p.ry or 0),math.rad(p.rz or 0)
  local sx,cx,sy,cy,sz,cz=math.sin(ax),math.cos(ax),math.sin(ay),math.cos(ay),math.sin(az),math.cos(az)
  local ex=(math.abs(cy*cz)*s[1]+math.abs(cy*sz)*s[2]+math.abs(sy)*s[3])/2
  local ey=(math.abs(cx*sz+sx*sy*cz)*s[1]+math.abs(cx*cz-sx*sy*sz)*s[2]+math.abs(sx*cy)*s[3])/2
  local ez=(math.abs(sx*sz-cx*sy*cz)*s[1]+math.abs(sx*cz+cx*sy*sz)*s[2]+math.abs(cx*cy)*s[3])/2
  b.minX=math.min(b.minX,p.x-ex);b.maxX=math.max(b.maxX,p.x+ex)
  b.minY=math.min(b.minY,p.y-ey);b.maxY=math.max(b.maxY,p.y+ey)
  b.minZ=math.min(b.minZ,p.z-ez);b.maxZ=math.max(b.maxZ,p.z+ez)
 end
 return b
end
function Shape.prepare(parts,o)
 local out={};o=o or {}
 for _,p in ipairs(parts) do
  local q={};for k,v in pairs(p) do q[k]=v end
  if o.material and o.material~='ORIGINAL' and q.kind:match('Block$') then q.kind=o.material end
  if o.paint==false then q.color=nil end
  if o.mirrorX then q.x=-q.x;q.ry=-(q.ry or 0);q.rz=-(q.rz or 0) end
  if o.mirrorZ then q.z=-q.z;q.rx=-(q.rx or 0);q.ry=-(q.ry or 0) end
  out[#out+1]=q
 end
 return out
end
function Shape.heart()
 local out={}
 for x=-12,12 do for y=-11,12 do
  local u,v=x/10,y/10
  if (u*u+v*v-1)^3-u*u*v^3<=0 then Shape.add(out,'PlasticBlock',x*2,y*2,0,{color={1,.12,.3}}) end
 end end
 return out
end
function Shape.doubleHelix()
 local out={};local steps=100
 for i=0,steps do
  local a=i*math.pi/12;local y=i*.55
  for _,side in ipairs({-1,1}) do Shape.add(out,'PlasticBlock',math.cos(a)*8*side,y,math.sin(a)*8*side,{color=side==1 and {.2,.5,1} or {1,.2,.45}}) end
  if i%6==0 then for n=-3,3 do Shape.add(out,'WoodBlock',math.cos(a)*n*2,y,math.sin(a)*n*2) end end
 end
 return out
end
function Shape.observationTower()
 local out={}
 for y=0,15 do for _,x in ipairs({-5,5}) do for _,z in ipairs({-5,5}) do Shape.add(out,'WoodBlock',x*2,y*2,z*2) end end end
 for x=-6,6 do for z=-6,6 do Shape.add(out,'WoodBlock',x*2,32,z*2);if math.abs(x)==6 or math.abs(z)==6 then Shape.add(out,'WoodBlock',x*2,36,z*2) end end end
 for i=0,15 do Shape.add(out,'WoodBlock',0,i*2,-12+i*1.4) end
 Shape.add(out,'Seat',0,34,0)
 return out
end
Shape.catalogSpecs={
 {'HEART','Serce 3D'},{'DOUBLE_HELIX','Podwójna helisa'},{'OBSERVATION_TOWER','Wieża obserwacyjna'},
 {'LOG_CABIN','Drewniany domek'},{'MAZE','Labirynt'},{'IGLOO','Igloo'},{'TORUS','Torus'},
 {'FUNNEL','Lej'},{'SPIRAL_STAIRS','Spiralne schody'},{'WELL','Studnia'},{'GAZEBO','Altana'},
 {'CAGE','Klatka dekoracyjna'},{'HANGAR','Hangar'},{'BOAT_DOCK','Przystań'},{'RACE_GATE','Brama wyścigowa'},
 {'CHECKPOINTS','Tor z bramkami'},{'TARGET','Tarcza'},{'SMILEY','Buźka'},{'SWORD','Miecz pomnik'},
 {'CROWN','Korona'},{'PIXEL_SKULL','Pikselowa czaszka'},{'CHESS_ROOK','Wieża szachowa'},
 {'LIGHTHOUSE','Latarnia morska'},{'TREASURE_CHEST','Skrzynia dekoracyjna'},{'RADAR','Antena dekoracyjna'},
 {'PICNIC','Stół i ławki'},{'GREENHOUSE','Szklarnia'},{'LAUNCH_PAD','Lądowisko'},{'TWIN_TOWERS','Dwie wieże'},
 {'AQUEDUCT','Akwedukt'}
}
function Shape.catalog(name)
 if name=='HEART' then return Shape.heart() elseif name=='DOUBLE_HELIX' then return Shape.doubleHelix() elseif name=='OBSERVATION_TOWER' then return Shape.observationTower() end
 local out,seen={},{}
 local function add(x,y,z,kind,color)
  local k=string.format('%.3f:%.3f:%.3f',x,y,z);if seen[k] then return end;seen[k]=true
  Shape.add(out,kind or 'WoodBlock',x,y,z,color and {color=color} or nil)
 end
 local function box(x0,x1,y0,y1,z0,z1,kind)
  for x=x0,x1,2 do for y=y0,y1,2 do for z=z0,z1,2 do add(x,y,z,kind) end end end
 end
 local function ring(r,y,cx,cz,kind)
  local n=math.max(12,math.ceil(r*math.pi));for i=0,n-1 do local a=i*math.pi*2/n;add((cx or 0)+math.cos(a)*r,y,(cz or 0)+math.sin(a)*r,kind) end
 end
 local function arch(cx,z)
  for y=0,12,2 do add(cx-8,y,z);add(cx+8,y,z) end
  for i=0,12 do local a=i*math.pi/12;add(cx+math.cos(a)*8,12+math.sin(a)*8,z) end
 end
 if name=='LOG_CABIN' or name=='GREENHOUSE' then
  box(-10,10,0,0,-14,14)
  local material=name=='GREENHOUSE' and 'GlassBlock' or 'WoodBlock'
  for y=2,12,2 do for x=-10,10,2 do for z=-14,14,2 do if (math.abs(x)==10 or math.abs(z)==14) and not (z==-14 and math.abs(x)<=2 and y<10) then add(x,y,z,material) end end end end
  for x=-10,10,2 do box(x,x,14+(10-math.abs(x))*.5,14+(10-math.abs(x))*.5,-14,14,material) end
 elseif name=='MAZE' then
  box(-20,20,0,0,-20,20)
  for z=-20,20,8 do for x=-20,20,2 do if math.floor((z+20)/8)%2==0 and x<16 or math.floor((z+20)/8)%2==1 and x>-16 then box(x,x,2,8,z,z) end end end
  box(-22,-22,2,8,-20,20);box(22,22,2,8,-20,20)
 elseif name=='IGLOO' then
  for _,p in ipairs(Shape.sphere({radius=14,dome=true,kind='IceBlock'})) do if not(p.z<-8 and math.abs(p.x)<4 and p.y<7) then add(p.x,p.y,p.z,p.kind) end end
 elseif name=='TORUS' then
  for i=0,43 do local a=i*math.pi/22;for j=0,11 do local b=j*math.pi/6;add(math.cos(a)*(13+4*math.cos(b)),4*math.sin(b),math.sin(a)*(13+4*math.cos(b)),'PlasticBlock') end end
 elseif name=='FUNNEL' then
  for y=0,12,2 do ring(4+y,y,0,0,'MetalBlock') end
 elseif name=='SPIRAL_STAIRS' then
  for i=0,59 do local a=i*math.pi/12;for r=2,8,2 do add(math.cos(a)*r,i*.6,math.sin(a)*r) end end
  box(0,0,0,36,0,0)
 elseif name=='WELL' then
  for y=0,6,2 do ring(7,y,0,0,'StoneBlock') end
  box(-8,-8,0,16,0,0);box(8,8,0,16,0,0);box(-10,10,18,18,-6,6)
 elseif name=='GAZEBO' then
  for x=-10,10,2 do for z=-10,10,2 do if x*x+z*z<=130 then add(x,0,z);add(x,16+(10-math.max(math.abs(x),math.abs(z)))*.5,z) end end end
  for i=0,5 do local a=i*math.pi/3;for y=2,16,2 do add(math.cos(a)*10,y,math.sin(a)*10) end end
 elseif name=='CAGE' then
  box(-12,12,0,0,-12,12);box(-12,12,20,20,-12,12)
  for i=-12,12,4 do for _,v in ipairs({-12,12}) do box(i,i,2,18,v,v,'MetalBlock');box(v,v,2,18,i,i,'MetalBlock') end end
 elseif name=='HANGAR' then
  box(-18,18,0,0,-20,20)
  for z=-20,20,2 do for i=0,24 do local a=i*math.pi/24;add(math.cos(a)*18,math.sin(a)*18+2,z,'MetalBlock') end end
 elseif name=='BOAT_DOCK' then
  box(-20,20,6,6,-18,-12);box(-20,-14,6,6,-10,22);box(14,20,6,6,-10,22)
  for _,x in ipairs({-18,18}) do for z=-16,22,12 do box(x,x,0,8,z,z) end end
 elseif name=='RACE_GATE' then arch(0,0)
 elseif name=='CHECKPOINTS' then for _,z in ipairs({-24,0,24}) do arch(0,z) end
 elseif name=='TARGET' or name=='SMILEY' then
  for x=-10,10 do for y=-10,10 do if x*x+y*y<=100 then
   local color={1,.8,.1}
   if name=='TARGET' then local odd=math.floor(math.sqrt(x*x+y*y)/2)%2; color=odd==0 and {1,.1,.1} or {1,1,1}
   elseif (math.abs(x)==4 and y==4) or y<=-2 and y>=-5 and math.abs(x)>=2 and math.abs(x)<=6 and math.abs(y+2)==6-math.abs(x) then color={.04,.04,.04} end
   add(x*2,y*2,0,'PlasticBlock',color)
  end end end
 elseif name=='SWORD' then
  box(-2,2,0,8,0,0);box(-10,10,10,10,0,0,'GoldBlock');box(-2,2,12,38,0,0,'MetalBlock');add(0,40,0,'MetalBlock')
 elseif name=='CROWN' then
  for y=0,6,2 do ring(12,y,0,0,'GoldBlock') end
  for i=0,7 do local a=i*math.pi/4;for y=8,14,2 do add(math.cos(a)*12,y,math.sin(a)*12,'GoldBlock') end end
 elseif name=='PIXEL_SKULL' then
  for x=-8,8 do for y=-8,8 do
   local eye=y>=0 and y<=4 and math.abs(x)>=2 and math.abs(x)<=6
   local nose=math.abs(x)<=1 and y>=-2 and y<=0
   if x*x+y*y<=78 and not eye and not nose and not(y<-4 and x%2==0) then add(x*2,y*2,0,'PlasticBlock',{.95,.95,.9}) end
  end end
 elseif name=='CHESS_ROOK' or name=='LIGHTHOUSE' then
  for y=0,30,2 do ring(y<4 and 11 or 7,y,0,0,name=='CHESS_ROOK' and 'StoneBlock' or 'PlasticBlock') end
  for x=-8,8,2 do for z=-8,8,2 do if x*x+z*z<100 then add(x,32,z,name=='LIGHTHOUSE' and 'GlassBlock' or 'StoneBlock') end end end
  for i=0,11 do local a=i*math.pi/6;add(math.cos(a)*8,34,math.sin(a)*8,'StoneBlock') end
 elseif name=='TREASURE_CHEST' then
  box(-10,10,0,0,-6,6)
  for y=2,10,2 do for x=-10,10,2 do for z=-6,6,2 do if math.abs(x)==10 or math.abs(z)==6 or y==10 then add(x,y,z,(math.abs(x)==6 or y==10) and 'GoldBlock' or 'WoodBlock') end end end end
  box(-2,2,6,8,-8,-8,'GoldBlock')
 elseif name=='RADAR' then
  box(-8,8,0,0,-8,8);box(0,0,2,12,0,0,'MetalBlock')
  for x=-8,8 do for z=-8,8 do if x*x+z*z<=64 then add(x*2,14+(x*x+z*z)*.12,z*2,'MetalBlock') end end end
 elseif name=='PICNIC' then
  box(-12,12,8,8,-4,4);for _,x in ipairs({-8,8}) do box(x,x,0,6,-2,-2);box(x,x,0,6,2,2) end
  for _,z in ipairs({-8,8}) do box(-12,12,4,4,z,z);box(-8,-8,0,2,z,z);box(8,8,0,2,z,z) end
 elseif name=='LAUNCH_PAD' then
  box(-16,16,0,2,-16,16,'StoneBlock');for x=-10,10,2 do add(x,4,0,'PlasticBlock',{1,.8,0}) end;for z=-10,10,2 do add(-10,4,z,'PlasticBlock',{1,.8,0});add(10,4,z,'PlasticBlock',{1,.8,0}) end
 elseif name=='TWIN_TOWERS' then
  for _,cx in ipairs({-12,12}) do for y=0,30,2 do for x=-4,4,2 do for z=-4,4,2 do if math.abs(x)==4 or math.abs(z)==4 or y%10==0 then add(cx+x,y,z,'StoneBlock') end end end end end
  box(-8,8,20,20,-2,2)
 elseif name=='AQUEDUCT' then
  for _,cx in ipairs({-18,0,18}) do for _,z in ipairs({-4,4}) do arch(cx,z) end end
  box(-26,26,22,22,-4,4);box(-26,26,24,26,-4,-4,'StoneBlock');box(-26,26,24,26,4,4,'StoneBlock')
 else error('Nieznany plan katalogu: '..tostring(name)) end
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
legacy.HEART=Shape.heart()
legacy.DOUBLE_HELIX=Shape.doubleHelix()
legacy.OBSERVATION_TOWER=Shape.observationTower()
for _,spec in ipairs(Shape.catalogSpecs) do legacy[spec[1]]=Shape.catalog(spec[1]) end

local AssetIndex={WORM_FILE={file="worm-red.json",title="Czerwony robak • plik z mechaniką",count=2830,need=4184},SHREDDER={file="shredder.json",title="Working Shredder • plik z mechaniką",count=960,need=973}}
legacy.WORM_FILE={}
legacy.SHREDDER={}
-- KUBI HUB V4.1. No downloaded UI libraries or third-party Lua are executed.
local H={version='4.1',alive=true,connections={},effects={},previewParts={},created={},log={},pending=nil}
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
 function H.run(fn) local ok,err=pcall(fn);if not ok then H.message(err,true);if H.notice then H.notice('Nie udało się wykonać akcji',tostring(err)) end end end
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
  local folders={data};for _,name in ipairs({'Inventory','Blocks','BlockInventory'}) do local f=data:FindFirstChild(name);if f then folders[#folders+1]=f end end
  for _,folder in ipairs(folders) do
   local v=folder:FindFirstChild(kind) or folder:FindFirstChild(kind:gsub('Block$',''))
   if v and (v:IsA('IntValue') or v:IsA('NumberValue')) then return math.max(0,math.floor(v.Value)),v end
  end
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
  local counts=H.requirements and H.requirements(parts) or Shape.count(parts);local names={};for kind in pairs(counts) do names[#names+1]=kind end;table.sort(names)
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
 H.new('TextLabel',{Position=UDim2.fromOffset(20,38),Size=UDim2.fromOffset(500,17),BackgroundTransparency=1,Text='V4.1  /  BUILD A BOAT FOR TREASURE',Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=H.palette.muted},H.top)
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
 -- Each request is awaited and verified before another placement is sent.
 function H.findTool(name)
  local names=({BuildingTool={'BuildingTool','BuildTool'},ScalingTool={'ScalingTool','ScaleTool'},PaintingTool={'PaintingTool','PaintTool'}})[name] or {name}
  local backpack=H.player:FindFirstChildOfClass('Backpack');local ch=H.player.Character
  for _,alias in ipairs(names) do local t=ch and ch:FindFirstChild(alias) or backpack and backpack:FindFirstChild(alias);if t and t:IsA('Tool') then return t end end
 end
 function H.remote(tool)
  if not tool then return nil end
  local rf=tool:FindFirstChild('RF');if rf and rf:IsA('RemoteFunction') then return rf end
  for _,obj in ipairs(tool:GetDescendants()) do if obj.Name=='RF' and obj:IsA('RemoteFunction') then return obj end end
 end
 function H.tool(name)
  local tool=H.findTool(name);if not tool then return nil,'Brak narzędzia '..name end
  local backpack=H.player:FindFirstChildOfClass('Backpack')
  if tool.Parent==backpack then local hum=H.humanoid();if not hum then return nil,'Brak aktywnej postaci' end;hum:EquipTool(tool);task.wait(.1) end
  return tool
 end
 function H.invoke(remote,args,timeout)
  if H.pending then return false,'Poprzednie żądanie serwera jeszcze trwa.' end
  if not remote or not remote:IsA('RemoteFunction') then return false,'Brak zgodnego narzędzia RF. Uruchom diagnostykę.' end
  local ticket={done=false};H.pending=ticket
  task.spawn(function()ticket.ok,ticket.result=pcall(function()return remote:InvokeServer(table.unpack(args,1,args.n or #args))end);ticket.done=true;if H.pending==ticket then H.pending=nil end end)
  local deadline=os.clock()+(timeout or 7)
  while H.alive and not ticket.done and os.clock()<deadline do task.wait(.02) end
  if not ticket.done then return false,'TIMEOUT: brak odpowiedzi serwera. Nie ponawiam żądania, by nie dublować bloków.' end
  if not ticket.ok then return false,tostring(ticket.result) end
  if ticket.result==false then return false,'Serwer odrzucił żądanie.' end
  return true,ticket.result
 end
 function H.part(model)
  if not model then return nil end;if model:IsA('BasePart') then return model end
  return model:FindFirstChild('PPart') or model:FindFirstChildWhichIsA('BasePart',true)
 end
 function H.buildOrigin()
  if H.originMode=='PLOT' then H.origin=H.defaultOrigin() end
  return H.origin
 end
 function H.originFor(parts,yaw)
  local b=Shape.bounds(parts)
  return H.buildOrigin()*CFrame.Angles(0,math.rad(yaw or 0),0)*CFrame.new(-(b.minX+b.maxX)/2,-b.minY-1,-(b.minZ+b.maxZ)/2)
 end
 function H.requirements(parts)
  local counts={}
  for _,p in ipairs(parts) do local cost=1;if p.size and p.kind:match('Block$') then cost=math.max(1,math.ceil(p.size[1]*p.size[2]*p.size[3]/8-.000001)) end;counts[p.kind]=(counts[p.kind] or 0)+cost end
  return counts
 end
 function H.needsScale(p)return p.size and (math.abs(p.size[1]-2)>.001 or math.abs(p.size[2]-2)>.001 or math.abs(p.size[3]-2)>.001) end
 function H.validateBuild(parts,origin)
  if H.s.building or H.pending then return false,'Poczekaj na zakończenie bieżącego żądania.' end
  if #parts==0 or #parts>6000 then return false,'Plan musi zawierać od 1 do 6000 elementów.' end
  local zone=H.zone();if not zone then return false,'Nie znaleziono działki. Dołącz do drużyny i sprawdź narzędzia BABFT w Ustawieniach.' end
  local summary,enough=H.summary(parts)
  if not enough then return false,'Brakuje materiałów. Potrzeba / dostępne:\n'..summary..'\nMożesz wybrać drewnianą wersję konstrukcji.' end
  for _,p in ipairs(parts) do
   local cf=origin*CFrame.new(p.x,p.y,p.z)*CFrame.Angles(math.rad(p.rx or 0),math.rad(p.ry or 0),math.rad(p.rz or 0))
   local size=p.size or {2,2,2}
   for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
    local pos=zone.CFrame:PointToObjectSpace((cf*CFrame.new(x*size[1]/2,y*size[2]/2,z*size[3]/2)).Position)
    if math.abs(pos.X)>zone.Size.X/2+.05 or math.abs(pos.Z)>zone.Size.Z/2+.05 then
     local b=Shape.bounds(parts);return false,string.format('Plan nie mieści się na działce. Rozmiar planu %.1f × %.1f; działka %.1f × %.1f. Zmień obrót lub wybierz mniejszy plan.',b.maxX-b.minX,b.maxZ-b.minZ,zone.Size.X,zone.Size.Z)
    end
   end end end
   if H.needsScale(p) and not H.remote(H.findTool('ScalingTool')) then return false,'Ten plan zawiera skalowane bloki i wymaga ScalingTool. Zwykłe schematy z bloków 2 × 2 × 2 go nie potrzebują.' end
  end
  local tool,err=H.tool('BuildingTool');if not tool then return false,err end
  if not H.remote(tool) then return false,'Brak BuildingTool.RF. Skopiuj raport narzędzi z Ustawień.' end
  return true,zone
 end
 function H.buildFailure(message)
  H.message(message,true);if H.buildProgress then H.buildProgress.Text=tostring(message) end
  if H.notice then H.notice('Budowa zatrzymana',tostring(message)) end
 end
 function H.verifyBlock(before,cf,result)
  local deadline=os.clock()+(H.s.verifyWait or 2.5)
  repeat
   local folder=H.ownFolder()
   if folder then
    if typeof(result)=='Instance' and result:IsDescendantOf(folder) then
     local model=result
     while model.Parent and model.Parent~=folder do model=model.Parent end
     if not before[model] and not H.created[model] and H.part(model) then return model end
    end
    for _,m in ipairs(folder:GetChildren()) do
     if not before[m] and not H.created[m] then local mp=H.part(m);if mp and (mp.Position-cf.Position).Magnitude<2 then return m end end
    end
   end
   task.wait(.04)
  until os.clock()>=deadline or not H.alive
 end
 function H.build(parts,origin,title)
  local valid,zone=H.validateBuild(parts,origin);if not valid then H.buildFailure(zone);return end
  H.s.farm=false;H.s.follow=false;H.s.orbit=false;H.s.building=true;H.s.buildPause=false;H.s.buildToken=H.s.buildToken+1
  local token=H.s.buildToken;H.previewClear();H.lastBuilt={};H.buildStats={sent=0,verified=0,failed=0,total=#parts,title=title,painted=0,paintUnverified=0,paintSkipped=0}
  H.message('Rozpoczynam '..title..': '..#parts..' elementów.')
  task.spawn(function()
   local ok,err=pcall(function()
    local paintQueue={};local paintAvailable=H.remote(H.findTool('PaintingTool'))~=nil and H.s.paint~=false
    for i,p in ipairs(parts) do
     if not H.alive or token~=H.s.buildToken then break end
     while H.s.buildPause and H.alive and token==H.s.buildToken do task.wait(.1) end
     if not H.alive or token~=H.s.buildToken then break end
     local have=H.inventory(p.kind);if not have or have<1 then error('Zabrakło materiału: '..p.kind) end
     local tool,toolErr=H.tool('BuildingTool');if not tool then error(toolErr) end
     local before={};local folder=H.ownFolder();if folder then for _,m in ipairs(folder:GetChildren()) do before[m]=true end end
     local cf=origin*CFrame.new(p.x,p.y,p.z)*CFrame.Angles(math.rad(p.rx or 0),math.rad(p.ry or 0),math.rad(p.rz or 0))
     H.buildStats.sent=H.buildStats.sent+1
     local called,result=H.invoke(H.remote(tool),{p.kind,have,zone,zone.CFrame:ToObjectSpace(cf),true,cf,false})
     if not called then H.buildStats.failed=H.buildStats.failed+1;error('Blok '..i..' ('..p.kind..'): '..tostring(result)) end
     local model=H.verifyBlock(before,cf,result)
     if not model then
      H.buildStats.failed=H.buildStats.failed+1
      local own=H.ownFolder();H.message('RF zwróciło '..typeof(result)..'; folder własnych bloków: '..(own and own.Name or 'nie znaleziono'))
      error('Brak potwierdzenia bloku '..i..' ('..p.kind..') po '..(H.s.verifyWait or 2.5)..' s. Podejdź na działkę. Uruchom TEST 1 BLOKU i skopiuj raport. Nie wysyłam kolejnych bloków.')
     end
     H.created[model]=true;H.lastBuilt[#H.lastBuilt+1]=model;H.buildStats.verified=H.buildStats.verified+1
     if H.needsScale(p) then
      local scale,scaleErr=H.tool('ScalingTool');if not scale then error(scaleErr) end
      local good,msg=H.invoke(H.remote(scale),{model,Vector3.new(p.size[1],p.size[2],p.size[3]),cf});if not good then error('Skalowanie: '..tostring(msg)) end
     end
     if p.color then if paintAvailable then paintQueue[#paintQueue+1]={model,Color3.new(p.color[1],p.color[2],p.color[3])} else H.buildStats.paintSkipped=H.buildStats.paintSkipped+1 end end
     if H.buildProgress then H.buildProgress.Text=string.format('%s\nPostawione %d/%d • żądania %d • błędy %d',title,H.buildStats.verified,#parts,H.buildStats.sent,H.buildStats.failed) end
     task.wait(H.s.buildDelay)
    end
    if H.alive and token==H.s.buildToken and #paintQueue>0 then
     local paint,paintErr=H.tool('PaintingTool');if not paint then error(paintErr) end
     for start=1,#paintQueue,32 do
      if not H.alive or token~=H.s.buildToken then break end
      while H.s.buildPause and H.alive and token==H.s.buildToken do task.wait(.1) end
      if not H.alive or token~=H.s.buildToken then break end
      local batch={};for j=start,math.min(#paintQueue,start+31) do if paintQueue[j][1].Parent then batch[#batch+1]=paintQueue[j] end end
      local good,msg=H.invoke(H.remote(paint),{batch});if not good then error('Malowanie: '..tostring(msg)) end
      task.wait(.12)
      for _,entry in ipairs(batch) do local part=H.part(entry[1]);local c=part and part.Color;local w=entry[2]
       if c and math.abs(c.R-w.R)<.03 and math.abs(c.G-w.G)<.03 and math.abs(c.B-w.B)<.03 then H.buildStats.painted=H.buildStats.painted+1 else H.buildStats.paintUnverified=H.buildStats.paintUnverified+1 end
      end
      if H.buildProgress then H.buildProgress.Text=string.format('%s\nPostawione %d/%d • kolory %d/%d potwierdzone',title,H.buildStats.verified,#parts,H.buildStats.painted,#paintQueue) end
      task.wait(H.s.buildDelay)
     end
    end
   end)
   H.s.building=false;H.s.buildPause=false
   local summary=string.format('%s: %d/%d elementów potwierdzonych.',title,H.buildStats.verified,#parts)
   if H.buildStats.paintSkipped>0 then summary=summary..' Pominięte kolory: '..H.buildStats.paintSkipped..' (brak PaintingTool lub malowanie OFF).' end
   if H.buildStats.paintUnverified>0 then summary=summary..' Kolory niepotwierdzone: '..H.buildStats.paintUnverified end
   if H.buildProgress then H.buildProgress.Text=summary end
   if not ok then H.buildFailure(summary..'\n'..tostring(err)) else H.message(token==H.s.buildToken and summary or 'Przerwano. '..summary) end
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
  H.button(card,'BUDUJ NA MOJEJ DZIAŁCE',function()
   local parts,origin,meta=get()
   if meta and meta.mechanical then H.notice('Plik z mechaniką','Ten plik jest dostępny do podglądu. Odtwarzanie połączeń WORM / SHREDDER w grze pozostaje niewykonane.');return end
   local pro=meta and meta.premium or title=='CIRCLE MAKER' and (H.s.circle.layers>4 or H.s.circle.filled) or title=='SHAPE LAB' and (H.s.other.filled or H.s.shape=='SPIRAL') or title=='BOMBA TNT' and H.s.bombCount>500
   if pro and not H.requireKey(meta and meta.title or title) then return end
   H.confirmBuild(parts,origin,meta and meta.title or title)
  end)
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
   return cached.parts,H.originFor(cached.parts,H.s.schemeYaw),cached.meta
  end
  local original=assert(legacy[name],'Nieznany schemat: '..tostring(name))
  local parts=Shape.prepare(original,{material=H.s.schemeMaterial,paint=H.s.paint,mirrorX=H.s.mirrorX,mirrorZ=H.s.mirrorZ})
  if H.s.bottomUp then table.sort(parts,function(a,b)if a.y~=b.y then return a.y<b.y elseif a.z~=b.z then return a.z<b.z else return a.x<b.x end end) end
  return parts,H.originFor(parts,H.s.schemeYaw),{title=name,premium=H.premiumSchemes[name]}
 end
 function H.refreshScheme()
  if not H.schemeInfo then return end
  local asset=AssetIndex[H.s.scheme]
  if asset then H.schemeInfo.Text=string.format('%s\n%d elementów / %d wymaganych bloków. Podgląd pliku; mechanika w przygotowaniu.',asset.title,asset.count,asset.need)
  else local p=H.schemeParts();local b=Shape.bounds(p);H.schemeInfo.Text=string.format('%s%s • %d elementów • %.0f × %.0f studów\n%s',H.premiumSchemes[H.s.scheme] and 'PRO • ' or '',H.favorites[H.s.scheme] and '★' or '',#p,b.maxX-b.minX,b.maxZ-b.minZ,H.summary(p)) end
 end
 function H.circleData()local parts=Shape.circle(H.s.circle);return parts,H.buildOrigin()*CFrame.Angles(0,math.rad(H.s.circle.yaw),0) end
 function H.refreshCircle(rebuildPreview)if H.circleCount then local parts=Shape.circle(H.s.circle);H.circleCount.Text=string.format('%d bloków • średnica %.1f studów\n%s',#parts,H.s.circle.radius*2,H.summary(parts)) end;if rebuildPreview~=false and H.s.livePreview and not H.s.building then local p,o=H.circleData();H.preview(p,o) end end
 function H.originFields(card)
  H.originBoxes={}
  for _,axis in ipairs({'X','Y','Z'}) do
   local key=axis
   H.originBoxes[key]=H.field(card,'Środek '..key,H.origin.Position[key],function(value)local n=tonumber(value);if not n or n~=n or math.abs(n)>100000 then return H.origin.Position[key] end;H.originMode='MANUAL';local pos=H.origin.Position;H.origin=CFrame.new(key=='X' and n or pos.X,key=='Y' and n or pos.Y,key=='Z' and n or pos.Z);H.refreshCircle();return n end,true)
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
   if hit then H.originMode='MANUAL';H.origin=CFrame.new(hit.Position+Vector3.new(0,1,0));H.picking=false;H.updateOriginBoxes();H.message('Środek ustawiony w klikniętym miejscu.') end
  end
  if H.s.infiniteJump and input.KeyCode==Enum.KeyCode.Space and not processed then local hum=H.humanoid();if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
 end)
 H.discord='https://discord.gg/qmWGb4Q9p'
 H.originMode='PLOT';H.s.titanium=false;H.s.schemeMaterial='ORIGINAL';H.s.schemeYaw=0;H.s.paint=true;H.s.verifyWait=2.5
 H.s.mirrorX=false;H.s.mirrorZ=false;H.s.coordHud=false;H.s.rainbow=false;H.s.lowFx=false;H.s.daylight=false
 H.premium=_G.KubiHubPremiumKey=='6969';H.bookmarks={};H.bookmarkIndex=1
 H.favorites=type(_G.KubiHubFavorites)=='table' and _G.KubiHubFavorites or {};_G.KubiHubFavorites=H.favorites
 H.premiumSchemes={FORTRESS=true,SPACESHIP=true,DOUBLE_HELIX=true,OBSERVATION_TOWER=true}
 function H.notice(title,message)
  if H.modal then H.modal:Destroy() end
  H.modal=H.new('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.12,ZIndex=40},H.frame)
  local box=H.new('Frame',{Size=UDim2.fromOffset(530,340),Position=UDim2.new(.5,-265,.5,-170),BackgroundColor3=H.palette.card,ZIndex=41},H.modal);H.corner(box,12)
  H.new('UIPadding',{PaddingLeft=UDim.new(0,18),PaddingRight=UDim.new(0,18),PaddingTop=UDim.new(0,12)},box);H.new('UIListLayout',{Padding=UDim.new(0,9)},box)
  local heading=H.label(box,title,28);heading.Font=Enum.Font.GothamBold;heading.ZIndex=42
  local scroll=H.new('ScrollingFrame',{Size=UDim2.new(1,0,0,194),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ZIndex=42},box)
  local detail=H.label(scroll,tostring(message),0);detail.Size=UDim2.new(1,-10,0,0);detail.AutomaticSize=Enum.AutomaticSize.Y;detail.TextYAlignment=Enum.TextYAlignment.Top;detail.ZIndex=43
  local copy=H.button(box,'KOPIUJ RAPORT',function()H.copyReport(tostring(message))end);copy.ZIndex=42
  local close=H.button(box,'ZAMKNIJ',function()H.modal:Destroy();H.modal=nil end);close.ZIndex=42
 end
 function H.requireKey(feature)
  if H.premium then return true end
  H.pendingFeature=feature;if H.pages.KEY then H.showPage('KEY') end
  if H.keyStatus then H.keyStatus.Text='Zablokowane: '..feature..'. Klucz znajdziesz na Discordzie KUBI HUB.' end
  H.message('Funkcja PRO: '..feature..'. Otwórz zakładkę KLUCZ / PRO.');return false
 end
 function H.unlock(value)
  if tostring(value):gsub('%s','')~='6969' then H.message('Nieprawidłowy klucz.',true);if H.keyStatus then H.keyStatus.Text='Nieprawidłowy klucz. Sprawdź kod na Discordzie.' end;return false end
  H.premium=true;_G.KubiHubPremiumKey='6969';if H.keyStatus then H.keyStatus.Text='PRO odblokowane w tej sesji. Wróć do wybranej funkcji.' end
  H.message('PRO odblokowane!');return true
 end
 function H.report(extra)
  local z=H.zone();local own=H.ownFolder();local lines={'KUBI HUB V4.1','Działka: '..(z and z.Name or 'BRAK'),'Folder bloków: '..(own and own.Name or 'BRAK')}
  if z then lines[#lines+1]=string.format('Rozmiar działki: %.1f / %.1f / %.1f',z.Size.X,z.Size.Y,z.Size.Z) end
  for _,folder in ipairs({H.player:FindFirstChildOfClass('Backpack'),H.player.Character}) do
   if folder then for _,t in ipairs(folder:GetChildren()) do if t:IsA('Tool') then local names={};for _,r in ipairs(t:GetDescendants()) do if r:IsA('RemoteFunction') or r:IsA('RemoteEvent') then names[#names+1]=r.Name..':'..r.ClassName end end;table.sort(names);lines[#lines+1]='Narzędzie '..t.Name..': '..table.concat(names,', ') end end end
  end
  for _,kind in ipairs({'WoodBlock','PlasticBlock','MetalBlock','TitaniumBlock','StoneBlock','GlassBlock','Seat','TNT'}) do local n=H.inventory(kind);lines[#lines+1]=kind..': '..(n and tostring(n) or 'NIE ODCZYTANO') end
  if extra then lines[#lines+1]=extra end;lines[#lines+1]='Ostatnie komunikaty:';for _,line in ipairs(H.log) do lines[#lines+1]=line end
  return table.concat(lines,'\n')
 end
 function H.copyReport(extra)
  local report=H.report(extra);if type(setclipboard)=='function' then setclipboard(report);H.message('Skopiowano raport. Wklej go na czacie, jeśli budowa nie działa.') else H.message('Schowek niedostępny. Raport jest w konsoli F9.',true) end;print(report);return report
 end
 function H.testBlock()
  local p={{kind='WoodBlock',x=0,y=0,z=0}}
  H.build(p,H.defaultOrigin()*CFrame.new(0,2,0),'TEST 1 BLOKU')
 end
 function H.setDaylight(on)
  local l=game:GetService('Lighting');H.s.daylight=on
  if on then if not H.lightBefore then H.lightBefore={ClockTime=l.ClockTime,Brightness=l.Brightness,GlobalShadows=l.GlobalShadows} end;l.ClockTime=14;l.Brightness=2;l.GlobalShadows=false
  elseif H.lightBefore then for k,v in pairs(H.lightBefore) do l[k]=v end;H.lightBefore=nil end
 end
 function H.setLowFx(on)
  H.s.lowFx=on
  if on then H.fxBefore=H.fxBefore or {};for _,folder in ipairs({workspace,game:GetService('Lighting')}) do for _,obj in ipairs(folder:GetDescendants()) do if obj:IsA('ParticleEmitter') or obj:IsA('Trail') or obj:IsA('Beam') or obj:IsA('PostEffect') then if H.fxBefore[obj]==nil then H.fxBefore[obj]=obj.Enabled end;obj.Enabled=false end end end
  else for obj,value in pairs(H.fxBefore or {}) do if obj.Parent then pcall(function()obj.Enabled=value end) end end;H.fxBefore={} end
 end
 function H.rainbow(on)
  if on and not H.requireKey('Tęczowy ślad') then return end
  if H.trail then H.trail:Destroy();H.trail=nil end;for _,a in ipairs(H.trailAttachments or {}) do a:Destroy() end;H.trailAttachments={};H.s.rainbow=false
  if not on then return end
  local r=H.root();if not r then H.message('Poczekaj na postać.',true);return end
  local a=H.new('Attachment',{Position=Vector3.new(-1,0,0)},r);local b=H.new('Attachment',{Position=Vector3.new(1,0,0)},r);H.trailAttachments={a,b}
  H.trail=H.new('Trail',{Attachment0=a,Attachment1=b,Lifetime=1.1,LightEmission=1,FaceCamera=true,Color=ColorSequence.new(H.palette.accent)},r);H.s.rainbow=true
 end
 function H.extraStop()
  H.rainbow(false);H.setLowFx(false);H.setDaylight(false);H.s.coordHud=false
  if H.coordHUD then H.coordHUD.Visible=false end
  if H.cameraBefore and H.cameraBefore.camera then pcall(function()H.cameraBefore.camera.FieldOfView=H.cameraBefore.fov end) end;H.cameraBefore=nil
 end
 function H.extraTick(now)
  if H.s.rainbow and H.trail then H.trail.Color=ColorSequence.new(Color3.fromHSV(now*.15%1,.85,1),Color3.fromHSV((now*.15+.3)%1,.85,1)) end
  if H.coordHUD then H.coordHUD.Visible=H.s.coordHud end
  if H.s.coordHud and now-(H.lastHUD or 0)>.2 then
   H.lastHUD=now;local r=H.root();local z=H.zone()
   if r then H.coordHUD.Text=string.format('KUBI HUB • X %.1f  Y %.1f  Z %.1f\nPrędkość %.1f • od działki %s',r.Position.X,r.Position.Y,r.Position.Z,r.AssemblyLinearVelocity.Magnitude,z and string.format('%.0f', (r.Position-z.Position).Magnitude) or '?') end
  end
 end
 function H.exportOwnBuild()
  if not H.requireKey('Zapis własnej budowli') then return end
  local folder=H.ownFolder();local zone=H.zone();assert(folder and zone,'Nie znaleziono Twoich bloków i działki.')
  local groups={};local count=0;local mechanical=false
  for _,model in ipairs(folder:GetChildren()) do
   local p=H.part(model);local kind=model.Name
   if p and kind:match('^[%w_ ]+$') and H.inventory(kind)~=nil then
    count=count+1;assert(count<=6000,'Limit eksportu: 6000 elementów');local relative=zone.CFrame:ToObjectSpace(p.CFrame);local rx,ry,rz=relative:ToOrientation()
    groups[kind]=groups[kind] or {};groups[kind][#groups[kind]+1]={Position={relative.X,relative.Y,relative.Z},Rotation={math.deg(rx),math.deg(ry),math.deg(rz)},Size={p.Size.X,p.Size.Y,p.Size.Z},Color={p.Color.R,p.Color.G,p.Color.B},Transparency=p.Transparency or 0}
    if not kind:match('Block$') and kind~='Seat' then mechanical=true end
   end
  end
  assert(count>0,'Brak rozpoznanych bloków do zapisania.');local json=H.Http:JSONEncode({format='LP_BUILD',name='Mój zapis KUBI HUB',mechanical=mechanical,blocks=groups})
  if type(setclipboard)=='function' then setclipboard(json);H.message('Skopiowano '..count..' elementów. Zapisz tekst jako plik JSON.') else H.message('Schowek niedostępny.',true) end
 end
 function H.installExtraPages()
  local page=H.page('KEY','KLUCZ / PRO')
  local card=H.card(page,'KUBI HUB • PRO','Wybrane większe schematy, złożone kształty, zapis własnej budowli i tęczowy ślad odblokujesz kluczem ze społeczności.')
  H.keyStatus=H.label(card,H.premium and 'PRO odblokowane w tej sesji.' or 'PRO zablokowane. Dołącz na Discord i wpisz klucz.',58,true)
  H.keyBox=H.field(card,'Twój klucz','',function(v)return v end)
  H.button(card,'ODBLOKUJ PRO',function()H.unlock(H.keyBox.Text)end)
  H.button(card,'DOŁĄCZ NA DISCORD • KOPIUJ LINK',function()if type(setclipboard)=='function' then setclipboard(H.discord);H.message('Skopiowano '..H.discord..'. Wklej w przeglądarce lub Discordzie.') else H.message(H.discord) end end)
  H.label(card,'Odblokowanie działa lokalnie. Hub nie sprawdza, czy dołączyłeś do serwera Discord.',52,true)
  H.button(card,'ZABLOKUJ PRO PONOWNIE',function()H.panic();H.premium=false;_G.KubiHubPremiumKey=nil;H.keyBox.Text='';H.keyStatus.Text='PRO zablokowane.'end)
  local page2=H.page('TOOLS','NARZĘDZIA +')
  local b=H.card(page2,'Naprawa i diagnostyka budowania','Test stawia jeden drewniany blok na środku działki. Podejdź do swojej działki, aby bloki były widoczne i wczytane.')
  H.button(b,'TEST 1 DREWNIANEGO BLOKU',H.testBlock)
  H.button(b,'POKAŻ RAPORT NARZĘDZI I MATERIAŁÓW',function()H.notice('Diagnostyka BABFT',H.report())end)
  H.button(b,'SKOPIUJ PEŁNY RAPORT',function()H.copyReport()end)
  local view=H.card(page2,'Widoczność i wygoda','Te ustawienia zmieniają obraz wyłącznie u Ciebie. STOP przywraca poprzednie ustawienia.')
  H.toggle(view,'Stały dzień • lokalnie',function()return H.s.daylight end,H.setDaylight)
  H.toggle(view,'Mniej efektów • lokalnie',function()return H.s.lowFx end,H.setLowFx)
  H.toggle(view,'Współrzędne i prędkość',function()return H.s.coordHud end,function(v)H.s.coordHud=v end)
  H.field(view,'Pole widzenia kamery',70,function(v)local c=workspace.CurrentCamera;if not c then return 70 end;if not H.cameraBefore then H.cameraBefore={camera=c,fov=c.FieldOfView} end;c.FieldOfView=Shape.number(v,70,40,110);return c.FieldOfView end,true)
  local saved=H.card(page2,'Punkty powrotu','Cztery własne pozycje w bieżącej sesji gry. Wybierz slot, zapisz miejsce i wróć do niego później.')
  H.cycle(saved,'Slot',{1,2,3,4},function()return H.bookmarkIndex end,function(v)H.bookmarkIndex=v end)
  H.button(saved,'ZAPISZ POZYCJĘ W SLOCIE',function()local r=H.root();if r then H.bookmarks[H.bookmarkIndex]=r.CFrame;H.message('Zapisano slot '..H.bookmarkIndex) end end)
  H.button(saved,'WRÓĆ DO SLOTU',function()local cf=H.bookmarks[H.bookmarkIndex];if cf then H.teleport(cf) else H.message('Ten slot jest pusty.',true) end end)
  local pro=H.card(page2,'Dodatki PRO','Tęczowy ślad jest lokalny. Eksport zapisuje geometrię i kolory własnych bloków; połączenia mechaniczne wymagają osobnej obsługi.')
  H.toggle(pro,'Tęczowy ślad • PRO, lokalny',function()return H.s.rainbow end,H.rainbow)
  H.button(pro,'ZAPISZ MOJĄ BUDOWLĘ DO SCHOWKA • PRO',H.exportOwnBuild)
  H.button(pro,'WYCZYŚĆ EFEKTY / PRZYWRÓĆ WIDOK',H.extraStop)
  H.coordHUD=H.new('TextLabel',{Size=UDim2.fromOffset(390,45),Position=UDim2.new(0,12,1,-65),BackgroundColor3=H.palette.bg,BackgroundTransparency=.25,Text='',TextColor3=H.palette.text,TextSize=12,Font=Enum.Font.Code,Visible=false},H.gui);H.corner(H.coordHUD,8)
 end

 do
  local home=H.page('HOME','START')
  local card=H.card(home,'Twój warsztat, jedno miejsce','Circle Maker, katalog narzędzi, rozbudowane schematy, generator kształtów, farmienie i narzędzia postaci.')
  H.button(card,'OTWÓRZ CIRCLE MAKER',function()H.showPage('CIRCLE')end)
  H.button(card,'SCHEMATY I WORM',function()H.showPage('SCHEMATY')end)
  H.button(card,'PANEL TROLLI',function()H.showPage('TROLLE')end)
  H.overview=H.label(card,'',75,true)
  local queue=H.card(home,'Kolejka budowania','Podglądy są lokalne. Licznik „potwierdzone” rośnie dopiero po znalezieniu rzeczywistego bloku na działce.')
  H.buildProgress=H.label(queue,'Nie rozpoczęto budowy.',80)
  H.button(queue,'PAUZA / WZNÓW',function()if not H.s.building then H.message('Brak aktywnej budowy.');return end;H.s.buildPause=not H.s.buildPause;H.message(H.s.buildPause and 'Budowa wstrzymana.' or 'Budowa wznowiona.')end)
  H.button(queue,'ANULUJ KOLEJKĘ',function()H.s.buildToken=H.s.buildToken+1;H.s.buildPause=false;H.message('Anulowano kolejne bloki. Trwające żądanie musi się zakończyć.')end,'danger')
  H.button(queue,'WYCZYŚĆ PODGLĄD',H.previewClear)
  H.button(queue,'TEST 1 DREWNIANEGO BLOKU',H.testBlock)
  H.button(queue,'POKAŻ PEŁNY RAPORT',function()H.notice('Diagnostyka BABFT',H.report())end)
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
  H.button(place,'ŚRODEK MOJEJ DZIAŁKI',function()H.originMode='PLOT';H.origin=H.defaultOrigin();H.updateOriginBoxes()end)
  H.button(place,'MIEJSCE POD MOJĄ POSTACIĄ',function()local r=H.root();if r then H.originMode='MANUAL';H.origin=CFrame.new(r.Position-Vector3.new(0,2,0));H.updateOriginBoxes()end end)
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
  local choices={'ORIGINAL'};for _,m in ipairs(H.materials) do choices[#choices+1]=m end
  H.cycle(card,'Materiał konstrukcji',choices,function()return H.s.schemeMaterial end,function(v)H.s.schemeMaterial=v;H.refreshScheme()end)
  H.button(card,'WERSJA DREWNIANA • zachowaj siedzenia',function()H.s.schemeMaterial='WoodBlock';H.refreshScheme();H.message('Konstrukcja będzie drewniana. Siedzenia i mechaniczne części zachowują swój typ.')end)
  H.cycle(card,'Obrót',{0,90,180,270},function()return H.s.schemeYaw end,function(v)H.s.schemeYaw=v;H.refreshScheme()end)
  H.toggle(card,'Lustro X',function()return H.s.mirrorX end,function(v)H.s.mirrorX=v end)
  H.toggle(card,'Lustro Z',function()return H.s.mirrorZ end,function(v)H.s.mirrorZ=v end)
  H.toggle(card,'Maluj, jeśli mam PaintingTool',function()return H.s.paint end,function(v)H.s.paint=v;H.refreshScheme()end)
  H.button(card,'DODAJ / USUŃ ULUBIONY SCHEMAT',function()H.favorites[H.s.scheme]=not H.favorites[H.s.scheme];H.refreshScheme()end)
  H.button(card,'NASTĘPNY ULUBIONY',function()local at=1;for i,n in ipairs(H.schemeNames) do if n==H.s.scheme then at=i;break end end;for i=1,#H.schemeNames do local name=H.schemeNames[(at+i-1)%#H.schemeNames+1];if H.favorites[name] then H.s.scheme=name;H.schemeChoice.Text='Schemat: '..name;H.refreshScheme();return end end;H.message('Dodaj najpierw ulubiony schemat.')end)
  H.toggle(card,'Animacja podglądu WORM',function()return H.s.previewMotion end,function(v)H.s.previewMotion=v end)
  H.actions(card,H.schemeParts,'SCHEMAT',true)
  local bomb=H.card(page,'BOMBA • TNT + stos drewna','1 TNT, 1 siedzenie przy TNT i do 3000 drewnianych bloków w jednym punkcie nad TNT. Odpalanie i rozrzut obsługuje fizyka oraz narzędzia gry.')
  H.field(bomb,'Drewno w stosie',3000,function(v)H.s.bombCount=Shape.number(v,H.s.bombCount,1,3000,true);H.bombInfo.Text=(H.s.bombCount+2)..' bloków\n'..H.summary(Shape.bomb(H.s.bombCount));return H.s.bombCount end,true)
  H.bombInfo=H.label(bomb,'3002 bloki\n'..H.summary(Shape.bomb(3000)),65,true)
  H.actions(bomb,function()local p=Shape.bomb(H.s.bombCount);return p,H.originFor(p) end,'BOMBA TNT')
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
  H.s.infiniteJump=false;H.s.antiAfk=false
  H.stopFly();H.restoreCamera();H.restoreCollision();H.previewClear();H.clearEffects();if H.extraStop then H.extraStop() end;if H.catalogStop then H.catalogStop() end;H.message('STOP: kolejka, farmienie, ruch i efekty zatrzymane.')
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
   H.s.rounds=H.s.rounds+1;H.s.stage=0;H.farmStatus('Respawn potwierdzony');H.farmWait(H.catalogFlags and H.catalogFlags.farmRest and 14 or 4)
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
   local parts,meta=H.decodeAsset(box.Text);H.fileParts=parts;H.fileMeta=meta
   H.fileInfo.Text=string.format('%d bloków; %s.\nPodgląd lokalny pokazuje geometrię, nie działanie połączeń.',#parts,meta.mechanical and 'plik zawiera mechanikę / powiązania' or 'geometria')
   local minX,minY,minZ,maxX,maxZ=math.huge,math.huge,math.huge,-math.huge,-math.huge
   for _,p in ipairs(parts) do minX=math.min(minX,p.x);maxX=math.max(maxX,p.x);minY=math.min(minY,p.y);minZ=math.min(minZ,p.z);maxZ=math.max(maxZ,p.z) end
   H.preview(parts,H.originFor(parts))
  end)
  H.button(card,'ZBUDUJ WCZYTANĄ GEOMETRIĘ',function()assert(H.fileParts,'Najpierw sprawdź plik.');if H.fileMeta.mechanical then H.notice('Plik z mechaniką','Ten plik zawiera powiązania lub części mechaniczne. Dostępny jest podgląd; nie obiecuję działających połączeń.');return end;H.confirmBuild(H.fileParts,H.originFor(H.fileParts),'PLIK JSON')end)
  H.label(card,'Do przeglądania plików nie są pobierane ani uruchamiane zewnętrzne skrypty. Format .Build jest czytany wyłącznie jako JSON.',55,true)
 end
 do
  local page=H.page('SETTINGS','USTAWIENIA')
  local card=H.card(page,'Wygląd i kolejka','Ukrywanie GUI: prawy Ctrl lub pływający przycisk K. Kolejka buduje pojedynczo i zatrzymuje się przy niepotwierdzonych blokach.')
  H.cycle(card,'Akcent',{'BLUE','PURPLE','RED','GREEN'},function()return H.accentName or 'BLUE' end,function(v)H.accentName=v;H.palette.accent=({BLUE=Color3.fromRGB(75,136,255),PURPLE=Color3.fromRGB(158,105,255),RED=Color3.fromRGB(240,80,105),GREEN=Color3.fromRGB(40,180,140)})[v];for _,entry in ipairs(H.accentItems) do if entry[1].Parent then entry[1][entry[2]]=H.palette.accent end end;H.showPage(H.currentPage)end)
  H.field(card,'Odstęp między blokami • s',.04,function(v)H.s.buildDelay=Shape.number(v,.04,.02,2);return H.s.buildDelay end,true)
  H.cycle(card,'Tempo budowy',{'FAST','TURBO','SAFE'},function()return H.buildMode or 'FAST' end,function(v)if v=='TURBO' and not H.requireKey('Tempo TURBO') then return end;H.buildMode=v;H.s.buildDelay=({FAST=.04,TURBO=.02,SAFE=.18})[v];H.message('Odstęp '..H.s.buildDelay..' s. Serwer nadal decyduje o przyjmowaniu żądań.')end)
  H.field(card,'Czekanie na blok • s',2.5,function(v)H.s.verifyWait=Shape.number(v,2.5,1,8);return H.s.verifyWait end,true)
  H.button(card,'SKOPIUJ LOG DIAGNOSTYCZNY',function()H.copyReport()end)
  H.button(card,'SPRAWDŹ NARZĘDZIA BABFT',function()
   local lines={};for _,folderName in ipairs({'Backpack','Character'}) do local folder=folderName=='Character' and H.player.Character or H.player:FindFirstChildOfClass('Backpack');if folder then for _,tool in ipairs(folder:GetChildren()) do if tool:IsA('Tool') then local remotes={};for _,obj in ipairs(tool:GetDescendants()) do if obj:IsA('RemoteFunction') or obj:IsA('RemoteEvent') then remotes[#remotes+1]=obj.Name..' ('..obj.ClassName..')' end end;table.sort(remotes);lines[#lines+1]=tool.Name..': '..table.concat(remotes,', ') end end end end;table.sort(lines);for _,line in ipairs(lines) do H.message(line) end;H.message('Lista narzędzi jest w logu diagnostycznym.')
  end)
  H.button(card,'SKOPIUJ STAŁY LOADER',function()if type(setclipboard)=='function' then setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/main.lua"))()');H.message('Skopiowano stały loader.') end end)
  H.button(card,'SKOPIUJ DISCORD KUBI HUB',function()if type(setclipboard)=='function' then setclipboard('https://discord.gg/qmWGb4Q9p');H.message('Skopiowano zaproszenie.') end end)
  H.button(card,'STOP WSZYSTKO',H.panic,'danger')
  H.button(card,'ZAMKNIJ I PRZYWRÓĆ POSTAĆ',function()_G.KubiHubV4Stop()end,'danger')
 end
  H.catalog={};H.catalogFlags={};H.catalogEffects={};H.breadcrumbs={};H.lastCatalogTick=0
 do
  local l=game:GetService('Lighting');local c=workspace.CurrentCamera
  H.viewSaved={ClockTime=l.ClockTime,Brightness=l.Brightness,GlobalShadows=l.GlobalShadows,FogEnd=l.FogEnd,Ambient=l.Ambient}
  H.catalogCamera=c and {camera=c,fov=c.FieldOfView,kind=c.CameraType,subject=c.CameraSubject,cf=c.CFrame} or nil
 end
 function H.catalogAdd(title,group,description,run,pro,flag)
  local entry={id=string.format('F%03d',#H.catalog+1),title=title,group=group,description=description,run=run,pro=pro==true,flag=flag}
  H.catalog[#H.catalog+1]=entry;return entry
 end
 function H.flag(name)
  H.catalogFlags[name]=not H.catalogFlags[name]
  if name=='stopTimer' then H.stopDeadline=H.catalogFlags[name] and os.clock()+300 or nil end
  if name=='ownBlocks' then H.knownOwn={};local f=H.ownFolder();if f then for _,m in ipairs(f:GetChildren()) do H.knownOwn[m]=true end end end
  if name=='route' or name=='autorun' then H.s.farm=false;H.s.follow=false;H.s.orbit=false end
  if name=='orbitCamera' and not H.catalogFlags[name] then H.restoreCatalogCamera() end
  if name=='autoZoom' and not H.catalogFlags[name] then local c=workspace.CurrentCamera;if c and H.catalogCamera and H.catalogCamera.fov then c.FieldOfView=H.catalogCamera.fov end end
  if name=='adaptiveFx' and not H.catalogFlags[name] then H.setLowFx(false) end
  H.message(name..': '..(H.catalogFlags[name] and 'ON' or 'OFF'))
 end
 function H.trackEffect(obj,seconds)
  H.catalogEffects[#H.catalogEffects+1]=obj
  if #H.catalogEffects>100 then local old=table.remove(H.catalogEffects,1);pcall(function()old:Destroy()end) end
  if seconds then task.delay(seconds,function()if obj.Parent then obj:Destroy() end end) end
  return obj
 end
 function H.clearCatalogEffects()
  for _,obj in ipairs(H.catalogEffects) do pcall(function()obj:Destroy()end) end;H.catalogEffects={};H.orbitParts=nil;H.haloParts=nil
  H.catalogFlags.footprints=false;H.catalogFlags.stars=false;H.catalogFlags.halo=false
 end
 function H.restoreCatalogCamera()
  H.catalogFlags.orbitCamera=false;local c=workspace.CurrentCamera;local saved=H.catalogCamera
  if c and saved then c.CameraType=saved.kind or Enum.CameraType.Custom;c.CameraSubject=H.humanoid() or saved.subject;if saved.fov then c.FieldOfView=saved.fov end;if saved.cf then c.CFrame=saved.cf end end
 end
 function H.restoreView()
  local l=game:GetService('Lighting');for k,v in pairs(H.viewSaved) do l[k]=v end;H.s.daylight=false;H.lightBefore=nil;H.restoreCatalogCamera()
 end
 function H.catalogStop()
  local hum=H.humanoid();local root=H.root();if hum and root then hum:MoveTo(root.Position) end
  if H.autoGuiBefore~=nil then H.frame.Visible=H.autoGuiBefore;H.bubble.Visible=not H.frame.Visible;H.autoGuiBefore=nil end
  H.catalogFlags={};H.stopDeadline=nil;H.clearCatalogEffects();H.restoreView();H.setLowFx(false)
  if H.playerMarkers then H.playerMarkers:Destroy();H.playerMarkers=nil end;H.markerCharacters={}
 end
 local originalClear=H.clearEffects
 function H.clearEffects()originalClear();H.clearCatalogEffects();H.rainbow(false)end
 function H.encodePlan(parts)
  local groups={};for _,p in ipairs(parts) do groups[p.kind]=groups[p.kind] or {};groups[p.kind][#groups[p.kind]+1]={Position={p.x,p.y,p.z},Rotation={p.rx or 0,p.ry or 0,p.rz or 0},Size=p.size or {2,2,2},Color=p.color,Transparency=p.transparency} end
  return H.Http:JSONEncode({format='LP_BUILD',mechanical=false,blocks=groups,name=H.s.scheme})
 end
 function H.copyText(value)if type(setclipboard)=='function' then setclipboard(value);H.message('Skopiowano do schowka.') else H.notice('Schowek niedostępny',value) end end
 function H.planBox()
  local p,o=H.schemeParts();local b=Shape.bounds(p);H.trackEffect(H.new('Part',{Name='KubiBounds',Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Transparency=.8,Color=H.palette.green,Size=Vector3.new(b.maxX-b.minX,b.maxY-b.minY,b.maxZ-b.minZ),CFrame=o*CFrame.new((b.minX+b.maxX)/2,(b.minY+b.maxY)/2,(b.minZ+b.maxZ)/2)},workspace),12)
  H.message('Zielona ramka pokazuje obszar schematu przez 12 s. To efekt lokalny.')
 end
 function H.fitPlan()
  local p=H.schemeParts();local b=Shape.bounds(p);local z=assert(H.zone(),'Nie znaleziono działki.');local x,d=b.maxX-b.minX,b.maxZ-b.minZ
  if x<=z.Size.X and d<=z.Size.Z then H.s.schemeYaw=0 elseif d<=z.Size.X and x<=z.Size.Z then H.s.schemeYaw=90 else H.notice('Plan zbyt duży','Schemat nie mieści się przy obrocie 0° ani 90°. Nie zmieniam jego skali ani kosztu.');return end
  H.originMode='PLOT';H.origin=H.defaultOrigin();H.refreshScheme();local parts,o=H.schemeParts();H.preview(parts,o);H.message('Dopasowano środek i obrót planu do prostokątnej działki.')
 end
 function H.localClone(player,scale,offset)
  local ch=player and player.Character;assert(ch,'Brak postaci do sklonowania.');local before=ch.Archivable;ch.Archivable=true;local ok,clone=pcall(function()return ch:Clone()end);ch.Archivable=before;assert(ok and clone,'Nie można skopiować postaci.')
  for _,obj in ipairs(clone:GetDescendants()) do if obj:IsA('Script') or obj:IsA('LocalScript') or obj:IsA('Tool') then obj:Destroy() elseif obj:IsA('BasePart') then obj.Anchored=true;obj.CanCollide=false;obj.CanTouch=false;obj.CanQuery=false end end
  clone.Name='KubiLocalClone';clone.Parent=workspace;H.trackEffect(clone,15);clone:ScaleTo(scale);clone:PivotTo(ch:GetPivot()*(offset or CFrame.new(5,0,0)));H.message('Lokalny sobowtór: 15 sekund.')
 end
 function H.particle(kind)
  local r=assert(H.root(),'Brak aktywnej postaci.');local a=H.trackEffect(H.new('Attachment',{Position=Vector3.new(0,kind=='snow' and 8 or 1,0)},r),7)
  local colors={snow=Color3.new(1,1,1),bubbles=Color3.fromRGB(120,210,255),firework=Color3.fromRGB(255,100,180),smoke=Color3.fromRGB(130,130,145),sparkles=Color3.fromRGB(255,210,50)}
  local smoke=kind=='smoke';local e=H.new('ParticleEmitter',{Texture=smoke and 'rbxasset://textures/particles/smoke_main.dds' or 'rbxasset://textures/particles/sparkles_main.dds',Rate=kind=='firework' and 0 or 22,Lifetime=NumberRange.new(1,3),Speed=NumberRange.new(kind=='firework' and 20 or 2,kind=='firework' and 40 or 7),SpreadAngle=Vector2.new(180,180),Size=NumberSequence.new(smoke and 2 or kind=='bubbles' and .7 or .3),Color=ColorSequence.new(colors[kind]),Acceleration=Vector3.new(0,kind=='snow' and -7 or kind=='firework' and -12 or 3,0),LightEmission=smoke and 0 or .8},a)
  if kind=='firework' then e:Emit(120) end;H.message('Efekt lokalny: '..kind..' (7 s).')
 end
 function H.orbitEffect(flag)
  H.catalogFlags[flag]=not H.catalogFlags[flag]
  local field=flag=='stars' and 'orbitParts' or 'haloParts'
  for _,p in ipairs(H[field] or {}) do p:Destroy() end;H[field]={}
  if H.catalogFlags[flag] then for i=1,flag=='stars' and 8 or 18 do H[field][i]=H.trackEffect(H.new('Part',{Name='KubiLocalOrbit',Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Material=Enum.Material.Neon,Shape=Enum.PartType.Ball,Size=Vector3.new(.5,.5,.5),Color=Color3.fromHSV(i/18,.8,1)},workspace)) end end
 end
 function H.cameraView(side)
  local c=assert(workspace.CurrentCamera,'Brak kamery.');local r=assert(H.root(),'Brak postaci.');H.catalogFlags.orbitCamera=false;c.CameraType=Enum.CameraType.Scriptable
  local offset=side=='top' and Vector3.new(0,65,.1) or side=='front' and Vector3.new(0,12,-35) or Vector3.new(35,12,0)
  c.CFrame=CFrame.lookAt(r.Position+offset,r.Position)
 end
 for i,spec in ipairs(Shape.catalogSpecs) do
  local name,title=spec[1],spec[2];local pro=i%5==0 or name=='DOUBLE_HELIX' or name=='OBSERVATION_TOWER';H.premiumSchemes[name]=pro
  H.catalogAdd(title,'BUDOWLE','Nowy statyczny plan. Otwiera podgląd i ustawienia przed budowaniem; używa posiadanych materiałów.',function()H.s.scheme=name;H.schemeChoice.Text='Schemat: '..name;H.refreshScheme();H.showPage('SCHEMATY');local p,o=H.schemeParts();H.preview(p,o)end,pro)
 end
 local function tool(title,desc,fn,pro)H.catalogAdd(title,'WARSZTAT',desc,fn,pro)end
 tool('Lustro konstrukcji X','Odwraca wybrany schemat względem osi X.',function()H.s.mirrorX=not H.s.mirrorX;H.refreshScheme()end)
 tool('Lustro konstrukcji Z','Odwraca wybrany schemat względem osi Z.',function()H.s.mirrorZ=not H.s.mirrorZ;H.refreshScheme()end)
 tool('Dopasuj obrót do działki','Dobiera 0° lub 90° i wyśrodkowuje plan.',H.fitPlan)
 tool('Drewniana wersja konstrukcji','Zamienia zwykłe materiały na drewno, zachowuje części specjalne.',function()H.s.schemeMaterial='WoodBlock';H.refreshScheme()end)
 tool('Przywróć oryginalne materiały','Cofa zamianę materiałów konstrukcji.',function()H.s.schemeMaterial='ORIGINAL';H.refreshScheme()end)
 tool('Buduj od dołu','Przełącza kolejność schematu według wysokości.',function()H.s.bottomUp=not H.s.bottomUp;H.message('Budowa od dołu: '..tostring(H.s.bottomUp))end)
 tool('Zmierz schemat','Pokazuje trzy wymiary i liczbę elementów.',function()local p=H.schemeParts();local b=Shape.bounds(p);H.notice('Wymiary planu',string.format('X %.1f • Y %.1f • Z %.1f\n%d elementów',b.maxX-b.minX,b.maxY-b.minY,b.maxZ-b.minZ,#p))end)
 tool('Lista potrzebnych materiałów','Porównuje koszt planu ze stanem ekwipunku.',function()local p=H.schemeParts();H.notice('Materiały • potrzeba / dostępne',H.summary(p))end)
 tool('Ramka obszaru budowy','Pokazuje lokalne granice planu przez 12 s.',H.planBox)
 tool('Eksport wybranego schematu','Kopiuje geometrię planu jako JSON.',function()local p,_,meta=H.schemeParts();assert(not(meta and meta.mechanical),'Mechaniczne pliki mają własne źródła.');H.copyText(H.encodePlan(p))end,true)
 tool('Zapis mojej budowli','Kopiuje geometrię własnych bloków jako JSON.',H.exportOwnBuild,true)
 tool('Ulubiony schemat','Dodaje lub usuwa wybrany schemat z ulubionych.',function()H.favorites[H.s.scheme]=not H.favorites[H.s.scheme];H.refreshScheme()end)
 tool('Losuj ulubiony schemat','Wybiera jeden z zapisanych ulubionych.',function()local list={};for _,n in ipairs(H.schemeNames) do if H.favorites[n] then list[#list+1]=n end end;assert(#list>0,'Najpierw dodaj ulubione.');H.s.scheme=list[math.random(#list)];H.schemeChoice.Text='Schemat: '..H.s.scheme;H.refreshScheme()end)
 for _,v in ipairs({{'Przesuń środek w prawo',2,0,0},{'Przesuń środek w lewo',-2,0,0},{'Podnieś środek',0,2,0},{'Obniż środek',0,-2,0},{'Przesuń środek w przód',0,0,-2},{'Przesuń środek w tył',0,0,2}}) do local a=v;tool(a[1],'Przesuwa punkt budowania o 2 study.',function()H.origin=H.buildOrigin()*CFrame.new(a[2],a[3],a[4]);H.originMode='MANUAL';H.updateOriginBoxes()end) end
 tool('Reset warsztatu','Przywraca środek działki, obrót, materiały i odbicia.',function()H.s.schemeYaw=0;H.s.mirrorX=false;H.s.mirrorZ=false;H.s.schemeMaterial='ORIGINAL';H.originMode='PLOT';H.origin=H.defaultOrigin();H.updateOriginBoxes();H.refreshScheme()end)
 local function view(title,desc,fn)H.catalogAdd(title,'WIDOK',desc..' Zmiana lokalna.',fn)end
 for _,v in ipairs({{'Pełne południe',14},{'Nocny klimat',0},{'Zachód słońca',18},{'Świt',6}}) do local a=v;view(a[1],'Ustawia porę dnia.',function()game:GetService('Lighting').ClockTime=a[2]end) end
 view('Usuń mgłę','Zwiększa dystans mgły.',function()game:GetService('Lighting').FogEnd=100000 end)
 view('Przywróć mgłę','Przywraca dystans z początku sesji.',function()if H.viewSaved.FogEnd then game:GetService('Lighting').FogEnd=H.viewSaved.FogEnd end end)
 view('Przełącz cienie','Przełącza globalne cienie.',function()local l=game:GetService('Lighting');l.GlobalShadows=not l.GlobalShadows end)
 view('Miękkie światło','Rozjaśnia światło otoczenia.',function()game:GetService('Lighting').Ambient=Color3.fromRGB(170,175,195)end)
 for _,v in ipairs({{'Zoom kinowy',40},{'Szeroka kamera',90},{'Bardzo szeroka kamera',110}}) do local a=v;view(a[1],'Ustawia pole widzenia kamery.',function()local c=assert(workspace.CurrentCamera,'Brak kamery.');c.FieldOfView=a[2]end) end
 view('Kamera z góry','Ustawia statyczny kadr nad własną postacią.',function()H.cameraView('top')end)
 view('Kamera z przodu','Ustawia statyczny kadr przed własną postacią.',function()H.cameraView('front')end)
 view('Kamera z boku','Ustawia statyczny kadr z boku własnej postaci.',function()H.cameraView('side')end)
 view('Reset kamery i oświetlenia','Przywraca widok z początku sesji.',H.restoreView)
 local function fun(title,desc,fn,pro,flag)H.catalogAdd(title,'ZABAWA',desc..' Efekt lokalny.',fn,pro,flag)end
 fun('Tęczowy ślad','Kolorowy ślad za Twoją postacią.',function()H.rainbow(not H.s.rainbow)end,true)
 for _,v in ipairs({{'Śnieżna chmura','snow'},{'Bąbelkowa aura','bubbles'},{'Fajerwerki','firework'},{'Chmura dymu','smoke'},{'Złote iskierki','sparkles'}}) do local a=v;fun(a[1],'Chwilowy efekt cząstek przy własnej postaci.',function()H.particle(a[2])end) end
 fun('Gwiazdy na orbicie','Kolorowe kule krążą wokół Twojej postaci.',function()H.orbitEffect('stars')end,false,'stars')
 fun('Kolorowe ślady stóp','Pozostawia chwilowe znaczniki podczas ruchu.',function()H.flag('footprints')end,false,'footprints')
 fun('Mini sobowtór','Tworzy małą kopię własnej postaci na 15 s.',function()H.localClone(H.player,.35)end)
 fun('Gigantyczny sobowtór','Tworzy dużą kopię własnej postaci na 15 s.',function()H.localClone(H.player,3,CFrame.new(10,0,0))end,true)
 fun('Armia sobowtórów','Pięć kopii Twojej postaci ustawionych w okręgu.',function()for i=1,5 do local a=i*math.pi*2/5;H.localClone(H.player,1,CFrame.new(math.cos(a)*9,0,math.sin(a)*9)) end end,true)
 fun('Sobowtór wybranego gracza','Kopiuje wygląd wybranego gracza na 15 s.',function()H.localClone(assert(H.selectedPlayer(),'Brak innego gracza.'),1)end)
 H.catalogAdd('Pomachaj','ZABAWA','Próbuje uruchomić gest wave własnego awatara. Obsługa i widoczność gestu zależą od gry.',function()assert(H.humanoid(),'Brak postaci.'):PlayEmote('wave')end)
 H.catalogAdd('Taniec','ZABAWA','Próbuje uruchomić gest dance własnego awatara. Obsługa i widoczność gestu zależą od gry.',function()assert(H.humanoid(),'Brak postaci.'):PlayEmote('dance')end)
 fun('Neonowa aureola','Neonowy pierścień nad własną postacią.',function()H.orbitEffect('halo')end,false,'halo')
 local autos={
  {'fallRescue','Ratunek po spadnięciu','Wraca na własną działkę po spadnięciu 40 studów poniżej niej.'},
  {'breadcrumbs','Automatyczne okruszki trasy','Zapamiętuje do 30 pozycji co 5 s w tej sesji.'},
  {'rewind','Powrót po ostatnich śladach','Cofa raz do najnowszej zapamiętanej pozycji.'},
  {'route','Spacer po zapisanych slotach','Powtarza spacer między czterema własnymi punktami.'},
  {'autorun','Automatyczny bieg','Biegnie w poziomym kierunku kamery. STOP kończy ruch.'},
  {'autoJump','Skok przy przeszkodzie','Próbuje przeskoczyć przeszkodę, gdy postać utknie w ruchu.'},
  {'getup','Automatyczne wstawanie','Próbuje wstać po przewróceniu własnej postaci.'},
  {'playerMarkers','Znaczniki graczy','Lokalne obrysy pozostałych postaci, odświeżane co 2 s.'},
  {'ownBlocks','Oznacz nowe własne bloki','Lokalnie wyróżnia nowo zaobserwowane bloki przez 4 s.'},
  {'adaptiveFx','Automatyczne ograniczanie efektów','Ogranicza lokalne efekty poniżej 35 FPS; przywraca powyżej 50.'},
  {'hideFarm','Ukryj okno podczas farmy','Chowa główne okno podczas aktywnej farmy i przywraca je po niej.'},
  {'farmRest','Przerwa między rundami','Dodaje 10 s odpoczynku po potwierdzonej rundzie farmy.'},
  {'stopTimer','STOP za pięć minut','Po 5 minutach zatrzymuje funkcje huba w tej sesji.'},
  {'plotGuard','Powiadomienie o opuszczeniu działki','Informuje przy przekroczeniu granic własnej działki.'},
  {'materialMonitor','Monitor materiałów schematu','Powiadamia, gdy zmieni się kompletność wymaganych materiałów.'},
  {'autoZoom','Kamera zależna od prędkości','Poszerza lokalne pole widzenia podczas szybkiego ruchu.'},
  {'orbitCamera','Automatyczna kamera orbitalna','Kamera okrąża Twoją postać; nie przemieszcza awatara.'},
  {'autoParty','Automatyczna impreza','Uruchamia lokalny efekt cząstek co 8 s.'},
  {'previewRainbow','Tęczowy podgląd budowli','Koloruje lokalne bloki podglądu, bez malowania na serwerze.'},
  {'respawnBookmark','Punkt startu po respawnie','Po odrodzeniu zapisuje pozycję w slocie 4.'}
 }
 for _,spec in ipairs(autos) do local key,title,desc=spec[1],spec[2],spec[3]
  H.catalogAdd(title,'AUTO',desc,function()
   if key=='rewind' then local cf=table.remove(H.breadcrumbs);assert(cf,'Włącz okruszki trasy i przemieść się.');H.teleport(cf)
   else H.flag(key) end
  end,key=='route' or key=='autoParty' or key=='previewRainbow',key~='rewind' and key or nil)
 end
 assert(#H.catalog==100,'Katalog musi zawierać dokładnie 100 akcji.')
 function H.runCatalog(entry)
  if entry.pro and not H.requireKey(entry.title) then return false end
  H.run(entry.run);H.filterCatalog();return true
 end
 function H.filterCatalog()
  if not H.catalogButtons then return end
  local q=(H.catalogQuery or ''):lower();local category=H.catalogCategory or 'WSZYSTKIE';local count=0
  for _,row in ipairs(H.catalogButtons) do local e=row.entry;local shown=(category=='WSZYSTKIE' or category==e.group) and (e.title:lower():find(q,1,true)~=nil or e.id:lower():find(q,1,true)~=nil)
   row.button.Visible=shown;if shown then count=count+1 end
   row.button.Text=e.id..' • '..(e.pro and 'PRO • ' or '')..e.title..(e.flag and (' ['..(H.catalogFlags[e.flag] and 'ON' or 'OFF')..']') or '')
  end
  H.catalogCount.Text=count..' / 100 akcji • wybierz kategorię albo wpisz nazwę. Opis wybranej akcji pojawi się poniżej.'
 end
 function H.installCatalogPage()
  local page=H.page('CATALOG','100 AKCJI')
  local controls=H.card(page,'100 narzędzi i gotowych akcji','30 planów, 20 akcji warsztatu, 15 ustawień widoku, 15 efektów i 20 pomocników. To także gotowe warianty i makra, nie 100 niezależnych mechanik gry.')
  H.catalogCount=H.label(controls,'',42,true);H.cycle(controls,'Kategoria',{'WSZYSTKIE','BUDOWLE','WARSZTAT','WIDOK','ZABAWA','AUTO'},function()return H.catalogCategory or 'WSZYSTKIE' end,function(v)H.catalogCategory=v;H.filterCatalog()end)
  H.field(controls,'Szukaj akcji','',function(v)H.catalogQuery=v;H.filterCatalog();return v end)
  H.catalogDescription=H.label(controls,'Kliknij akcję, aby ją uruchomić. Podglądy i efekty lokalne nie zmieniają budowli innych graczy.',75,true)
  H.button(controls,'STOP WSZYSTKIE AKCJE',H.panic,'danger')
  local list=H.card(page,'Katalog','Przyciski PRO wymagają klucza z Discorda. Plany otwierają warsztat; budowę uruchamiasz oddzielnie.')
  H.catalogButtons={};for _,entry in ipairs(H.catalog) do local e=entry;local b=H.button(list,e.title,function()H.catalogDescription.Text=e.description;H.runCatalog(e)end);H.catalogButtons[#H.catalogButtons+1]={entry=e,button=b} end
  H.filterCatalog()
 end
 function H.catalogTick(now,dt)
  local f=H.catalogFlags;local r=H.root();local hum=H.humanoid();local camera=workspace.CurrentCamera
  H.fpsEMA=(H.fpsEMA or 60)*.96+(dt and dt>0 and math.min(200,1/dt) or 60)*.04
  if camera and r and f.orbitCamera then camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(r.Position+Vector3.new(math.cos(now*.35)*24,10,math.sin(now*.35)*24),r.Position) end
  if camera and r and f.autoZoom then camera.FieldOfView=70+math.min(30,r.AssemblyLinearVelocity.Magnitude*.2) end
  for field,flag in pairs({orbitParts='stars',haloParts='halo'}) do if r and f[flag] then local list=H[field] or {};for i,p in ipairs(list) do if p.Parent then local a=now*(flag=='stars' and 1.6 or .5)+i*math.pi*2/#list;p.CFrame=CFrame.new(r.Position+Vector3.new(math.cos(a)*(flag=='stars' and 4 or 2),flag=='stars' and (2+math.sin(a*2)) or 4,math.sin(a)*(flag=='stars' and 4 or 2))) end end end end
  if f.previewRainbow then for i,e in ipairs(H.previewParts) do if e.part.Parent then e.part.Color=Color3.fromHSV((now*.08+i*.008)%1,.8,1) end end end
  if now-H.lastCatalogTick<.2 then return end;H.lastCatalogTick=now
  if f.stopTimer and H.stopDeadline and now>=H.stopDeadline then H.panic();H.message('Minęło pięć minut. Zatrzymano hub.');return end
  if not r or not hum then return end
  local zone=H.zone()
  if f.fallRescue and zone and r.Position.Y<zone.Position.Y-40 and not H.s.building then H.teleport(zone.CFrame*CFrame.new(0,6,0)) end
  if f.breadcrumbs and now-(H.lastCrumb or 0)>5 then H.lastCrumb=now;H.breadcrumbs[#H.breadcrumbs+1]=r.CFrame;if #H.breadcrumbs>30 then table.remove(H.breadcrumbs,1) end end
  if f.route and not H.s.building and not H.s.farm then
   local index=H.routeIndex or 1;local point=H.bookmarks[index]
   if not point or (point.Position-r.Position).Magnitude<4 then H.routeIndex=index%4+1 else hum:MoveTo(point.Position) end
  elseif f.autorun and camera and not H.s.building and not H.s.farm then local dir=camera.CFrame.LookVector;local flat=Vector3.new(dir.X,0,dir.Z);if flat.Magnitude>.01 then hum:MoveTo(r.Position+flat.Unit*30) end end
  if f.autoJump and hum.MoveDirection.Magnitude>.1 and r.AssemblyLinearVelocity.Magnitude<1.5 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
  if f.getup and not H.s.fly then local state=hum:GetState();if state==Enum.HumanoidStateType.FallingDown or state==Enum.HumanoidStateType.Ragdoll then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end end
  if f.adaptiveFx then if H.fpsEMA<35 and not H.s.lowFx then H.setLowFx(true) elseif H.fpsEMA>50 and H.s.lowFx then H.setLowFx(false) end end
  if f.hideFarm then
   if H.s.farm and H.autoGuiBefore==nil then H.autoGuiBefore=H.frame.Visible;H.frame.Visible=false;H.bubble.Visible=true
   elseif not H.s.farm and H.autoGuiBefore~=nil then H.frame.Visible=H.autoGuiBefore;H.bubble.Visible=not H.frame.Visible;H.autoGuiBefore=nil end
  elseif H.autoGuiBefore~=nil then H.frame.Visible=H.autoGuiBefore;H.bubble.Visible=not H.frame.Visible;H.autoGuiBefore=nil end
  if f.plotGuard and zone then local p=zone.CFrame:PointToObjectSpace(r.Position);local outside=math.abs(p.X)>zone.Size.X/2 or math.abs(p.Z)>zone.Size.Z/2;if outside~=H.plotWasOutside then H.plotWasOutside=outside;if outside then H.message('Opuściłeś obszar swojej działki.') end end end
  if f.footprints and now-(H.lastFoot or 0)>.45 and r.AssemblyLinearVelocity.Magnitude>2 then H.lastFoot=now;H.trackEffect(H.new('Part',{Name='KubiLocalFootprint',Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Size=Vector3.new(1,.1,1),Color=Color3.fromHSV(now*.1%1,.8,1),Material=Enum.Material.Neon,CFrame=r.CFrame*CFrame.new(0,-2.8,0)},workspace),4) end
  if f.autoParty and now-(H.lastParty or 0)>8 then H.lastParty=now;H.particle(({'snow','bubbles','firework','sparkles'})[math.random(4)]) end
  if f.materialMonitor and now-(H.lastMaterialCheck or 0)>4 then H.lastMaterialCheck=now;if not AssetIndex[H.s.scheme] then local parts=H.schemeParts();local _,enough=H.summary(parts);if enough~=H.lastEnough then H.lastEnough=enough;H.message(enough and 'Masz komplet materiałów wybranego schematu.' or 'Brakuje części materiałów wybranego schematu.') end end end
  if f.ownBlocks and now-(H.lastOwnCheck or 0)>1 then
   H.lastOwnCheck=now;H.knownOwn=H.knownOwn or {};local folder=H.ownFolder()
   if folder then for _,m in ipairs(folder:GetChildren()) do if not H.knownOwn[m] then H.knownOwn[m]=true;H.trackEffect(H.new('Highlight',{Adornee=m,FillColor=H.palette.green,FillTransparency=.6,OutlineColor=H.palette.green},m),4) end end end
  end
  if now-(H.lastMarkerCheck or 0)>2 then
   H.lastMarkerCheck=now
   if f.playerMarkers then
    if H.playerMarkers then H.playerMarkers:Destroy() end;H.playerMarkers=H.new('Folder',{Name='KubiLocalPlayerMarkers'},workspace)
    for _,p in ipairs(H.Players:GetPlayers()) do if p~=H.player and p.Character then H.new('Highlight',{Adornee=p.Character,FillTransparency=.85,OutlineColor=H.palette.accent},H.playerMarkers) end end
   elseif H.playerMarkers then H.playerMarkers:Destroy();H.playerMarkers=nil end
  end
 end

 H.installExtraPages();H.installCatalogPage()
 function H.captureCharacter()
  local hum=H.humanoid();if not hum then return end
  H.savedCharacter={hum=hum,walk=hum.WalkSpeed,jump=hum.JumpPower,jumpHeight=hum.JumpHeight,platform=hum.PlatformStand}
  hum.WalkSpeed=H.s.walk;if hum.UseJumpPower then hum.JumpPower=H.s.jump else hum.JumpHeight=H.s.jump^2/(2*workspace.Gravity) end
  if H.s.fly then H.startFly() end
 end
 H.captureCharacter()
 H.connect(H.player.CharacterAdded,function()H.stopFly();H.savedCollision={};task.wait(.9);if H.alive then H.captureCharacter();if H.catalogFlags and H.catalogFlags.respawnBookmark then local r=H.root();if r then H.bookmarks[4]=r.CFrame end end;if H.s.rainbow then H.rainbow(true) end;if not H.s.spectate then H.restoreCamera() end end end)
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
  H.extraTick(now);if H.catalogTick then H.catalogTick(now,dt) end
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
 print('[KUBI HUB V4.1] GUI, Circle Maker, Shape Lab, blueprints, TNT payload, farm and player tools loaded.')
end,function(err)return tostring(err)..'\n'..(debug and debug.traceback and debug.traceback() or '')end)
if not bootOK then
 warn('[KUBI HUB V4.1 STARTUP] '..tostring(bootError))
 pcall(function()
  if type(_G.KubiHubV4Stop)=='function' then _G.KubiHubV4Stop() else H.alive=false;for _,c in ipairs(H.connections) do pcall(function()c:Disconnect()end) end;if H.previewFolder then H.previewFolder:Destroy() end;if H.gui then H.gui:Destroy() end end
  local player=game:GetService('Players').LocalPlayer;local pg=player and player:FindFirstChild('PlayerGui');if not pg then return end
  local gui=Instance.new('ScreenGui');gui.Name='KubiHubDiagnostics';gui.ResetOnSpawn=false;gui.Parent=pg
  local label=Instance.new('TextLabel');label.Size=UDim2.fromOffset(440,210);label.Position=UDim2.new(.5,-220,.5,-105);label.BackgroundColor3=Color3.fromRGB(22,26,39);label.TextColor3=Color3.fromRGB(255,130,140);label.Font=Enum.Font.Code;label.TextSize=13;label.TextWrapped=true;label.Text='KUBI HUB V4.1\nBłąd uruchamiania. Szczegóły: F9.\n\n'..string.sub(tostring(bootError),1,350);label.Parent=gui
 end)
end
