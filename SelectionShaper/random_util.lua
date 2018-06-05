require('waves')
require('modulation')
require('make_wave')
require('band_limited_waves')
require('selection_with_upbeat')
require('globals')


-- rndm({{0,1,1},{100,1000}}) -> 0.2, 320, 0.3 ...
rndm =
function (tbl)
  local round =
  function(num, idp)
    if type(num)~='number' then return nil end
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
  end
  local cnt = #tbl
  local tp = math.random(cnt)
  local x1,x2,idp = tbl[tp][1],tbl[tp][2],tbl[tp][3]
  local y =
  (x2-x1)*math.random() + x1
  return round(y,idp)
end


-- wv: table

local rtn_rndm_wv =
function(wv)
  local s = rndm({{1,1},{2,4},{1,4},{1,4},{1,8}})
  if s == 1 then
    wv.form = 'sin'
  elseif s == 2 then
    wv.form = 'saw'
  elseif s == 3 then
    wv.form = 'square'
  elseif s == 4 then
    wv.form = 'triangle'
  elseif s == 5 then
    wv.form = 'white_noise'
  elseif s == 6 then
    wv.form = 'brown_noise'
  elseif s == 7 then
    wv.form = 'violet_noise'
  elseif s == 8 then
    get_init_env()
    wv.form = 'copy'
  end
  return wv
end

-- a:  the coefficient for long sample
-- cf. cycle_phase_duty_mod (cycle,shift,duty_fiducal,duty_var,duty_var_frq)
local rtn_rndm_mod =
function(wv,a)
  if a == nil then a = 1 end
  wv.cycle = rndm({{2,9},{1,8},{1,4}})*a
  wv.shift = rndm({{0,0},{-1,1,2}})
  wv.duty =
  rndm({{50,50},{1,99},{50,52,1},{48,50,1},{10,90}})
  wv.duty_v = 
  rndm({{0,0},{0,0},{-0.5,0.5,1},{-1,1,2},{0,10,2},{10,100}})
  wv.duty_v_f =
  rndm({{1,1},{-8,8},{-2000,2000}})
  local torf =
  function(x) if x<=0 then return false else return true end end
  wv.band_limited =
  torf(rndm({{1,1}}))
  wv.duty_onoff =
  torf(rndm({{0,0},{0,0},{0,0},{0,0},{1,1}}))
  return wv
end

local rtn_rndm_mod_for_copy =
function(wv)
  wv.cycle = rndm({{1,4},{0.5,0.5},{0.5,0.5}})
  wv.shift = rndm({{0,0}})
  wv.duty =
  rndm({{50,50},{50,50},{50,52,1},{48,50,1},{10,90}})
  wv.duty_v = 
  rndm({{0,0},{0,0},{0,0},{-0.5,0.5,1},{-1,1,2},{0,10,2},{10,100}})
  wv.duty_v_f =
  rndm({{1,1},{-8,8},{-2000,2000}})
  -- torf(x) returns true or false
  local torf =
  function(x) if x<=0 then return false else return true end end
  wv.band_limited =
  torf(rndm({{1,1}}))
  wv.duty_onoff =
  torf(rndm({{0,0},{1,1},{1,1}}))
  return wv
end

-- a:  the coefficient for long sample
local rtn_rndm_fn_fn =
function(wv,a,duty_off)
  if a == nil then a = 1 end
  wv =rtn_rndm_mod(wv,a)
  if duty_off == true then wv.duty_onoff = false end
  wv = rtn_rndm_wv(wv)
  local _fn,_mod =
  wave_fn_fn(wv.form,wv.cycle,wv.shift,wv.duty_onoff,
  wv.duty,wv.duty_v,wv.duty_v_f,wv.band_limited)
  if type(_mod) == 'function' then 
  return function(x) return _fn(_mod(x)) end  
  else
  return _fn,wv
  end
end

local rtn_rndm_copy_fn_fn =
function(wv)
  wv =rtn_rndm_mod_for_copy(wv)
  wv.form = 'copy'
  local _fn,_mod =
  wave_fn_fn(wv.form,wv.cycle,wv.shift,wv.duty_onoff,
  wv.duty,wv.duty_v,wv.duty_v_f,wv.band_limited)
  if type(_mod) == 'function' then 
  return function(x) return _fn(_mod(x)) end  
  else
  return _fn,wv
  end
end

function rndm_wv()
  get_init_env()
  -- a: the coefficient for long sample
  local a = round(init_range/167)
  if a  < 5 then a = 1 end
  local fn = rtn_rndm_fn_fn({},a,false) 
  for i= 1,5 do
    fn = mix_fn_fn(fn,rtn_rndm_fn_fn({},a,false),math.random())
  end
  
  local wv_last = rtn_rndm_wv{}
  local fn_last = 
  wave_fn_fn(wv_last.form,a*rndm({{1,2},{1,4},{8,8},{16,16}}),0,false,50,0,1,true)
  fn = mix_fn_fn(fn,fn_last,math.random()*0.9+0.1) 
  make_wave(fn)
  
  if math.random()<0.1 then
    local max = math.random(3)
   for i = 1,max do
     fn = rtn_rndm_copy_fn_fn{}
     make_wave(fn)
   end
  end
end

