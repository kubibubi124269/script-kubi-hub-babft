return function(Util)
 local Runtime={};Runtime.__index=Runtime
 function Runtime.new(clock,onError)
  return setmetatable({clock=clock,errors=onError,alive=true,connections={},objects={},jobs={},schedules={},lock=nil,serial=0},Runtime)
 end
 function Runtime:connect(signal,fn,module)
  local c=signal:Connect(function(...)if not self.alive then return end;local args=table.pack(...);local ok,err=xpcall(function()fn(table.unpack(args,1,args.n))end,function(e)return tostring(e)end);if not ok then self.errors(module or 'Event',err) end end)
  self.connections[#self.connections+1]=c;return c
 end
 function Runtime:own(object)self.objects[#self.objects+1]=object;return object end
 function Runtime:disconnect(c)
  c:Disconnect();for i=#self.connections,1,-1 do if self.connections[i]==c then table.remove(self.connections,i);break end end
 end
 function Runtime:acquire(owner)
  if not self.alive then return false,'Runtime closed' end
  if self.lock and self.lock~=owner then return false,'Aktywny moduł: '..self.lock end
  for _,j in pairs(self.jobs) do if not j.done and j.owner~=owner then return false,'Trwa kończenie zadania '..j.owner end end
  self.lock=owner;return true
 end
 function Runtime:release(owner)if self.lock==owner then self.lock=nil end end
 function Runtime:job(owner,fn,spawn)
  self.serial=self.serial+1;local j={id=self.serial,owner=owner,done=false,cancelled=false,started=self.clock()};self.jobs[j.id]=j
  spawn(function()
   local ok,result=xpcall(function()return fn(j)end,function(e)return tostring(e)end)
   j.ok=ok;j.result=result;j.done=true;j.finished=self.clock()
   if not ok and self.alive then self.errors(owner,result) end
   self.jobs[j.id]=nil
  end)
  return j
 end
 function Runtime:schedule(name,interval,fn)self.schedules[name]={interval=interval,last=-math.huge,fn=fn} end
 function Runtime:tick(dt)
  if not self.alive then return end
  local now=self.clock()
  for name,s in pairs(self.schedules) do if now-s.last>=s.interval then s.last=now;local ok,err=xpcall(function()s.fn(dt,now)end,function(e)return tostring(e)end);if not ok then self.errors(name,err);self.schedules[name]=nil end end end
 end
 function Runtime:counts()
  local n,c,s=0,0,0;for _ in pairs(self.jobs) do n=n+1 end;for _,v in ipairs(self.connections) do if v.Connected~=false then c=c+1 end end;for _ in pairs(self.schedules) do s=s+1 end
  return {jobs=n,connections=c,schedules=s}
 end
 function Runtime:close()
  if not self.alive then return end;self.alive=false;self.lock=nil;self.schedules={}
  for _,j in pairs(self.jobs) do j.cancelled=true end
  for _,c in ipairs(self.connections) do local ok,err=pcall(function()c:Disconnect()end);if not ok then self.errors('Cleanup',tostring(err)) end end;self.connections={}
  for i=#self.objects,1,-1 do local ok,err=pcall(function()self.objects[i]:Destroy()end);if not ok then self.errors('Cleanup',tostring(err)) end end;self.objects={}
 end
 return Runtime
end
