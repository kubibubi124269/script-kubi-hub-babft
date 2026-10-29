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
for _,size in ipairs({Vector2.new(320,600),Vector2.new(760,600),Vector2.new(1280,720)})do workspace.CurrentCamera.ViewportSize=size;second.ui:fit();check(second.ui.layout.width<=size.X-8,'responsive window fits '..size.X)end
second:unload();check(second.runtime:counts().connections==0,'unload removes current connections');check(second.ui.gui.Parent==nil,'unload destroys owned GUI')
print('UI SMOKE COMPLETE: mock contract only; no native visual or physics claim')
