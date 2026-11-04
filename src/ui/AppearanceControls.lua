return function(M)
 return function(app,page,withHitbox)
  local ui=app.ui;local a=app.avatar;local body=ui:card(page,'Wygląd postaci — lokalnie','Efekty widoczne u Ciebie. Nie nadają własności przedmiotów ani zakupów na konto.')
  local function toggle(key)return function()return a:set(key,not a.enabled[key])end end
  ui:feature(body,'Fake Headless',function()return a.enabled.headless end,toggle('headless'),function(panel)
   ui:label(panel,'Ukrywa głowę i twarz lokalnie. Nie usuwa głowy, szyi ani zdrowia.')
   ui:toggle(panel,'Ukryj też dodatki głowy',function()return a.settings.hideHats end,function(v)return a:option('hideHats',v)end)
  end)
  ui:feature(body,'Fake Korblox — noga',function()return a.enabled.korblox end,toggle('korblox'),function(panel)ui:label(panel,'Lokalna noga w stylu Korblox, z prostych kształtów. Obsługuje R6 / R15. Oryginalna noga i połączenia pozostają. To nie jest płatny przedmiot.')end)
  ui:feature(body,'Mały skin',function()return a.enabled.mini end,toggle('mini'),function(panel)
   ui:field(panel,'Rozmiar: 0.35–1',a.settings.scale,function(v)local ok,err=a:option('scale',tonumber(v));if not ok then return false,err end;return a.settings.scale end,false,function()return a.settings.scale end)
   ui:label(panel,'Zmniejsza własny model lokalnie. Gra może przywrócić swój rozmiar. Wyłącz farmę i Fly przed zmianą.')
  end)
  if withHitbox then ui:feature(body,'Mniejszy hitbox — lokalnie',function()return a.enabled.hitbox end,toggle('hitbox'),function(panel)
   ui:field(panel,'Współczynnik korzenia: 0.3–1',a.settings.rootFactor,function(v)local ok,err=a:option('rootFactor',tonumber(v));if not ok then return false,err end;return a.settings.rootFactor end,false,function()return a.settings.rootFactor end)
   ui:label(panel,'Zmienia tylko lokalny HumanoidRootPart. Nie potwierdza zmniejszenia serwerowego obszaru trafień i nie daje odporności na obrażenia.')
  end)end
  ui:button(body,'Przywróć wygląd i rozmiar',function()if app.runtime.lock then return false,'Najpierw zatrzymaj moduł '..app.runtime.lock end;a:reset();ui:refreshFeatures();return true end)
  return body
 end
end
