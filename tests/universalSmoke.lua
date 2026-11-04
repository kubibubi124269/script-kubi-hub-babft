-- Appearance, chooser and cleanup contracts only: no native render or server hitbox claim.
game.PlaceId=987654321;game.GameId=1
local universalCharacter,universalHum,universalRoot=newCharacter('UniversalR15');player.Character=universalCharacter
local upper=child(universalCharacter,'Part','RightUpperLeg');local lower=child(universalCharacter,'Part','RightLowerLeg');local foot=child(universalCharacter,'Part','RightFoot');local neck=child(universalCharacter.Head,'Motor6D','Neck')
local face=child(universalCharacter.Head,'Decal','face');face.Transparency=.15;universalCharacter.Head.LocalTransparencyModifier=.2
local hat=child(universalCharacter,'Accessory','Hat');local handle=child(hat,'Part','Handle');child(handle,'Attachment','HatAttachment')
local launcher=openLauncher();check(launcher.gui:FindFirstChild('UNIVERSAL',true)~=nil,'chooser includes Universal next to BABFT and MM2')
local ok,u=launcher:choose('UNIVERSAL');assert(ok,u)
check(u.mode=='UNIVERSAL' and u.ui.pages.FARM==nil and u.ui.pages.FIGHT==nil and u.ui.pages.CAMERA~=nil,'Universal opens in an unrelated game with its own tools and no MM2 combat or fake farm')
local count=0;for _ in pairs(u.ui.pages)do count+=1 end;check(count==5 and u.ui.layout.navColumns==1,'Universal keeps a simple vertical five-category menu')
local a=u.avatar;check(not a.enabled.headless and not a.enabled.mini and not u.fovEnabled and not u.bright and not u.cross.Visible,'Universal and appearance options always start disabled')
local rootSize=universalRoot.Size;local hip=universalHum.HipHeight;local originalAutomatic=universalHum.AutomaticScalingEnabled
assert(a:set('headless',true));check(universalCharacter.Head.LocalTransparencyModifier==1 and face.Transparency==1 and neck.Parent~=nil and universalHum.Health==100,'fake headless hides head and face without destroying neck or health')
check(universalRoot.Size==rootSize and universalHum.HipHeight==hip,'cosmetic headless does not resize the local collision root')
assert(a:option('hideHats',true));check(handle.LocalTransparencyModifier==1,'optional headless accessory hiding follows attachment type')
universalCharacter.Head.LocalTransparencyModifier=0;a:render();check(universalCharacter.Head.LocalTransparencyModifier==1,'headless reapplies its local visibility after camera changes')
local extraFace=child(universalCharacter.Head,'Decal','newFace');extraFace.Transparency=.25;assert(a:refresh());check(extraFace.Transparency==1,'late appearance descendants receive the active local visibility effect')
assert(a:set('headless',false));check(universalCharacter.Head.LocalTransparencyModifier==.2 and face.Transparency==.15 and extraFace.Transparency==.25 and handle.LocalTransparencyModifier==0,'headless off restores the exact original local opacity and face values')
assert(a:set('korblox',true));local legFolder=a.legFolder
check(upper.LocalTransparencyModifier==1 and lower.LocalTransparencyModifier==1 and foot.LocalTransparencyModifier==1 and legFolder and #legFolder:GetChildren()==2,'R15 fake Korblox keeps originals and creates two local non-colliding pieces')
local welded=true;for _,piece in ipairs(legFolder:GetChildren())do local weld=piece:FindFirstChildOfClass('WeldConstraint');welded=welded and not piece.CanCollide and not piece.CanTouch and not piece.CanQuery and piece.Massless and weld.Part0==upper end
check(welded,'local leg geometry follows its own upper leg without changing collision or foreign characters')
for _=1,8 do assert(a:refresh())end;check(a.legFolder==legFolder and #a.legFolder:GetChildren()==2,'appearance refresh does not create accumulating fake legs')
assert(a:set('korblox',false));check(legFolder.Parent==nil and upper.LocalTransparencyModifier==0 and lower.LocalTransparencyModifier==0 and foot.LocalTransparencyModifier==0,'Korblox off removes owned geometry and restores all original leg visuals')
assert(a:set('mini',true));check(math.abs(universalCharacter:GetScale()-.6)<.001 and math.abs(universalRoot.Size.X-rootSize.X*.6)<.001 and math.abs(universalHum.HipHeight-hip*.6)<.001,'small skin applies the requested local model scale and matching hip height')
assert(a:set('hitbox',true));check(math.abs(universalRoot.Size.X-rootSize.X*.36)<.001,'local root factor composes with small skin without claiming a server hitbox change')
assert(a:set('hitbox',false));check(math.abs(universalRoot.Size.X-rootSize.X*.6)<.001 and a.enabled.mini,'turning off root scaling preserves the active small skin')
assert(a:option('scale',.5));assert(a:set('mini',true));check(math.abs(universalCharacter:GetScale()-.5)<.001 and math.abs(universalRoot.Size.X-rootSize.X*.5)<.001,'reapplying size options uses the saved baseline rather than shrinking cumulatively')
assert(a:set('mini',false));check(universalCharacter:GetScale()==1 and math.abs(universalRoot.Size.X-rootSize.X)<.001 and universalHum.HipHeight==hip and universalHum.AutomaticScalingEnabled==originalAutomatic,'small skin off restores scale, root size, hip height and automatic scaling')
universalCharacter:ScaleTo(1.2);local customSize=universalRoot.Size;assert(a:set('headless',true));assert(a:set('mini',true));check(math.abs(universalCharacter:GetScale()-.6)<.001,'small skin is relative to the existing model scale');a:reset();check(math.abs(universalCharacter:GetScale()-1.2)<.001 and math.abs(universalRoot.Size.X-customSize.X)<.001,'restore preserves a non-default avatar scale');universalCharacter:ScaleTo(1)
assert(u.runtime:acquire('Fly'));local blocked=a:set('mini',true);check(not blocked and not a.enabled.mini and u.runtime.lock=='Fly','resize cannot race Fly or release another movement owner');u.runtime:release('Fly')
universalCharacter.ScaleError='Fixture ScaleTo failure';local resized=a:set('mini',true);universalCharacter.ScaleError=nil
check(not resized and not a.enabled.mini and a.base==nil and u.runtime.lock==nil,'failed scale application clears enabled flags and releases its lock')
local priorFov=workspace.CurrentCamera.FieldOfView;button(u,'Pole widzenia  OFF').Activated:Fire();check(u.fovEnabled and workspace.CurrentCamera.FieldOfView==80,'Universal FOV updates the current camera only after explicit enable')
local originalCamera=workspace.CurrentCamera;local replacement=Instance.new('Camera');replacement.FieldOfView=65;replacement.ViewportSize=Vector2.new(1280,720);workspace.CurrentCamera=replacement;u:applyFov();u:resetFov()
check(originalCamera.FieldOfView==priorFov and replacement.FieldOfView==65,'FOV off restores both original and replacement cameras');workspace.CurrentCamera=originalCamera
local clock=services.Lighting.ClockTime;local brightness=services.Lighting.Brightness;assert(u:setBright(true));check(services.Lighting.ClockTime==14 and not services.Lighting.GlobalShadows,'Universal bright-day changes only client lighting')
assert(u:setBright(false));check(services.Lighting.ClockTime==clock and services.Lighting.Brightness==brightness and services.Lighting.GlobalShadows,'bright-day off restores time, brightness and shadows')
button(u,'Celownik  OFF').Activated:Fire();check(u.cross.Visible and u.crossGui.IgnoreGuiInset,'Universal crosshair is an owned screen overlay at screen centre')
u.config.data.movement.walk=27;assert(u.movement:apply());check(universalHum.WalkSpeed==27,'Universal movement uses its own humanoid outside BABFT and MM2')
assert(u.travel:save());assert(u.travel:go(CFrame.new(30,0,0)));check(universalRoot.Position.X==30,'Universal can use the shared manual point teleport in an unrelated game fixture')
assert(a:set('headless',true));assert(a:set('korblox',true));assert(a:set('mini',true));u.fovEnabled=true;u:applyFov();u:setBright(true);u:stopAll()
check(not a.enabled.headless and not a.enabled.korblox and not a.enabled.mini and a.legFolder==nil and not u.cross.Visible and not u.fovEnabled and not u.bright and universalHum.WalkSpeed==16,'Universal STOP restores appearance, model size, movement, FOV, lighting and crosshair')
local r6,r6hum,r6root=newCharacter('UniversalR6');local r6leg=child(r6,'Part','Right Leg');player.Character=r6;player.CharacterAdded:Fire(r6)
assert(a:set('korblox',true));check(a.legPart==r6leg and r6leg.LocalTransparencyModifier==1,'fake Korblox also supports the R6 Right Leg layout')
assert(a:set('mini',true));local r6scale=r6:GetScale();local afterRespawn=newCharacter('AfterUniversalRespawn');player.Character=afterRespawn;player.CharacterAdded:Fire(afterRespawn)
check(not a.enabled.mini and not a.enabled.korblox and r6:GetScale()==1 and r6scale<1 and afterRespawn:GetScale()==1,'respawn restores the previous model and leaves new appearance effects disabled')
u:unload();check(u.runtime:counts().connections==0 and u.crossGui.Parent==nil and u.ui.gui.Parent==nil,'Universal unload removes GUI, crosshair and event listeners')
print('UNIVERSAL SMOKE COMPLETE: local contracts only; no paid ownership, native appearance or server hitbox claim')
