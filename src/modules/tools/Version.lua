return function(Util)
 local Version={current='5.0.0',url='https://raw.githubusercontent.com/kubibubi124269/script-kubi-hub-babft/main/version.json'}
 function Version.validate(raw)
  if type(raw)~='table' or not Util.semver(raw.version) or type(raw.releaseDate)~='string' or not raw.releaseDate:match('^%d%d%d%d%-%d%d%-%d%d$') then return nil,'Nieprawidłowe informacje o wersji.' end
  if type(raw.changes)~='table' or #raw.changes>30 then return nil,'Nieprawidłowa lista zmian.' end
  for _,line in ipairs(raw.changes) do if type(line)~='string' or #line>300 then return nil,'Nieprawidłowy opis zmiany.' end end
  return {version=raw.version,releaseDate=raw.releaseDate,changes=Util.copy(raw.changes),compatibility=tostring(raw.compatibility or 'Brak opisu'):sub(1,500),update=Util.newer(raw.version,Version.current)}
 end
 function Version.fetch(get,decode)
  local ok,text=pcall(get,Version.url);if not ok or type(text)~='string' or #text>20000 then return nil,'Nie udało się odczytać version.json. Hub działa dalej.' end
  local parsed,raw=pcall(decode,text);if not parsed then return nil,'version.json nie jest poprawnym JSON.' end
  return Version.validate(raw)
 end
 return Version
end
