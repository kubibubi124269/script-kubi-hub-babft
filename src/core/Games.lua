local G={}
G.items={BABFT={name='Build A Boat For Treasure',placeId=537413528},MM2={name='Murder Mystery 2',placeId=142823291,gameId=66654135}}
function G.detect(placeId,gameId)
 for id,item in pairs(G.items) do if placeId==item.placeId or item.gameId and gameId==item.gameId then return id end end
end
function G.canLaunch(id,placeId,gameId,studio)
 if not G.items[id] then return false,'Nieznany hub.' end
 if studio or G.detect(placeId,gameId)==id then return true end
 return false,'Ten hub jest przeznaczony do '..G.items[id].name..'. Najpierw dołącz do tej gry w Robloxie.'
end
return G
