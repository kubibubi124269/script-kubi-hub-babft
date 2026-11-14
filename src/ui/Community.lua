return function(M)
 local C={}
 C.links={{'Discord','Kopiuj Discord','https://discord.gg/qmWGb4Q9p'},{'YouTube','Kopiuj YouTube','https://www.youtube.com/@Kubi_Bubi1242'}}
 function C.copy(url)
  if type(setclipboard)~='function' then return false end
  return pcall(setclipboard,url)
 end
 function C.page(app)
  local ui=app.ui
  local card=ui:card(ui:page('SETTINGS'),'Społeczność KUBI HUB')
  ui:label(card,'Dołącz na Discordzie lub zasubskrybuj kanał na YouTube. Kod PRO znajdziesz u twórcy.')
  for _,row in ipairs(C.links)do
   local box=ui:field(card,row[1],row[3]);box.TextEditable=false
   ui:button(card,row[2],function()if C.copy(row[3]) then ui:toast('KUBI HUB','Skopiowano link.')else box:CaptureFocus()end end)
  end
  if app.needPro then
   app.proBody=card
   local key=ui:field(card,'Kod PRO','')
   ui:button(card,'Odblokuj PRO',function()
    local code=key.Text:gsub('%s','');key.Text=''
    if code~='6969' then return false,'Nieprawidłowy klucz.' end
    app.pro=true;ui:toast('PRO','Odblokowano funkcje społeczności.');return true
   end)
  end
  ui:button(card,'Wróć do wyboru huba',function()M.Launcher.back(app)end)
  ui:button(card,'Zmień język',function()app:unload();_G.KubiHubRuntime=M.Launcher.new()end)
 end
 return C
end
