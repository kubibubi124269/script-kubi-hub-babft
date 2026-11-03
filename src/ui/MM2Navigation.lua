return function(Navigation)
 local N={order={'HOME','FARM','COMBAT','PLAYER','SETTINGS'},titles={HOME='MM2',FARM='Autofarm',COMBAT='Combat',PLAYER='Player',SETTINGS='Settings'},aliases={DEBUG='SETTINGS'}}
 function N.resolve(id)return N.aliases[id] or id end
 function N.rank(id)for i,key in ipairs(N.order) do if id==key then return i end end;return 99 end
 N.matches=Navigation.matches;return N
end
