local round =
function(num, idp)
  if type(num)~='number' then return nil end
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


--  String to semitone. 'C#4678' -> c # 4 -> 49
local  str2st=
function(str)
  if type(str) ~= 'string' then return nil end
  local note ={
    'c','c#','d','d#','e','f',
    'f#','g','g#','a','a#','b'}
  local st_tbl ={}
  for i=1,12 do
    st_tbl[note[i]]=i-1
  end
  local x,y,z =  
  string.match(str,'([abcdefgABCDEFG])([#]?)[-]?(%d)')
  if x==nil or z==nil then return nil end
  if y==nil then y = "" end
  local st1 = st_tbl[string.lower(tostring(x)..tostring(y))]
  if st1==nil then return nil end
  local st = st1 + 12*tonumber(z)
  return st
end

-- Semitone-number to wavenumber. C-4:48 -> 169
local st2wvnum =
function(st,hz_ini)
  if type(st) ~= 'number' then return nil end
  if hz_ini==nil then hz_ini=440 end
  local rate =
  renoise.song().selected_sample.sample_buffer.sample_rate
  local wvnum =
  round(((1/2)^((st-57)/12))*(rate/hz_ini))
  return wvnum
end

-- C-4: 48 -> 261.6
local st2hznum =
function(st,hz_ini)
  if type(st) ~= 'number' then return nil end
  if hz_ini==nil then hz_ini=440 end
  local hz =
  round((2^((st-57)/12))*hz_ini,1)
  return hz
end  

-- for indicating number in vb valuebox 
vb_tonumber =
function(x)
  local num
    local x_str = 'return '..x
  if pcall(loadstring(x_str))==false
    or
    loadstring(x_str)()==nil
  then  return nil
  else num=loadstring(x_str)()
  end
  return tonumber(num)
end


str2wvnum =
function(str,ini_hz)
  if ini_hz==nil then ini_hz=440 end
  local st = str2st(str)
  if st == nil then return vb_tonumber(str)
  else return st2wvnum(st,ini_hz)
  end
end

str2hznum =
function(str,ini_hz)
  if ini_hz==nil then ini_hz=440 end
  local st = str2st(str)
  if st == nil then return vb_tonumber(str)
  else return st2hznum(st,ini_hz)
  end
end


ini2wvnum =
function(ini,ini_hz)
  local tp = type(ini)
  if tp=='number' then
    return ini
  elseif tp=='string' then 
    return str2wvnum(ini,ini_hz)
  else return nil
  end
end
  
ini2hznum =
function(ini,ini_hz)
  local tp = type(ini)
  if tp=='number' then
    return ini
  elseif tp=='string' then 
    return str2hznum(ini,ini_hz)
  else return nil
  end
end


ini2num =
function(ini)
  local tp = type(ini)
  if tp=='number' then
    return ini
  elseif tp=='string' then 
    return vb_tonumber(ini)
  else return nil
  end
end  
