return function(M)
 local A={};A.__index=A;A.run=M.Application.run;A.notify=M.Application.notify;A.copy=M.Application.copy
 local N={order={'MISC','PLAYER','CAMERA','TELEPORT','SETTINGS'},titles={MISC='Główne',PLAYER='Postać',CAMERA='Widok',TELEPORT='Teleport',SETTINGS='Ustawienia'},matches=M.Navigation.matches}
 function N.resolve(id)return id=='HOME' and 'MISC' or id=='DEBUG' and 'SETTINGS' or id end
 function N.rank(id)for i,key in ipairs(N.order)do if id==key then return i end end;return 99 end
 function A.new(onCreating)
  local self=setmetatable({alive=true,mode='UNIVERSAL',navigation=N,clock=os.clock,fps=0,fovEnabled=false,fov=80,cameraOriginal={},bright=false},A)
  self.player=game:GetService('Players').LocalPlayer;assert(self.player,'Brak LocalPlayer.');self.player:WaitForChild('PlayerGui',10)
  self.input=game:GetService('UserInputService');self.runService=game:GetService('RunService');self.lighting=game:GetService('Lighting')
  self.log=M.Log.new(function()return os.date('%H:%M:%S')end);self.runtime=M.Runtime.new(self.clock,function(module,err)self.log:error(module,err);if self.ui then self.ui:toast(module,err,true)end end)
  if onCreating then onCreating(self)end
  self.config={data=M.Util.copy(M.Config.defaults)};local saved=_G.KubiHubUniversalSettings;if type(saved)=='table' then local value=M.Config.validate({ui=saved.ui});if value then self.config.data.ui=value.ui end end
  self.platform={allowed=true,character=function()
   local c=self.player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local r=c and c:FindFirstChild('HumanoidRootPart');if c and h and r and h.Health>0 then return c,h,r end
  end}
  self.adapter={mode='UNIVERSAL',capabilities={movement=true},cancel=function()end,movement=function(_,values)local _,h=self.platform:character();if not h then return {ok=false,error='Poczekaj na aktywną postać.'}end;h.WalkSpeed=values.walk;if h.UseJumpPower then h.JumpPower=values.jump else h.JumpHeight=values.jump^2/(2*workspace.Gravity)end;return {ok=true}end}
  self.movement=M.Movement.new(self.runtime,self.adapter,self.player,self.input,self.log,self.config.data.movement);self.avatar=M.AvatarAppearance.new(self.platform,self.runtime);self.runtime:own(self.avatar)
  self.ui=M.UI.new(self);self.ui.title.Text='KUBI HUB  /  UNIVERSAL'
  self.crossGui=self.ui:create('ScreenGui',{Name='KubiHubUniversalCrosshair',IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=80},self.player.PlayerGui);self.runtime:own(self.crossGui)
  self.cross=self.ui:create('TextLabel',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(48,48),Text='+',TextSize=24,Font=Enum.Font.GothamBold,TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,Visible=false},self.crossGui)
  self:pages();self.ui:show('MISC');self.ui:theme();self:updateDashboard()
  self.runtime:connect(self.runService.Heartbeat,function(dt)self.fps=self.fps==0 and 1/math.max(dt,.001) or self.fps*.95+1/math.max(dt,.001)*.05;self.runtime:tick(dt)end,'Universal')
  self.runtime:connect(self.runService.RenderStepped,function()self.movement:tick();self.avatar:render();self:applyFov()end,'Universal')
  self.runtime:connect(self.player.CharacterAdded,function()self.movement:reset();self.avatar:reset();self.ui:refreshFeatures()end,'Respawn')
  self.runtime:schedule('UniversalUI',.1,function()self.ui:tick()end)
  self.runtime:schedule('UniversalStatus',.5,function()local ok,err=self.avatar:refresh();if not ok then self.ui:toast('Postać',err,true)end;self:updateDashboard()end)
  return self
 end
 function A:applyFov()
  local camera=workspace.CurrentCamera;if not self.fovEnabled or not camera then return end
  if self.cameraOriginal[camera]==nil then self.cameraOriginal[camera]=camera.FieldOfView end
  if camera.FieldOfView~=self.fov then camera.FieldOfView=self.fov end
 end
 function A:resetFov()
  self.fovEnabled=false;for camera,value in pairs(self.cameraOriginal)do pcall(function()camera.FieldOfView=value end)end;self.cameraOriginal={}
 end
 function A:setBright(value)
  if value and not self.bright then self.lightOriginal={};for _,key in ipairs({'Brightness','ClockTime','Ambient','OutdoorAmbient','FogEnd','GlobalShadows'})do self.lightOriginal[key]=self.lighting[key]end end
  if value then self.lighting.Brightness=2;self.lighting.ClockTime=14;self.lighting.Ambient=Color3.fromRGB(170,170,170);self.lighting.OutdoorAmbient=Color3.fromRGB(170,170,170);self.lighting.FogEnd=100000;self.lighting.GlobalShadows=false
  elseif self.lightOriginal then for key,original in pairs(self.lightOriginal)do self.lighting[key]=original end;self.lightOriginal=nil end
  self.bright=value;return true
 end
 function A:pages()
  local ui=self.ui;M.ExtraPages(self)
  local main=ui:card(ui:page('MISC'),'Universal','Wspólne narzędzia klienta. Gra może przywracać własny ruch, kamerę i oświetlenie. Nie ma tu serwerowych nagród ani funkcji walki MM2.')
  self.info=ui:label(main,'');ui:button(main,'STOP / przywróć zmiany',function()self:stopAll()end);ui:button(main,'Wróć do wyboru huba',function()self:unload();_G.KubiHubRuntime=M.Launcher.new()end)
  local player=ui:page('PLAYER');local move=ui:card(player,'Ruch postaci','Zastosowanie lokalne. Gra może korygować ruch. Wyłączenie przywraca zapamiętane ustawienia.')
  local function options(panel)for _,row in ipairs({{'Prędkość','walk',8,60},{'Skok','jump',20,120},{'Prędkość Fly','flySpeed',10,100}})do local spec=row;ui:slider(panel,spec[1],function()return self.config.data.movement[spec[2]]end,function(v)self.config.data.movement[spec[2]]=v end,spec[3],spec[4],1)end end
  ui:feature(move,'Zastosuj ruch',nil,function()return self.movement:apply()end,options)
  ui:feature(move,'Fly',function()return self.movement.fly end,function()if self.movement.fly then self.movement:stopFly();return true else return self.movement:startFly()end end,options)
  ui:button(move,'Przywróć ruch',function()return self.movement:reset()end);M.AppearanceControls(self,player,false)
  local view=ui:card(ui:page('CAMERA'),'Kamera i widok','Zmiany widoczne u Ciebie. STOP przywraca zapamiętane wartości.')
  ui:feature(view,'Pole widzenia',function()return self.fovEnabled end,function()if self.fovEnabled then self:resetFov()else self.fovEnabled=true;self:applyFov()end end,function(panel)ui:slider(panel,'FOV',function()return self.fov end,function(v)self.fov=v;self:applyFov()end,40,110,1)end)
  ui:feature(view,'Celownik',function()return self.cross.Visible end,function()self.cross.Visible=not self.cross.Visible end,function(panel)ui:slider(panel,'Rozmiar celownika',function()return self.cross.TextSize end,function(v)self.cross.TextSize=v end,12,40,1)end)
  ui:feature(view,'Jasny dzień — lokalnie',function()return self.bright end,function()return self:setBright(not self.bright)end,function(panel)ui:label(panel,'Lokalne oświetlenie. Wyłączenie przywraca porę, jasność, mgłę i cienie.')end)
  local settings=ui:page('SETTINGS');local s=ui:card(settings,'Wygląd huba')
  ui:cycle(s,'Akcent',{'BLUE','PURPLE'},function()return self.config.data.ui.theme end,function(v)self.config.data.ui.theme=v;ui:theme()end)
  ui:toggle(s,'Tryb kompaktowy',function()return self.config.data.ui.compact end,function(v)self.config.data.ui.compact=v;ui:fit()end)
  ui:button(s,'Zapisz wygląd na sesję',function()_G.KubiHubUniversalSettings={ui=M.Util.copy(self.config.data.ui)};self:notify('Universal','Zapisano wygląd. Funkcje nie włączą się automatycznie.')end)
  ui.statusBody=ui:card(settings,'Ostatni komunikat');ui.statusInfo=ui:label(ui.statusBody,'Gotowy.');ui.routes.DEBUG=ui.statusBody
  ui:button(s,'Wyłącz i przywróć zmiany',function()self:unload()end)
 end
 function A:updateDashboard()
  self.ui:refreshFeatures();self.ui.subtitle.Text='V'..M.Version.current..'  •  UNIVERSAL'
  self.info.Text=string.format('FPS %.0f\nMiejsce: %s\nLPM: użyj · PPM / ⋯: opcje\nFunkcje zaczynają wyłączone.',self.fps,tostring(game.PlaceId))
 end
 function A:stopAll()
  self.movement:reset();self.avatar:reset();self:resetFov();self:setBright(false);self.cross.Visible=false;if self.ui then self.ui:refreshFeatures()end
 end
 function A:unload()if not self.alive then return end;self:stopAll();self.alive=false;self.runtime:close();if _G.KubiHubRuntime==self then _G.KubiHubRuntime=nil end end
 return A
end
