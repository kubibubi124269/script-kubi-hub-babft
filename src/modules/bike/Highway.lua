return function(M)
 local H={};H.__index=H
 local keys=Enum.KeyCode
 local function flat(v)return Vector3.new(v.X,0,v.Z)end
 local function route(points)
  if not M.Util.vector(points.start) or not M.Util.vector(points.finish) then return nil,'Zapisz początek i koniec odcinka autostrady.'end
  local start,finish=Vector3.new(table.unpack(points.start)),Vector3.new(table.unpack(points.finish))
  local delta=flat(finish-start);local length=delta.Magnitude
  if length<70 or length>2000 or math.abs(finish.Y-start.Y)>length*.15 then
   return nil,'Wybierz prosty odcinek: 70–2000 studów między punktami, bez stromego podjazdu.'
  end
  local direction=delta.Unit
  return {start=start,direction=direction,right=Vector3.new(-direction.Z,0,direction.X),length=length}
 end
 function H.new(app)
  return setmetatable({app=app,active=false,state='OFF',laps=0,recoveries=0},H)
 end
 function H:label(text)
  if text then self.message=self.app:localize(text)end
  local points=self.app.config.data.bike.highway
  self.info.Text=(self.message or self.app:localize('Zapisz początek i koniec odcinka autostrady.'))..
   '\n'..self.app:localize('Punkty')..': '..(points.start and 'A ✓' or 'A —')..' / '..(points.finish and 'B ✓' or 'B —')..
   '  ·  '..self.app:localize('Pętle')..': '..self.laps..'  ·  '..self.app:localize('Odzyskania')..': '..self.recoveries
 end
 function H:save(which)
  if self.active or self.app.riding or self.app.routeIndex then return false,'Najpierw zatrzymaj jazdę.'end
  local _,_,seat=self.app:seat()
  if not seat then return false,'Zapisz punkty siedząc na rowerze.'end
  local p=seat.Position
  local point={p.X,p.Y,p.Z};if not M.Util.vector(point) then return false,'Nieprawidłowa pozycja roweru.'end
  self.app.config.data.bike.highway[which]=point
  self:label(which=='start' and 'Zapisano początek autostrady.' or 'Zapisano koniec autostrady.')
  return true
 end
 function H:clear()
  if self.active then return false,'Najpierw zatrzymaj jazdę.'end
  self.app.config.data.bike.highway={};self:label('Zapisz początek i koniec odcinka autostrady.');return true
 end
 function H:off(message)
  self.active=false;self.state='OFF';self.bike=nil;self.oldBike=nil
  self:label(message or 'Jazda zatrzymana.')
 end
 function H:align(seat)
  local assembly=seat.AssemblyRootPart
  if not assembly or assembly.Anchored then return false,'Nie rozpoznano ruchomego roweru.'end
  local line=self.line
  local pose=CFrame.lookAt(line.start,line.start+line.direction)
  assembly.AssemblyLinearVelocity=Vector3.zero;assembly.AssemblyAngularVelocity=Vector3.zero
  assembly.CFrame=pose*seat.CFrame:ToObjectSpace(assembly.CFrame)
  return true
 end
 function H:place(seat,now)
  local ok,err=self:align(seat);if not ok then return false,err end
  self.state='ALIGN';self.bike=seat;self.nextAt=now+.45;self.deadline=now+2.5
  self:label('Ustawiam rower na autostradzie…');return true
 end
 function H:start()
  local app=self.app
  if app.riding or app.flight.active or app.routeIndex or next(app.held) then return false,'Najpierw zatrzymaj jazdę.'end
  local line,err=route(app.config.data.bike.highway);if not line then return false,err end
  local ok,why=app:inputReady();if not ok then return false,why end
  self.active=true;self.line=line;self.laps=0;self.recoveries=0;self.retryTimes={};self.oldBike=nil
  local now=app.clock();local _,_,seat=app:seat()
  if seat then
   ok,why=self:place(seat,now);if not ok then app:stop(why);return false,why end
  else
   self.state='SPAWN';self.deadline=now+12;self.nextAt=now;self.recovering=false
   self:label('Szukam roweru…')
  end
  return true
 end
 function H:recover(now,reason)
  local app=self.app
  for key in pairs(app.held)do app:release(key)end
  while self.retryTimes[1] and now-self.retryTimes[1]>=45 do table.remove(self.retryTimes,1)end
  if #self.retryTimes>=3 then app:stop('Autostrada: limit prób powrotu. Sprawdź rower i odcinek.');return end
  self.retryTimes[#self.retryTimes+1]=now;self.recoveries+=1
  local _,_,seat=app:seat()
  self.oldBike=seat or self.oldBike
  self.state='SPAWN';self.bike=nil;self.deadline=now+12;self.nextAt=now+.65;self.recovering=true
  self:label('Odtwarzam rower po kraksie…'..(reason and '\n'..reason or ''))
 end
 function H:launch(now)
  local app=self.app;local _,_,seat=app:seat()
  if now>=self.deadline then
   if self.recovering then self:recover(now,'Rower nie wrócił.')else app:stop('Nie udało się wsiąść na rower. Użyj Q i E ręcznie.')end
   return
  end
  if next(app.held) or now<self.nextAt then return end
  if self.state=='SPAWN' then
   local c,humanoid,root=app:character()
   if not root then return end
   if seat and seat==self.oldBike then
    humanoid.Sit=false;self.nextAt=now+.4;return
   elseif not seat then
    local p=self.line.start+Vector3.new(0,2.5,0)
    local cf=CFrame.lookAt(p,p+self.line.direction)
    c:PivotTo(cf*root.CFrame:ToObjectSpace(c:GetPivot()))
   end
   local ok,err=app:press(keys.Q,.12,now);if not ok then app:stop(err);return end
   self.state='MOUNT';self.nextAt=now+1.2
   return
  end
  if seat and seat~=self.oldBike then
   local ok,err=self:place(seat,now);if not ok then app:stop(err)end
   return
  end
  local ok,err=app:press(keys.E,.12,now);if not ok then app:stop(err);return end
  self.nextAt=now+.9
 end
 function H:drive(now,c,root,seat)
  local app=self.app;local line=self.line
  local offset=flat(seat.Position-line.start)
  local along=offset:Dot(line.direction)
  local side=offset:Dot(line.right)
  if along>=line.length-8 and math.abs(side)<=10 then
   for key in pairs(app.held)do app:release(key)end
   self.state='BANK';self.nextAt=now+3;self.laps+=1;self:label('Koniec odcinka. Czekam na rozliczenie trików…');return
  end
  if math.abs(side)>11 or along< -9 then self:recover(now,'Rower zjechał z odcinka.');return end
  if now>=self.guardAt then
   self.guardAt=now+.15
   local reason=app:hazard(c,root,seat,line.direction)
   if reason then self:recover(now,reason);return end
   if along>=self.progress+.85 then self.progress=along;self.progressAt=now
   elseif now-self.progressAt>=4 then self:recover(now,'Rower nie rusza do przodu.');return end
  end
  local front=flat(seat.CFrame.LookVector)
  if front.Magnitude<.25 or front.Unit:Dot(line.direction)<.4 then self:recover(now,'Rower stracił kierunek.');return end
  local desired=(line.direction-line.right*math.clamp(side/15,-.45,.45)).Unit
  local error=front.Unit:Cross(desired).Y
  local steering=math.abs(error)>.085
  if steering and not app:release(keys.LeftControl) then app:stop('Nie udało się zwolnić wheelie.');return end
  if steering and now>=self.steerAt then
   local key=error>0 and keys.A or keys.D
   local other=key==keys.A and keys.D or keys.A
   if not app:release(other) then app:stop('Nie udało się zwolnić skrętu.');return end
   local ok,err=app:press(key,math.clamp(math.abs(error)*.45,.06,.16),now);if not ok then app:stop(err);return end
   self.steerAt=now+.25
  end
  local ok,err=app:driveInput(now,seat,not steering and not app.held[keys.A] and not app.held[keys.D] and math.abs(side)<2.5)
  if not ok then app:stop(err)end
 end
 function H:update(now)
  local app=self.app
  if app.input:GetFocusedTextBox() then app:stop('Otwarto pole tekstowe.');return end
  if self.state=='SPAWN' or self.state=='MOUNT' then self:launch(now);return end
  local c,root,seat=app:seat()
  if not seat or seat~=self.bike then self:recover(now,'Zejście z roweru.');return end
  if self.state=='ALIGN' then
   if now<self.nextAt then return end
   local front=flat(seat.CFrame.LookVector)
   if (seat.Position-self.line.start).Magnitude>8 or front.Magnitude<.25 or front.Unit:Dot(self.line.direction)<.9 then
    if now>=self.deadline then app:stop('Gra nie przyjęła ustawienia roweru na autostradzie.')end
    return
   end
   self.state='DRIVE';self.progress=0;self.progressAt=now;self.guardAt=now;self.steerAt=now
   app.gasAt=now;app.trickAt=now+2;app.trickIndex=0;app.trickSlot=1
   self.recovering=false;self:label('Jadę po zapisanej prostej.')
  elseif self.state=='BANK' then
   if now>=self.nextAt and not next(app.held) then
    local ok,err=self:place(seat,now);if not ok then app:stop(err)end
   end
   return
  end
  if self.state=='DRIVE' then self:drive(now,c,root,seat)end
 end
 function H:page(page)
  local app,ui=self.app,self.app.ui
  local card=ui:card(page,'Autostrada')
  ui:label(card,'Na rowerze zapisz A na początku pasa i B dalej na tej samej prostej. Po starcie hub wraca do A. Ustawienia gazu i trików są w sekcji Jazda. F8 zatrzymuje automat.')
  self.info=ui:label(card,'');self:label()
  ui:feature(card,'Farma autostrady',function()return self.active end,function()
   if self.active then return app:stop()end
   return self:start()
  end)
  ui:button(card,'Zapisz A — początek',function()return self:save('start')end)
  ui:button(card,'Zapisz B — koniec',function()return self:save('finish')end)
  ui:button(card,'Wyczyść odcinek',function()return self:clear()end)
 end
 return H
end
