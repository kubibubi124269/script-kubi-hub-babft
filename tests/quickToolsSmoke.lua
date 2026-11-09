do
 game.PlaceId=987654321;game.GameId=1
 local ok,app=openLauncher():choose('UNIVERSAL');assert(ok,app)
 local q=app.quickTools;local page=app.ui.pages.QUICK
 local groups=0;for _,card in ipairs(app.ui.cards)do if card.page=='QUICK' then groups+=1 end end
 check(groups==4 and not q.hud.Visible and not q.effect and not q.marker,'the quick tools start inactive in four separate groups')
 app.ui:show('QUICK')
 button(app,'Pozycja XYZ  OFF').Activated:Fire()
 button(app,'Zdrowie  OFF').Activated:Fire()
 check(q.hud.Visible and q.hud.Text:find('Pozycja XYZ',1,true) and q.hud.Text:find('100 / 100',1,true),'independent HUD controls compose on the overlay')
 button(app,'Pozycja XYZ  ON').Activated:Fire()
 check(q.hud.Visible and not q.hud.Text:find('Pozycja XYZ',1,true),'turning off one HUD line preserves other lines')
 button(app,'Sepia  OFF').Activated:Fire();local sepia=q.effect
 button(app,'Chłodny obraz  OFF').Activated:Fire()
 check(sepia.Parent==nil and q.effect and q.effect.Parent==services.Lighting,'selecting a new filter replaces the old effect')
 button(app,'Chłodny obraz  ON').Activated:Fire();check(q.effect==nil,'the current filter can be turned off again')
 button(app,'Stoper  OFF').Activated:Fire();tick+=12
 button(app,'Zapisz międzyczas').Activated:Fire()
 check(q.lap=='00:12' and q.timerInfo.Text:find('00:12',1,true),'the stopwatch records a real elapsed split')
 button(app,'Stoper  ON').Activated:Fire();tick+=4;q:update(tick)
 check(q:elapsed(tick)==12,'the stopwatch does not advance while paused')
 button(app,'Reset stopera').Activated:Fire();check(not q.lap and q:elapsed(tick)==0,'reset clears the stopwatch and split')
 q.timerSeconds=5;button(app,'Minutnik  OFF').Activated:Fire();tick+=5.5;services.RunService.Heartbeat:Fire(.05)
 check(not q.timerEnd and q.timerDone and app.ui.statusInfo.Text:find('Czas minął',1,true),'the countdown ends and raises its own notification')
 button(app,'Zapisz znacznik tutaj').Activated:Fire();local marker=q.marker
 button(app,'Pokaż znacznik  ON').Activated:Fire()
 check(marker.Parent==workspace and not marker.CanCollide and not marker.CanTouch and not q.billboard.Enabled,'the local marker can hide without changing its saved position or collision')
 button(app,'Usuń znacznik').Activated:Fire();check(not q.marker and marker.Parent==nil,'delete removes the local marker')
 button(app,'Zapisz znacznik tutaj').Activated:Fire();button(app,'Czarno-biały  OFF').Activated:Fire();local active=q.effect;marker=q.marker
 app:stopAll()
 check(active.Parent==nil and marker.Parent==nil and not q.hud.Visible and not q.started and not q.timerEnd,'global STOP clears the shared HUD, filters, marker and timers')
 app:unload();check(page.Parent==nil,'unloading removes the shared tools page')
end
