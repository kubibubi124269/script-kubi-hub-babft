local Util = {}
function Util.finite(v) return type(v)=='number' and v==v and math.abs(v)<math.huge end
function Util.number(v,default,lo,hi,integer)
 if not Util.finite(v) then return default end
 local n=math.max(lo,math.min(hi,v));return integer and math.floor(n+.5) or n
end
function Util.copy(v,depth)
 if type(v)~='table' then return v end
 assert((depth or 0)<24,'Data nesting exceeds 24 levels')
 local out={};for k,x in pairs(v) do out[k]=Util.copy(x,(depth or 0)+1) end;return out
end
function Util.vector(v,limit)
 if type(v)~='table' or #v~=3 then return false end
 for i=1,3 do if not Util.finite(v[i]) or math.abs(v[i])>(limit or 100000) then return false end end
 return true
end
function Util.id(v) return type(v)=='string' and #v>0 and #v<=80 and v:match('^[%w_%-%.]+$')~=nil end
function Util.keys(t) local out={};for k in pairs(t) do out[#out+1]=k end;table.sort(out);return out end
function Util.semver(v)
 if type(v)~='string' then return nil end
 local a,b,c=v:match('^(%d+)%.(%d+)%.(%d+)$');if not a then return nil end
 return {tonumber(a),tonumber(b),tonumber(c)}
end
function Util.newer(a,b)
 local x,y=Util.semver(a),Util.semver(b);if not x or not y then return false end
 for i=1,3 do if x[i]~=y[i] then return x[i]>y[i] end end;return false
end
function Util.matrix(r)
 local x,y,z=math.rad(r[1]),math.rad(r[2]),math.rad(r[3]);local a,b,c,d,e,f=math.sin(x),math.cos(x),math.sin(y),math.cos(y),math.sin(z),math.cos(z)
 return {d*f,-d*e,c,b*e+a*c*f,b*f-a*c*e,-a*d,a*e-b*c*f,a*f+b*c*e,b*d}
end
function Util.rotate(v,r)
 local m=Util.matrix(r);return {m[1]*v[1]+m[2]*v[2]+m[3]*v[3],m[4]*v[1]+m[5]*v[2]+m[6]*v[3],m[7]*v[1]+m[8]*v[2]+m[9]*v[3]}
end
function Util.yawRotation(rotation,yaw)
 local m=Util.matrix(rotation);local a=math.rad(yaw);local c,s=math.cos(a),math.sin(a)
 local out={c*m[1]+s*m[7],c*m[2]+s*m[8],c*m[3]+s*m[9],m[4],m[5],m[6],-s*m[1]+c*m[7],-s*m[2]+c*m[8],-s*m[3]+c*m[9]}
 local y=math.asin(math.clamp(out[3],-1,1));local x,z
 if math.abs(math.cos(y))>1e-7 then x=math.atan2(-out[6],out[9]);z=math.atan2(-out[2],out[1])
 else x=math.atan2((out[3]>=0 and 1 or -1)*out[4],out[5]);z=0 end
 return {math.deg(x),math.deg(y),math.deg(z)}
end
return Util
