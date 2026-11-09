-- Verify the AutoSteal client and chooser without simulating theft or ownership.
do
 local service={PromptShown=signal(),PromptHidden=signal(),PromptTriggered=signal()}
 services.ProximityPromptService=service
 local c,h,r=newCharacter('BrainrotTester');c.Parent=workspace;player.Character=c
 local function prompt(action,x,duration,attachment)
  local part=child(workspace,'Part','Pedestal');part.CFrame=CFrame.new(x,0,0)
  local parent=part
  if attachment then parent=child(part,'Attachment');parent.WorldPosition=part.Position end
  local p=child(parent,'ProximityPrompt')
  p.ActionText=action;p.ObjectText='Example Brainrot';p.Enabled=true;p.MaxActivationDistance=8;p.HoldDuration=duration
  p.begins=0;p.ends=0
  function p:InputHoldBegin()self.begins+=1;if self.beginError then error('prompt refused begin') end end
  function p:InputHoldEnd()self.ends+=1 end
  return p
 end
 local function pulse(seconds)tick+=seconds;services.RunService.Heartbeat:Fire(seconds)end
 game.PlaceId=987654321;game.GameId=1
 local launcher=openLauncher()
 local rejected=launcher:choose('BRAINROT')
 check(not rejected and launcher.alive and launcher.gui:FindFirstChild('BRAINROT',true)~=nil,'Brainrot has a chooser option but cannot open in another experience')
 game.PlaceId=109983668079237
 launcher:unload();launcher=openLauncher()
 check(launcher.status.Text:find('Steal a Brainrot',1,true)~=nil,'chooser detects the official Brainrot place')
 launcher.gui:FindFirstChild('BRAINROT',true).Activated:Fire()
 local app=_G.KubiHubRuntime
 check(app.mode=='BRAINROT' and not app.enabled and app.ui.current=='STEAL','Brainrot opens its own AutoSteal screen with the feature off')

 local target=prompt('  Steal ',3,.7,true)
 local other=prompt('Steal Example Brainrot',5,2)
 local far=prompt('Steal',15,.2)
 local buy=prompt('Buy',1,.2);buy.ObjectText='Steal'
 local hidden=prompt('Steal',1,0)
 local blocked=prompt('Steal',2,0);blocked.Enabled=false
 for _,p in ipairs({target,other,far,buy,blocked})do service.PromptShown:Fire(p)end
 pulse(.1);check(target.begins==0,'shown prompts remain untouched while AutoSteal is off')
 button(app,'AutoSteal  OFF').Activated:Fire();pulse(.1)
 check(app.active.prompt==target and target.begins==1 and other.begins+far.begins+buy.begins+hidden.begins+blocked.begins==0,'AutoSteal holds only the nearest shown, enabled, in-range Steal action')
 pulse(.6);check(target.ends==0 and target.HoldDuration==.7 and target.MaxActivationDistance==8,'AutoSteal respects the required hold and leaves the prompt properties intact')
 service.PromptTriggered:Fire(target,player)
 pulse(.24);check(target.ends==1 and not app.active and app.last.Text:find('Zarejestrowano',1,true)~=nil,'AutoSteal releases after the full hold and reports only the interaction signal')
 pulse(.2);check(other.begins==0,'AutoSteal leaves a pause before attempting another prompt')
 pulse(1.2);check(other.begins==1 and target.begins==1,'a shown prompt is attempted only once before moving to the next target')
 button(app,'STOP / wyłącz AutoSteal').Activated:Fire();pulse(.2)
 check(not app.enabled and other.ends==1 and app.active==nil,'STOP disables AutoSteal and releases the current hold immediately')

 service.PromptHidden:Fire(other);service.PromptHidden:Fire(target);service.PromptShown:Fire(target)
 button(app,'AutoSteal  OFF').Activated:Fire();pulse(1.25)
 check(target.begins==2 and app.active.prompt==target,'a prompt can be tried again after hiding and appearing')
 r.CFrame=CFrame.new(30,0,0);pulse(.1)
 check(target.ends==2 and app.active==nil,'leaving range releases a hold without moving the avatar')
 r.CFrame=CFrame.new()
 service.PromptHidden:Fire(target);service.PromptShown:Fire(target);pulse(1.4)
 service.PromptHidden:Fire(target)
 check(target.begins==3 and target.ends==3 and app.active==nil,'a disappearing action immediately releases the hold')
 service.PromptShown:Fire(target);pulse(1.4);player.CharacterAdded:Fire(c)
 check(not app.enabled and target.begins==4 and target.ends==4 and not app.active,'respawn releases the prompt and requires manual re-enabling')
 service.PromptHidden:Fire(target);service.PromptShown:Fire(target)
 button(app,'AutoSteal  OFF').Activated:Fire();pulse(1.4)
 app:unload();pulse(.1);service.PromptShown:Fire(hidden);pulse(2)
 check(target.begins==5 and target.ends==5 and hidden.begins==0 and not next(app.shown) and app.runtime:counts().connections==0 and _G.KubiHubRuntime==nil,'unloading releases input and removes the AutoSteal listeners and state')

 game.PlaceId=12345;game.GameId=7709344486
 local subplace=openLauncher()
 check(subplace.status.Text:find('Steal a Brainrot',1,true)~=nil,'chooser also recognizes a place within the official Brainrot universe')
 subplace:unload()
end
