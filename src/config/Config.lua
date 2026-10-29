return function(Util,Inventory)
 local Config={version=2}
 Config.defaults={schemaVersion=2,ui={theme='BLUE',width=960,height=650,x=.08,y=.08,compact=false,tooltips=true},farm={profile='NORMAL',retryLimit=2,stopAfter=0},builder={material='ORIGINAL',yaw=0,mirrorX=false,mirrorZ=false,previewLayer=0,scale=1,offsetX=0,offsetY=0,offsetZ=0},movement={walk=16,jump=50,flySpeed=40},performance={profile='BALANCED'},favorites={},language='PL'}
 function Config.profileName(name)
  if type(name)~='string' or #name<1 or #name>24 or not name:match('^[%a%d][%w_%-]*$') then return false end
  local n=name:upper();return n~='CON' and n~='PRN' and n~='AUX' and n~='NUL' and not n:match('^COM[1-9]$') and not n:match('^LPT[1-9]$')
 end
 local enum={theme={BLUE=true,PURPLE=true},profile={NORMAL=true,FAST=true,TURBO=true,HYPER=true,LIGHTNING=true,SONIC=true},performance={QUALITY=true,BALANCED=true,PERFORMANCE=true}}
 function Config.validate(raw)
  if type(raw)~='table' then return nil,{'Konfiguracja musi być obiektem JSON.'} end
  if raw.schemaVersion~=nil and raw.schemaVersion~=1 and raw.schemaVersion~=2 then return nil,{'Nieobsługiwana wersja konfiguracji.'} end
  local out=Util.copy(Config.defaults);local errors={}
  for _,group in ipairs({'ui','farm','builder','movement','performance','favorites'}) do if raw[group]~=nil and type(raw[group])~='table' then errors[#errors+1]=group..': wymagany obiekt ustawień' end end
  local function read(group,key)if type(raw[group])=='table' then return raw[group][key] end;return nil end
  local function number(group,key,lo,hi,integer)
   local v=read(group,key);if v~=nil then if not Util.finite(v) then errors[#errors+1]=group..'.'..key..': nieprawidłowa liczba' else out[group][key]=Util.number(v,out[group][key],lo,hi,integer) end end
  end
  for _,s in ipairs({{'ui','width',340,1200,true},{'ui','height',400,900,true},{'ui','x',0,.95},{'ui','y',0,.95},{'farm','retryLimit',0,3,true},{'farm','stopAfter',0,10000,true},{'builder','yaw',-360,360},{'builder','previewLayer',0,1000,true},{'movement','walk',8,60},{'movement','jump',20,120},{'movement','flySpeed',10,100}}) do number(table.unpack(s)) end
  for _,s in ipairs({{'builder','scale',.1,2},{'builder','offsetX',-1000,1000},{'builder','offsetY',-1000,1000},{'builder','offsetZ',-1000,1000}}) do number(table.unpack(s)) end
  for _,s in ipairs({{'ui','compact'},{'ui','tooltips'},{'builder','mirrorX'},{'builder','mirrorZ'}}) do local v=read(s[1],s[2]);if v~=nil then if type(v)=='boolean' then out[s[1]][s[2]]=v else errors[#errors+1]=table.concat(s,'.')..': wymagany boolean' end end end
  for _,s in ipairs({{'ui','theme','theme'},{'farm','profile','profile'},{'performance','profile','performance'}}) do local v=read(s[1],s[2]);if v~=nil then if type(v)=='string' and enum[s[3]][v] then out[s[1]][s[2]]=v else errors[#errors+1]=s[1]..'.'..s[2]..': nieznany profil' end end end
  if raw.builder and type(raw.builder)=='table' and raw.builder.material~=nil then local m=raw.builder.material;if m=='ORIGINAL' or type(m)=='string' and Inventory.definitions[m] and Inventory.definitions[m].volume then out.builder.material=m else errors[#errors+1]='Nieznany materiał konstrukcji.' end end
  if raw.favorites~=nil then if type(raw.favorites)~='table' then errors[#errors+1]='favorites: wymagany obiekt' else local n=0;for id,value in pairs(raw.favorites) do n=n+1;if n>200 or not Util.id(id) or type(value)~='boolean' then errors[#errors+1]='Nieprawidłowa lista ulubionych.';break end;out.favorites[id]=value end end end
  if raw.language~=nil then if raw.language=='PL' or raw.language=='EN' then out.language=raw.language else errors[#errors+1]='Nieznany język.' end end
  if #errors>0 then return nil,errors end
  return out,{}
 end
 function Config.new(codec,storage,log)
  local self={data=Util.copy(Config.defaults),previous=nil,codec=codec,storage=storage,log=log}
  function self:import(text)
   if type(text)~='string' or #text>65536 then return false,'Limit konfiguracji: 64 KB.' end
   local ok,raw=pcall(codec.decode,text);if not ok then return false,'Nieprawidłowy JSON konfiguracji.' end
   local value,errors=Config.validate(raw);if not value then return false,table.concat(errors,'; ') end
   self.previous=Util.copy(self.data);self.data=value;return true
  end
  function self:export()return codec.encode(self.data)end
  function self:save(name)
   if not Config.profileName(name) then return false,'Nazwa profilu: litery, cyfry, myślnik; maks. 24 znaki.' end
   local valid,errors=Config.validate(self.data);if not valid then return false,table.concat(errors,'; ') end
   local text=self:export();local ok,err=pcall(function()storage.write(name,text)end)
   if not ok then log:error('Config',err);return false,tostring(err) end;log:add('Config','Zapisano profil '..name..' ('..storage.label..').');return true
  end
  function self:load(name)
   if not Config.profileName(name) then return false,'Nieprawidłowa nazwa profilu.' end
   local ok,text=pcall(storage.read,name);local good,err=false,'Brak poprawnego profilu '..name
   if ok and text then good,err=self:import(text) end
   if not good and storage.backup then local backed,backup=pcall(storage.backup,name);if backed and backup then good,err=self:import(backup);if good then log:add('Config','Przywrócono poprzednią kopię profilu '..name,'WARN') end end end
   if not good then log:error('Config',err) end;return good,err
  end
  function self:rollback()if not self.previous then return false,'Brak poprzedniej konfiguracji.' end;self.data,self.previous=self.previous,self.data;return true end
  function self:reset()self.previous=Util.copy(self.data);self.data=Util.copy(Config.defaults)end
  return self
 end
 return Config
end
