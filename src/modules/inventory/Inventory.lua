return function(Util)
 local Inventory={}
 Inventory.definitions={}
 for _,id in ipairs({'WoodBlock','PlasticBlock','MetalBlock','TitaniumBlock','GlassBlock','ConcreteBlock','StoneBlock','MarbleBlock','GoldBlock','IceBlock','NeonBlock','Seat','CarSeat','PilotSeat','Servo','Piston','FrontWheel','BackWheel','Cannon','Thruster','TNT','Dynamite','HarpoonDragon','Bar','Motor','JetPack','Switch','CameraDome','Rope','SpikeTrap'}) do Inventory.definitions[id]={id=id,label=id,volume=id:match('Block$')~=nil} end
 local labels={WoodBlock='Drewno',PlasticBlock='Plastik',MetalBlock='Metal',TitaniumBlock='Tytan',GlassBlock='Szkło',ConcreteBlock='Beton',StoneBlock='Kamień',Seat='Siedzenie',CarSeat='Fotel kierowcy',PilotSeat='Fotel pilota',Servo='Serwo',Dynamite='Laska dynamitu',TNT='TNT'}
 for id,label in pairs(labels) do Inventory.definitions[id].label=label end
 function Inventory.cost(element)
  local d=Inventory.definitions[element.material];if not d then return nil end
  if not d.volume then return 1 end
  local s=element.size or {2,2,2};return math.max(1,math.ceil(s[1]*s[2]*s[3]/8-1e-8))
 end
 function Inventory.requirements(schema)
  local out={}
  for _,e in ipairs(schema.elements) do local cost=assert(Inventory.cost(e),'Unknown material '..tostring(e.material));out[e.material]=(out[e.material] or 0)+cost end
  for _,c in ipairs(schema.connections or {}) do if c.kind=='Hinge' then out.Servo=(out.Servo or 0)+1 end end
  return out
 end
 function Inventory.snapshot(values,source)
  local out={source=source or 'unknown',items={}}
  for id in pairs(Inventory.definitions) do
   local v=values and values[id];local known=Util.finite(v) and v>=0 and v%1==0
   out.items[id]={known=known,count=known and v or nil,source=out.source,id=id}
  end
  return out
 end
 function Inventory.compare(schema,snapshot)
  local requirements=Inventory.requirements(schema);local rows={};local enough=true;local unknown=false
  for _,id in ipairs(Util.keys(requirements)) do
   local item=snapshot and snapshot.items[id];local known=item and item.known==true;local have=known and item.count or nil
   local required=requirements[id];local missing=known and math.max(0,required-have) or nil
   if not known then unknown=true;enough=false elseif missing>0 then enough=false end
   rows[#rows+1]={id=id,label=Inventory.definitions[id].label,have=have,required=required,missing=missing,known=known}
  end
  return {rows=rows,enough=enough,unknown=unknown}
 end
 function Inventory.describe(comparison)
  local lines={}
  for _,r in ipairs(comparison.rows) do lines[#lines+1]=string.format('%s: posiadane %s / wymagane %d%s',r.label,r.known and tostring(r.have) or 'NIE ODCZYTANO',r.required,r.known and (' / brakuje '..r.missing) or ' / stan nieznany') end
  return table.concat(lines,'\n')
 end
 function Inventory.readPlayer(player)
  local data=player:FindFirstChild('Data');local roots={};local records={};local values={}
  if data then roots[#roots+1]=data;for _,name in ipairs({'Inventory','Blocks','BlockInventory'}) do local folder=data:FindFirstChild(name);if folder then roots[#roots+1]=folder end end end
  for id in pairs(Inventory.definitions) do
   local found
   for _,root in ipairs(roots) do local v=root:FindFirstChild(id);if v and (v:IsA('IntValue') or v:IsA('NumberValue')) then found=v;break end end
   if not found and id:match('Block$') then
    -- gsub also returns a replacement count; only its string belongs in the Roblox call.
    local alias=id:gsub('Block$','')
    for _,root in ipairs(roots) do local v=root:FindFirstChild(alias);if v and (v:IsA('IntValue') or v:IsA('NumberValue')) then found=v;break end end
   end
   if found then records[id]=found;values[id]=found.Value end
  end
  return values,records,roots
 end
 function Inventory.observePlayer(player,runtime,changed)
  local folderConnections={};local valueConnections={};local snapshot=Inventory.snapshot(nil,'player.Data (nieodczytane)')
  local function clear(list)for _,c in ipairs(list) do runtime:disconnect(c) end;table.clear(list)end
  local function bind()
   clear(valueConnections)
   local values,records=Inventory.readPlayer(player)
   local function publish()local current=Inventory.readPlayer(player);snapshot=Inventory.snapshot(current,'player.Data / dokładne identyfikatory i jawne aliasy');changed(snapshot)end
   for _,v in pairs(records) do valueConnections[#valueConnections+1]=runtime:connect(v.Changed,publish,'Inventory') end
   snapshot=Inventory.snapshot(values,'player.Data / dokładne identyfikatory i jawne aliasy');changed(snapshot)
  end
  local attach
  attach=function()
   clear(folderConnections);local _,_,roots=Inventory.readPlayer(player)
   for _,root in ipairs(roots) do folderConnections[#folderConnections+1]=runtime:connect(root.ChildAdded,attach,'Inventory');folderConnections[#folderConnections+1]=runtime:connect(root.ChildRemoved,attach,'Inventory') end;bind()
  end
  runtime:connect(player.ChildAdded,attach,'Inventory');runtime:connect(player.ChildRemoved,attach,'Inventory');attach()
  return function()return snapshot end
 end
 return Inventory
end
