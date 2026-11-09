-- Native client fixtures: contract tests, not Roblox physics or server validation.
local chooser=openLauncher();check(chooser.gui.Name=='KubiHubGameChooser' and chooser.alive,'entry point opens the game chooser before starting modules')
local accepted,wrong=chooser:choose('MM2');check(not accepted and chooser.alive and wrong:find('Murder Mystery 2',1,true)~=nil,'wrong game choice does not start MM2 modules inside BABFT');chooser:unload()
local stages=child(child(workspace,'Folder','BoatStages'),'Folder','NormalStages')
for stage=1,10 do local point=child(child(stages,'Folder','CaveStage'..stage),'Part','DarknessPart');point.CFrame=CFrame.new(0,10,stage*100)end
local trigger=child(child(child(stages,'Folder','TheEnd'),'Model','GoldenChest'),'Part','Trigger');trigger.CFrame=CFrame.new(0,5,1500)
local function newCharacter(name,headClass)
 local c=Instance.new('Model');c.Name=name;local h=child(c,'Humanoid');h.Health=100;h.MaxHealth=100;h.WalkSpeed=16;h.JumpPower=50;h.JumpHeight=7;h.UseJumpPower=true;h.AutoRotate=true;h.PlatformStand=false
 local r=child(c,'Part','HumanoidRootPart');r.CFrame=CFrame.new();local head=child(c,headClass or 'Part','Head');head.CFrame=CFrame.new(0,2,0);return c,h,r
end
local routeHub=startHub();check(routeHub.adapter.capabilities.farm,'complete BABFT route enables the restored farm without a Studio bridge')
routeHub.config.data.farm.profile='SONIC';routeHub.config.data.farm.stopAfter=1
local route=routeHub.adapter.platform.route;local oldCharacter=player.Character
task.onWait=function()if route:expectingRespawn() then task.onWait=nil;local c=newCharacter('Returned');player.Character=c;player.CharacterAdded:Fire(c)end end
assert(routeHub.farm:start());for _=1,50 do routeHub.farm:tick();tick+=.35 end
check(player.Character~=oldCharacter and routeHub.farm.stats.completed==1 and routeHub.farm.state=='STOPPED','ten BABFT stages and chest complete once after the observed expected respawn')
check(route.floor==nil and route.expectedCharacter==nil and routeHub.runtime.lock==nil,'completed farm clears support part and controller lock')
local farmOrigin=player.Character.HumanoidRootPart.CFrame
routeHub.config.data.farm.stopAfter=0;assert(routeHub.farm:start());routeHub.farm:tick();assert(routeHub.farm:pause());local _,pausedRoot=route:character();local pausedPosition=pausedRoot.CFrame
tick+=10;routeHub.farm:tick();check(pausedRoot.CFrame==pausedPosition and routeHub.farm.state=='PAUSED','BABFT pause prevents dispatching another teleport')
routeHub.farm:stop();routeHub.farm:tick();check(route.floor==nil and routeHub.farm.state=='STOPPED' and pausedRoot.CFrame==farmOrigin,'BABFT STOP removes support and returns the same living character to its start')
assert(routeHub.farm:start());local unexpected=newCharacter('Unexpected');player.Character=unexpected;player.CharacterAdded:Fire(unexpected)
check(routeHub.farm.state=='STOPPED' and routeHub.farm.stats.completed==1,'unrelated respawn stops the route without crediting another cycle')
routeHub.farm:tick();routeHub.farm:stop()
local beforeStopCycles=routeHub.farm.stats.completed
task.onWait=function()if route:expectingRespawn() then task.onWait=nil;routeHub.farm:stop()end end
assert(routeHub.farm:start());for _=1,50 do routeHub.farm:tick();tick+=.35 end
check(routeHub.farm.state=='STOPPED' and routeHub.farm.stats.completed==beforeStopCycles and route.expectedCharacter==nil,'STOP while waiting at the chest cannot count a late or unobserved completion')
local pausedRoute=true;local waits=0
task.onWait=function()waits+=1;if waits==1 then tick+=40;pausedRoute=false else task.onWait=nil;player.Character=newCharacter('AfterLongPause') end end
local pauseReply=route:step(11,function()return false end,function()return pausedRoute end)
check(pauseReply.ok and pauseReply.completed,'chest wait timeout excludes a long paused interval even across resume')
local stageTwo=stages:FindFirstChild('CaveStage2');local missingPoint=stageTwo:FindFirstChild('DarknessPart');missingPoint.Parent=nil
check(route:inspect(),'BABFT availability does not require every distant stage to be loaded at START')
local restored=false;task.onWait=function()if not restored then restored=true;missingPoint.Parent=stageTwo;task.onWait=nil end end
local delayed=route:step(2,function()return false end,nil,{crossingTime=.4});check(delayed.ok and restored,'BABFT waits for a stage which arrives after replication')
local routeChar,routeRoot=route:character();local routeHum=routeChar:FindFirstChildOfClass('Humanoid');routeHum.Sit=true
local headBefore=routeChar.Head.Position.Z;local movesBefore=routeChar.PivotMoves or 0
local crossed=route:step(1,function()return false end,nil,{crossingTime=.4})
check(crossed.ok and routeHum.Sit==false and routeChar.PivotMoves>movesBefore+2 and routeChar.Head.Position.Z~=headBefore,'BABFT unseats and moves the whole character through a stage rather than jumping only the root')
local cancelCross=false;task.onWait=function()cancelCross=true;task.onWait=nil end
local stoppedCross=route:step(2,function()return cancelCross end,nil,{crossingTime=.4});check(not stoppedCross.ok and route.floor==nil,'STOP during an active BABFT crossing cancels movement and cleans support')
routeHub:unload()

game.PlaceId=142823291;game.GameId=66654135
local mmCharacter,mmHum,mmRoot=newCharacter('MM2Self');player.Character=mmCharacter
local enemy=child(services.Players,'Player','Enemy');enemy.UserId=456;local enemyChar,enemyHum,enemyRoot=newCharacter('EnemyCharacter');enemy.Character=enemyChar;enemyRoot.CFrame=CFrame.new(10,0,0);enemyChar.Head.CFrame=CFrame.new(10,2,0);child(enemyChar,'Tool','Knife')
local mmGun=child(backpack,'Tool','Gun')
local map=child(workspace,'Model','MM2FixtureMap');local coins=child(map,'Folder','CoinContainer')
local function coin(name,kind,x)local o=child(coins,'Part',name);o.CFrame=CFrame.new(x,0,0);o:SetAttribute('CoinType',kind);child(o,'TouchTransmitter','TouchInterest');return o end
local candy=coin('Candy_Server','Candy',20);local money=coin('Coin_Server','Coin',30)
candy.Transparency=1;local candyVisual=child(candy,'Part','CoinVisual');candyVisual.CFrame=candy.CFrame
money.Transparency=1;local moneyVisual=child(money,'Part','CoinVisual');moneyVisual.CFrame=money.CFrame
local mmChooser=openLauncher();check(mmChooser.alive and _G.KubiHubRuntime==mmChooser,'MM2 also starts at the chooser with no automatic farming')
local ok,mm=mmChooser:choose('MM2');assert(ok,mm)
check(mm.platform.allowed and mm.ui.pages.FIGHT~=nil and mm.ui.pages.BUILDER==nil and not mm.controller.farming,'MM2 creates its separate Combat hub with all modules initially off')
local c=mm.controller
workspace.CurrentCamera.CameraSubject=mmHum;assert(mm.platform:watch('Enemy'));check(workspace.CurrentCamera.CameraSubject==enemyHum,'player spectate uses the selected live humanoid')
c.aimbot=true;c.autoShot=true;local watchedShots=c.shots;c:aimTick(.05);check(c.shots==watchedShots,'spectating suppresses camera aiming and Auto Shot')
enemyHum.Health=0;mm.platform:updateWatch();check(mm.platform.spectating==nil and workspace.CurrentCamera.CameraSubject==mmHum,'target death restores the original camera subject');enemyHum.Health=100;c.aimbot=false;c.autoShot=false
local danger,dangerDistance=mm.platform:nearestMurderer();check(danger and danger.player==enemy and math.abs(dangerDistance-10)<.001,'proximity uses the measured distance to a detected knife holder')
check(#mm.platform:coins('BOTH')==2,'transparent coin collision roots with a visible CoinVisual remain collectible')
moneyVisual:SetAttribute('Collected',true);check(#mm.platform:coins('COIN')==0,'collected visual is excluded even while collision root and touch remain');moneyVisual:SetAttribute('Collected',false)
moneyVisual.Transparency=1;check(#mm.platform:coins('COIN')==0,'hidden visual is not treated as a new pickup');moneyVisual.Transparency=0
local mmFarmSettings;for _,entry in ipairs(mm.ui.featureSettings)do if entry.title=='Monety / cukierki' then mmFarmSettings=entry end end;assert(mmFarmSettings)
mmFarmSettings.button.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton2});check(mm.ui.activeSettings==mmFarmSettings.panel and not c.farming,'MM2 right click opens only collection settings without a teleport')
local hasFilter=false;for _,o in ipairs(mmFarmSettings.body:GetDescendants())do if o:IsA('TextButton')and o.Text:find('Zbieraj:',1,true)then hasFilter=true end end;check(hasFilter,'MM2 farm settings contain the live currency filter')
mm.ui:show('FIGHT');check(mm.ui.activeSettings==nil,'MM2 category change dismisses the settings panel')
local function renderAim()services.RunService.RenderBindings.KubiHubMM2Aim.fn(.05)end
local function renderWalk()services.RunService.RenderBindings.KubiHubMM2FarmMotion.fn()end
check(services.RunService.RenderBindings.KubiHubMM2Aim.priority==201,'aim updates are bound immediately after the game camera')
do
 check(c.farmMotion=='Lot' and not c.farming,'MM2 defaults to flight but requires enabling the farm')
 assert(c:setFilter('CANDY'));assert(c:startFarm());c:tick(.05);renderWalk()
 local flight=mm.platform.pickupFlightState
 check(flight and flight.force.Parent==mmRoot and flight.force.VectorVelocity.X==15 and flight.force.VectorVelocity.Y>0 and mmRoot.Position.X==0 and not mmCharacter.PivotMoves,'coin flight uses a limited physical velocity without moving the character instantly')
 mmRoot.CFrame=CFrame.new(18,2,0);tick+=.1;c:tick(.05);renderWalk()
 check(mm.platform.pickupFlightState==flight and flight.force.VectorVelocity.X<15 and flight.force.VectorVelocity.Y<0,'flight reuses its force and slows and descends near the pickup')
 assert(c:setFarmMotion('Chód'))
 check(not mm.platform.pickupFlightState and not flight.force.Parent and not flight.anchor.Parent and c.current==nil,'changing motion to walking removes both flight objects')
 c:stopFarm();assert(c:resetStats());mmRoot.CFrame=CFrame.new()
end
assert(c:setFilter('CANDY'));assert(c:startFarm());c:tick(.05);renderWalk()
check(c.current and c.current.object==candy and c.attempts==1 and c.state=='APPROACH','candy filter selects a typed candy to approach')
check(mmHum.LastMove.X==1 and mmHum.RelativeMove==false and mmRoot.Position.X==0 and not mmCharacter.PivotMoves and mmHum.WalkSpeed==16,'MM2 farm commands ordinary walking without teleporting or changing speed')
mmRoot.CFrame=CFrame.new(20,0,0);tick+=.3;c:tick(.05);renderWalk()
check(c.state=='PICKUP' and mmHum.LastMove.Magnitude==0,'arrival stops walking and waits for the normal pickup')
candy:Destroy();tick+=.2;c:tick(.05)
check(c.disappeared==1 and c.state=='WAIT_ITEMS','removed pickup updates only the observed disappearance counter')
assert(c:pauseFarm());local attempts=c.attempts;tick+=1;c:tick(.05);check(c.attempts==attempts and c.state=='PAUSED','MM2 farm pause blocks all later pickup visits');assert(c:pauseFarm())
local bag=child(child(child(child(child(child(player.PlayerGui,'ScreenGui','MainGUI'),'Frame','Game'),'Frame','CoinBags'),'Frame','Container'),'Frame','Coin'),'Frame','FullBagIcon');bag.Visible=true
tick+=1;c:tick(.05);check(c.state=='BAG_FULL','visible full-bag state pauses the pickup queue')
bag.Visible=false;assert(c:setFilter('COIN'));mmRoot.CFrame=CFrame.new();tick+=1;c:tick(.05);renderWalk()
check(c.current and c.current.object==money,'coin filter resumes with a typed coin after the bag state clears')
assert(c:pauseFarm());check(mmHum.LastMove.Magnitude==0 and c.current==nil,'pause releases current walking immediately');assert(c:pauseFarm());tick+=.2;c:tick(.05);renderWalk()
local flingOk=c:startFling();check(not flingOk and mm.platform.fling==nil and mm.runtime.lock=='MM2Farm','farming excludes simultaneous Fling character movement')
do
 local distant=coin('OutOfRangeCoin','Coin',75)
 tick+=2.1;c:tick(.05)
 check(c.current==nil and c.state=='WAIT_ITEMS' and mmHum.LastMove.Magnitude==0 and c.cooldown[money]>tick,'blocked walking times out and ignores out-of-range pickups')
 distant:Destroy()
 tick+=5.5;c:tick(.05);renderWalk()
 services.UserInputService.mockKeys={[Enum.KeyCode.W]=true}
 mmHum:Move(Vector3.new(0,0,-1),true);renderWalk();tick+=.2;c:tick(.05)
 services.UserInputService.mockKeys=nil
 check(c.state=='MANUAL' and not c.current and mmHum.LastMove.Z==-1,'manual keyboard input has priority over the farm')
end
c:stopFarm();c.aimbot=true;c.autoShot=true;local shots=mmGun.Activations or 0;tick+=1;c:tick(.05);renderAim()
check((mmGun.Activations or 0)==shots+1 and c.shots==1,'Auto Shot activates the owned gun only with a visible target')
tick+=.1;c:tick(.05);renderAim();check(c.shots==1,'Auto Shot respects its configured interval')
local wall=child(workspace,'Part','AimWall');workspace.raycastHit={Instance=wall};tick+=1;c:tick(.05);renderAim();check(c.shots==1,'wall check prevents firing through a blocking part');workspace.raycastHit=nil
mmGun.ActivateError='Fixture gun rejection';tick+=1;c:tick(.05);renderAim();check(c.shots==1 and c.lastError:find('Fixture gun rejection',1,true)~=nil,'tool activation errors do not become fake successful shots or kill the scheduler');mmGun.ActivateError=nil
c:stopAll();mm.platform:updateESP(true);check(mm.platform.highlights[enemy.UserId]~=nil,'role ESP owns a highlight on a detected player');mm.platform:updateESP(false);check(next(mm.platform.highlights)==nil,'disabling ESP removes all owned highlights')
local knife=child(backpack,'Tool','Knife');assert(c:startKillAll());c:tick(.05)
check(c.stabs==1 and (knife.Activations or 0)==1 and enemyHum.Health==100,'Kill all issues an owned knife activation without forging damage or a kill counter')
tick+=1;c:tick(.05);check(c.combat==nil and mm.runtime.lock==nil,'Kill all finishes its bounded target pass and releases movement')
local origin=mmRoot.CFrame;local originalAngular=mmRoot.AssemblyAngularVelocity
assert(c:startFling());c:tick(.05);check(mm.platform.fling~=nil and mmRoot.AssemblyAngularVelocity.Y==1800,'Fling changes only its own character during the bounded attempt')
tick+=2;c:tick(.05);check(c.combat==nil and mm.platform.fling==nil and mmRoot.CFrame==origin and mmRoot.AssemblyAngularVelocity==originalAngular,'Fling timeout restores its own position and velocities')
local targetKnife=enemyChar:FindFirstChild('Knife');targetKnife.Parent=nil;c.flingSettings.target='NEAREST';assert(c:startFling());check(mm.platform.fling.person.player==enemy,'general Fling can select the nearest player without requiring a Murderer role');c:stopCombat();targetKnife.Parent=enemyChar
c.flingSettings.target='SELECTED';c.flingSettings.selected='Absent';local missingFling=c:startFling();check(not missingFling and c.combat==nil and mm.runtime.lock==nil,'missing selected Fling target does not start movement or hold a lock')
c.flingSettings.selected='Enemy';c.flingSettings.duration=3;assert(c:startFling());tick+=2;c:tick(.05);check(c.combat~=nil,'Fling uses the configured bounded duration');enemyHum.Health=0;c:tick(.05);check(c.combat==nil and mm.platform.fling==nil and mm.runtime.lock==nil,'Fling stops immediately if its selected target dies');enemyHum.Health=100;c.flingSettings.duration=1.5;c.flingSettings.target='NEAREST'
local avatarToggles={};for _,entry in ipairs(mm.ui.featureSettings)do avatarToggles[entry.title]=entry end
check(avatarToggles['Fling'] and avatarToggles['Fake Headless'] and avatarToggles['Fake Korblox — noga'] and avatarToggles['Mały skin'] and avatarToggles['Mniejszy hitbox — lokalnie'],'MM2 Trolling exposes Fling and all four requested appearance/root controls')
avatarToggles['Mniejszy hitbox — lokalnie'].button.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton2});check(mm.ui.activeSettings==avatarToggles['Mniejszy hitbox — lokalnie'].panel and not mm.avatar.enabled.hitbox,'MM2 hitbox right-click opens its limitations and options without changing the avatar')
mm.ui:show('TROLLING');avatarToggles['Fake Headless'].button.Activated:Fire();check(mm.avatar.enabled.headless and mmCharacter.Head.LocalTransparencyModifier==1,'MM2 fake Headless left-click enables the local appearance effect');mm:stopAll();check(not mm.avatar.enabled.headless and mmCharacter.Head.LocalTransparencyModifier==0,'MM2 STOP restores its local appearance changes')
do
 assert(mm.avatar:set('headless',true));local originalAimTick=c.aimTick;c.aimTick=function()error('Fixture aim failure')end
 renderAim();c.aimTick=originalAimTick;services.RunService.RenderBindings.KubiHubAvatarVisibility.fn()
 check(mm.avatar.enabled.headless and mmCharacter.Head.Transparency==1,'an aiming error cannot disable the independent Headless fix')
 mm:stopAll();check(mmCharacter.Head.Transparency==0,'MM2 STOP restores original head Transparency')
end
local drop=child(workspace,'Part','GunDrop');drop.CFrame=CFrame.new(50,0,0);assert(mm.platform:pickupGun());check(mmRoot.Position.X==50,'gun pickup visits an actual replicated GunDrop')
knife:Destroy();mmGun:Destroy();mmRoot.CFrame=CFrame.new();c.autoGun=true;tick+=2;c:tick(.05);check(mmRoot.Position.X==50,'Auto Gun visits a real drop only while no owned weapon or movement task is active');c.autoGun=false
local auraKnife=child(backpack,'Tool','Knife');mmRoot.CFrame=enemyRoot.CFrame*CFrame.new(0,0,2);c.aura=true;local stabsBefore=c.stabs;tick+=1;c:tick(.05);check(c.stabs==stabsBefore+1 and auraKnife.Activations==1,'Knife Aura uses its owned knife only when a target is within six studs');c.aura=false
bag.Parent.Visible=false;bag.Visible=true;check(not mm.platform:bagFull(),'a hidden ancestor prevents a stale full-bag icon from stopping the next round');bag.Visible=false;bag.Parent.Visible=true
mmRoot.CFrame=CFrame.new();assert(c:startFarm());tick+=2;c:tick(.05);mmHum.MoveError='Fixture respawn race';renderWalk();mmHum.MoveError=nil
check(not c.farming and mm.runtime.schedules.MM2Controllers~=nil and mm.ui.statusInfo.Text:find('Fixture respawn race',1,true)~=nil,'unexpected walking failure stops the farm and preserves the scheduler plus readable error')
assert(c:startFarm());tick+=1;c:tick(.05);renderWalk();player.CharacterAdded:Fire(mmCharacter)
check(not c.farming and mmHum.LastMove.Magnitude==0 and mm.runtime.lock==nil,'respawn turns off pickup walking and releases control')
assert(c:startFarm());local seenAttempts=c.attempts;c:stopAll();tick+=2;c:tick(.05);check(not c.farming and not c.aimbot and not c.autoShot and c.attempts==seenAttempts and mm.runtime.lock==nil,'STOP ALL prevents subsequent MM2 farm and combat actions')
c:stopAll();c.settings.selected='Enemy';button(mm,'Teleport do gracza').Activated:Fire();check(mmRoot.Position.X==enemyRoot.Position.X+3,'manual player teleport uses the selected live player with an offset')
assert(mm.platform:watch('Enemy'));mm.proximity=true;mm:stopAll();check(mm.platform.spectating==nil and workspace.CurrentCamera.CameraSubject==mmHum and not mm.proximity,'STOP ALL restores spectate camera and disables the proximity warning')
mmRoot.CFrame=CFrame.new(5,0,5);mm.travel.slot=2;assert(mm.travel:save());mmRoot.CFrame=CFrame.new(90,0,90);assert(mm.travel:go(mm.travel.slots[2]));check(mmRoot.Position.X==5 and mmRoot.Position.Z==5,'Teleport uses the selected saved point')
assert(mm.runtime:acquire('MM2Farm'));local blockedTravel=mm.travel:go(CFrame.new());check(not blockedTravel and mm.runtime.lock=='MM2Farm','manual teleport cannot race an active farm');mm.runtime:release('MM2Farm')
assert(mm.travel:back());check(mmRoot.Position.X==90,'Teleport back restores the prior position for the same character')
do
 local sheriff=child(services.Players,'Player','Detective');sheriff.UserId=789;local sheriffChar,sheriffHum,sheriffRoot=newCharacter('SheriffCharacter');sheriff.Character=sheriffChar;sheriffRoot.CFrame=CFrame.new(200,0,0);child(sheriffChar,'Tool','Gun')
 local detected,err=mm.platform:personByRole('Sheriff');check(detected and detected.player==sheriff and err==nil,'role shortcut identifies only a live visible weapon holder')
 button(mm,'Podgląd Sheriffa  OFF').Activated:Fire();check(workspace.CurrentCamera.CameraSubject==sheriffHum,'Sheriff watch shortcut selects the detected camera subject')
 button(mm,'Podgląd Sheriffa  ON').Activated:Fire();check(mm.platform.spectating==nil and workspace.CurrentCamera.CameraSubject==mmHum,'role watch shortcut can stop and restore the camera')
 button(mm,'Teleport do Sheriffa').Activated:Fire();check(mmRoot.Position.X==203,'role teleport uses the detected live player and a small offset')
 assert(mm.runtime:acquire('MM2Farm'));local before=mmRoot.CFrame;button(mm,'Teleport do Murderera').Activated:Fire();check(mmRoot.CFrame==before and mm.runtime.lock=='MM2Farm','role teleport cannot interrupt a running movement owner');mm.runtime:release('MM2Farm')
 local targets={};for i=1,50 do local object=coin('ExtraCoin'..i,'Coin',0);object.CFrame=CFrame.new(mmRoot.Position+Vector3.new(i,0,0));targets[#targets+1]=object end
 local attempts=c.attempts;c.itemESP.coins=true;c.itemESP.gun=true;c.itemESP.range=300;mm.platform:updateItems(c.itemESP)
 local total=0;for _ in pairs(mm.platform.itemHighlights)do total+=1 end
 check(total==41 and mm.platform.itemHighlights[drop]~=nil and c.attempts==attempts,'item ESP caps coins at forty, highlights the actual gun and never starts collection')
 local marker=mm.platform.itemHighlights[drop];drop:Destroy();mm.platform:updateItems(c.itemESP);check(marker.Parent==nil and mm.platform.itemHighlights[drop]==nil,'gun marker is removed when the actual drop disappears')
 mm:stopAll();check(next(mm.platform.itemHighlights)==nil and not c.itemESP.coins and not c.itemESP.gun,'MM2 STOP clears both item overlays and their toggles')
 for _,object in ipairs(targets)do object:Destroy()end;sheriff:Destroy()
end
check(mm.ui.pages.QUICK~=nil and mm.quickTools~=nil,'MM2 has the same grouped quick tools as the other modes')
mm:unload();check(services.RunService.RenderBindings.KubiHubAvatarVisibility==nil,'MM2 unload removes the dedicated Headless render binding');check(mm.runtime:counts().connections==0 and mm.ui.gui.Parent==nil and next(mm.platform.highlights)==nil and services.RunService.RenderBindings.KubiHubMM2Aim==nil and services.RunService.RenderBindings.KubiHubMM2FarmMotion==nil,'MM2 unload removes GUI, listeners, movement/aim bindings and local effects')
local failedChooser=openLauncher();local savedViewport=workspace.CurrentCamera.ViewportSize;workspace.CurrentCamera.ViewportSize=nil
local failedOpen=failedChooser:choose('MM2');workspace.CurrentCamera.ViewportSize=savedViewport
check(not failedOpen and failedChooser.alive and player.PlayerGui:FindFirstChild('KubiHubUltimateV5')==nil,'failed hub startup leaves the chooser usable and cleans partial GUI resources');failedChooser:unload()
print('MULTIGAME SMOKE COMPLETE: no native server, rendering or physics claim')
