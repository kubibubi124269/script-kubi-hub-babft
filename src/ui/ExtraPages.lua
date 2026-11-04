return function(M)
 return function(app)
  local ui=app.ui;app.travel=M.Travel.new(app.runtime,app.player,M.Games.detect(game.PlaceId,game.GameId)~=nil or app.runService:IsStudio())
  local t=app.travel;local teleport=ui:page('TELEPORT');local p=ui:card(teleport,'Punkty teleportu','Zapisz własny punkt i wróć do niego. Punkty są przechowywane tylko w tej sesji.')
  local info=ui:label(p,'');local function status()info.Text='Wybrany punkt: '..t.slot..' / 3  ·  '..(t.slots[t.slot] and 'zapisany' or 'pusty') end;status();ui.refreshers[#ui.refreshers+1]=status
  local function options(panel)ui:cycle(panel,'Punkt',{1,2,3},function()return t.slot end,function(v)t.slot=v;status()end);ui:button(panel,'Zapisz obecną pozycję',function()local ok,err=t:save();status();return ok,err end)end
  ui:feature(p,'Zapisz punkt',nil,function()local ok,err=t:save();status();return ok,err end,options)
  ui:feature(p,'Teleport do punktu',nil,function()return t:go(t.slots[t.slot])end,options)
  ui:feature(p,'Wróć do poprzedniej pozycji',nil,function()return t:back()end,function(panel)ui:label(panel,'Powrót działa dla tej samej żywej postaci i zapamiętuje ostatni teleport.')end)
  local fight=ui:page('FIGHT')
  if not app.controller then local f=ui:card(fight,'Fight — MM2','Funkcje walki są dostępne w trybie Murder Mystery 2.');ui:label(f,'Dołącz do MM2, uruchom hub i wybierz MM2.');ui:button(f,'Wróć do wyboru gry',function()app:unload();_G.KubiHubRuntime=M.Launcher.new()end) end
 end
end
