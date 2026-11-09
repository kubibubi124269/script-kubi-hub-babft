local function check(condition,message)assert(condition,message);print('PASS UI '..message)end
local first=startHub();check(first and first.alive,'full client starts in assistant mode')
check(first.adapter.capabilities.build~=true,'absent adapter cannot report build authorization')
local n=0;for _ in pairs(first.ui.pages)do n+=1 end;check(n==7 and first.ui.pages.QUICK and first.ui.pages.SHAPES==nil,'BABFT adds one grouped tools category without bringing back Shapes')
local farmSettings;for _,entry in ipairs(first.ui.featureSettings)do if entry.title=='Autofarma BABFT' then farmSettings=entry end end;assert(farmSettings)
farmSettings.button.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton2});check(first.ui.activeSettings~=nil and first.farm.state=='STOPPED','right click opens feature options without starting the farm')
local settingsConnections=first.runtime:counts().connections;local panel=farmSettings.panel
for _=1,12 do farmSettings.open()end;check(first.runtime:counts().connections==settingsConnections and farmSettings.panel==panel,'reopening options reuses controls without leaking listeners')
first.ui:show('TELEPORT');check(first.ui.activeSettings==nil,'switching categories closes feature options')
first.ui:show('SHAPES');check(first.ui.current=='MISC','legacy Shapes route opens Builder')
first.ui:show('CIRCLE');check(first.ui.current=='MISC','dedicated Circle Maker page is reachable')
first.ui.search.Text='promień';check(first.ui.results.Visible,'global search shows results')
local found=false;for _,r in ipairs(first.ui.cards)do if r.result.Visible and r.title:find('Circle Maker',1,true)then found=true end end;check(found,'search indexes function settings')
for _,r in ipairs(first.ui.cards)do if r.title:find('Circle Maker',1,true)then r.result.Activated:Fire();check(r.body.Visible,'search expands matching section');check(first.ui.current=='MISC','search opens matching tab')end end
first.ui:show('BUILDER');check(first.preview.shown>0 and first.preview.shown<=350,'viewport has bounded sampled geometry')
local function button(app,text)for _,o in ipairs(app.ui.gui:GetDescendants())do if o:IsA('TextButton') and o.Text==text then return o end end;error('Missing button: '..text)end
button(first,'Wczytaj: Classic House — dom / 568 części').Activated:Fire()
check(first.builder.source.id=='community_classic_house' and #first.builder.source.elements==568 and first.builder.source.geometryOnly,'Builder loads actual downloaded community house geometry through the JSON path')
check(first.builder.placed==0 and first.preview.shown<=350 and not first.builder.source.importedMechanics,'community loading remains a bounded preview until explicit BUILD')
button(first,'ASYSTENT — pokaż kroki budowania').Activated:Fire()
check(first.ui.current=='MISC' and first.assistantBody.Visible,'unavailable server build opens the usable manual assistant')
check(first.builder.placed==0 and not first.builder:isBusy(),'manual assistant never starts a server build or fake progress')
for _,b in ipairs(first.buildControls)do check(not b.Visible,'transaction control is hidden without build access')end
local longMessage=string.rep('Pełna treść komunikatu. ',40)..'KONIEC'
first.ui:toast('BUILDER',longMessage,true);first.ui.footer.Activated:Fire()
check(first.ui.current=='SETTINGS' and first.ui.statusBody.Visible,'status bar expands the actual message section')
check(first.ui.statusInfo.Text=='[BUILDER] '..longMessage,'full status message is preserved beyond the toast limit')
check(first.ui.statusInfo.AutomaticSize==Enum.AutomaticSize.Y and first.ui.statusInfo.TextYAlignment==Enum.TextYAlignment.Top,'message text grows vertically and aligns to the top')
check(first.ui.footer.Text:find('Pełna treść komunikatu.',1,true)~=nil and first.ui.notification.Text:find('Pełna treść komunikatu.',1,true)~=nil,'footer and popup show the actual error instead of a generic announcement')
check(utf8.len(first.ui.notification.Text)~=nil and utf8.len(first.ui.notification.Text)<260,'long Polish messages have a bounded valid UTF-8 notification')
first.ui:show('FARM');first.ui:hide();first.ui.notification.Activated:Fire()
check(first.ui.frame.Visible and first.ui.current=='SETTINGS' and first.ui.statusBody.Visible,'clicking the notification reopens the hub at the complete error')
local oldConnection=first.ui.notificationConnection;local notificationConnections=first.runtime:counts().connections
for _=1,20 do first.ui:toast('TEST','Żółć — dokładna przyczyna błędu.',true)end
check(not oldConnection.Connected and first.runtime:counts().connections==notificationConnections,'replacing notifications disconnects old click handlers without growing listeners')
first.ui.notifyUntil=-math.huge;first.ui:tick()
check(first.ui.notification==nil and first.ui.notificationConnection==nil and first.runtime:counts().connections==notificationConnections-1,'expired notifications also release their event connection')
local camera=workspace.CurrentCamera;workspace.CurrentCamera=nil;first.ui:toast('TEST','Brak kamery nie może ukryć błędu.',true);workspace.CurrentCamera=camera
check(first.ui.notification.Text:find('Brak kamery',1,true)~=nil,'error notification remains available while the game camera is absent')
local exactError='Kontrolowany błąd przycisku: '..string.rep('ą',180)..' KONIEC'
first:run('TEST',function()error(exactError)end)
check(first.ui.statusInfo.Text:find(exactError,1,true)~=nil,'button exceptions keep the entire error for copying instead of truncating at 170 bytes')
local testSignal=signal();local testConnection=first.runtime:connect(testSignal,function()error('Kontrolowany błąd zdarzenia')end,'TEST');testSignal:Fire();first.runtime:disconnect(testConnection)
check(first.ui.notification.Text:find('Kontrolowany błąd zdarzenia',1,true)~=nil,'runtime event errors expose their actual cause in the notification')
first.ui:show('DEBUG');check(first.debugBody.Visible and first.ui.scrollTarget==first.ui.cardBodies[first.debugBody],'debug route expands and targets the report instead of session stats')
first:updateDashboard();check(first.debugBox.Text:find('Środowisko:',1,true)~=nil,'report refresh runs in the real Settings tab')
first.adapter.capabilities.build=true;first:updateDashboard()
check(first.buildButton.Text=='BUILD — sprawdź i zbuduj przez adapter' and first.buildControls[1].Visible,'build controls appear only after confirmed capability')
first.adapter.capabilities.build=nil;first:updateDashboard()
local sectionHeading=button(first,'[-]  Raport błędów, zadania i zgodność');sectionHeading.Activated:Fire()
check(sectionHeading.Text=='[+]  Raport błędów, zadania i zgodność','section controls use supported plain text symbols')
local libraryCard;for _,r in ipairs(first.ui.cards)do if r.title=='Biblioteka konstrukcji'then libraryCard=r end end
local termsLength=#libraryCard.terms;local connections=first.runtime:counts().connections
for _=1,20 do first:renderSchematics()end
check(#libraryCard.terms==termsLength,'rebuilding the catalog does not grow search text')
check(first.runtime:counts().connections==connections,'rebuilding the catalog disconnects old controls')
first.previewDirty=false;button(first,'Widok z góry').Activated:Fire();check(not first.previewDirty,'camera controls do not rebuild all preview parts')
first.config.data.farm.stopAfter=7;first.config.data.builder.yaw=90;first.config.data.builder.material='TitaniumBlock';assert(first:applyConfig())
local circleSettings;for _,entry in ipairs(first.ui.featureSettings)do if entry.title=='GENERUJ KOŁO — podgląd i materiały' then circleSettings=entry end end;assert(circleSettings)
circleSettings.button.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton2});check(first.ui.activeSettings==circleSettings.panel and first.generatorKind=='SPHERE','Circle Maker has its own settings without changing the Shape Lab selection')
local layerField;for _,o in ipairs(circleSettings.body:GetDescendants())do if o:IsA('TextBox')and o.PlaceholderText=='Liczba warstw'then layerField=o end end;assert(layerField);layerField.Text='2';layerField.FocusLost:Fire();check(first.circle.layers==2,'right-click Circle Maker settings update the generator used by the action')
button(first,'GENERUJ KOŁO — podgląd i materiały').Activated:Fire()
check(first.builder.options.yaw==0 and first.builder.options.material=='ORIGINAL','new circle uses its own selected material and rotation')
check(first.builder.schema.elements[1].material=='WoodBlock','circle wood is not silently replaced with previous titanium')
local opts=table.clone(first.builder.options);opts.yaw=90;assert(first.builder:edit(opts));first:refreshPreview()
button(first,'Eksport wybranego schematu').Activated:Fire();local exported=first.codec.decode(first.schemaBox.Text);local beforeImport=first.schemaBox.Text
button(first,'Import i zapisz własny projekt').Activated:Fire();local importedId=first.builder.source.id
check(first.builder.options.yaw==0,'import does not apply exported rotation twice')
check(math.abs(first.builder.schema.elements[1].position[1]-exported.elements[1].position[1])<1e-7,'export/import keeps rendered placement')
first.schemaBox.Text=beforeImport;button(first,'Import i zapisz własny projekt').Activated:Fire();check(first.builder.source.id~=importedId and first.library.items[importedId]~=nil,'rapid consecutive imports never overwrite an earlier project')
first:needPro('test');check(first.ui.current=='SETTINGS' and first.proBody.Visible,'locked feature points to the actual key page')
button(first,'Wyśrodkuj schemat X/Z').Activated:Fire();check(math.abs(first.builder.bounds.center[1])<1e-7 and math.abs(first.builder.bounds.center[3])<1e-7,'center button moves the plan to the middle')
button(first,'Dopasuj do obszaru').Activated:Fire();check(first.builder.state=='PREVIEW','fit button prepares a preview without claiming server build')
button(first,'Kopiuj listę materiałów').Activated:Fire();check(first.schemaBox.Text:find('wymagane',1,true)~=nil,'copy materials has a usable text fallback without clipboard API')
local oldSpeed=hum.WalkSpeed;local second=startHub();check(not first.alive,'second execution unloads first runtime');check(first.runtime:counts().connections==0,'old event connections are disconnected')
n=0;for _,o in ipairs(player.PlayerGui:GetChildren())do if o.Name=='KubiHubUltimateV5'then n+=1 end end;check(n==1,'second execution leaves one GUI')
check(hum.WalkSpeed==oldSpeed,'startup preserves original character movement')
for _,size in ipairs({Vector2.new(320,600),Vector2.new(580,527),Vector2.new(760,600),Vector2.new(1280,720)})do workspace.CurrentCamera.ViewportSize=size;second.ui:fit();check(second.ui.layout.width<=size.X-8,'responsive window fits '..size.X)
 check(second.ui.nav.ScrollingEnabled and second.ui.navLayout.FillDirectionMaxCells==1,'vertical navigation remains reachable at '..size.X)
end
second:unload();check(second.runtime:counts().connections==0,'unload removes current connections');check(second.ui.gui.Parent==nil,'unload destroys owned GUI')
-- BABFT compatibility is exercised against a tool/folder fixture, never a live game.
game.PlaceId=537413528;player.TeamColor='White';local zone=child(workspace,'Part','WhiteZone');zone.Size=Vector3.new(120,2,120);zone.CFrame=CFrame.new();child(zone,'StringValue','TeamColor').Value='White'
local blocks=child(workspace,'Folder','Blocks');local own=child(blocks,'Folder',player.Name);local backpack=child(player,'Backpack');local tool=child(backpack,'Tool','BuildingTool');local rf=child(tool,'RemoteFunction','RF');local sent=0
rf.InvokeServer=function(_,material,amount,plot,relative,anchored,cf,flag)
 sent+=1;assert((material=='WoodBlock' or material=='Seat') and amount>0 and plot==zone and anchored==true and flag==false)
 local model=child(own,'Model',material);local part=child(model,'Part','PPart');part.Size=material=='Seat' and Vector3.new(2,1,2) or Vector3.new(2,2,2);part.CFrame=cf;return model
end
local native=startHub();check(native.adapter.mode=='BABFT','actual BABFT place selects native compatibility instead of the Studio-only bridge')
check(native.farmAvailability.Text==native.adapter.farmReason,'missing BABFT route has a precise status before START')
native.ui:show('FARM');button(native,'Autofarma BABFT  OFF').Activated:Fire();native:updateDashboard()
check(native.farm.state=='STOPPED' and native.farm.stats.failed==0 and native.farm.stats.lastError==native.adapter.farmReason,'missing route START records the precise reason without inventing a failed farming cycle')
check(native.ui.notification.Text:find(native.adapter.farmReason,1,true)~=nil,'the exact blocked START reason is readable in the popup from the reported screenshot')
check(sent==0 and not native.adapter.capabilities.build,'loading the hub never places a probe or authorizes untested tools')
check(native.buildTestButton.Visible and native.babftRefresh.Visible,'BABFT has visible tool test and refresh actions')
native.buildTestButton.Activated:Fire();check(sent==1 and #own:GetChildren()==1,'explicit probe sends one placement and observes the resulting own block')
check(native.adapter.capabilities.build and native.buildButton.Text=='BUILD — zbuduj statyczny plan w BABFT','successful native probe enables the actual build action')
assert(native:select('WORM_MK2',true));native:updateDashboard()
check(native.staticButton.Visible and not native.buildButton.Visible,'mechanical schema shows an explicit static option instead of the failing native BUILD action')
native.staticButton.Activated:Fire();check(native.builder.schema.geometryOnly and not native.builder.schema.mechanical and #native.builder.schema.connections==0 and not native.builder:isBusy(),'static option creates a separate labelled draft without starting placement')
local savedFarmTick=native.farm.tick;native.farm.tick=function()error('Fixture farm failure')end;native.runtime.schedules.Controllers.fn();native.farm.tick=savedFarmTick
check(native.farm.state=='ERROR' and native.runtime.schedules.Controllers~=nil and native.ui.statusInfo.Text:find('Fixture farm failure',1,true),'BABFT controller errors remain readable without removing all module scheduling')
native.farm:stop()
local piece=table.clone(native.builder.schema.elements[1]);piece.material='WoodBlock';piece.position={4,2,0};piece.color=nil;piece.size={2,2,2};piece.class='Part'
local seat=table.clone(piece);seat.id='native_seat';seat.material='Seat';seat.class='Seat';seat.position={6,2,0}
assert(native.builder:select({schemaVersion=2,id='native_test',name='Static fixture',elements={piece,seat},connections={}},true))
assert(native.builder:start(native.inventorySnapshot));for _=1,6 do native.builder:tick()end
check(native.builder.state=='COMPLETED' and native.builder.placed==2 and sent==3,'static build integrates native adapter, observed placement and completion controller')
check(#own:GetChildren()==3 and own:FindFirstChild('Seat')~=nil,'one native seat is placed without scaling it to the generic block size')
local nested=child(data,'Folder','Inventory');child(nested,'IntValue','GlassBlock').Value=17;data.ChildAdded:Fire(nested)
check(native.readInventory().items.GlassBlock.count==17,'inventory finds exact identifiers in nested game inventory folders')
local glass=nested:FindFirstChild('GlassBlock');glass.Value=9;glass.Changed:Fire()
check(native.readInventory().items.GlassBlock.count==9,'nested inventory changes update the observed count')
local rootWood=data:FindFirstChild('WoodBlock');rootWood:Destroy();local alias=child(nested,'IntValue','Wood');alias.Value=27;data.ChildRemoved:Fire(rootWood);nested.ChildAdded:Fire(alias)
check(native.readInventory().items.WoodBlock.count==27 and native.readInventory().items.TitaniumBlock.count==10000,'explicit wood alias does not confuse metal and titanium')
player.CharacterAdded:Fire(ch);check(not native.adapter.capabilities.build,'respawn invalidates the old tool test')
rf.InvokeServer=function()sent+=1;return nil end;local beforeProbe=sent;native.buildTestButton.Activated:Fire()
check(not native.adapter.capabilities.build and sent==beforeProbe+1,'a tool returning normally without a replicated block cannot unlock build or trigger a retry')
native:unload();check(native.runtime:counts().connections==0,'native compatibility unload disconnects inventory and GUI listeners')
print('UI SMOKE COMPLETE: mock contract only; no native visual or physics claim')
