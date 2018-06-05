require ('globals')
require ('waves')



function cycle_phase_mod (cycl,phs)
  return
  function (x)
    return cycl*x + phs
  end
end


-- return the function that return the selected sample data
copy_fn_fn =
function(rough)
  get_init_env()
  local cycle_fmod =
  function(x,val)
    local m 
    if val == nil then m =1 
    else m = val
    end    
    return math.fmod((math.fmod(x,m) +m),m)
  end
  local rgh = 1
  if rough == true then rgh = 0 end
  return 
  function (_x,ch)
    local x = cycle_fmod(_x)
    local xx = cycle_fmod(x*init_range,init_range+1)
    local x1 = math.floor(xx)  -- <= (init_range -1)
    local x2 = x1 +1
    if x2 >= init_range then x2 = x1 end -- near the last point
    local d = (xx - x1)*rgh
    return   
    init_buffer:sample_data(ch,
      x1
      + selection_start) *(1-d) +
    init_buffer:sample_data(ch,
      x2
      +selection_start) *d
    
  end
end


local duty_phase = function(x,dty)
  local d = dty/100
  local y =0
  if
    0<=x and x< d then y = (1/(2*d))*x 
    elseif
      d<=x and x<=1 then y=(1/(2*(1-d)))*(x-1)+1
      end
  return  y
end


local decay = function(x,min,max)
  local y= (max -min)*x +min
  return y
end


function cycle_phase_duty_mod (cycle,shift,duty_fiducal,duty_var,duty_var_frq)
  local cycle_phase_mod =
  function(cycl,phs)
    return
    function (x)
      return cycl*x + phs
    end
  end
  local cycle_fmod =
  function(x,val)
    local m 
    if val == nil then m =1 
    else m = val
    end
    return math.fmod((math.fmod(x,m) +m),m)
  end
  local duty_phase = function(x,dty)
    local d = dty/100
    local y =0
    if
    0<=x and x< d then y = (1/(2*d))*x 
    elseif
      d<=x and x<=1 then y=(1/(2*(1-d)))*(x-1)+1
      end
    return  y
  end
  return function(x)
    local xx =cycle_fmod(cycle_phase_mod (cycle,shift)(x))
    local xxx = duty_fiducal + duty_var*(1/2)*(-1*cos_fn(duty_var_frq*x)+1) 
    local y= duty_phase (xx,xxx)
    return y
  end
end


--------------------------
-- == Copy to table == --
--------------------------

-- Use with 'tbl2fn'
function wave2tbl()
  get_init_env()
  -- utility table for channel selecting
  local ch_util ={}
  -- In monoral,selected_channel is 3
  ch_util[1] = {0,0,{1,1}}
  -- stereo
  ch_util[2] = {{1,1},{2,2},{1,2}}
  local _ch=
  ch_util
  [init_number_of_channels][init_selected_channel]        
  local ch1,ch2 = _ch[1],_ch[2]    
  local tbl ={{},{}}  
  for i_ch = ch1,ch2 do
    for i =1,init_range  do
      tbl[i_ch][i]=
      init_buffer:sample_data(i_ch,
        i + selection_start -1)
    end
    -- add last point data for reference
    if math.abs(tbl[i_ch][init_range]) <= 2/32767 then
      tbl[i_ch][init_range +1] = 0
    else  
      tbl[i_ch][init_range +1]=tbl[i_ch][init_range]
    end
  end
 return tbl
end   

-- e.g.: make_wave(tbl2fn({{0,1,0,-1,0},{}})
function tbl2fn(wave_tbl)
  get_init_env()
  local cycle_fmod =
  function(x,val)
    local m 
    if val == nil then m =1 
    else m = val
    end
    return math.fmod((math.fmod(x,m) +m),m)
  end
  local another =
  function(num,a,b)
    if num == a then return b
    elseif num == b then return a
    else return nil
    end
  end
  local count_tbl = {}
  for i = 1,2 do
    count_tbl[i] = table.count(wave_tbl[i])
  end
  
  return 
  function (x,ch)
    local _ch = ch
    if _ch == nil then _ch = 1 end
    if count_tbl[_ch] == 0
    then _ch = another(_ch,1,2)
    end
    if count_tbl[_ch] == 0
    then return 0
    end
    local count = count_tbl[_ch]
    -- wave_tbl[_ch][count] is reference data for the last point.
    local xx = cycle_fmod(x*(count-1),count)
    local x1 = math.floor(xx) +1  -- first index is 1
    local x2 = x1 +1
    if x2 >= count then x2 = count end -- Near the last point
    local d = xx - (x1 -1)
    return   
    (wave_tbl[_ch][x1])
    *(1-d) +
    (wave_tbl[_ch][x2])*d
  end
end  


function mix_fn_fn(fn1,fn2,deg)
  local d = (1/2)
  if type(deg) == 'number' then d = deg end
  return
  function(x,ch)
    local y =
    fn1(x,ch)*d+
    fn2(x,ch)*(1-d)
    return y
  end
end


-- == appendix == --
-- Karplus-Strong string with options
function ks_copy_fn_fn(len,mix,amp_ini)
  get_init_env()
  local cycle =
  function(x)
    return math.fmod((math.fmod(x,1) +1),1)
  end
  
  local round =
  function(num, idp)
    if type(num)~='number' then return nil end
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
  end
  
  local min_max =
  function (min,max,x)
    if x > max then
      return max
    elseif x < min then
      return min
    else return x
    end
  end
  local abs = math.abs   
  local max_abs =
  function(t,m,n)
    if #t == 0  then return nil end   
    if tonumber(m) == nil then m=1 end
    local  value = abs(t[m])
    if n == nil or n >= #t
    then n = #t end   
    for i = m, n do
      if abs(value) < abs(t[i]) then
        value =  abs(t[i])
      end
    end
    return value
  end 
  
  if amp_ini ==nil then amp_ini =0 end
  local amp = 1+(amp_ini) 
  local _amp = amp    
  
    -- utility table for channel selecting
  local ch_util ={}
  -- In monoral,selected_channel is 3
  ch_util[1] = {0,0,{1,1}}
  -- stereo
  ch_util[2] = {{1,1},{2,2},{1,2}}
  local _ch=
  ch_util
  [init_number_of_channels][init_selected_channel]        
  local ch1,ch2 = _ch[1],_ch[2]    
  
  local dly =round(len)
  local tbl ={{},{}}
  
  for i_ch = ch1,ch2 do
    for i =0,init_range-1 do
      tbl[i_ch][i]=
      init_buffer:sample_data(i_ch,
        i + selection_start)
    end
  end     
  
  return 
  function (x,ch)
    local y_out      
    local x = cycle_fmod(x)
    local xx = min_max(0,init_range-1,round(init_range*x))
    if xx <= dly-1 then 
      y_out= tbl[ch][xx]  
    else
      local max_y = max_abs(tbl[ch],min_max(1,xx,xx-21),xx-1)
      if max_y < 0.78 
      then
        _amp = (_amp-1)*2+1
        if _amp>=amp then _amp =amp end
     elseif max_y >= 0.95
     then _amp = 1+((_amp-1)/2)
     end
      
      local y_out_1 =
      tbl[ch][xx-dly]*((1-mix)/2)*_amp +
      tbl[ch][min_max(0,init_range-1,xx-dly-1)]*((1-mix)/2)*_amp
      local y_out_2 =
      tbl[ch][xx]*(mix/2) + 
      tbl[ch][min_max(0,init_range-1,xx-1)]*(mix/2)
      y_out = y_out_1 + y_out_2
      if abs(y_out)>=1 then y_out = y_out_1/_amp + y_out_2 end
      tbl[ch][xx] = y_out
    end        
    return y_out
  end 
end

