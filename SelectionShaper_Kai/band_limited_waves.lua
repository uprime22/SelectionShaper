require('globals')
require('modulation')
require('selection_with_upbeat')

local pi = math.pi
local sin = math.sin

local duty_shape =
function(duty,m)
  -- d/50 :integer*(1/m)
  local d = round((duty/50)*m)/m*50
  if d< (1/m)*50 then d = (1/m)*50
  elseif d > 100 then d =100
  end  
  return d
end

local duty_phase =
function(x,dty)
  local d = dty/100
  local y =0
  if
    0<=x and x< d then y = (1/(2*d))*x 
  elseif
    d<=x and x<=1 then y=(1/(2*(1-d)))*(x-1)+1 
  end
  return  y
end

local partition_duty_mod =
function(cycle,shift,duty_fiducal,duty_var,duty_var_frq)
  local floor = math.floor
  local fmod = math.fmod
  local cos =
  function(x)
    return math.cos(2*pi*x)
  end
  get_init_env()
  local rng = init_range
  return 
  function(x)
    local xx = cycle*x + (shift)
    local xxx = 
    duty_fiducal 
    + duty_var*(1/2)*(-1*cos(duty_var_frq*x)+1)
    xxx = duty_shape(xxx,rng)
    local y= (floor(xx)  + 
          duty_phase(fmod(xx,1),xxx))/cycle 
    return y
  end
end



--------------------------
-- == BLITs == --

local sinc_m_fn_fn = 
function(m)
  local pi = math.pi
  local sin = math.sin
  local cos = math.cos
  if m == nil then m =1 end
  return
  function(x)
    local xx = sin(pi * x / m)
    local y
    if math.abs(xx) <= 1e-12  then
      y = cos(pi*x)/cos(pi*x/m) 
    else
      y= sin(pi * x) / (m * xx) 
    end
    return
    y    
  end
end

local blit_m_p_tbl =
function(m,p)
--  get_init_env()
  local sincm = sinc_m_fn_fn(m)
  local rng =init_range
  local tbl ={{},{}}
  for i = 1,rng+1 do
  tbl[1][i] =(m/p)*sincm((i-1)*(m/p))
  end
  return tbl
end

local max_odd =
function(num)
 local y
 local n = math.floor(num)
 if math.fmod(n,2) == 1
 then y = n
 else y = n -1
 end
 return y
end

local max_even =
function(num)
 local y
 local n = math.floor(num)
 if math.fmod(n,2) == 1
 then y = n -1
 else y = n
 end
 return y
end


--y(n+1) = y(n) + sin( PI * M / P * n) / (sin(PI / P * n) * P) - 1/P  
local blit_saw_tbl =
function(p,shift,a)
  if a == nil then a =1 end
--  get_init_env()
  local rng =init_range
  p= p*a ; rng = rng*a
  if shift==nil then shift =0 end
  local sft = math.floor(p*cycle_fmod(shift+0.5))    
  local m = max_odd(p/2)
  if m<=3 then m =3 end  
  local sincm = sinc_m_fn_fn(m)
  local tbl_pre ={}
  local tbl ={{},{}}
  local y,y_pre =0,(m/p/2)
  local d = 1/p
  local m_p = m/p
  for i = 1,round(rng+1+sft) do  
    y = (y_pre -(m_p)*sincm((i-1)*(m/p)) +d)
    tbl_pre[i]=y *(1/m_p*0.58)
    y_pre = y
  end
  for j = 1,round(rng+1) do
    tbl[1][j]= tbl_pre[j+sft]
  end
  return tbl
end  
  
local blit_square_tbl =
function(p,shift,a)
  if a == nil then a =1 end
--  get_init_env() 
  local rng =init_range 
  p= p*a ; rng = rng*a   
  if shift==nil then shift =0 end
  local sft = math.floor(p*cycle_fmod(shift))
  local p = p/2        
  local m =  max_even(p/2)
  if m<=2 then m =2 end
  local sincm = sinc_m_fn_fn(m)
  local tbl_pre ={}
  local tbl ={{},{}}
  local y,y_pre =0,-(m/p/2)
  local m_p = m/p
  for i = 1,round(rng+1+sft) do  
  y = (y_pre +(m_p)*sincm((i-1)*(m/p)) )
  tbl_pre[i]=y *(1/m_p*0.58)
  y_pre = y
  end
  for j = 1,round(rng+1) do
    tbl[1][j]= tbl_pre[j+sft]
  end  
  return tbl
end  


local blit_triangle_tbl =
function (p,shift,a)
  if a == nil then a =1 end
  get_init_env()
  local rng =init_range  
  p= p*a ; rng = rng*a  
  if shift==nil then shift =0 end
  local sft = math.floor(p*cycle_fmod(shift+0.25))
  local pp = p/2        
  local m =  max_even(pp/2)
  if m<=2 then m =2 end  
  local sincm = sinc_m_fn_fn(m)
  local square = {}
  local tbl_pre ={}
  local tbl ={{},{}}
  local m_pp = m/pp  
  local y,y_pre =0,-(m_pp/2)
  local yy,yy_pre = 0,-(m_pp/2)
  for i = 1,round(rng+1+sft) do  
    y = (y_pre +(m_pp)*sincm((i-1)*(m/pp)) )
    square[i]=y 
    y_pre = y
  end      
  for j = 1,round(rng+1+sft) do 
    yy= yy_pre + square[j]/pp
    tbl_pre[j] = yy*(1/(m_pp/2)*0.8)
    yy_pre = yy
  end
  for k = 1,round(rng+1) do
    tbl[1][k]= tbl_pre[k+sft]
  end  
  return tbl 
end   
    
local blit_duty_fn_fn =
function(form,p,duty)
--  get_init_env()
  local rng = init_range
--  print("duty: "..duty)
  local form_f = blit_square_tbl
  if form =='saw' then form_f = blit_saw_tbl
  elseif form =='square' then form_f = blit_square_tbl
  elseif form =='triangle' then form_f = blit_triangle_tbl
  end
  
  duty = duty_shape(duty,rng)
  local half =duty_shape(50,rng) 
  local a1,a2  
  a1 = (duty/50) ;a2 = 2 - a1
  local fn_1,fn_2,m_1,m_2
  fn_1 = tbl2fn(form_f(p,0,a1))
  fn_2 = tbl2fn(form_f(p,0,a2))
  return 
  function(x)
    local xx = math.fmod(x,(p/rng))/(p/rng)
    local out
    if xx < (0.5) then out = fn_1(x,1)
    elseif xx >=(0.5) then out = fn_2(x,1)
    else out = 0
    end
    return out
  end 
end

local maximize_fn_fn =
function (fn,m,a)
  if a == nil then a = 1 end
  local abs = math.abs
  local max = 1/32767
  for i = 1,m do
    local y = abs(fn((i-1)/m))
    if y >= max then max = y end
  end
  local aa = 1/max
  return
  function (x)
    return aa*a* fn(x)
  end
end

function band_limited_fn_fn
(form,cycle,shift,duty_onoff,duty_fiducal,duty_var,duty_var_frq)
  if duty_onoff == false then
    duty_fiducal,duty_var,duty_var_frq = 50,0,1
  end
  local fn,mod_fn
  if form == "sin" then
    fn = function(x) return sin(x*2*pi) end
    mod_fn =
    cycle_phase_duty_mod (cycle,shift,
         duty_fiducal,duty_var,duty_var_frq)
    return fn,mod_fn
  end
  get_init_env()
  local rng = init_range
  local tbl ={{},{}}
  local _fn,_mod_fn
  _fn = 
  blit_duty_fn_fn(form,rng/cycle,duty_fiducal)
  _mod_fn =
  partition_duty_mod(cycle,0,duty_fiducal,duty_var,duty_var_frq)
  fn = function(x) return _fn(_mod_fn(x)) end
  if shift ~= 0 then
    local p = math.floor(rng*shift/cycle)
    for i = 1,rng -p do
    tbl[1][i] = fn((i-1+p)/rng)
    end
    for j = rng-p+1,rng+1 do
    tbl[1][j] = fn((j-1+p-rng)/rng)
    end
    fn = tbl2fn(tbl)  
  end
  fn =  maximize_fn_fn(fn,rng,0.95)
  return
  fn,mod_fn
end  


-- Utility for changing modulate-function
function mod_fn_fn(cycle,shift,duty_onoff,
  duty,duty_var,duty_var_frq)
  local fn
  if duty_onoff == false
  then
    fn = cycle_phase_mod (cycle,shift)
  elseif duty_onoff == true
  then
      fn = cycle_phase_duty_mod (cycle,shift,
        duty,duty_var,duty_var_frq)
  else return nil 
  end
  return fn
end


-- change wave_fn & mod_fn
function wave_fn_fn(form,cycle,shift,duty_onoff,
  duty,duty_var,duty_var_frq,band_limited)
  local fn,mod
  mod = mod_fn_fn(
    cycle,shift,duty_onoff
    ,duty,duty_var,duty_var_frq)
  
  if form == 'white_noise' then fn = white_noise_fn return fn,nil
  elseif form == 'brown_noise' then fn = brown_noise_fn return fn,nil
  elseif form == 'violet_noise' then fn = violet_noise_fn return fn,nil
  elseif form == 'copy' then fn = copy_fn_fn()
  end
    
  if band_limited ~= true then
    if form =='sin' then fn = sin_2pi_fn
    elseif form =='saw' then fn = saw_fn
    elseif form =='square' then fn = square_fn
    elseif form =='triangle' then fn = triangle_fn
    end
  elseif band_limited == true then
    fn,mod =
    band_limited_fn_fn(form,cycle,shift,duty_onoff,
      duty,duty_var,duty_var_frq)
  end
  if type(mod) == 'function' then 
    return function(x) return fn(mod(x)) end  
  else
    return fn
  end
end

