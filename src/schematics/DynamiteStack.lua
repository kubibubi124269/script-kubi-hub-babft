return function(Schema)
 local function create(count)
  assert(type(count)=='number' and count>=1 and count<=3000 and count%1==0,'Stos: 1–3000 drewnianych bloków.')
  local s={schemaVersion=2,id='DYNAMITE_STACK',name='Dynamit + stos '..count..' drewna',category='Proste budowle',elements={},connections={},mechanical=false,assistantOnly=true,intentionalOverlap=true}
  local function add(id,name,material,pos,size,class,color)
   s.elements[#s.elements+1]={id=id,name=name,material=material,position=pos,size=size or {2,2,2},rotation={0,0,0},layer=material=='WoodBlock' and 1 or 0,class=class or 'Part',color=color}
  end
  add('dynamite','Laska dynamitu','Dynamite',{0,1,0},{.7,3,.7},nil,{.9,.05,.04})
  add('seat','Jedyne siedzenie','Seat',{0,1,2},{2,1,2},'Seat',{.2,.2,.2})
  s.connections[1]={id='seat_to_dynamite',a='dynamite',b='seat',kind='Weld'}
  for i=1,count do add('wood_'..i,'Drewno w stosie '..i,'WoodBlock',{0,4,0}) end
  -- Deliberate overlap is represented as data. This assistant does not detonate explosives or flood a public server.
  return Schema.validate(s)
 end
 return create
end
