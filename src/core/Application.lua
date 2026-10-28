return function(M)
 local App={};App.__index=App
 function App.new()
  local self=setmetatable({alive=true,clock=os.clock,pro=_G.KubiHubPremiumKey=='6969',schemaQuery='',schemaCategory='Wszystkie',schemaSort='Nazwa',manualStep=1,fps=0,lastInventoryAt=0},App)
  self.player=game:GetService('Players').LocalPlayer;assert(self.player,'V5 wymaga klienta / LocalScript.');self.player:WaitForChild('PlayerGui',10)
  self.input=game:GetService('UserInputService');self.runService=game:GetService('RunService');self.http=game:GetService('HttpService')
  self.log=M.Log.new(function()return os.date('%Y-%m-%d %H:%M:%S')end)
  self.runtime=M.Runtime.new(self.clock,function(module,err)self.log:error(module,err);if self.ui then self.ui:toast(module,'Wystąpił błąd. Szczegóły w DEBUG.',true) end end)
  self.codec={encode=function(v)return self.http:JSONEncode(v)end,decode=function(s)return self.http:JSONDecode(s)end}
  self.storage=self:storageAdapter();self.config=M.Config.new(self.codec,self.storage,self.log)
  local saved=_G.KubiHubV5Settings;if type(saved)=='table' then local value=M.Config.validate(saved);if value then self.config.data=value end end
  self.library=M.Library.new();for _,err in ipairs(self.library.errors) do self.log:error('Schematics',err) end
  self.adapter=M.Adapter.new({userId=self.player.UserId,placeId=game.PlaceId,clock=self.clock,spawn=task.spawn,wait=task.wait,alive=function()return self.alive end})
  self.farm=M.Farm.new(self.runtime,self.adapter,self.config.data.farm,self.log,task.spawn)
  self.builder=M.Builder.new(self.runtime,self.adapter,self.log,task.spawn)
  self.movement=M.Movement.new(self.runtime,self.adapter,self.player,self.input,self.log,self.config.data.movement)
  self.effects=M.Effects.new(self.clock);self.inventorySnapshot=M.Inventory.snapshot(nil,'Oczekiwanie na dane')
  self.readInventory=M.Inventory.observePlayer(self.player,self.runtime,function(snapshot)if not self.serverInventory then self.inventorySnapshot=snapshot;self.previewDirty=true end end)
  self.ui=M.UI.new(self);self:pages();self:select('WORM_MK2');self.ui:show('HOME');self.ui:theme()
  self.runtime:connect(self.player.CharacterAdded,function()self.farm:stop('Respawn — uruchom ponownie ręcznie.');self.movement:reset();if self.builder:isBusy() then self.builder:cancel('Respawn — anulowanie własnej budowy.') end;self.effects:clear()end,'Character')
  self.runtime:connect(self.runService.Heartbeat,function(dt)
   self.fps=self.fps==0 and 1/math.max(dt,.001) or self.fps*.94+math.min(240,1/math.max(dt,.001))*.06
   self.runtime:tick(dt)
  end,'Scheduler')
  self.runtime:connect(self.runService.RenderStepped,function()self.movement:tick()end,'Movement')
  self.runtime:schedule('Controllers',.1,function()self.farm:tick();self.builder:tick();self.effects:tick();self.ui:tick()end)
  self.runtime:schedule('Dashboard',1,function()self:updateDashboard()end)
  self.runtime:schedule('InventoryRefresh',2,function()if self.adapter.capabilities.inventory and not self.adapter.pending and not self.builder:isBusy() and self.farm.state=='STOPPED' then self:refreshInventory() end end)
  self.runtime:schedule('PreviewRefresh',.2,function()if self.previewDirty and self.ui.current=='BUILDER' then self:refreshPreview() end end)
  self.runtime:job('Adapter',function()local ok,err=self.adapter:connect(game:GetService('ReplicatedStorage'));if ok then self.log:add('Adapter',self.adapter.label);self:refreshInventory() else self.log:add('Adapter',err,'WARN') end;return true end,task.spawn)
  self.log:add('Core','KUBI HUB ULTIMATE V5.0 uruchomiony.');self:updateDashboard();return self
 end
 function App:storageAdapter()
  _G.KubiHubV5Profiles=type(_G.KubiHubV5Profiles)=='table' and _G.KubiHubV5Profiles or {};local memory=_G.KubiHubV5Profiles
  if type(readfile)=='function' and type(writefile)=='function' and type(isfile)=='function' and type(isfolder)=='function' and type(makefolder)=='function' then
   local folder='KubiHubUltimateV5';local ok=pcall(function()if not isfolder(folder) then makefolder(folder) end end)
   if ok then return {label='własne pliki KubiHubUltimateV5',write=function(n,s)local path=folder..'/'..n..'.json';if isfile(path) then writefile(folder..'/'..n..'.backup.json',readfile(path)) end;writefile(path,s)end,read=function(n)local p=folder..'/'..n..'.json';return isfile(p) and readfile(p) or nil end,backup=function(n)local p=folder..'/'..n..'.backup.json';return isfile(p) and readfile(p) or nil end} end
   self.log:add('Config','Pliki profili niedostępne; używam pamięci sesji.','WARN')
  end
  return {label='pamięć bieżącej sesji; eksport JSON do trwałej kopii',write=function(n,s)local old=memory[n];memory[n]={text=s,backup=old and old.text}end,read=function(n)return memory[n] and memory[n].text end,backup=function(n)return memory[n] and memory[n].backup end}
 end
 function App:run(module,fn)
  if not self.alive then return false end
  local ok,a,b=xpcall(fn,function(e)return tostring(e)..'\n'..debug.traceback()end)
  if not ok then self.log:error(module,a);self.ui:toast(module,tostring(a):sub(1,170),true);return false end
  if type(a)=='table' and a.ok~=nil then b=a.error;a=a.ok end
  if a==false then self.log:add(module,tostring(b or 'Funkcja niedostępna.'),'WARN');self.ui:toast(module,b or 'Funkcja niedostępna.',true);return false end
  self.previewDirty=true;return true
 end
 function App:notify(module,text)self.log:add(module,text);self.ui:toast(module,text)end
 function App:copy(text,box)
  if box then box.Text=text end
  if type(setclipboard)=='function' then setclipboard(text);self:notify('Tools','Skopiowano tekst.') else self:notify('Tools','Tekst jest w polu. Zaznacz go i skopiuj ręcznie.') end
 end
 function App:needPro(feature)
  if self.pro then return true end;self.ui:show('SETTINGS');self.ui:toast('PRO','Wpisz klucz społeczności, aby odblokować '..feature);return false,'Funkcja PRO wymaga klucza.'
 end
 function App:applyConfig()
  self:stopAll();self.farm.settings=self.config.data.farm;self.movement.settings=self.config.data.movement
  if self.builder:isBusy() then self.deferredConfig=true;return true end
  if self.builder.source then local ok,err=self.builder:edit(self.config.data.builder);if not ok then return false,err end end
  self.ui:fit();self.ui:theme();self.ui:refreshControls();self.previewDirty=true;_G.KubiHubV5Settings=M.Util.copy(self.config.data);return true
 end
 function App:refreshInventory()
  if not self.adapter.capabilities.inventory then self.inventorySnapshot=self.readInventory();return end
  local reply=self.adapter:inventory();if reply.ok and type(reply.values)=='table' then self.serverInventory=true;self.inventorySnapshot=M.Inventory.snapshot(reply.values,reply.source or self.adapter.label);self.previewDirty=true else self.log:add('Inventory',reply.error or 'Brak danych adaptera.','WARN') end
 end
 function App:select(id)
  local item=self.library.items[id];if not item then return false,'Nie znaleziono schematu.' end
  local ok,err=self.builder:select(item);if not ok then return false,err end
  if item.mechanical then self.config.data.builder.mirrorX=false;self.config.data.builder.mirrorZ=false end
  ok,err=self.builder:edit(self.config.data.builder,false);if not ok then return false,err end
  self.manualStep=1;self.previewDirty=true;self:refreshPreview();return true
 end
 function App:refreshPreview()
  if not self.builder.schema or not self.preview then return end
  local p=M.Performance.get(self.config.data.performance.profile,self.fps);self.preview:set(self.builder.schema,self.inventorySnapshot,{limit=p.previewLimit,layer=self.config.data.builder.previewLayer,yaw=self.builder.options.yaw});self.previewDirty=false
  local report=self.builder:assistant(self.inventorySnapshot);local b=report.bounds.size
  self.planInfo.Text=string.format('%s\n%d części • %d połączeń • %.1f × %.1f × %.1f studów\nPodgląd: %d obiektów / %d części. Czerwone: brakujące, bursztynowe: nieodczytane.',self.builder.schema.name,report.elements,report.connections,b[1],b[2],b[3],self.preview.shown,report.elements)
  self.materialInfo.Text='Źródło: '..self.inventorySnapshot.source..'\n'..M.Inventory.describe(report.materials);self.materialInfo.Size=UDim2.new(1,0,0,math.max(80,#report.materials.rows*50+40))
  self:updateStep()
 end
 function App:updateStep()
  if not self.stepInfo or not self.builder.schema then return end
  local list=self.builder.schema.elements;self.manualStep=math.clamp(self.manualStep,1,#list);local e=list[self.manualStep]
  self.stepInfo.Text=string.format('Krok %d / %d: %s\nID %s • %s\nPozycja %.2f / %.2f / %.2f • obrót %.1f / %.1f / %.1f\nTo instrukcja i podgląd, nie potwierdzenie budowy w grze.',self.manualStep,#list,e.name,e.id,e.material,e.position[1],e.position[2],e.position[3],e.rotation[1],e.rotation[2],e.rotation[3])
 end
 function App:renderSchematics()
  self.ui:clearList(self.schemaList)
  local list=self.library:list(self.schemaQuery,self.schemaCategory,self.schemaSort,self.config.data.favorites,self.onlyFavorites)
  self.schemaCount.Text=#list..' pasujących projektów. Wbudowane modele pojazdów zachowują geometrię; sterowanie potwierdzamy osobno.'
  for _,item in ipairs(list) do local schema=item;self.ui:button(self.schemaList,(self.config.data.favorites[item.id] and '★ ' or '')..item.name..'  ·  '..#item.elements,function()local ok,err=self:select(schema.id);if ok then self.ui:show('BUILDER') end;return ok,err end,'Kategoria: '..item.category..'. Otwórz podgląd, materiały i kroki.',true) end
 end
 function App:pages()
  local ui=self.ui
  local home=ui:page('HOME','HOME');local h=ui:card(home,'KUBI HUB ULTIMATE V5.0','Nowy warsztat z walidowanymi schematami, profilem ustawień i jawnym stanem zgodności. Brak adaptera oznacza tryb asystenta.')
  self.homeInfo=ui:label(h,'',125);ui:button(h,'WORM MK2 — otwórz warsztat',function()local ok,err=self:select('WORM_MK2');ui:show('BUILDER');return ok,err end)
  ui:button(h,'Biblioteka schematów',function()ui:show('SCHEMATICS')end);ui:button(h,'STOP WSZYSTKIE MODUŁY',function()self:stopAll()end)
  local news=ui:card(home,'Ostatnie zmiany','Materiały z osobnymi identyfikatorami. WORM z grafem połączeń. Stos: 1 laska dynamitu, 1 siedzenie, 3000 drewna. Nowy podgląd i profile. Uprawnione budowanie wymaga adaptera.')
  self.versionInfo=ui:label(news,'V5.0.0 • wydanie 2026-10-28. Najnowsza wersja: jeszcze nie sprawdzono.',85)
  ui:button(news,'Sprawdź aktualizację',function()
   if self.versionJob and not self.versionJob.done then return false,'Trwa sprawdzanie wersji.' end
   self.versionJob=self.runtime:job('Version',function()local value,err=M.Version.fetch(function(url)return game:HttpGet(url)end,self.codec.decode);if not value then self.log:add('Version',err,'WARN');self.versionInfo.Text=err;return false end;self.versionInfo.Text='Obecna '..M.Version.current..' • najnowsza '..value.version..' • '..value.releaseDate..'\n'..value.compatibility..'\n'..table.concat(value.changes,'; ');self:notify('Version',value.update and 'Dostępna jest aktualizacja. Kod nie został podmieniony.' or 'Brak nowszej wersji.');return true end,task.spawn)
  end)
  local farm=ui:page('FARM','FARM');local f=ui:card(farm,'Kontroler cykli','Wymaga autoryzowanego serwera. Zestaw Studio ma trasę testową bez nagród BABFT. Profile zmieniają przerwę między potwierdzonymi etapami i respektują minimum serwera.')
  self.farmInfo=ui:label(f,'',155)
  for _,a in ipairs({{'START',function()return self.farm:start()end},{'STOP',function()return self.farm:stop()end},{'PAUZA',function()return self.farm:pause()end},{'WZNÓW',function()return self.farm:resume()end},{'RESET SESJI',function()return self.farm:reset()end}}) do ui:button(f,a[1],a[2]) end
  ui:cycle(f,'Profil',{'NORMAL','FAST','TURBO','HYPER','LIGHTNING','SONIC'},function()return self.config.data.farm.profile end,function(v)self.config.data.farm.profile=v end)
  ui:field(f,'Stop po potwierdzonych cyklach • 0 bez limitu',0,function(v)self.config.data.farm.stopAfter=M.Util.number(tonumber(v),0,0,10000,true);return self.config.data.farm.stopAfter end)
  local builder=ui:page('BUILDER','BUILDER');local b=ui:card(builder,'Podgląd 3D i budowanie','Przeciągnij podgląd, by obrócić kamerę. Kółko myszy lub przyciski zmieniają zoom. Obszar podglądu jest oddzielony od świata gry.')
  self.preview=M.Preview.new(b);self.runtime:own(self.preview.viewport)
  ui:bind(self.preview.viewport.InputBegan,function(i)if ui:isPress(i) then ui.previewDrag=i.Position end end)
  ui:bind(self.preview.viewport.InputChanged,function(i)if i.UserInputType==Enum.UserInputType.MouseWheel then self.preview:changeZoom(math.exp(-i.Position.Z*.15)) end end)
  self.planInfo=ui:label(b,'',112)
  for _,v in ipairs({{'Widok perspektywiczny','PERSPECTIVE'},{'Widok z góry','TOP'},{'Widok z boku','SIDE'}}) do local a=v;ui:button(b,a[1],function()self.preview:view(a[2])end) end
  ui:button(b,'Przybliż',function()self.preview:changeZoom(.8)end);ui:button(b,'Oddal',function()self.preview:changeZoom(1.25)end)
  ui:field(b,'Warstwa • 0 = wszystkie',0,function(v)self.config.data.builder.previewLayer=M.Util.number(tonumber(v),0,0,1000,true);self.previewDirty=true;return self.config.data.builder.previewLayer end)
  self.materialInfo=ui:label(b,'',180)
  ui:button(b,'BUILD — sprawdź i zbuduj przez adapter',function()self:refreshPreview();return self.builder:start(self.inventorySnapshot)end,'Tylko uprawniony serwer i własna działka. Podgląd nie jest budowlą serwerową.')
  ui:button(b,'Pauza budowania',function()return self.builder:pause()end);ui:button(b,'Wznów budowanie',function()return self.builder:resume()end);ui:button(b,'Anuluj własną transakcję',function()return self.builder:cancel()end)
  self.buildInfo=ui:label(b,'',75)
  local edits=ui:card(builder,'Edytor i historia','Obrót dotyczy budowy na działce; kamera podglądu obraca się niezależnie. Odbicie mechanicznego rig-u jest zablokowane, by nie uszkodzić jego osi.')
  local function edit(k,v)local options=M.Util.copy(self.builder.options);options[k]=v;local ok,err=self.builder:edit(options);if ok then self.config.data.builder=M.Util.copy(options);self.previewDirty=true end;return ok,err end
  ui:cycle(edits,'Obrót', {0,90,180,270},function()return self.builder.options.yaw end,function(v)return edit('yaw',v)end)
  ui:cycle(edits,'Materiał',{'ORIGINAL','WoodBlock','MetalBlock','TitaniumBlock','PlasticBlock'},function()return self.builder.options.material end,function(v)return edit('material',v)end)
  ui:toggle(edits,'Lustro X',function()return self.builder.options.mirrorX end,function(v)return edit('mirrorX',v)end);ui:toggle(edits,'Lustro Z',function()return self.builder.options.mirrorZ end,function(v)return edit('mirrorZ',v)end)
  ui:button(edits,'UNDO',function()return self.builder:undo()end);ui:button(edits,'REDO',function()return self.builder:redo()end)
  local assistant=ui:card(builder,'Asystent ręcznego budowania','Współrzędne są względem konstrukcji. Stos drewna zawiera celowe nałożenie elementów; nie uruchamiam eksplozji ani nie wysyłam go do publicznego serwera.')
  self.stepInfo=ui:label(assistant,'',140);ui:button(assistant,'Poprzedni element',function()self.manualStep=self.manualStep-1;self:updateStep()end);ui:button(assistant,'Następny element',function()self.manualStep=self.manualStep+1;self:updateStep()end)
  local schematics=ui:page('SCHEMATICS','SCHEMATICS');local sc=ui:card(schematics,'Biblioteka konstrukcji','Zachowana geometria poprzednich projektów, WORM MK2 oraz własne projekty. Stan mechaniki jest oddzielony od samego planu.')
  ui:field(sc,'Szukaj schematu','',function(v)self.schemaQuery=v;self:renderSchematics();return v end)
  ui:cycle(sc,'Kategoria',{'Wszystkie','Pojazdy','Łodzie','Samoloty','Konstrukcje mechaniczne','WORMS','Proste budowle','Własne projekty'},function()return self.schemaCategory end,function(v)self.schemaCategory=v;self:renderSchematics()end)
  ui:cycle(sc,'Sortuj',{'Nazwa','Bloki'},function()return self.schemaSort end,function(v)self.schemaSort=v;self:renderSchematics()end)
  ui:toggle(sc,'Tylko ulubione',function()return self.onlyFavorites==true end,function(v)self.onlyFavorites=v;self:renderSchematics()end)
  ui:button(sc,'Dodaj / usuń wybrany z ulubionych',function()local id=self.builder.source.id;self.config.data.favorites[id]=not self.config.data.favorites[id];self:renderSchematics()end)
  self.schemaCount=ui:label(sc,'',60);self.schemaList=ui:create('Frame',{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},sc);ui:create('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},self.schemaList);self:renderSchematics()
  local assets=ui:card(schematics,'Modele społeczności — tylko podgląd','Zachowane pliki czerwonego WORM-a i SHREDDER-a. Odczytuję JSON z tego repozytorium. Ich oryginalne połączenia pozostają w plikach; importer nie udaje gotowej mechaniki.')
  for _,spec in ipairs({{'Czerwony WORM','worm-red.json'},{'SHREDDER','shredder.json'}}) do local a=spec;ui:button(assets,'Wczytaj podgląd: '..a[1],function()
   local text=game:HttpGet('https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/'..a[2]);if #text>2000000 then return false,'Plik przekracza 2 MB.' end
   local schema,errors=M.Schema.import(self.codec.decode(text));if not schema then return false,table.concat(errors,'; ') end;schema.id='asset_'..a[2]:gsub('[^%w]','_');schema.name=a[1]..' — podgląd';schema.assistantOnly=true;schema.importedMechanics=true
   local ok,err=self.library:save(schema);if not ok then return false,err end;ok,err=self:select(schema.id);if ok then self:renderSchematics();ui:show('BUILDER') end;return ok,err
  end) end
  local movement=ui:page('MOVEMENT','MOVEMENT');local mv=ui:card(movement,'Ruch własnej postaci','W dozwolonym środowisku testowym: WASD / joystick, Spacja w górę, lewy Ctrl w dół. Respawn zatrzymuje moduł i wymaga ręcznego wznowienia.')
  self.movementInfo=ui:label(mv,'',75)
  for _,a in ipairs({{'WalkSpeed','walk',8,60},{'Siła skoku','jump',20,120},{'Prędkość Fly','flySpeed',10,100}}) do local field=a;ui:slider(mv,field[1],function()return self.config.data.movement[field[2]]end,function(v)self.config.data.movement[field[2]]=v end,field[3],field[4],1) end
  ui:button(mv,'Zastosuj WalkSpeed i skok',function()return self.movement:apply()end);ui:button(mv,'Włącz Fly',function()return self.movement:startFly()end);ui:button(mv,'Wyłącz Fly',function()self.movement:stopFly()end);ui:button(mv,'Przywróć oryginalny ruch',function()return self.movement:reset()end)
  local player=ui:page('PLAYER','PLAYER');local pl=ui:card(player,'Postać i efekty lokalne','Efekty są widoczne tylko u Ciebie. Nie zmieniają postaci innych graczy i nie niszczą konstrukcji.')
  self.playerInfo=ui:label(pl,'',85);ui:button(pl,'Konfetti',function()local _,_,r=self.movement:character();self.effects:confetti(r)end);ui:button(pl,'Tęczowy ślad • PRO',function()if not self:needPro('tęczowy ślad') then return false,'Wymagany klucz.' end;local _,_,r=self.movement:character();self.effects:trail(r)end)
  ui:button(pl,'Mini kopia własnego awatara',function()self.effects:clone(self.player.Character,.4)end);ui:button(pl,'Duża kopia własnego awatara',function()self.effects:clone(self.player.Character,2)end);ui:button(pl,'Wyczyść własne efekty',function()self.effects:clear()end)
  ui:button(pl,'WORM: otwórz / zamknij paszczę • klawisz E',function()return self.adapter:rig('mouth')end,'Działa po zbudowaniu rig-u przez autoryzowany adapter i zajęciu własnego fotela.')
  local tools=ui:page('TOOLS','TOOLS');self:toolsPage(tools)
  local stats=ui:page('STATS','STATS');local st=ui:card(stats,'Rzeczywiste pomiary sesji','Brak pomiaru jest oznaczony „—”. FPS dotyczy klienta. Czas odpowiedzi adaptera jest osobnym pomiarem i nie jest przedstawiany jako ping Roblox.')
  self.statsInfo=ui:label(st,'',210);self.lastSession=ui:label(st,_G.KubiHubLastSession and ('Poprzednia sesja:\n'.._G.KubiHubLastSession) or 'Pierwsza sesja V5.0.',100)
  local settings=ui:page('SETTINGS','SETTINGS');self:settingsPage(settings)
  local debugPage=ui:page('DEBUG','DEBUG');local dbg=ui:card(debugPage,'Błędy, zadania i zgodność','Raport zawiera datę, moduł, poziom i szczegóły błędu. Nie zawiera tokenów ani odczytu plików przeglądarki.')
  self.debugInfo=ui:label(dbg,'',140);self.debugBox=ui:field(dbg,'Raport do skopiowania','',nil,true);self.debugBox.Size=UDim2.new(1,0,0,260)
  ui:button(dbg,'Odśwież raport',function()self.debugBox.Text=self:report()end);ui:button(dbg,'Skopiuj raport',function()self:copy(self:report(),self.debugBox)end);ui:button(dbg,'Wyczyść historię',function()self.log:clear();self.debugBox.Text='' end)
  local performance=ui:page('PERFORMANCE','PERFORMANCE');local perf=ui:card(performance,'Wydajność KUBI HUB','Profile zmieniają limit obiektów podglądu i częstotliwość statystyk. Nie zmieniają Windows, innych aplikacji ani całego świata gry.')
  ui:cycle(perf,'Profil',{'QUALITY','BALANCED','PERFORMANCE'},function()return self.config.data.performance.profile end,function(v)self.config.data.performance.profile=v;self.previewDirty=true end);self.performanceInfo=ui:label(perf,'',110)
  ui:button(perf,'Wyczyść podgląd i efekty',function()self.preview:clear();self.effects:clear();self.previewDirty=false end);ui:button(perf,'Przywróć podgląd',function()self.previewDirty=true;self:refreshPreview()end)
 end
 function App:toolsPage(page)
  local ui=self.ui;local c=ui:card(page,'Import / eksport schematów','Tylko JSON lub dane LP_BUILD. Tekst nigdy nie jest uruchamiany jako Lua. Połączenia WORM-a w formacie V5 są zachowywane.')
  self.schemaBox=ui:field(c,'Dane projektu','',nil,true)
  ui:button(c,'Eksport wybranego schematu',function()self:copy(self.codec.encode(self.builder.schema),self.schemaBox)end)
  ui:button(c,'Import i zapisz własny projekt',function()
   local text=self.schemaBox.Text;if #text>2000000 then return false,'Limit pliku 2 MB.' end
   if text:match('^%s*LP_META') then local marker=text:find('LP_BUILD',1,true);if not marker then return false,'Brak sekcji LP_BUILD.' end;text=text:sub(marker+8) end
   local raw=self.codec.decode(text);local schema,errors=M.Schema.import(raw);if not schema then return false,table.concat(errors,'; ') end
   schema.id='custom_'..math.floor(self.clock()*1000);schema.name='Własny projekt '..self.library.revision+1;local ok,value=self.library:save(schema);if not ok then return false,value end;self:select(schema.id);self:renderSchematics();self:notify('Schematics','Zapisano własny schemat w sesji. Eksport JSON służy do trwałej kopii.');return true
  end)
  ui:button(c,'Eksport własnej budowli serwerowej',function()if not self.adapter.capabilities.build then return false,'Brak uprawnionego adaptera eksportu.' end;local r=self.adapter:snapshot();if not r.ok then return false,r.error end;self:copy(self.codec.encode(r.schema),self.schemaBox)end)
  local shapePage=ui:page('SHAPES','Shapes');local generators=ui:card(shapePage,'Shape Lab — bryły','Kula, kopuła, spirala i ściana. Gotowe konstrukcje znajdziesz wyżej w bibliotece. Osobna zakładka Circle Maker służy do kół i łuków.')
  self.generator={radius=10,segments=32,layers=1,kind='WoodBlock',filled=false};self.generatorKind='CIRCLE'
  self.generatorKind='SPHERE';ui:cycle(generators,'Generator',{'SPHERE','DOME','SPIRAL','WALL'},function()return self.generatorKind end,function(v)self.generatorKind=v end)
  for _,spec in ipairs({{'Promień','radius',2,28},{'Bloki obwodu / zwoju','segments',8,120},{'Liczba warstw','layers',1,20}}) do local f=spec;ui:field(generators,f[1],self.generator[f[2]],function(v)self.generator[f[2]]=M.Util.number(tonumber(v),self.generator[f[2]],f[3],f[4],true);return self.generator[f[2]] end) end
  ui:cycle(generators,'Materiał',{'WoodBlock','MetalBlock','TitaniumBlock','PlasticBlock'},function()return self.generator.kind end,function(v)self.generator.kind=v end)
  ui:toggle(generators,'Wypełnienie',function()return self.generator.filled end,function(v)self.generator.filled=v end)
  ui:button(generators,'Utwórz plan i pokaż',function()
   local o=M.Util.copy(self.generator);local p;if self.generatorKind=='CIRCLE' then p=M.LegacyShapes.circle(o) elseif self.generatorKind=='SPHERE' or self.generatorKind=='DOME' then o.dome=self.generatorKind=='DOME';p=M.LegacyShapes.sphere(o) elseif self.generatorKind=='SPIRAL' then o.turns=o.layers;p=M.LegacyShapes.spiral(o) else o.width=o.radius;o.height=o.layers;p=M.LegacyShapes.wall(o) end
   local schema,errors=M.Schema.fromLegacy('generated_'..math.floor(self.clock()*1000),'Generator '..self.generatorKind,p,'Własne projekty');if not schema then return false,table.concat(errors,'; ') end;self.library:save(schema);self:select(schema.id);self:renderSchematics();self.ui:show('BUILDER')
  end)
  local circlePage=ui:page('CIRCLE','Circle Maker');local circle=ui:card(circlePage,'Circle Maker — koła, dyski i łuki','Ustaw środek konstrukcji względem własnej działki, materiał, rozmiar i warstwy. Podgląd oraz lista materiałów pojawią się w Builderze.')
  self.circle={radius=12,segments=40,layers=1,thickness=1,layerGap=2,arc=360,axis='XZ',kind='WoodBlock',filled=false,x=0,y=2,z=0}
  for _,spec in ipairs({{'Promień','radius',2,50},{'Bloki na obwodzie','segments',8,120},{'Liczba warstw','layers',1,20},{'Grubość pierścienia','thickness',1,8},{'Odstęp warstw','layerGap',.5,10},{'Łuk w stopniach','arc',15,360},{'Środek X','x',-50,50},{'Środek Y','y',0,100},{'Środek Z','z',-50,50}}) do local s=spec;ui:field(circle,s[1],self.circle[s[2]],function(v)self.circle[s[2]]=M.Util.number(tonumber(v),self.circle[s[2]],s[3],s[4],s[2]=='layers' or s[2]=='segments' or s[2]=='thickness');return self.circle[s[2]] end) end
  ui:cycle(circle,'Materiał',{'WoodBlock','MetalBlock','TitaniumBlock','PlasticBlock','GlassBlock'},function()return self.circle.kind end,function(v)self.circle.kind=v end)
  ui:cycle(circle,'Płaszczyzna',{'XZ','XY','YZ'},function()return self.circle.axis end,function(v)self.circle.axis=v end);ui:toggle(circle,'Wypełniony dysk',function()return self.circle.filled end,function(v)self.circle.filled=v end)
  ui:button(circle,'GENERUJ KOŁO — podgląd i materiały',function()
   local o=self.circle;local estimated=o.filled and (2*math.floor(o.radius/2)+1)^2*o.layers or (o.segments+1)*o.layers*o.thickness
   if estimated>M.Schema.limit then return false,'Plan może przekroczyć 6000 części. Zmniejsz promień, warstwy albo grubość.' end
   local parts=M.LegacyShapes.circle(o);for _,p in ipairs(parts) do p.x=p.x+o.x;p.y=p.y+o.y;p.z=p.z+o.z end
   local schema,errors=M.Schema.fromLegacy('circle_'..math.floor(self.clock()*1000),'Koło / łuk '..o.radius,parts,'Własne projekty');if not schema then return false,table.concat(errors,'; ') end
   local ok,err=self.library:save(schema);if not ok then return false,err end;ok,err=self:select(schema.id);if ok then self:renderSchematics();ui:show('BUILDER') end;return ok,err
  end)
  local dynamite=ui:card(shapePage,'Dynamit + drewno — plan','3000 drewnianych bloków w jednym punkcie nad laską dynamitu i jedno siedzenie. To plan / asystent; detonacja i wysyłanie nakładających się bloków na publiczny serwer są wyłączone.')
  ui:button(dynamite,'Otwórz dokładny plan stosu',function()local ok,err=self:select('DYNAMITE_STACK');ui:show('BUILDER');return ok,err end)
 end
 function App:settingsPage(page)
  local ui=self.ui;local card=ui:card(page,'Profile i ustawienia','Zapis nie uruchamia automatycznie farmy ani ruchu. Źródło zapisu: '..self.storage.label)
  self.profileName=ui:field(card,'Nazwa profilu','default');self.configBox=ui:field(card,'Konfiguracja JSON','',nil,true)
  ui:button(card,'Zapisz profil',function()self.config.data.builder=M.Util.copy(self.builder.options);return self.config:save(self.profileName.Text)end)
  ui:button(card,'Wczytaj profil',function()local ok,err=self.config:load(self.profileName.Text);if not ok then return false,err end;return self:applyConfig()end)
  ui:button(card,'Eksport ustawień',function()self:copy(self.config:export(),self.configBox)end);ui:button(card,'Import ustawień',function()local ok,err=self.config:import(self.configBox.Text);if not ok then return false,err end;return self:applyConfig()end)
  ui:button(card,'Przywróć poprzednią konfigurację',function()local ok,err=self.config:rollback();if not ok then return false,err end;return self:applyConfig()end);ui:button(card,'Ustawienia domyślne',function()self.config:reset();return self:applyConfig()end)
  ui:cycle(card,'Akcent',{'BLUE','PURPLE'},function()return self.config.data.ui.theme end,function(v)self.config.data.ui.theme=v;ui:theme()end)
  ui:toggle(card,'Tryb kompaktowy',function()return self.config.data.ui.compact end,function(v)self.config.data.ui.compact=v;ui:fit()end);ui:toggle(card,'Podpowiedzi',function()return self.config.data.ui.tooltips end,function(v)self.config.data.ui.tooltips=v end)
  ui:button(card,'Pomoc i nawigacja',function()self:notify('Pomoc','Prawy Ctrl ukrywa okno. U góry wyszukaj nazwę funkcji. Kliknij nagłówek sekcji, aby ją rozwinąć. Raport błędów i wydajność znajdziesz w Settings.')end)
  local pro=ui:card(ui.pages.PRO,'PRO — społeczność i klucz','Klucz PRO jest lokalnym kodem, a nie uprawnieniem do serwera gry. Hub nie weryfikuje członkostwa na Discordzie.')
  local key=ui:field(pro,'Klucz','');ui:button(pro,'Odblokuj PRO',function()if key.Text:gsub('%s','')~='6969' then return false,'Nieprawidłowy klucz.' end;self.pro=true;_G.KubiHubPremiumKey='6969';key.Text='';self:notify('PRO','Odblokowano funkcje społeczności.');return true end)
  ui:button(pro,'Kopiuj zaproszenie Discord',function()self:copy('https://discord.gg/qmWGb4Q9p',self.configBox)end)
  ui:button(pro,'Wyłącz hub i posprzątaj',function()self:unload()end)
 end
 function App:report()
  local count=self.runtime:counts();local lines={self.log:text(),'','Środowisko: '..self.adapter.label,'Adapter: '..tostring(self.adapter.session~=nil),'Zadania klienta: '..count.jobs,'Połączenia klienta: '..count.connections,'Harmonogramy: '..count.schedules,'Otwarte RF adaptera: '..tostring(self.adapter.pending~=nil),'Źródło materiałów: '..self.inventorySnapshot.source}
  if self.builder.schema then lines[#lines+1]=M.Inventory.describe(M.Inventory.compare(self.builder.schema,self.inventorySnapshot)) end
  return table.concat(lines,'\n')
 end
 function App:updateDashboard()
  if self.deferredConfig and not self.builder:isBusy() then self.deferredConfig=false;self:applyConfig() end
  local fs=self.farm:summary();local counts=self.runtime:counts();local _,hum,root=self.movement:character();local speed=root and root.AssemblyLinearVelocity.Magnitude;local active=(self.farm.state=='RUNNING' and 1 or 0)+(self.builder:isBusy() and 1 or 0)+(self.movement.fly and 1 or 0)+(#self.effects.objects>0 and 1 or 0)
  local p=M.Performance.get(self.config.data.performance.profile,self.fps);self.runtime.schedules.Dashboard.interval=p.statsInterval
  self.homeInfo.Text=string.format('Wersja 5.0.0 • %s\nAktywne moduły: %d\nFarm: %s • Builder: %s\nSchematy: %d • błędy walidacji biblioteki: %d',self.adapter.label,active,self.farm.state,self.builder.state,#self.library:list(),#self.library.errors)
  self.ui.subtitle.Text='V5.0  •  '..(self.adapter.session and 'UPRAWNIONY ADAPTER / '..self.adapter.label or 'ASYSTENT • BRAK API BUDOWANIA')
  self.farmInfo.Text=string.format('Stan: %s • etap: %d\nCykle potwierdzone %d • nieudane %d\nŚredni cykl: %s s • cykle/h: %s\nOstatni błąd: %s',fs.state,fs.stage,fs.completed,fs.failed,fs.average and string.format('%.2f',fs.average) or '—',fs.cyclesPerHour and string.format('%.1f',fs.cyclesPerHour) or '—',fs.lastError~='' and fs.lastError or '—')
  self.buildInfo.Text=string.format('Stan: %s\nCzęści potwierdzone przez serwer: %d / %d\n%s',self.builder.state,self.builder.placed,self.builder.total,self.builder.error or '')
  self.movementInfo.Text=string.format('Prędkość rzeczywista: %s stud/s\nFly: %s • uprawnienie: %s',speed and string.format('%.1f',speed) or '—',self.movement.fly and 'ON' or 'OFF',self.adapter.capabilities.movement and 'potwierdzone' or 'brak adaptera')
  self.playerInfo.Text=hum and string.format('%s\nZdrowie: %.0f / %.0f • stan: %s',self.player.DisplayName,hum.Health,hum.MaxHealth,hum:GetState().Name) or 'Oczekiwanie na postać.'
  self.statsInfo.Text=string.format('Sesja %.1f min • FPS %.1f\nCykle %d • nieudane %d\nŚredni czas cyklu %s s\nOdpowiedź adaptera %s ms\nZadania %d • połączenia %d • harmonogramy %d\nBrak symulowanych nagród ani złota.',fs.elapsed/60,self.fps,fs.completed,fs.failed,fs.average and string.format('%.2f',fs.average) or '—',self.adapter.lastLatency and string.format('%.1f',self.adapter.lastLatency) or '—',counts.jobs,counts.connections,counts.schedules)
  self.debugInfo.Text='Środowisko: '..self.adapter.label..'\nZadania klienta: '..counts.jobs..' • aktywne połączenia: '..counts.connections..'\nFarm / Builder / Movement: '..self.farm.state..' / '..self.builder.state..' / '..(self.movement.fly and 'FLY' or 'OFF')
  if self.ui.current=='DEBUG' then self.debugBox.Text=self:report() end
  self.performanceInfo.Text=string.format('FPS %.1f • limit podglądu %d\nCzęstotliwość statystyk: co %.1f s\nObiekty podglądu: %d • lokalne efekty: %d',self.fps,p.previewLimit,p.statsInterval,#self.preview.parts,#self.effects.objects)
 end
 function App:stopAll()
  self.farm:stop();self.builder:cancel();self.movement:reset();self.effects:clear();self.adapter:cancel('all');self:notify('Core','Zatrzymano moduły. Trwające żądanie serwera może jeszcze kończyć zatwierdzanie; stan sprawdzisz w DEBUG.')
 end
 function App:unload()
  if not self.alive then return end
  self:stopAll();_G.KubiHubV5Settings=M.Util.copy(self.config.data);local f=self.farm:summary();_G.KubiHubLastSession=string.format('%d cykli potwierdzonych, %d nieudanych, %.1f min. Bez deklaracji testów fizyki.',f.completed,f.failed,f.elapsed/60)
  self.alive=false;self.runtime:close();if _G.KubiHubRuntime==self then _G.KubiHubRuntime=nil end
 end
 return App
end
