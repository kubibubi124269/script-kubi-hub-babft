do
 game.PlaceId=142823291;game.GameId=66654135
 local languages={PL='Monety / cukierki',EN='Coins / candy',RU='Монеты / конфеты',UK='Монети / цукерки',ZH='金币 / 糖果',ES='Monedas / caramelos',DE='Münzen / Süßigkeiten',PT='Moedas / doces',FR='Pièces / bonbons',IT='Monete / caramelle'}
 for lang,caption in pairs(languages)do
  local entry=openEntry();assert(entry.screen=='languages')
  entry.gui:FindFirstChild('Language_'..lang,true).Activated:Fire()
  assert(entry.screen=='community' and entry.gui:FindFirstChild('YouTubeURL',true).Text=='https://www.youtube.com/@Kubi_Bubi1242')
  entry.gui:FindFirstChild('Continue',true).Activated:Fire()
  local ok,app=entry:choose('MM2');assert(ok,app)
  assert(app.language==lang and button(app,caption..'  OFF'));app:unload()
 end
 check(true,'all ten launch choices carry through the community card to localized farm controls')

 local disk,folders={},{};local originals={isfile,isfolder,readfile,writefile,makefolder}
 isfile=function(path)return disk[path]~=nil end;isfolder=function(path)return folders[path]==true end
 readfile=function(path)return assert(disk[path])end;writefile=function(path,text)disk[path]=text end;makefolder=function(path)folders[path]=true end
 local originalId=player.UserId
 local ok,app=openLauncher():choose('MM2');assert(ok,app)
 app.profileName.Text='CoinsMix';assert(app.controller:setTempo('FAST'));assert(app.controller:setFilter('CANDY'))
 app.config.data.unexpected='should not be saved';assert(app:saveProfile())
 local packed=services.HttpService:JSONDecode(disk['KubiHubProfiles/123_MM2/coinsmix.json'])
 check(packed.mm2.tempo=='FAST' and packed.mm2.kind=='CANDY' and not packed.unexpected,'named profiles persist validated settings only')
 app:unload()
 local reopened,second=openLauncher():choose('MM2');assert(reopened,second)
 check(second.accountProfile=='CoinsMix' and second.controller.farmTempo=='FAST' and second.controller.kind=='CANDY' and not second.controller.farming,'last named config restores on the same account without starting farm')
 second:unload();player.UserId=165
 local other,third=openLauncher():choose('MM2');assert(other,third)
 third.profileName.Text='CoinsMix';local loaded=third:loadProfile()
 check(not loaded and third.controller.kind=='BOTH','another account cannot read the first account profile even with the same name')
 third:unload();player.UserId=originalId
 isfile,isfolder,readfile,writefile,makefolder=table.unpack(originals,1,5)
end

do
 game.PlaceId=98628861455414;game.GameId=10768284407
 local bikeCharacter,h,root=newCharacter('Rider');player.Character=bikeCharacter
 local seat=child(workspace,'VehicleSeat','BikeSeat');seat.Occupant=h;h.SeatPart=seat
 seat.AssemblyLinearVelocity=Vector3.new(0,0,-12)
 local ok,bike=openLauncher():choose('BIKE');assert(ok,bike)
 check(not bike:startRide() and not bike.riding,'unsupported virtual input fails closed')
 local pressed,events={},{}
 services.UserInputService.mockVirtualInput={SendKey=function(_,down,key)
  assert(not down or not pressed[key],'cannot press the same input twice')
  pressed[key]=down or nil;events[#events+1]={key=key,down=down}
 end}
 local k=Enum.KeyCode
 button(bike,'Zresp rower (Q)').Activated:Fire();bike:update(tick+.15);tick+=.15
 button(bike,'Wsiądź (E)').Activated:Fire();bike:update(tick+.15);tick+=.15
 check(events[1].key==k.Q and events[3].key==k.E and not next(pressed),'bike controls use the specified Q and E keys and release them')
 bike.config.data.bike.guard=false
 assert(bike:startRide());bike:update(tick);tick+=2.05;bike:update(tick)
 check(pressed[k.W] and pressed[k.LeftControl],'auto ride holds throttle and issues a bounded Ctrl wheelie')
 tick+=5.05;bike:update(tick)
 check(pressed[k.One] and not pressed[k.LeftControl],'bike switches from wheelie to the first equipped trick')
 services.UserInputService.WindowFocusReleased:Fire()
 check(not bike.riding and not next(pressed),'focus loss stops automatic riding and releases every synthetic key')
 workspace.mockRaycast=function()return {Instance=seat}end
 bike.config.data.bike.guard=true;assert(bike:startRide());bike:update(tick)
 check(not bike.riding and not next(pressed) and bike.rideInfo.Text:find('Przeszkoda',1,true),'crash guard stops before driving into a detected obstacle')
 workspace.mockRaycast=nil
 h.SeatPart=nil
 root.CFrame=CFrame.new(1,0,1);assert(bike:mark(true))
 root.CFrame=CFrame.new(2,0,2);assert(bike:mark(false))
 root.CFrame=CFrame.new(4,0,4);assert(bike:mark(false))
 button(bike,'Przenieś do startu').Activated:Fire();check(root.Position.X==1,'race route returns to the explicitly saved start')
 button(bike,'Przejedź zapisane checkpointy').Activated:Fire();bike:update(tick)
 check(root.Position.X==2 and bike.routeIndex==2,'race follows first saved checkpoint and waits before the next')
 tick+=1.1;bike:update(tick);check(root.Position.X==4 and bike.routeIndex==3,'race follows checkpoints in saved order')
 tick+=1.1;bike:update(tick);check(not bike.routeIndex,'race ends without claiming a server result')
 bike:unload();services.UserInputService.mockVirtualInput=nil
 seat:Destroy()
end
