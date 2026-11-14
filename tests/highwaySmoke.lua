do
 game.PlaceId=98628861455414;game.GameId=10768284407
 local playerModel,h,root=newCharacter('HighwayRider');player.Character=playerModel
 local seat=child(workspace,'VehicleSeat','HighwayBike');seat.Occupant=h;h.SeatPart=seat;seat.AssemblyRootPart=seat
 local k=Enum.KeyCode;local pressed,events={},{}
 services.UserInputService.mockVirtualInput={SendKey=function(_,down,key)
  assert(not down or not pressed[key],'duplicate press')
  pressed[key]=down or nil;events[#events+1]={key=key,down=down}
  if down then services.UserInputService.InputBegan:Fire({KeyCode=key})end
 end}
 workspace.mockRaycast=function(_,direction)if direction.Y<0 then return {Instance=seat}end end
 local ok,app=openLauncher():choose('BIKE');assert(ok,app)
 local lane=app.highway
 local function advance(seconds)tick+=seconds;app:update(tick)end
 check(not lane:start() and not next(pressed),'highway refuses to drive before two points are set')
 seat.CFrame=CFrame.new(10,4,200);button(app,'Zapisz A — początek').Activated:Fire()
 seat.CFrame=CFrame.new(10,4,70);button(app,'Zapisz B — koniec').Activated:Fire()
 button(app,'Farma autostrady  OFF').Activated:Fire()
 check(lane.state=='ALIGN' and seat.Position.Z==200 and seat.CFrame.LookVector.Z==-1 and not next(pressed),'start returns the occupied bike to A and faces B before pressing throttle')
 advance(.5);check(lane.state=='DRIVE' and pressed[k.W],'throttle waits for observed highway alignment')
 seat.CFrame=CFrame.new(10,4,170);seat.AssemblyLinearVelocity=Vector3.new(0,0,-20)
 advance(2.05);check(pressed[k.LeftControl],'straight movement schedules a bounded wheelie')
 seat.CFrame=CFrame.new(10,4,140);advance(5.05)
 check(pressed[k.One] and not pressed[k.LeftControl],'the first ground trick follows the wheelie')
 seat.CFrame=CFrame.new(14,4,130);advance(.2)
 check(pressed[k.A] and not pressed[k.D] and lane.active,'lane drift uses a short return-to-line steering input without stopping the farm')
 seat.CFrame=CFrame.new(10,4,75);advance(.25)
 check(lane.state=='BANK' and lane.laps==1 and not next(pressed),'end of lane releases input and leaves time for the game to bank tricks')
 advance(2.5);check(lane.state=='BANK' and seat.Position.Z==75,'the farm does not teleport before the bank delay ends')
 advance(.55);check(lane.state=='ALIGN' and seat.Position.Z==200,'loop returns to A after waiting')
 advance(.5);h.SeatPart=nil;seat.Occupant=nil;advance(.2)
 check(lane.state=='SPAWN' and lane.recoveries==1 and not next(pressed),'loss of seat releases throttle and begins recovery')
 advance(.7);check(pressed[k.Q] and root.Position.Z==200 and lane.state=='MOUNT','recovery returns to A and requests a new bike with Q')
 advance(1.25);check(not pressed[k.Q] and pressed[k.E],'mount request uses E only after Q has been released')
 local newSeat=child(workspace,'VehicleSeat','NewBike');newSeat.Occupant=h;h.SeatPart=newSeat;newSeat.AssemblyRootPart=newSeat
 advance(.95);check(lane.state=='ALIGN' and newSeat.Position.Z==200,'recovery aligns the replacement bike only after observing the player seated')
 advance(.5);check(lane.state=='DRIVE' and pressed[k.W],'highway resumes throttle after successful recovery')
 services.UserInputService.InputBegan:Fire({KeyCode=k.F8});advance(.1)
 check(not lane.active and not next(pressed),'F8 also cancels further recovery')
 check(app.config.data.bike.highway.start[3]==200 and app.config.data.bike.highway.finish[3]==70,'config remembers both highway points')
 app.profileName.Text='HighwayTest';assert(app:saveProfile());app.config.data.bike.highway={};assert(app:loadProfile())
 check(app.config.data.bike.highway.start[3]==200 and app.config.data.bike.highway.finish[3]==70 and not lane.active,'a saved account profile restores both positions without resuming the farm')

 h.SeatPart=nil;newSeat.Occupant=nil;assert(lane:start());advance(.1)
 advance(12.1)
 check(not lane.active and not next(pressed),'initial spawn that never seats the player stops instead of driving blindly')
 h.SeatPart=newSeat;newSeat.Occupant=h;assert(lane:start());advance(.5)
 for _=1,4 do if lane.active then lane:recover(tick,'fixture crash');tick+=1 end end
 check(not lane.active and lane.recoveries==3 and not next(pressed),'repeated crashes are capped with no keys left held')
 do
  local f=app.flight;local cas=services.ContextActionService
  local function binding()return cas.bindings and cas.bindings.KubiHubDeluxeBikeFlight end
  local function input(state,key)return binding().fn('flight',state,{KeyCode=key})end
  h.SeatPart=nil
  check(not f:start() and not binding(),'motorcycle fly requires a recognized occupied seat')
  h.SeatPart=newSeat;newSeat.Occupant=h
  button(app,'Fly na motorze  OFF').Activated:Fire()
  check(f.active and binding() and f.velocity.Parent==newSeat and f.align.Parent==newSeat and f.anchor.Parent==newSeat,'enabling motor fly attaches movement only to the occupied bike')
  check(not lane:start() and not app:startRide(),'motor fly excludes highway farm and automatic riding')
  local camera=workspace.CurrentCamera;local before=camera.CFrame
  camera.CFrame=CFrame.lookAt(Vector3.zero,Vector3.new(0,0,-1))
  local b,e=Enum.UserInputState.Begin,Enum.UserInputState.End
  check(input(b,k.W)==Enum.ContextActionResult.Sink,'fly captures WASD so throttle does not compete')
  input(b,k.Space);advance(.05)
  check(f.velocity.VectorVelocity.Z==-36 and f.velocity.VectorVelocity.Y>0,'W and Space produce forward and climbing velocity')
  input(e,k.W);input(e,k.Space);input(b,k.LeftControl);advance(.05)
  check(f.velocity.VectorVelocity.Y<0 and f.velocity.VectorVelocity.Z==0,'Ctrl descends without retaining released movement')
  services.UserInputService.mockFocused=true;advance(.05)
  check(f.velocity.VectorVelocity.Magnitude==0 and not next(f.pressed),'text focus clears movement and leaves the bike hovering')
  services.UserInputService.mockFocused=nil;camera.CFrame=before
  local force,align,anchor=f.velocity,f.align,f.anchor
  services.UserInputService.InputBegan:Fire({KeyCode=k.F8});advance(.05)
  check(not f.active and not binding() and not force.Parent and not align.Parent and not anchor.Parent,'F8 unbinds the controls and removes all flight attachments')
  assert(f:start());h.SeatPart=nil;advance(.05)
  check(not f.active and not binding(),'dismount also clears flight instead of flying the empty bike')
 end
 app:unload();workspace.mockRaycast=nil;services.UserInputService.mockVirtualInput=nil;seat:Destroy();newSeat:Destroy()
end
