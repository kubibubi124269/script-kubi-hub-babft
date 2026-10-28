return function(Util)
 local Log={};Log.__index=Log
 function Log.new(stamp) return setmetatable({rows={},serial=0,stamp=stamp,limit=150},Log) end
 function Log:add(module,message,level,details,handled)
  self.serial=self.serial+1;local row={id=self.serial,time=self.stamp(),module=tostring(module),message=tostring(message):sub(1,1000),level=level or 'INFO',details=tostring(details or ''):sub(1,6000),handled=handled~=false}
  self.rows[#self.rows+1]=row;if #self.rows>self.limit then table.remove(self.rows,1) end;return row
 end
 function Log:error(module,err) return self:add(module,'Operacja nie powiodła się','ERROR',err,true) end
 function Log:clear()self.rows={}end
 function Log:text()
  local lines={'KUBI HUB ULTIMATE V5.0 — raport diagnostyczny'}
  for _,r in ipairs(self.rows) do lines[#lines+1]=string.format('[%s] %s / %s / handled=%s: %s%s',r.time,r.module,r.level,tostring(r.handled),r.message,r.details~='' and ('\n'..r.details) or '') end
  return table.concat(lines,'\n')
 end
 return Log
end
