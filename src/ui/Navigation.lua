local N={}
N.order={'FARM','TROLLING','TELEPORT','FIGHT','MISC','SETTINGS'}
N.titles={FARM='Autofarm',TROLLING='Trolling',TELEPORT='Teleport',FIGHT='Fight',MISC='Misc',SETTINGS='Ustawienia'}
N.aliases={HOME='SETTINGS',PRO='SETTINGS',MOVEMENT='MISC',PLAYER='TROLLING',BUILDER='MISC',TOOLS='MISC',SCHEMATICS='MISC',SHAPES='MISC',CIRCLE='MISC',COMBAT='FIGHT',STATS='SETTINGS',DEBUG='SETTINGS',PERFORMANCE='SETTINGS'}
function N.resolve(id)return N.aliases[id] or id end
function N.rank(id)for i,v in ipairs(N.order) do if id==v then return i end end;return 99 end
function N.matches(query,text)
 local q=string.lower(query):gsub('^%s+',''):gsub('%s+$','');local t=string.lower(text)
 for word in q:gmatch('%S+') do if not t:find(word,1,true) then return false end end
 return true
end
return N
