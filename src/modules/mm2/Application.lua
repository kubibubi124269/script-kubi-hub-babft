return function(M)
 local A={};A.__index=A
 A.run=M.Application.run;A.notify=M.Application.notify;A.copy=M.Application.copy
 function A.new(onCreating)
  local self=setmetatable({alive=true,clock=os.clock,navigation=M.MM2Navigation,fps=0},A)
  self.players=game:GetService('Players');self.player=self.players.LocalPlayer;assert(self.player,'Brak LocalPlayer.');self.player:WaitForChild('PlayerGui',10)
  self.input=game:GetService('UserInputService');self.runService=game:GetService('RunService');self.http=game:GetService('HttpService')
  self.log=M.Log.new(function()return os.date('%H:%M:%S')end);self.runtime=M.Runtime.new(self.clock,function(module,e)self.log:error(module,e);if self.ui then self.ui:toast(module,e,true) end end)
  if onCreating then onCreating(self) end
  self.config={data=M.Util.copy(M.Config.defaults)}
  local saved=_G.KubiHubMM2Settings;if type(saved)=='table' then local data=M.Config.validate({ui=saved.ui});if data then self.config.data.ui=data.ui end end
  self.platform=M.MM2Platform.new(self.player,self.players,workspace,game.PlaceId,game.GameId);self.controller=M.MM2Controller.new(self.runtime,self.platform,self.clock)
  self.adapter={mode='MM2',capabilities={movement=self.platform.allowed},cancel=function()end}
  self.adapter.movement=function(_,values)local _,h=self.platform:character();if not self.platform.allowed or not h then return {ok=false,error='Brak aktywnej postaci MM2.'} end;h.WalkSpeed=values.walk;if h.UseJumpPower then h.JumpPower=values.jump else h.JumpHeight=values.jump^2/(2*workspace.Gravity) end;return {ok=true}end
  self.movement=M.Movement.new(self.runtime,self.adapter,self.player,self.input,self.log,self.config.data.movement);self.effects=M.Effects.new(self.clock)
  self.ui=M.UI.new(self);self.ui.title.Text='KUBI HUB  /  MM2';self:pages();self.ui:show('HOME');self.ui:theme();self:updateDashboard()
  self.runtime:connect(self.runService.Heartbeat,function(dt)self.fps=self.fps==0 and 1/math.max(dt,.001) or self.fps*.95+1/math.max(dt,.001)*.05;self.runtime:tick(dt)end,'MM2')
  self.runtime:connect(self.runService.RenderStepped,function()self.movement:tick()end,'Movement')
  self.runService:BindToRenderStep('KubiHubMM2Aim',Enum.RenderPriority.Camera.Value+1,function(dt)if self.alive then local ok,err=pcall(function()self.controller:aimTick(dt)end);if not ok then self.controller.aimbot=false;self.controller.autoShot=false;self.log:error('Aim',err);self.ui:toast('Aim',err,true);self.ui:refreshControls() end end end)
  self.runtime:own({Destroy=function()self.runService:UnbindFromRenderStep('KubiHubMM2Aim')end})
  self.runtime:connect(self.player.CharacterAdded,function()self.controller:stopCombat();self.controller.current=nil;self.controller.coins={};self.controller.scannedAt=-math.huge;self.movement:reset();self.effects:clear()end,'Respawn')
  self.runtime:schedule('MM2Controllers',.05,function(dt)
   local ok,err=pcall(function()self.controller:tick(dt)end)
   if not ok then self.controller:stopAll();self.log:error('MM2',err);self.ui:toast('MM2',err,true);self.ui:refreshControls() end
   self.effects:tick();self.ui:tick()
  end)
  self.runtime:schedule('MM2Status',.5,function()self.platform:updateESP(self.controller.esp);self:updateDashboard()end)
  return self
 end
 function A:pages()
  local ui=self.ui;local c=self.controller
  local home=ui:page('HOME');local info=ui:card(home,'MM2 — centrum sterowania','Role są rozpoznawane po widocznej broni. Brak noża lub pistoletu nie dowodzi roli innego gracza. Nowe funkcje wymagają sprawdzenia w obecnej grze.')
  self.homeInfo=ui:label(info,'');ui:button(info,'STOP WSZYSTKO',function()self:stopAll()end);ui:button(info,'Wróć do wyboru BABFT / MM2',function()self:unload();_G.KubiHubRuntime=M.Launcher.new()end)
  ui:button(info,'Otwórz autofarmę',function()ui:show('FARM')end);ui:button(info,'Otwórz Combat',function()ui:show('COMBAT')end)
  local farm=ui:page('FARM');local f=ui:card(farm,'Monety i cukierki — szybkie zbieranie','TURBO podejmuje następną próbę co 0,12 s, gdy poprzedni przedmiot zniknie. Pełna torba wstrzymuje zbieranie. Przedmioty bez oznaczenia typu są obsługiwane przez oba filtry; na ekranie są próby i zniknięcia obiektów, bez deklaracji zdobytej waluty.')
  self.farmInfo=ui:label(f,'');ui:button(f,'START zbierania',function()return c:startFarm()end);ui:button(f,'STOP zbierania',function()return c:stopFarm()end);ui:button(f,'PAUZA / WZNÓW',function()return c:pauseFarm()end)
  ui:cycle(f,'Przedmioty',{'BOTH','COIN','CANDY'},function()return c.kind end,function(v)return c:setFilter(v)end);ui:cycle(f,'Prędkość',{'NORMAL','FAST','TURBO'},function()return c.speed end,function(v)c.speed=v end)
  ui:button(f,'Odśwież przedmioty',function()c.scannedAt=-math.huge;c.current=nil;self:notify('MM2','Lista zostanie odświeżona przy następnym kroku zbierania.')end);ui:button(f,'Reset statystyk',function()return c:resetStats()end)
  local combat=ui:page('COMBAT');local aim=ui:card(combat,'Aimbot i Auto Shot','Celowanie obraca kamerę. Auto Shot używa wyłącznie własnego pistoletu i zwykłej aktywacji narzędzia; odnowienie oraz obrażenia nadal zatwierdza gra.')
  self.combatInfo=ui:label(aim,'');ui:toggle(aim,'Aimbot',function()return c.aimbot end,function(v)c.aimbot=v end);ui:toggle(aim,'Auto Shot',function()return c.autoShot end,function(v)c.autoShot=v end)
  ui:cycle(aim,'Cel',{'MURDERER','NEAREST','SELECTED'},function()return c.settings.target end,function(v)c.settings.target=v end)
  ui:field(aim,'Dokładny nick wybranego celu','',function(v)c.settings.selected=v;return v end)
  ui:slider(aim,'Zasięg celownika w pikselach',function()return c.settings.fov end,function(v)c.settings.fov=v end,40,500,10)
  ui:slider(aim,'Szybkość celowania',function()return c.settings.smooth end,function(v)c.settings.smooth=v end,5,60,1)
  ui:toggle(aim,'Sprawdzaj ściany',function()return c.settings.wallCheck end,function(v)c.settings.wallCheck=v end)
  ui:field(aim,'Przerwa Auto Shot w sekundach',.7,function(v)c.settings.shotInterval=M.Util.number(tonumber(v),.7,.35,3);return c.settings.shotInterval end)
  local melee=ui:card(combat,'Murderer, Kill all i Fling','Kill all: pojedynczy obieg widocznych żywych postaci z własnym nożem. Murder Fling: krótka próba fizyki własnej postaci, maksymalnie 1,5 s. Skutek obu akcji zależy od serwera. Zbieranie i Fly muszą być wcześniej zatrzymane.')
  ui:button(melee,'KILL ALL — użyj własnego noża',function()return c:startKillAll()end);ui:button(melee,'MURDER FLING — wykryty Murderer / wybrany nick',function()return c:startFling()end);ui:button(melee,'STOP akcji walki',function()return c:stopCombat()end)
  ui:toggle(melee,'Knife Aura — własny nóż, zasięg 6 studów',function()return c.aura end,function(v)c.aura=v end)
  local players=ui:page('PLAYER');local p=ui:card(players,'ESP ról i upuszczona broń','Czerwony: wykryty nóż. Niebieski: wykryty pistolet. Żółty: rola nieznana. Oznaczenia są lokalne.')
  self.rolesInfo=ui:label(p,'');ui:toggle(p,'ESP ról',function()return c.esp end,function(v)c.esp=v;self.platform:updateESP(v)end)
  ui:toggle(p,'Auto podnoszenie upuszczonego pistoletu',function()return c.autoGun end,function(v)c.autoGun=v end)
  ui:button(p,'Podnieś upuszczony pistolet',function()if self.runtime.lock then return false,'Najpierw zatrzymaj moduł '..self.runtime.lock end;return self.platform:pickupGun()end)
  local move=ui:card(players,'Własna postać','Zmiany ruchu są lokalne i mogą być korygowane przez serwer. Fly wyklucza jednoczesne zbieranie i akcje walki.')
  for _,spec in ipairs({{'WalkSpeed','walk',8,60},{'Skok','jump',20,120},{'Fly speed','flySpeed',10,100}}) do local s=spec;ui:slider(move,s[1],function()return self.config.data.movement[s[2]]end,function(v)self.config.data.movement[s[2]]=v end,s[3],s[4],1) end
  ui:button(move,'Zastosuj ruch',function()return self.movement:apply()end);ui:button(move,'Włącz Fly',function()return self.movement:startFly()end);ui:button(move,'Wyłącz Fly / przywróć ruch',function()return self.movement:reset()end)
  ui:button(move,'Konfetti',function()local _,_,r=self.platform:character();self.effects:confetti(r)end)
  local settings=ui:page('SETTINGS');local s=ui:card(settings,'Wygląd i ustawienia','Moduły zawsze zaczynają wyłączone. Prawy Ctrl pokazuje lub ukrywa hub.')
  ui:cycle(s,'Akcent',{'BLUE','PURPLE'},function()return self.config.data.ui.theme end,function(v)self.config.data.ui.theme=v;ui:theme()end);ui:toggle(s,'Tryb kompaktowy',function()return self.config.data.ui.compact end,function(v)self.config.data.ui.compact=v;ui:fit()end)
  ui:button(s,'Zapisz wygląd na sesję',function()_G.KubiHubMM2Settings={ui=M.Util.copy(self.config.data.ui)};self:notify('Settings','Zapisano wygląd. Moduły nie uruchomią się automatycznie.')end)
  ui.statusBody=ui:card(settings,'Ostatni komunikat','Kliknij powiadomienie lub dolny pasek, aby otworzyć pełną treść.');ui.statusInfo=ui:label(ui.statusBody,'Gotowy.')
  local debug=ui:card(settings,'Raport MM2','Próby strzału i ciosu nie są liczone jako trafienia. Nie są wyświetlane wymyślone salda ani potwierdzenia zabójstw.');ui.routes.DEBUG=debug
  self.debugBox=ui:field(debug,'Raport do skopiowania','',nil,true);ui:button(debug,'Skopiuj raport MM2',function()self:copy(self:report(),self.debugBox)end);ui:button(debug,'Wyłącz hub',function()self:unload()end)
 end
 function A:report()
  local c=self.controller;return self.log:text()..string.format('\nMM2 wykryte: %s\nWłasna broń / rola: %s\nZbieranie: %s\nPróby odbioru: %d\nZniknięcia obiektów po próbie: %d\nAktywacje pistoletu: %d\nAktywacje noża: %d\nOstatni błąd: %s',tostring(self.platform.allowed),self.platform:role(self.player),c.state,c.attempts,c.disappeared,c.shots,c.stabs,c.lastError)
 end
 function A:updateDashboard()
  local c=self.controller;local roles={};for _,p in ipairs(self.platform:people()) do roles[#roles+1]=p.player.Name..': '..p.role end
  self.ui.subtitle.Text='V'..M.Version.current..'  •  MURDER MYSTERY 2'
  self.homeInfo.Text=string.format('MM2: %s\nWłasna rola / broń: %s\nFPS %.1f • zbieranie: %s\nAkcja walki: %s',self.platform.allowed and 'wykryto' or 'nie wykryto — moduły gry zablokowane',self.platform:role(self.player),self.fps,c.state,c.combat and c.combat.kind or 'STOP')
  self.farmInfo.Text=string.format('Stan %s\nPróby odbioru %d • zniknięcia obiektów %d\nNie jest to potwierdzone saldo monet ani cukierków.\n%s',c.state,c.attempts,c.disappeared,c.lastError)
  self.combatInfo.Text=string.format('Aimbot %s • Auto Shot %s\nAktywacje pistoletu %d • noża %d\n%s',c.aimbot and 'ON' or 'OFF',c.autoShot and 'ON' or 'OFF',c.shots,c.stabs,c.lastError)
  self.rolesInfo.Text=#roles>0 and table.concat(roles,'\n') or 'Brak innych aktywnych postaci.'
  if self.ui.current=='SETTINGS' then self.debugBox.Text=self:report() end
 end
 function A:stopAll()self.controller:stopAll();self.movement:reset();self.effects:clear();if self.ui then self.ui:refreshControls();self:notify('MM2','Zatrzymano zbieranie, celowanie, walkę, Auto Gun, Knife Aura, ESP i własne efekty.') end end
 function A:unload()if not self.alive then return end;self:stopAll();self.alive=false;self.runtime:close();if _G.KubiHubRuntime==self then _G.KubiHubRuntime=nil end end
 return A
end
