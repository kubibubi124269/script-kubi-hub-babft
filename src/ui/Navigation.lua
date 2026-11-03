local N={}
N.order={'PRO','BUILDER','FARM','CIRCLE','SETTINGS'}
N.titles={PRO='PRO',BUILDER='Builder',FARM='Autofarm',CIRCLE='Circle Maker',SETTINGS='Settings'}
N.aliases={HOME='PRO',MOVEMENT='PRO',PLAYER='PRO',TOOLS='BUILDER',SCHEMATICS='BUILDER',SHAPES='BUILDER',STATS='SETTINGS',DEBUG='SETTINGS',PERFORMANCE='SETTINGS'}
function N.resolve(id)return N.aliases[id] or id end
function N.rank(id)for i,v in ipairs(N.order) do if id==v then return i end end;return 99 end
function N.matches(query,text)
 local q=string.lower(query):gsub('^%s+',''):gsub('%s+$','');local t=string.lower(text)
 for word in q:gmatch('%S+') do if not t:find(word,1,true) then return false end end
 return true
end
return N
