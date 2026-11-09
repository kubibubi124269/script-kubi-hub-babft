return function(M)
 local Q={};Q.__index=Q
 local filters={
  {'Czarno-biały',-1,.08,0,255,255,255},
  {'Sepia',-.65,.07,0,255,221,174},
  {'Wyższy kontrast',0,.32,0,255,255,255},
  {'Nasycone kolory',.45,.08,0,255,255,255},
  {'Chłodny obraz',.05,0,0,190,224,255},
  {'Przyciemnienie',0,0,-.22,255,255,255},
 }
 local function formatTime(seconds)
  seconds=math.max(0,math.floor(seconds));return string.format('%02d:%02d',math.floor(seconds/60),seconds%60)
 end
 local function character(player)
  local model=player.Character
  return model and model:FindFirstChildOfClass('Humanoid'),model and model:FindFirstChild('HumanoidRootPart')
 end
 function Q:elapsed(now)return self.elapsedTime+(self.started and (now-self.started) or 0)end
 function Q:filter(row)
  if self.effect then self.effect:Destroy();self.effect=nil end
  if self.filterChoice==row or not row then self.filterChoice=nil;return end
  local effect=Instance.new('ColorCorrectionEffect');effect.Name='KubiHubQuickFilter'
  effect.Saturation=row[2];effect.Contrast=row[3];effect.Brightness=row[4];effect.TintColor=Color3.fromRGB(row[5],row[6],row[7])
  self.effect=effect;self.filterChoice=row;effect.Parent=game:GetService('Lighting')
 end
 function Q:deleteMarker()
  if self.marker then self.marker:Destroy();self.marker=nil;self.billboard=nil end
 end
 function Q:mark()
  local _,root=character(self.app.player);if not root then return false,'Brak aktywnej postaci.' end
  if not self.marker then
   local part=Instance.new('Part');part.Name='KubiHubLocalMarker';part.Size=Vector3.new(1,1,1);part.Transparency=1;part.Anchored=true
   part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;self.marker=part
   self.billboard=self.ui:create('BillboardGui',{Name='KubiHubMarkerLabel',Size=UDim2.fromOffset(130,34),StudsOffset=Vector3.new(0,2,0),MaxDistance=300,AlwaysOnTop=true,Adornee=part},part)
   self.ui:create('TextLabel',{Size=UDim2.fromScale(1,1),Text='▼  ZNACZNIK',TextColor3=Color3.fromRGB(255,224,93),TextStrokeTransparency=.2,BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=15},self.billboard)
  end
  self.marker.CFrame=CFrame.new(root.Position);self.marker.Parent=workspace;self.billboard.Enabled=true
  self.ui:refreshFeatures();return true
 end
 function Q:update(now)
  if self.timerEnd and now>=self.timerEnd then
   self.timerEnd=nil;self.timerDone=true
   self.ui:toast('Minutnik','Czas minął.');self.ui:refreshFeatures()
  end
  self.timerInfo.Text='Stoper: '..formatTime(self:elapsed(now))..'  ·  Międzyczas: '..(self.lap or '—')..
   '\nMinutnik: '..(self.timerEnd and formatTime(math.ceil(self.timerEnd-now)) or self.timerDone and 'koniec' or '—')
  if not next(self.metrics) then self.hud.Visible=false;return end
  local h,root=character(self.app.player)
  local pos=root and root.Position;local v=root and root.AssemblyLinearVelocity
  local rows={
   {'FPS',self.fps and string.format('%.0f',self.fps) or '—'},
   {'Czas sesji',formatTime(now-self.opened)},
   {'Pozycja XYZ',pos and string.format('%.0f / %.0f / %.0f',pos.X,pos.Y,pos.Z) or '—'},
   {'Zdrowie',h and string.format('%.0f / %.0f',h.Health,h.MaxHealth) or '—'},
   {'Prędkość',v and string.format('%.1f studów/s',Vector3.new(v.X,0,v.Z).Magnitude) or '—'},
   {'Liczba graczy',tostring(#game:GetService('Players'):GetPlayers())},
   {'Odległość do znacznika',pos and self.marker and string.format('%.0f studów',(self.marker.Position-pos).Magnitude) or '—'},
  }
  local lines={}
  for _,row in ipairs(rows)do if self.metrics[row[1]] then lines[#lines+1]=row[1]..': '..row[2] end end
  self.hud.Text=table.concat(lines,'\n');self.hud.Visible=true
 end
 function Q:reset()
  table.clear(self.metrics);self.hud.Visible=false;self:filter(nil);self:deleteMarker()
  self.started=nil;self.elapsedTime=0;self.lap=nil;self.timerEnd=nil;self.timerDone=false
  self:update(self.app.clock());self.ui:refreshFeatures()
 end
 function Q:Destroy()self:filter(nil);self:deleteMarker()end
 return function(app)
  local ui=app.ui
  local q=setmetatable({app=app,ui=ui,metrics={},opened=app.clock(),elapsedTime=0,timerSeconds=60},Q)
  app.quickTools=q;app.runtime:own(q)
  q.hud=ui:create('TextLabel',{Name='KubiHubQuickHUD',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12),Size=UDim2.fromOffset(205,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=ui.palette.panel,BackgroundTransparency=.12,TextColor3=ui.palette.text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,Text='',Visible=false},ui.gui)
  ui:corner(q.hud,8);ui:create('UIPadding',{PaddingLeft=UDim.new(0,9),PaddingRight=UDim.new(0,9),PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6)},q.hud)
  local page=ui:page('QUICK')
  local hud=ui:card(page,'HUD — informacje na ekranie')
  for _,label in ipairs({'FPS','Czas sesji','Pozycja XYZ','Zdrowie','Prędkość','Liczba graczy','Odległość do znacznika'})do
   ui:feature(hud,label,function()return q.metrics[label]==true end,function()
    q.metrics[label]=not q.metrics[label] and true or nil;q:update(app.clock())
   end)
  end
  local look=ui:card(page,'Filtry obrazu','Jeden filtr naraz. Kliknij aktywny filtr ponownie, aby go wyłączyć.')
  for _,row in ipairs(filters)do
   ui:feature(look,row[1],function()return q.filterChoice==row end,function()q:filter(row);ui:refreshFeatures()end)
  end
  local time=ui:card(page,'Czas — stoper i minutnik')
  q.timerInfo=ui:label(time,'')
  ui:feature(time,'Stoper',function()return q.started~=nil end,function()
   local now=app.clock()
   if q.started then q.elapsedTime=q:elapsed(now);q.started=nil else q.started=now end;q:update(now)
  end)
  ui:feature(time,'Zapisz międzyczas',nil,function()
   if not q.started and q.elapsedTime==0 then return false,'Najpierw uruchom stoper.' end
   q.lap=formatTime(q:elapsed(app.clock()));q:update(app.clock())
  end)
  ui:feature(time,'Reset stopera',nil,function()
   q.elapsedTime=0;q.lap=nil;if q.started then q.started=app.clock()end;q:update(app.clock())
  end)
  ui:feature(time,'Minutnik',function()return q.timerEnd~=nil end,function()
   if q.timerEnd then q.timerEnd=nil else q.timerEnd=app.clock()+q.timerSeconds end
   q.timerDone=false;q:update(app.clock())
  end,function(panel)
   ui:field(panel,'Czas następnego odliczania: 5–600 s',q.timerSeconds,function(v)q.timerSeconds=M.Util.number(tonumber(v),60,5,600);return q.timerSeconds end,false,function()return q.timerSeconds end)
  end)
  local mark=ui:card(page,'Znacznik miejsca','Punkt widoczny tylko u Ciebie. Zapisuje pozycję do końca sesji lub do STOP.')
  ui:feature(mark,'Zapisz znacznik tutaj',nil,function()return q:mark()end)
  ui:feature(mark,'Pokaż znacznik',function()return q.billboard and q.billboard.Enabled end,function()
   if not q.billboard then return false,'Najpierw zapisz znacznik.' end;q.billboard.Enabled=not q.billboard.Enabled
  end)
  ui:feature(mark,'Usuń znacznik',nil,function()q:deleteMarker();q:update(app.clock());ui:refreshFeatures()end)
  app.runtime:connect(game:GetService('RunService').Heartbeat,function(dt)
   if q.metrics.FPS and dt>0 then local current=1/dt;q.fps=q.fps and q.fps*.9+current*.1 or current end
  end,'Narzędzia')
  app.runtime:schedule('QuickTools',.25,function(_,now)q:update(now)end)
  q:update(app.clock())
 end
end
