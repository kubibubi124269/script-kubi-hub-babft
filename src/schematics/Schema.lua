return function(Util,Inventory)
 local Schema={version=2,limit=6000}
 function Schema.validate(raw)
  local errors={};local function bad(s)errors[#errors+1]=s end
  if type(raw)~='table' then return nil,{'Schemat musi być obiektem.'} end
  if raw.schemaVersion~=2 then return nil,{'Nieobsługiwana wersja schematu.'} end
  for _,flag in ipairs({'mechanical','assistantOnly','intentionalOverlap','importedMechanics'}) do if raw[flag]~=nil and type(raw[flag])~='boolean' then bad('Pole '..flag..' wymaga wartości boolean.') end end
  if not Util.id(raw.id) or type(raw.name)~='string' or #raw.name<1 or #raw.name>120 then bad('Nieprawidłowy identyfikator lub nazwa.') end
  if type(raw.elements)~='table' or #raw.elements<1 or #raw.elements>Schema.limit then return nil,{'Schemat wymaga 1–6000 elementów.'} end
  if type(raw.connections)~='table' or #raw.connections>12000 then return nil,{'Nieprawidłowa lista połączeń.'} end
  local ids,adj={},{ }
  for i,e in ipairs(raw.elements) do
   if type(e)~='table' then bad('Element '..i..' nie jest obiektem.');continue end
   if not Util.id(e.id) or ids[e.id] then bad('Błędny lub powtórzony ID elementu '..i) else ids[e.id]=e;adj[e.id]={} end
   if type(e.name)~='string' or #e.name>120 then bad('Brak nazwy elementu '..i) end
   if not Inventory.definitions[e.material] then bad('Nieznany identyfikator materiału: '..tostring(e.material)) end
   if not Util.vector(e.position,10000) or not Util.vector(e.rotation,36000) or not Util.vector(e.size,200) then bad('Nieprawidłowe pozycja / obrót / rozmiar: '..i)
   else for _,s in ipairs(e.size) do if s<=0 then bad('Nieprawidłowy rozmiar: '..i) end end end
   if e.color~=nil then if not Util.vector(e.color,1) then bad('Nieprawidłowy kolor: '..i) else for _,c in ipairs(e.color) do if c<0 then bad('Ujemny kolor.') end end end end
   if not Util.finite(e.layer) or e.layer<0 or e.layer>1000 or e.layer%1~=0 then bad('Nieprawidłowa warstwa: '..i) end
   if e.class~='Part' and e.class~='WedgePart' and e.class~='VehicleSeat' and e.class~='Seat' then bad('Nieobsługiwana klasa elementu: '..tostring(e.class)) end
  end
  local connectionIds={}
  for i,c in ipairs(raw.connections) do
   if type(c)~='table' or not Util.id(c.id) or connectionIds[c.id] then bad('Nieprawidłowe ID połączenia '..i);continue end;connectionIds[c.id]=true
   if not ids[c.a] or not ids[c.b] or c.a==c.b then bad('Połączenie wskazuje nieistniejący lub ten sam element: '..i)
   else table.insert(adj[c.a],c.b);table.insert(adj[c.b],c.a) end
   if c.kind~='Weld' and c.kind~='Hinge' then bad('Nieobsługiwany typ połączenia: '..i) end
   if c.kind=='Hinge' then
    if raw.mechanical~=true then bad('Plan z zawiasami musi być oznaczony jako mechaniczny.') end
    if not Util.vector(c.pivot,10000) or not Util.vector(c.axis,1) then bad('Nieprawidłowa oś zawiasu: '..i)
    else local length=0;for _,v in ipairs(c.axis) do length=length+v*v end;if math.abs(length-1)>.0001 then bad('Oś zawiasu musi być jednostkowa: '..i) end end
    if not Util.finite(c.lower) or not Util.finite(c.upper) or c.lower>c.upper or c.lower<-90 or c.upper>90 then bad('Nieprawidłowy zakres zawiasu: '..i) end
   end
  end
  if raw.mechanical then
   if not ids[raw.root] then bad('Brak korzenia konstrukcji.') end
   if not ids[raw.driver] or ids[raw.driver].class~='VehicleSeat' then bad('Brak fotela kierowcy.') end
   if ids[raw.root] then local visited={[raw.root]=true};local queue={raw.root};local n=1;while n<=#queue do local id=queue[n];n=n+1;for _,nextId in ipairs(adj[id]) do if not visited[nextId] then visited[nextId]=true;queue[#queue+1]=nextId end end end;for id in pairs(ids) do if not visited[id] then bad('Niepołączony element: '..id) end end end
  end
  if #errors>0 then return nil,errors end
  local out=Util.copy(raw);out.category=type(raw.category)=='string' and raw.category or 'Proste budowle';return out,{}
 end
 function Schema.bounds(schema,yaw)
  local min,max={math.huge,math.huge,math.huge},{-math.huge,-math.huge,-math.huge}
  for _,e in ipairs(schema.elements) do
   for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
    local p=Util.rotate({x*e.size[1]/2,y*e.size[2]/2,z*e.size[3]/2},e.rotation)
    p=Util.rotate({p[1]+e.position[1],p[2]+e.position[2],p[3]+e.position[3]},{0,yaw or 0,0})
    for i=1,3 do min[i]=math.min(min[i],p[i]);max[i]=math.max(max[i],p[i]) end
   end end end
  end
  return {min=min,max=max,size={max[1]-min[1],max[2]-min[2],max[3]-min[3]},center={(max[1]+min[1])/2,(max[2]+min[2])/2,(max[3]+min[3])/2}}
 end
 function Schema.fromLegacy(id,name,parts,category)
  local out={schemaVersion=2,id=id,name=name,category=category or 'Proste budowle',elements={},connections={},mechanical=false}
  if type(parts)~='table' or #parts>Schema.limit then return nil,{'Nieprawidłowa lista części.'} end
  local levels={};for i,p in ipairs(parts) do
   if type(p)~='table' or type(p.kind)~='string' or not Util.vector({p.x,p.y,p.z},10000) then return nil,{'Nieprawidłowy element planu: '..i} end
   levels[math.floor(p.y/2+1e-8)]=true
  end
  local sorted=Util.keys(levels);for i,key in ipairs(sorted) do levels[key]=i end
  for i,p in ipairs(parts) do out.elements[i]={id='part_'..i,name=p.kind..' '..i,material=p.kind,position={p.x,p.y,p.z},rotation={p.rx or 0,p.ry or 0,p.rz or 0},size=p.size or {2,2,2},color=p.color,layer=levels[math.floor(p.y/2+1e-8)],class=(p.kind=='CarSeat' or p.kind=='PilotSeat') and 'VehicleSeat' or p.kind=='Seat' and 'Seat' or 'Part'} end
  return Schema.validate(out)
 end
 function Schema.import(raw)
  if type(raw)~='table' then return nil,{'Nieprawidłowy JSON.'} end
  if raw.schemaVersion then return Schema.validate(raw) end
  local groups=raw.blocks or raw;local parts={};local complex=raw.mechanical==true
  if type(groups)~='table' then return nil,{'LP_BUILD wymaga listy materiałów.'} end
  for id,rows in pairs(groups) do if not Inventory.definitions[id] or type(rows)~='table' then return nil,{'Nieznany materiał albo nieobsługiwany format LP_BUILD: '..tostring(id)} end end
  for _,id in ipairs(Util.keys(groups)) do local rows=groups[id]
   for _,item in ipairs(rows) do
    if #parts>=Schema.limit or type(item)~='table' or not Util.vector(item.Position,10000) or not Util.vector(item.Rotation or {0,0,0},36000) then return nil,{'Nieprawidłowy element LP_BUILD.'} end
    local p=item.Position;local r=item.Rotation or {0,0,0};parts[#parts+1]={kind=id,x=p[1],y=p[2],z=p[3],rx=r[1],ry=r[2],rz=r[3],size=item.Size,color=item.Color}
    if item.BindTable~=nil and type(item.BindTable)~='table' then return nil,{'BindTable musi być tabelą danych.'} end
    if item.BindTable and next(item.BindTable) or id=='Servo' or id=='Piston' then complex=true end
   end
  end
  local result,errors=Schema.fromLegacy('imported','Importowany projekt',parts,'Własne projekty');if result then result.importedMechanics=complex end;return result,errors
 end
 function Schema.transform(schema,options)
  local out=Util.copy(schema);options=options or {}
  local scale=options.scale or 1;local offset={options.offsetX or 0,options.offsetY or 0,options.offsetZ or 0}
  if not Util.finite(scale) or scale<.1 or scale>2 or not Util.vector(offset,1000) then return nil,{'Nieprawidłowa skala lub przesunięcie projektu.'} end
  if scale~=1 then
   if schema.mechanical or schema.importedMechanics then return nil,{'Skalowanie mechaniki jest zablokowane; można ją przesuwać i obracać.'} end
   for _,c in ipairs(schema.connections) do if c.kind=='Hinge' then return nil,{'Nie skaluję planu z zawiasami.'} end end
  end
  -- Mirroring native hinges requires transforming their handed control axes; reject rather than corrupt the rig.
  if schema.mechanical and (options.mirrorX or options.mirrorZ) then return nil,{'Odbijanie mechanicznego WORM-a nie jest obsługiwane. Obrót pozostaje dostępny.'} end
  for _,e in ipairs(out.elements) do
   if options.material and options.material~='ORIGINAL' and e.material:match('Block$') then if not Inventory.definitions[options.material] then return nil,{'Nieznany materiał.'} end;e.material=options.material end
   if options.mirrorX then e.position[1]=-e.position[1];e.rotation[2]=-e.rotation[2];e.rotation[3]=-e.rotation[3] end
   if options.mirrorZ then e.position[3]=-e.position[3];e.rotation[1]=-e.rotation[1];e.rotation[2]=-e.rotation[2] end
   for i=1,3 do e.position[i]=e.position[i]*scale+offset[i];e.size[i]=e.size[i]*scale end
  end
  for _,c in ipairs(out.connections) do if c.kind=='Hinge' then for i=1,3 do c.pivot[i]=c.pivot[i]+offset[i] end end end
  return Schema.validate(out)
 end
 function Schema.bakeYaw(schema,yaw)
  if not Util.finite(yaw) or math.abs(yaw)>360 then return nil,{'Nieprawidłowy obrót eksportu.'} end
  local out,errors=Schema.validate(schema);if not out then return nil,errors end
  for _,e in ipairs(out.elements) do e.position=Util.rotate(e.position,{0,yaw,0});e.rotation=Util.yawRotation(e.rotation,yaw) end
  for _,c in ipairs(out.connections) do if c.kind=='Hinge' then c.pivot=Util.rotate(c.pivot,{0,yaw,0});c.axis=Util.rotate(c.axis,{0,yaw,0}) end end
  return Schema.validate(out)
 end
 return Schema
end
