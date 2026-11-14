return function(M)
 local P={}
 function P.storage(userId,mode,api)
  local id=tostring(userId)
  assert(id:match('^%-?%d+$') and M.Games.items[mode],'Invalid configuration scope')
  local scope=id..'_'..mode
  _G.KubiHubAccountProfiles=_G.KubiHubAccountProfiles or {}
  local memory=_G.KubiHubAccountProfiles[scope] or {};_G.KubiHubAccountProfiles[scope]=memory
  local base='KubiHubProfiles';local folder=base..'/'..scope
  local disk=api and pcall(function()
   if not api.isfolder(base) then api.makefolder(base)end
   if not api.isfolder(folder) then api.makefolder(folder)end
  end)
  local function path(name,suffix)
   assert(M.Config.profileName(name),'Invalid profile name')
   return folder..'/'..name:lower()..suffix
  end
  local function read(file)
   if not disk or not api.isfile(file) then return nil end
   return api.read(file)
  end
  return {
   label=disk and 'Pliki na tym urządzeniu' or 'Pamięć bieżącej sesji',
   read=function(name)local file=path(name,'.json');local row=memory[name:lower()];return disk and read(file) or row and row.text end,
   backup=function(name)local file=path(name,'.backup.json');local row=memory[name:lower()];return disk and read(file) or row and row.backup end,
   write=function(name,text)
    local file=path(name,'.json');local key=name:lower()
    if disk then
     local previous=read(file);if previous and #previous<=65536 then api.write(path(name,'.backup.json'),previous)end
     api.write(file,text)
    end
    local old=memory[key];memory[key]={text=text,backup=old and old.text}
   end,
   last=function()
    if disk then local ok,value=pcall(read,folder..'/last-profile.txt');if ok and M.Config.profileName(value) then return value end end
    return memory.lastName
   end,
   remember=function(name)
    if not M.Config.profileName(name) then return end
    memory.lastName=name;if disk then pcall(api.write,folder..'/last-profile.txt',name)end
   end,
  }
 end
 function P.init(app,mode)
  local api
  if type(readfile)=='function' and type(writefile)=='function' and type(isfile)=='function' and type(isfolder)=='function' and type(makefolder)=='function' then
   api={read=readfile,write=writefile,isfile=isfile,isfolder=isfolder,makefolder=makefolder}
  end
  local storage=P.storage(app.player.UserId,mode,api);app.storage=storage
  local http=game:GetService('HttpService')
  local codec=app.codec or {encode=function(v)return http:JSONEncode(v)end,decode=function(s)return http:JSONDecode(s)end}
  app.config=M.Config.new(codec,storage,app.log)
  local last=storage.last()
  app.accountProfile=last or 'default'
  if last then app.loadedProfile=app.config:load(last)end
 end
 function P.page(app)
  local ui=app.ui
  local card=ui:card(ui:page('SETTINGS'),'Konfiguracje konta')
  ui:label(card,app.storage.label)
  app.profileName=ui:field(card,'Nazwa profilu',app.accountProfile)
  function app:saveProfile()
   if app.captureProfile then app:captureProfile()end
   local name=app.profileName.Text;local ok,err=app.config:save(name);if not ok then return false,err end
   app.accountProfile=name;app.storage.remember(name);ui:toast('Config','Zapisano profil.');return true
  end
  function app:loadProfile()
   local name=app.profileName.Text;local ok,err=app.config:load(name);if not ok then return false,err end
   app.accountProfile=name;app.storage.remember(name)
   if app.applyConfig then return app:applyConfig()end
   app:stopAll()
   if app.restoreProfile then app:restoreProfile()end
   if app.movement then app.movement.settings=app.config.data.movement end
   ui:fit();ui:theme();ui:refreshControls();return true
  end
  ui:button(card,'Zapisz profil',function()return app:saveProfile()end)
  ui:button(card,'Wczytaj profil',function()return app:loadProfile()end)
  return card
 end
 return P
end
