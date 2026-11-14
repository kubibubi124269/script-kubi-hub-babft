local G={}
G.items={BABFT={name='Build A Boat For Treasure',placeId=537413528},MM2={name='Murder Mystery 2',placeId=142823291,gameId=66654135}}
G.items.BRAINROT={name='Steal a Brainrot',placeId=109983668079237,gameId=7709344486}
G.items.BIKE={name='Bike Universe',placeId=98628861455414,gameId=10768284407}
G.items.UNIVERSAL={name='Universal',universal=true}
function G.detect(placeId,gameId)
 for id,item in pairs(G.items) do if (item.placeId and placeId==item.placeId) or (item.gameId and gameId==item.gameId) then return id end end
end
function G.canLaunch(id,placeId,gameId,studio)
 if not G.items[id] then return false,'Nieznany hub.' end
 if id=='UNIVERSAL' then return true end
 if studio or G.detect(placeId,gameId)==id then return true end
 return false,'Ten hub jest przeznaczony do '..G.items[id].name..'. Najpierw dołącz do tej gry w Robloxie.'
end
return G
