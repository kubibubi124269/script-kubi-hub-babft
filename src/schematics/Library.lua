return function(Util,Schema,LegacyShapes,LegacyPlans,WormMK2,DynamiteStack)
 local Library={};Library.__index=Library
 function Library.new()
  local self=setmetatable({items={},custom={},errors={},revision=0},Library)
  local plans,assets=LegacyPlans(LegacyShapes);self.assets=assets
  local groups={SPEEDBOAT='Łodzie',RAFT='Łodzie',SUBMARINE='Łodzie',HOVERCRAFT='Łodzie',JET='Samoloty',SPACESHIP='Samoloty',UFO='Samoloty',['MINI TANK']='Pojazdy',WORM='WORMS'}
  for _,name in ipairs(Util.keys(plans)) do
   if #plans[name]>0 and name~='TNT_STACK' then
    local id='legacy_'..name:gsub(' ','_');local value,errors=Schema.fromLegacy(id,name,plans[name],groups[name])
    if value then value.legacy=true;self.items[id]=value else self.errors[#self.errors+1]=name..': '..table.concat(errors,'; ') end
   end
  end
  self.items.WORM_MK2=WormMK2();self.items.DYNAMITE_STACK=assert(DynamiteStack(3000))
  return self
 end
 function Library:list(query,category,sort,favorites,onlyFavorites)
  local out={};query=(query or ''):lower();favorites=favorites or {}
  for _,item in pairs(self.items) do if (not category or category=='Wszystkie' or item.category==category) and (not onlyFavorites or favorites[item.id]) and (item.name:lower():find(query,1,true) or item.id:lower():find(query,1,true)) then out[#out+1]=item end end
  table.sort(out,function(a,b)if sort=='Bloki' and #a.elements~=#b.elements then return #a.elements<#b.elements end;return a.name<b.name end);return out
 end
 function Library:save(raw)
  local item,errors=Schema.validate(raw);if not item then return false,table.concat(errors,'; ') end
  if self.items[item.id] and not self.custom[item.id] then return false,'Wbudowany schemat wymaga nowego identyfikatora przy zapisie.' end
  item.category='Własne projekty';self.items[item.id]=item;self.custom[item.id]=true;self.revision=self.revision+1;return true,item
 end
 return Library
end
