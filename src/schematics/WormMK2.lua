return function(Schema)
 local function create()
  local s={schemaVersion=2,id='WORM_MK2',name='WORM MK2 — rig testowy',category='WORMS',elements={},connections={},mechanical=true,root='body_1',driver='driver',rig='worm_mk2'}
  local red,white={.84,.025,.045},{.96,.96,.89}
  local function part(id,name,material,pos,size,rot,class,layer,color)
   s.elements[#s.elements+1]={id=id,name=name,material=material,position=pos,size=size,rotation=rot or {0,0,0},class=class or 'Part',layer=layer or 0,color=color or red}
  end
  local function weld(a,b) s.connections[#s.connections+1]={id='weld_'..#s.connections,a=a,b=b,kind='Weld'} end
  local function hinge(id,a,b,pivot,axis,role,lower,upper)
   s.connections[#s.connections+1]={id=id,a=a,b=b,kind='Hinge',pivot=pivot,axis=axis,lower=lower or -22,upper=upper or 22,role=role}
  end
  for i=1,9 do
   part('body_'..i,'Segment '..i,'MetalBlock',{0,6,(i-1)*7},{6,5,6},nil,nil,i)
   if i>1 then hinge('spine_'..i,'body_'..(i-1),'body_'..i,{0,6,(i-1)*7-3.5},{0,1,0},'spine') end
   for _,side in ipairs({-1,1}) do local id='ridge_'..i..'_'..(side+2);part(id,'Pancerz segmentu '..i,'PlasticBlock',{side*3.5,6,(i-1)*7},{1,3,4},nil,nil,i);weld('body_'..i,id) end
  end
  part('head','Głowa','MetalBlock',{0,6,-7},{6,6,6},nil,nil,10)
  hinge('neck','body_1','head',{0,6,-3.5},{0,1,0},'neck',-18,18)
  part('driver','Fotel kierowcy','CarSeat',{0,9.5,1},{2,1.5,2},nil,'VehicleSeat',1,{.12,.12,.16});weld('body_1','driver')
  for i=1,5 do
   local a=(i-1)*math.pi*2/5+math.pi/2;local c,n=math.cos(a),math.sin(a);local id='petal_'..i
   part(id,'Płat paszczy '..i,'PlasticBlock',{c*6,6+n*6,-10},{3,6,1.2},{0,0,math.deg(a)-90},'WedgePart',11)
   hinge('mouth_'..i,'head',id,{c*3,6+n*3,-10},{-n,c,0},'mouth',-5,65)
   for j=1,3 do
    local r=3.7+j*1.25;local tooth='tooth_'..i..'_'..j
    part(tooth,'Ząb '..i..'.'..j,'PlasticBlock',{c*r,6+n*r,-10.9},{.7,1.4,.7},{0,0,math.deg(a)-90},'WedgePart',11,white);weld(id,tooth)
   end
  end
  local valid,errors=Schema.validate(s);assert(valid,table.concat(errors,'; '));return valid
 end
 return create
end
