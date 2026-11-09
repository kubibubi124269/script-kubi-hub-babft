return function(M)
 local A={};A.__index=A
 A.extraPages=M.ExtraPages;A.run=M.Application.run;A.notify=M.Application.notify;A.copy=M.Application.copy
 function A.new(onCreating)
  local self=setmetatable({alive=true,clock=os.clock,navigation=M.MM2Navigation,fps=0},A)
  self.players=game:GetService('Players');self.player=self.players.LocalPlayer;assert(self.player,'Brak LocalPlayer.');self.player:WaitForChild('PlayerGui',10)
  self.input=game:GetService('UserInputService');self.runService=game:GetService('RunService');self.http=game:GetService('HttpService')
  self.log=M.Log.new(function()return os.date('%H:%M:%S')end);self.runtime=M.Runtime.new(self.clock,function(module,e)self.log:error(module,e);if self.ui then self.ui:toast(module,e,true) end end)
  if onCreating then onCreating(self) end
  self.config={data=M.Util.copy(M.Config.defaults)}
  local saved=_G.KubiHubMM2Settings;if type(saved)=='table' then local data=M.Config.validate({ui=saved.ui});if data then self.config.data.ui=data.ui end end
  self.platform=M.MM2Platform.new(self.player,self.players,workspace,game.PlaceId,game.GameId);self.controller=M.MM2Controller.new(self.runtime,self.platform,self.clock);self.avatar=M.AvatarAppearance.new(self.platform,self.runtime);self.controller.avatar=self.avatar;self.controller.itemESP={coins=false,gun=false,range=120};self.runtime:own(self.avatar);self.avatar:bind(self.runService)
  self.adapter={mode='MM2',capabilities={movement=self.platform.allowed},cancel=function()end}
  self.adapter.movement=function(_,values)local _,h=self.platform:character();if not self.platform.allowed or not h then return {ok=false,error='Brak aktywnej postaci MM2.'} end;h.WalkSpeed=values.walk;if h.UseJumpPower then h.JumpPower=values.jump else h.JumpHeight=values.jump^2/(2*workspace.Gravity) end;return {ok=true}end
  self.movement=M.Movement.new(self.runtime,self.adapter,self.player,self.input,self.log,self.config.data.movement);self.effects=M.Effects.new(self.clock)
  self.ui=M.UI.new(self);self.ui.title.Text='KUBI HUB  /  MM2';self:pages();M.QuickTools(self);self.ui:show('FARM');self.ui:theme();self:updateDashboard()
  self.runtime:connect(self.runService.Heartbeat,function(dt)self.fps=self.fps==0 and 1/math.max(dt,.001) or self.fps*.95+1/math.max(dt,.001)*.05;self.runtime:tick(dt)end,'MM2')
  self.runtime:connect(self.runService.RenderStepped,function()self.movement:tick()end,'Movement')
  self.runService:BindToRenderStep('KubiHubMM2Aim',Enum.RenderPriority.Camera.Value+1,function(dt)if self.alive then local ok,err=pcall(function()self.controller:aimTick(dt)end);if not ok then self.controller.aimbot=false;self.controller.autoShot=false;self.log:error('Aim',err);self.ui:toast('Aim',err,true);self.ui:refreshControls() end end end)
  self.runtime:own({Destroy=function()self.runService:UnbindFromRenderStep('KubiHubMM2Aim')end})
  local manualKeys={Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Down,Enum.KeyCode.Left,Enum.KeyCode.Right,Enum.KeyCode.Space}
  self.runService:BindToRenderStep('KubiHubMM2FarmMotion',Enum.RenderPriority.Character.Value+1,function()
   local c=self.controller;if not self.alive or not c.farming then return end
   local manual=self.input:GetFocusedTextBox()~=nil
   for _,key in ipairs(manualKeys)do if self.input:IsKeyDown(key) then manual=true;break end end
   local ok,err=pcall(c.farmMotionTick,c,manual)
   if not ok then c:stopFarm();c.lastError=tostring(err);self.log:error('MM2 Farm',err);self.ui:toast('MM2 Farm',err,true);self.ui:refreshFeatures()end
  end)
  self.runtime:own({Destroy=function()self.runService:UnbindFromRenderStep('KubiHubMM2FarmMotion')end})
  self.runtime:connect(self.player.CharacterAdded,function()self.controller:stopFarm();self.controller:stopCombat();self.avatar:reset();self.movement:reset();self.effects:clear();self.ui:refreshFeatures()end,'Respawn')
  self.runtime:schedule('MM2Controllers',.05,function(dt)
   local ok,err=pcall(function()self.controller:tick(dt)end)
   if not ok then self.controller:stopAll();self.log:error('MM2',err);self.ui:toast('MM2',err,true);self.ui:refreshControls() end
   self.effects:tick();self.ui:tick()
  end)
  self.runtime:schedule('MM2Status',.5,function()self.platform:updateESP(self.controller.esp);self.platform:updateItems(self.controller.itemESP);local ok,err=self.avatar:refresh();if not ok then self.ui:toast('Postać',err,true)end;self:updateDashboard()end)
  return self
 end
 function A:pages()
  local ui=self.ui;local c=self.controller;self:extraPages()
  local farm=ui:page('FARM');local f=ui:card(farm,'Autofarma MM2','Postać leci do pobliskich monet lub cukierków. Poniżej możesz zmienić Lot na Chód. Pełna torba wstrzymuje zbieranie, a odrodzenie je wyłącza.')
  self.farmInfo=ui:label(f,'')
  ui:feature(f,'Monety / cukierki',function()return c.farming end,function()if c.farming then return c:stopFarm() else return c:startFarm() end end,function(panel)
   ui:cycle(panel,'Zbieraj',{'BOTH','COIN','CANDY'},function()return c.kind end,function(v)return c:setFilter(v)end)
   ui:slider(panel,'Zasięg szukania (study)',function()return c.farmRange end,function(v)c.farmRange=v;c:refreshFarm()end,8,45,1)
   ui:slider(panel,'Czekanie na odbiór (s)',function()return c.pickupTimeout end,function(v)c.pickupTimeout=v end,.3,2,.1)
   ui:button(panel,'Odśwież przedmioty',function()c:refreshFarm()end)
   ui:button(panel,'Reset statystyk',function()return c:resetStats()end)
  end)
  ui:cycle(f,'Ruch',{'Lot','Chód'},function()return c.farmMotion end,function(v)return c:setFarmMotion(v)end)
  ui:button(f,'PAUZA / WZNÓW',function()return c:pauseFarm()end);ui:button(f,'STOP zbierania',function()return c:stopFarm()end)
  local combat=ui:page('FIGHT');local aim=ui:card(combat,'Celowanie i walka','Auto Shot wymaga własnego pistoletu. Kill all i Knife Aura wymagają własnego noża. Skutki akcji zatwierdza gra.')
  self.combatInfo=ui:label(aim,'')
  local function targets(panel)
   ui:cycle(panel,'Cel',{'MURDERER','NEAREST','SELECTED'},function()return c.settings.target end,function(v)c.settings.target=v end)
   ui:field(panel,'Dokładny nick',c.settings.selected,function(v)c.settings.selected=v;return v end,false,function()return c.settings.selected end)
  end
  local function aimOptions(panel)
   targets(panel);ui:slider(panel,'Zasięg w pikselach',function()return c.settings.fov end,function(v)c.settings.fov=v end,40,500,10)
   ui:slider(panel,'Szybkość celowania',function()return c.settings.smooth end,function(v)c.settings.smooth=v end,5,60,1)
   ui:toggle(panel,'Sprawdzaj ściany',function()return c.settings.wallCheck end,function(v)c.settings.wallCheck=v end)
  end
  ui:feature(aim,'Aimbot',function()return c.aimbot end,function()c.aimbot=not c.aimbot end,aimOptions)
  ui:feature(aim,'Auto Shot',function()return c.autoShot end,function()c.autoShot=not c.autoShot end,function(panel)aimOptions(panel);ui:slider(panel,'Przerwa strzałów (s)',function()return c.settings.shotInterval end,function(v)c.settings.shotInterval=v end,.35,3,.05)end)
  ui:feature(aim,'Kill all',function()return c.combat and c.combat.kind=='KILL_ALL' end,function()if c.combat and c.combat.kind=='KILL_ALL' then return c:stopCombat() else return c:startKillAll() end end,function(panel)ui:label(panel,'Jeden obieg żywych postaci z własnym nożem. STOP przerywa akcję.');ui:button(panel,'STOP walki',function()return c:stopCombat()end)end)
  ui:feature(aim,'Knife Aura',function()return c.aura end,function()c.aura=not c.aura end,function(panel)ui:label(panel,'Własny nóż. Zasięg 6 studów, przerwa 0,45 s.');ui:button(panel,'Wyłącz aurę',function()c.aura=false;ui:refreshControls()end)end)
  local trolling=ui:page('TROLLING');local tr=ui:card(trolling,'Fling','Krótka próba fizyki własnej postaci. Skutek zależy od kolizji i serwera.')
  c.flingSettings={target='NEAREST',selected='',duration=1.5}
  ui:feature(tr,'Fling',function()return c.combat and c.combat.kind=='FLING' end,function()if c.combat and c.combat.kind=='FLING' then return c:stopCombat() else return c:startFling() end end,function(panel)
   ui:cycle(panel,'Cel',{'NEAREST','MURDERER','SELECTED'},function()return c.flingSettings.target end,function(v)c.flingSettings.target=v end)
   ui:field(panel,'Dokładny nick celu','',function(v)c.flingSettings.selected=v;return v end,false,function()return c.flingSettings.selected end)
   ui:field(panel,'Czas: 0.5–3 s',1.5,function(v)c.flingSettings.duration=M.Util.number(tonumber(v),1.5,.5,3);return c.flingSettings.duration end,false,function()return c.flingSettings.duration end)
   ui:button(panel,'STOP Fling',function()return c:stopCombat()end)
  end)
  M.AppearanceControls(self,trolling,true)
  ui:feature(tr,'Konfetti',nil,function()local _,_,r=self.platform:character();self.effects:confetti(r)end,function(panel)ui:label(panel,'Efekt widoczny u Ciebie.');ui:button(panel,'Wyczyść efekty',function()self.effects:clear()end)end)
  local players=ui:page('MISC');local p=ui:card(players,'Gracze i przedmioty','Czerwony: nóż. Niebieski: pistolet. Żółty: nieznana rola. Oznaczenia są lokalne.')
  self.rolesInfo=ui:label(p,'')
  local function playerOptions(panel)
   local names={};for _,person in ipairs(self.platform:people())do names[#names+1]=person.player.Name end;if #names==0 then names={'Brak graczy'}end
   ui:cycle(panel,'Gracz',names,function()return c.settings.selected end,function(v)c.settings.selected=v end)
   ui:field(panel,'Dokładny nick',c.settings.selected,function(v)c.settings.selected=v;return v end,false,function()return c.settings.selected end)
  end
  ui:feature(p,'Podgląd gracza',function()return self.platform.spectating~=nil end,function()if self.platform.spectating then self.platform:stopWatch();return true end;local ok,err=self.platform:watch(c.settings.selected);if ok then c.aimbot=false;c.autoShot=false end;return ok,err end,playerOptions)
  self.proximity=false;self.alertDistance=30;self.threatInfo=ui:label(p,'')
  ui:feature(p,'Ostrzeżenie o Murdererze',function()return self.proximity end,function()self.proximity=not self.proximity;self:updateDashboard()end,function(panel)ui:slider(panel,'Odległość ostrzeżenia',function()return self.alertDistance end,function(v)self.alertDistance=v end,10,100,5);ui:label(panel,'Rozpoznaje wyłącznie gracza z widocznym nożem.')end)
  ui:feature(p,'ESP ról',function()return c.esp end,function()c.esp=not c.esp;self.platform:updateESP(c.esp)end,function(panel)ui:label(panel,'Czerwony — nóż, niebieski — pistolet, żółty — nieznana rola.')end)
  ui:feature(p,'Auto podnoszenie pistoletu',function()return c.autoGun end,function()c.autoGun=not c.autoGun end,function(panel)ui:label(panel,'Odwiedza upuszczony GunDrop, gdy nie masz broni i inne moduły ruchu są wyłączone.')end)
  local travel=ui:card(ui:page('TELEPORT'),'Upuszczona broń');ui:feature(travel,'Podnieś pistolet',nil,function()if self.runtime.lock then return false,'Najpierw zatrzymaj moduł '..self.runtime.lock end;return self.platform:pickupGun()end,function(panel)ui:label(panel,'Przenosi do pistoletu obecnego na mapie.')end)
  ui:feature(travel,'Teleport do gracza',nil,function()local person=self.platform:selected(c.settings.selected);if not person then return false,'Wybierz aktywnego gracza pod PPM.' end;return self.travel:go(person.root.CFrame*CFrame.new(3,0,0))end,playerOptions)
  local items=ui:card(players,'Przedmioty na mapie')
  ui:feature(items,'Podświetl monety / cukierki',function()return c.itemESP.coins end,function()c.itemESP.coins=not c.itemESP.coins;self.platform:updateItems(c.itemESP)end,function(panel)
   ui:field(panel,'Zasięg: 10–300',c.itemESP.range,function(v)c.itemESP.range=M.Util.number(tonumber(v),120,10,300);return c.itemESP.range end,false,function()return c.itemESP.range end)
   ui:label(panel,'Do 40 najbliższych rzeczywistych przedmiotów. Nie uruchamia zbierania.')
  end)
  ui:feature(items,'Podświetl upuszczony pistolet',function()return c.itemESP.gun end,function()c.itemESP.gun=not c.itemESP.gun;self.platform:updateItems(c.itemESP)end,function(panel)ui:label(panel,'Oznacza rzeczywisty GunDrop na mapie, gdy jest dostępny.')end)
  local roles=ui:card(players,'Szybki podgląd ról')
  local locations=ui:card(ui:page('TELEPORT'),'Skróty do graczy')
  for _,row in ipairs({{'Murderer','Murderera'},{'Sheriff','Sheriffa'}})do local role,label=row[1],row[2]
   local function help(panel)ui:label(panel,'Wybiera najbliższego gracza z widoczną bronią tej roli. Brak broni oznacza brak pewnego rozpoznania.')end
   ui:feature(roles,'Podgląd '..label,function()return self.platform.spectating and self.platform.spectating.role==role end,function()
    if self.platform.spectating and self.platform.spectating.role==role then self.platform:stopWatch();return true end
    local person,err=self.platform:personByRole(role);if not person then return false,err end
    local ok,why=self.platform:watch(person.player.Name);if ok then c.aimbot=false;c.autoShot=false end;return ok,why
   end,help)
   ui:feature(locations,'Teleport do '..label,nil,function()local person,err=self.platform:personByRole(role);if not person then return false,err end;return self.travel:go(person.root.CFrame*CFrame.new(3,0,0))end,help)
  end
  local move=ui:card(players,'Własna postać')
  local function moveOptions(panel)for _,spec in ipairs({{'WalkSpeed','walk',8,60},{'Skok','jump',20,120},{'Fly speed','flySpeed',10,100}}) do local s=spec;ui:slider(panel,s[1],function()return self.config.data.movement[s[2]]end,function(v)self.config.data.movement[s[2]]=v end,s[3],s[4],1)end end
  ui:feature(move,'Zastosuj ruch',nil,function()return self.movement:apply()end,moveOptions)
  ui:feature(move,'Fly',function()return self.movement.fly end,function()if self.movement.fly then self.movement:stopFly();return true else return self.movement:startFly() end end,moveOptions)
  ui:button(move,'Przywróć ruch',function()return self.movement:reset()end)
  local settings=ui:page('SETTINGS');local s=ui:card(settings,'KUBI HUB / MM2')
  self.homeInfo=ui:label(s,'');ui:button(s,'STOP WSZYSTKO',function()self:stopAll()end);ui:button(s,'Wybór BABFT / MM2',function()self:unload();_G.KubiHubRuntime=M.Launcher.new()end)
  ui:cycle(s,'Akcent',{'BLUE','PURPLE'},function()return self.config.data.ui.theme end,function(v)self.config.data.ui.theme=v;ui:theme()end);ui:toggle(s,'Tryb kompaktowy',function()return self.config.data.ui.compact end,function(v)self.config.data.ui.compact=v;ui:fit()end)
  ui:button(s,'Zapisz wygląd na sesję',function()_G.KubiHubMM2Settings={ui=M.Util.copy(self.config.data.ui)};self:notify('Ustawienia','Zapisano wygląd.')end)
  ui.statusBody=ui:card(settings,'Ostatni komunikat');ui.statusInfo=ui:label(ui.statusBody,'Gotowy.')
  local debug=ui:card(settings,'Raport MM2');ui.routes.DEBUG=debug
  self.debugBox=ui:field(debug,'Raport do skopiowania','',nil,true);ui:button(debug,'Skopiuj raport MM2',function()self:copy(self:report(),self.debugBox)end);ui:button(debug,'Wyłącz hub',function()self:unload()end)
 end
 function A:report()
  local c=self.controller;return self.log:text()..'\nWersja: '..M.Version.current..string.format('\nMM2 wykryte: %s\nWłasna broń / rola: %s\nZbieranie: %s\nPróby odbioru: %d\nZniknięcia obiektów po próbie: %d\nAktywacje pistoletu: %d\nAktywacje noża: %d\nOstatni błąd: %s',tostring(self.platform.allowed),self.platform:role(self.player),c.state,c.attempts,c.disappeared,c.shots,c.stabs,c.lastError)
 end
 function A:updateDashboard()
  self.ui:refreshFeatures()
  self.platform:updateWatch()
  if self.threatInfo then local person,distance=self.platform:nearestMurderer();self.threatInfo.Visible=self.proximity;self.threatInfo.Text=person and (distance<=self.alertDistance and 'UWAGA: ' or '')..person.player.Name..' · '..math.floor(distance)..' studów' or 'Brak gracza z wykrytym nożem.';self.threatInfo.TextColor3=person and distance<=self.alertDistance and self.ui.palette.red or self.ui.palette.muted end
  local c=self.controller;local roles={};for _,p in ipairs(self.platform:people()) do roles[#roles+1]=p.player.Name..': '..p.role end
  self.ui.subtitle.Text='V'..M.Version.current..'  •  MURDER MYSTERY 2'
  self.homeInfo.Text=string.format('MM2: %s\nWłasna rola / broń: %s\nFPS %.1f • zbieranie: %s\nAkcja walki: %s',self.platform.allowed and 'wykryto' or 'nie wykryto — moduły gry zablokowane',self.platform:role(self.player),self.fps,c.state,c.combat and c.combat.kind or 'STOP')
  local states={STOPPED='Wyłączona',SEARCHING='Szukam przedmiotów',WAIT_ITEMS='Brak przedmiotu w zasięgu — podejdź bliżej',WAIT_CHARACTER='Czekam na aktywną postać',BAG_FULL='Pełna torba — czekam',PICKUP='Czekam na odbiór',APPROACH=c.farmMotion=='Lot' and 'Lecę do przedmiotu' or 'Idę do przedmiotu',MANUAL='Sterujesz ręcznie',PAUSED='Pauza'}
  self.farmInfo.Text=string.format('Stan %s\nPróby odbioru %d • zniknięcia obiektów %d\nNie jest to potwierdzone saldo monet ani cukierków.\n%s',(states[c.state] or c.state)..' · znaleziono '..c.lastScanCount,c.attempts,c.disappeared,c.lastError)
  self.combatInfo.Text=string.format('Aimbot %s • Auto Shot %s\nAktywacje pistoletu %d • noża %d\n%s',c.aimbot and 'ON' or 'OFF',c.autoShot and 'ON' or 'OFF',c.shots,c.stabs,c.lastError)
  self.rolesInfo.Text=#roles>0 and table.concat(roles,'\n') or 'Brak innych aktywnych postaci.'
  if self.ui.current=='SETTINGS' then self.debugBox.Text=self:report() end
 end
 function A:stopAll()self.controller:stopAll();self.proximity=false;if self.threatInfo then self.threatInfo.Visible=false end;self.movement:reset();self.effects:clear();if self.quickTools then self.quickTools:reset()end;if self.ui then self.ui:refreshControls();self:notify('MM2','Zatrzymano funkcje, przywrócono kamerę i wyczyszczono efekty.') end end
 function A:unload()if not self.alive then return end;self:stopAll();self.alive=false;self.runtime:close();if _G.KubiHubRuntime==self then _G.KubiHubRuntime=nil end end
 return A
end
