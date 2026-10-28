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
 Shape.add(out,'Dynamite',0,0,0,{group='charge'})
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
return Shape
