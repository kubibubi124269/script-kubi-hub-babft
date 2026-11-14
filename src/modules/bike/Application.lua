return function(M)
 local A={};A.__index=A;A.run=M.Application.run
 local N={order={'RIDE','QUICK','SETTINGS'},titles={RIDE='Jazda',QUICK='Narzędzia',SETTINGS='Ustawienia'},matches=M.Navigation.matches}
 function N.resolve(id)return id=='HOME' and 'RIDE' or id=='DEBUG' and 'SETTINGS' or id end
 function N.rank(id)return id=='RIDE' and 1 or id=='QUICK' and 2 or 3 end
 local keys=Enum.KeyCode
 local tricks={keys.One,keys.Two,keys.Three,keys.Four}
 function A:localize(text)return M.Locale.text(self.language,text)end
 function A:inputReady()
  if self.input:GetFocusedTextBox() then return false,'Zamknij pole tekstowe i spróbuj ponownie.'end
  if self.virtual then return true end
  local ok,input=pcall(function()return self.input:CreateVirtualInput()end)
  if not ok or not input then return false,'Ten klient nie udostępnia sterowania wirtualnego Roblox.'end
  self.virtual=input;return true
 end
 function A:press(key,seconds,now)
  local held=self.held[key]
  if held then
   if held==-math.huge then return false,'Poczekaj na zwolnienie klawiszy.'end
   self.held[key]=math.max(held,now+seconds);return true
  end
  local ok,err=pcall(function()self.virtual:SendKey(true,key,false)end)
  if not ok then return false,tostring(err)end
  self.held[key]=now+seconds;return true
 end
 function A:release(key)
  if not self.held[key] then return true end
  local ok=pcall(function()self.virtual:SendKey(false,key,false)end)
  if ok then self.held[key]=nil else self.held[key]=-math.huge end
  return ok
 end
 function A:stop(message)
  self.riding=false;self.rider=nil;self.routeIndex=nil
  for key in pairs(self.held)do self:release(key)end
  self.rideInfo.Text=self:localize(message or 'Jazda zatrzymana.')
  if self.routeInfo then self:updateRouteLabel()end
  self.ui:refreshFeatures()
  return true
 end
 function A:character()
  local c=self.player.Character
  local h=c and c:FindFirstChildOfClass('Humanoid')
  local root=c and c:FindFirstChild('HumanoidRootPart')
  if h and h.Health>0 and root and root:IsA('BasePart')then return c,h,root end
 end
 function A:seat()
  local c,h,root=self:character()
  local seat=h and h.SeatPart
  if seat and seat:IsDescendantOf(workspace) and seat.Occupant==h then return c,root,seat end
 end
 function A:hazard(c,root,seat)
  if seat.CFrame.UpVector.Y<.35 then return 'Rower się przewrócił.'end
  local front=seat.CFrame.LookVector
  local velocity=seat.AssemblyLinearVelocity.Magnitude
  local cfg=RaycastParams.new();cfg.FilterType=Enum.RaycastFilterType.Exclude;cfg.IgnoreWater=true;cfg.RespectCanCollide=true
  cfg.FilterDescendantsInstances={c,seat:FindFirstAncestorOfClass('Model') or seat}
  local reach=math.clamp(5+velocity*.22,5,20)
  if workspace:Raycast(seat.Position+Vector3.new(0,.8,0),front*reach,cfg) then return 'Przeszkoda — jazda zatrzymana.'end
  if not workspace:Raycast(seat.Position+front*reach+Vector3.new(0,3,0),Vector3.new(0,-14,0),cfg) then return 'Brak podłoża przed rowerem.'end
  if self.lastPosition and (root.Position-self.lastPosition).Magnitude>=.75 then self.lastPosition=root.Position;self.lastProgress=self.clock()end
  if self.riding and self.clock()-self.lastProgress>=4 then return 'Rower utknął. Przejmij sterowanie.'end
 end
 function A:startRide()
  if next(self.held) then return false,'Poczekaj na zwolnienie klawiszy.'end
  local c,root,seat=self:seat()
  if not seat then return false,'Najpierw wsiądź na rower.'end
  local ok,err=self:inputReady();if not ok then return false,err end
  local now=self.clock()
  self.routeIndex=nil;self.rider=c;self.riding=true;self.gasAt=now;self.trickAt=now+2;self.lastProgress=now;self.lastPosition=root.Position
  self.rideInfo.Text=self:localize('Automatyczna jazda');return true
 end
 function A:tap(key)
  if self.riding or self.routeIndex then return false,'Najpierw zatrzymaj jazdę.'end
  local ok,err=self:inputReady();if not ok then return false,err end
  return self:press(key,.12,self.clock())
 end
 function A:mark(index)
  if self.routeIndex then return false,'Najpierw zatrzymaj trasę.'end
  local _,_,root=self:character();if not root then return false,'Brak aktywnej postaci.'end
  if index then self.startPoint=root.CFrame
  else
   if #self.checkpoints>=30 then return false,'Limit: 30 checkpointów.'end
   self.checkpoints[#self.checkpoints+1]=root.CFrame
  end
  self:updateRouteLabel();return true
 end
 function A:updateRouteLabel()
  local state=self.routeIndex and (math.max(0,self.routeIndex-1)..' / '..#self.checkpoints) or tostring(#self.checkpoints)
  self.routeInfo.Text=self:localize('Checkpointy')..': '..state
 end
 function A:moveTo(cf)
  local c,h,root=self:character()
  if not root then return false,'Brak aktywnej postaci.'end
  if h.SeatPart then
   local seat=h.SeatPart
   local assembly=seat.Occupant==h and seat.AssemblyRootPart
   if not assembly or assembly.Anchored or not seat:IsDescendantOf(workspace) then return false,'Nie rozpoznano ruchomego roweru.'end
   assembly.CFrame=assembly.CFrame+(cf.Position-root.Position)
  else c:PivotTo(cf*root.CFrame:ToObjectSpace(c:GetPivot())) end
  return true
 end
 function A:raceTick(now)
  local index=self.routeIndex
  if not index or now<self.routeAt then return end
  local point=self.checkpoints[index]
  if not point then self:stop('Trasa zakończona. Sprawdź wynik w grze.');self:updateRouteLabel();return end
  local ok,err=self:moveTo(point)
  if not ok then self:stop(err);self:updateRouteLabel();return end
  self.routeIndex=index+1;self.routeAt=now+1;self:updateRouteLabel()
 end
 function A:update(now)
  for key,untilAt in pairs(self.held)do if now>=untilAt then self:release(key)end end
  if self.routeIndex then self:raceTick(now);return end
  if not self.riding then return end
  local c,root,seat=self:seat();if not seat or c~=self.rider then self:stop('Zejście z roweru.');return end
  if self.input:GetFocusedTextBox() then self:stop('Otwarto pole tekstowe.');return end
  local cfg=self.config.data.bike
  if cfg.guard then local reason=self:hazard(c,root,seat);if reason then self:stop(reason);return end end
  local pace=M.Tempo.bike[cfg.tempo] or M.Tempo.bike.NORMAL
  if now>=self.gasAt then
   local time=pace.gas*(cfg.boost and 1.35 or 1)
   local ok,err=self:press(keys.W,time,now);if not ok then self:stop(err);return end
   self.gasAt=now+time+pace.coast
  end
  if now>=self.trickAt and seat.AssemblyLinearVelocity.Magnitude>=6 then
   self.trickAt=now+pace.interval
   local ok,err=true,nil
   if cfg.wheelie and (not cfg.tricks or self.trickIndex%2==0) then ok,err=self:press(keys.LeftControl,pace.wheelie,now)
   elseif cfg.tricks then
    ok,err=self:press(tricks[self.trickSlot],.12,now);self.trickSlot=self.trickSlot%#tricks+1
   end
   if not ok then self:stop(err)end
   self.trickIndex+=1
  end
 end
 function A:stopAll()self:stop();self:updateRouteLabel();if self.quickTools then self.quickTools:reset()end end
 function A:unload()
  if not self.alive then return end
  self:stopAll();self.alive=false;self.runtime:close();if _G.KubiHubRuntime==self then _G.KubiHubRuntime=nil end
 end
 function A.new(onCreating)
  local self=setmetatable({alive=true,mode='BIKE',clock=os.clock,navigation=N,held={},checkpoints={},trickIndex=0,trickSlot=1},A)
  self.player=game:GetService('Players').LocalPlayer;assert(self.player and self.player:WaitForChild('PlayerGui',10),'Missing local PlayerGui.')
  self.input=game:GetService('UserInputService')
  self.log=M.Log.new(function()return os.date('%H:%M:%S')end)
  self.runtime=M.Runtime.new(self.clock,function(module,err)self.log:error(module,err);if self.ui then self.ui:toast(module,err,true)end end)
  if onCreating then onCreating(self)end
  M.Profiles.init(self,'BIKE')
  self.runtime:own({Destroy=function()for key in pairs(self.held)do self:release(key)end end})
  local ui=M.UI.new(self);self.ui=ui;ui.title.Text='DELUXE / BIKE UNIVERSE'
  local page=ui:page('RIDE')
  local ride=ui:card(page,'Jazda')
  ui:label(ride,'Trzymaj się otwartej drogi. F8 zatrzymuje gaz i triki. Nagrody nalicza gra.')
  self.rideInfo=ui:label(ride,'Gotowy.')
  ui:feature(ride,'Automatyczna jazda',function()return self.riding end,function()if self.riding then return self:stop()end;return self:startRide()end)
  ui:cycle(ride,'Profil tempa',M.Tempo.order,function()return self.config.data.bike.tempo end,function(v)self.config.data.bike.tempo=v end)
  ui:button(ride,'Zresp rower (Q)',function()return self:tap(keys.Q)end)
  ui:button(ride,'Wsiądź (E)',function()return self:tap(keys.E)end)
  for _,row in ipairs({{'Wheelie (Ctrl)','wheelie'},{'Triki 1–4','tricks'},{'Osłona przed kraksą','guard'},{'Boost gazu','boost'},{'Puls podczas bezczynności','antiIdle'}})do
   ui:feature(ride,row[1],function()return self.config.data.bike[row[2]]end,function()local cfg=self.config.data.bike;cfg[row[2]]=not cfg[row[2]]end)
  end
  ui:label(ride,'Boost wydłuża trzymanie W. Osłona próbuje zatrzymać automat przy przeszkodzie, krawędzi lub utknięciu.')
  ui:button(ride,'STOP',function()return self:stopAll()end)
  local race=ui:card(page,'Trasa wyścigu')
  ui:label(race,'Zapisz start i punkty w kolejności. Przyjmij zaproszenie w grze, a po starcie użyj zapisanej trasy.')
  self.routeInfo=ui:label(race,'');self:updateRouteLabel()
  ui:button(race,'Zapisz start',function()return self:mark(true)end)
  ui:button(race,'Dodaj checkpoint',function()return self:mark(false)end)
  ui:button(race,'Przenieś do startu',function()if not self.startPoint then return false,'Najpierw zapisz start.'end;self:stop();return self:moveTo(self.startPoint)end)
  ui:button(race,'Przejedź zapisane checkpointy',function()
   if #self.checkpoints==0 then return false,'Najpierw dodaj checkpointy.'end
   self:stop();self.routeIndex=1;self.routeAt=self.clock();self:updateRouteLabel();return true
  end)
  ui:button(race,'Wyczyść trasę',function()self:stop();self.startPoint=nil;table.clear(self.checkpoints);self:updateRouteLabel()end)
  M.QuickTools(self);M.Profiles.page(self);M.CommunityLinks.page(self)
  ui:show('RIDE');ui:theme()
  self.runtime:connect(self.player.CharacterAdded,function()self:stopAll()end,'Bike')
  self.runtime:connect(self.input.WindowFocusReleased,function()self:stopAll()end,'Bike')
  self.runtime:connect(self.input.InputBegan,function(event)if event.KeyCode==keys.F8 or self.riding and (event.KeyCode==keys.A or event.KeyCode==keys.D or event.KeyCode==keys.S or event.KeyCode==keys.Space) then self:stop()end end,'Bike')
  self.runtime:connect(self.player.Idled,function()
   if not self.riding or not self.config.data.bike.antiIdle then return end
   local c,root,seat=self:seat();if not seat or self.input:GetFocusedTextBox() or self:hazard(c,root,seat) then return end
   if not self.held[keys.W] then local ok,err=self:press(keys.W,.15,self.clock());if not ok then self:stop(err)end end
  end,'Bike')
  ui.statusBody=ui:card(ui:page('SETTINGS'),'Ostatni komunikat');ui.statusInfo=ui:label(ui.statusBody,'Gotowy.')
  self.runtime:connect(game:GetService('RunService').Heartbeat,function(dt)self.runtime:tick(dt)end,'Bike')
  self.runtime:schedule('Bike',.05,function(_,now)
   local ok,err=pcall(self.update,self,now);if not ok then self:stop();self.runtime.errors('Bike',err)end
   ui:tick()
  end)
  return self
 end
 return A
end
