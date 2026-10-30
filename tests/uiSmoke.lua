local function check(condition,message)assert(condition,message);print('PASS UI '..message)end
local first=startHub();check(first and first.alive,'full client starts in assistant mode')
check(first.adapter.capabilities.build~=true,'absent adapter cannot report build authorization')
local n=0;for _ in pairs(first.ui.pages)do n+=1 end;check(n==6,'exactly six navigation pages')
first.ui:show('CIRCLE');check(first.ui.current=='CIRCLE','dedicated Circle Maker page is reachable')
first.ui.search.Text='promień';check(first.ui.results.Visible,'global search shows results')
local found=false;for _,r in ipairs(first.ui.cards)do if r.result.Visible and r.title:find('Circle Maker',1,true)then found=true end end;check(found,'search indexes function settings')
for _,r in ipairs(first.ui.cards)do if r.title:find('Circle Maker',1,true)then r.result.Activated:Fire();check(r.body.Visible,'search expands matching section');check(first.ui.current=='CIRCLE','search opens matching tab')end end
first.ui:show('BUILDER');check(first.preview.shown>0 and first.preview.shown<=350,'viewport has bounded sampled geometry')
local function button(app,text)for _,o in ipairs(app.ui.gui:GetDescendants())do if o:IsA('TextButton') and o.Text==text then return o end end;error('Missing button: '..text)end
button(first,'ASYSTENT — pokaż kroki budowania').Activated:Fire()
check(first.ui.current=='BUILDER' and first.assistantBody.Visible,'unavailable server build opens the usable manual assistant')
check(first.builder.placed==0 and not first.builder:isBusy(),'manual assistant never starts a server build or fake progress')
for _,b in ipairs(first.buildControls)do check(not b.Visible,'transaction control is hidden without build access')end
local longMessage=string.rep('Pełna treść komunikatu. ',40)..'KONIEC'
first.ui:toast('BUILDER',longMessage,true);first.ui.footer.Activated:Fire()
check(first.ui.current=='SETTINGS' and first.ui.statusBody.Visible,'status bar expands the actual message section')
check(first.ui.statusInfo.Text=='[BUILDER] '..longMessage,'full status message is preserved beyond the toast limit')
check(first.ui.statusInfo.AutomaticSize==Enum.AutomaticSize.Y and first.ui.statusInfo.TextYAlignment==Enum.TextYAlignment.Top,'message text grows vertically and aligns to the top')
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
button(first,'GENERUJ KOŁO — podgląd i materiały').Activated:Fire()
check(first.builder.options.yaw==0 and first.builder.options.material=='ORIGINAL','new circle uses its own selected material and rotation')
check(first.builder.schema.elements[1].material=='WoodBlock','circle wood is not silently replaced with previous titanium')
local opts=table.clone(first.builder.options);opts.yaw=90;assert(first.builder:edit(opts));first:refreshPreview()
button(first,'Eksport wybranego schematu').Activated:Fire();local exported=first.codec.decode(first.schemaBox.Text);local beforeImport=first.schemaBox.Text
button(first,'Import i zapisz własny projekt').Activated:Fire();local importedId=first.builder.source.id
check(first.builder.options.yaw==0,'import does not apply exported rotation twice')
check(math.abs(first.builder.schema.elements[1].position[1]-exported.elements[1].position[1])<1e-7,'export/import keeps rendered placement')
first.schemaBox.Text=beforeImport;button(first,'Import i zapisz własny projekt').Activated:Fire();check(first.builder.source.id~=importedId and first.library.items[importedId]~=nil,'rapid consecutive imports never overwrite an earlier project')
first:needPro('test');check(first.ui.current=='PRO','locked feature points to the actual key page')
button(first,'Wyśrodkuj schemat X/Z').Activated:Fire();check(math.abs(first.builder.bounds.center[1])<1e-7 and math.abs(first.builder.bounds.center[3])<1e-7,'center button moves the plan to the middle')
button(first,'Dopasuj do obszaru').Activated:Fire();check(first.builder.state=='PREVIEW','fit button prepares a preview without claiming server build')
button(first,'Kopiuj listę materiałów').Activated:Fire();check(first.schemaBox.Text:find('wymagane',1,true)~=nil,'copy materials has a usable text fallback without clipboard API')
local oldSpeed=hum.WalkSpeed;local second=startHub();check(not first.alive,'second execution unloads first runtime');check(first.runtime:counts().connections==0,'old event connections are disconnected')
n=0;for _,o in ipairs(player.PlayerGui:GetChildren())do if o.Name=='KubiHubUltimateV5'then n+=1 end end;check(n==1,'second execution leaves one GUI')
check(hum.WalkSpeed==oldSpeed,'startup preserves original character movement')
for _,size in ipairs({Vector2.new(320,600),Vector2.new(580,527),Vector2.new(760,600),Vector2.new(1280,720)})do workspace.CurrentCamera.ViewportSize=size;second.ui:fit();check(second.ui.layout.width<=size.X-8,'responsive window fits '..size.X)
 if second.ui.layout.narrow then check(not second.ui.nav.ScrollingEnabled and second.ui.navLayout.FillDirectionMaxCells==second.ui.layout.navColumns,'narrow navigation displays the complete tab grid at '..size.X)end
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
check(sent==0 and not native.adapter.capabilities.build,'loading the hub never places a probe or authorizes untested tools')
check(native.buildTestButton.Visible and native.babftRefresh.Visible,'BABFT has visible tool test and refresh actions')
native.buildTestButton.Activated:Fire();check(sent==1 and #own:GetChildren()==1,'explicit probe sends one placement and observes the resulting own block')
check(native.adapter.capabilities.build and native.buildButton.Text=='BUILD — zbuduj statyczny plan w BABFT','successful native probe enables the actual build action')
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
