require ('globals')

local sin,cos = math.sin, math.cos
local pi = math.pi


-- cycle_fmod (-0.2) -> 0.8
function cycle_fmod (x)
  local fmod = math.fmod
  return fmod((fmod(x,1) +1),1)
end


-- sine wave 
function sin_2pi_fn(x)
  local y = sin(x*2*pi) 
  return y
end

-- cosine wave 
function cos_fn(x)
  local y = cos(x*2*pi) 
  return y
end

-- saw wave
function saw_fn(x)
  local y =
  2*(x - math.floor(x + (1/2)))
  return y
end

-- Square wave (op:pulse width)
function square_fn(x)
  local x = cycle_fmod (x)
  local y = 0
  if  
    0 <= x and x<(1/2)  then y = 1 
  elseif
    (1/2) <= x and x < 1 then y = -1
      end
  return y
end


-- triangle wave
function triangle_fn(x)
  local x = cycle_fmod (x)
  local y=0
  if
    0 <= x and x <(1/4) then y = 4*x
    elseif
      (1/4)<= x and x < (3/4) then y = -4*x +2
      elseif
        (3/4)<= x and x <=1 then y = 4*x -4
        end
  return y
end
        
-- multiply 11/12
function multiply_11on12_fn(x)
  return 11/12
end

-- multiply 13/12
function multiply_13on12_fn(x)
  return 13/12
end

-- Fade in 7/8
function fade_in_7on8_fn(x)
  local y = (1/8)*x +(7/8) 
  return y
end

-- Fade out 7/8
function fade_out_7on8_fn(x)
  local y = (-1/8)*x +1
  return y
end


-- Quadratic curve,7/8 in center
function center_7on8_fn(x)
  local y = (1/2)*(x-(1/2))^2 +(7/8) 
  return y
end

-- Quadratic curve,9/8 in center
function center_9on8_fn(x)
  local y = -(1/2)*(x-(1/2))^2 +(9/8) 
  return y
end



--------------
-- Noise

-- White Noise
function white_noise_fn()
  local y = math.random()
  return 2*y -1
end

-- can use global variables:
-- random_seed, x_pre, x_next, brown_parameter,
-- If you use new variable, write it on 'glovals.lua'.

-- Brown noise
function brown_noise_fn()
  local r = (2*math.random() -1)
  *brown_parameter -- [-1,1] variable. default:1/6
  x_next = x_pre + r
  if x_next >1 then
    x_next = 1
  elseif x_next < -1 then
   x_next = -1
  end 
  x_pre = x_next
  return x_next
end


-- Violet Noise
function violet_noise_fn()
  local r = (2*math.random()-1)
  x_next = (r - x_pre)/2
  x_pre = r
  return x_next
end


-- Pink noise(not finished)
-- The Voss-McCartney algorithm:
-- http://www.firstpr.com.au/dsp/pink-noise/

function biased_noise ()
  local r, r1, r2 =  nil, math.random(), math.random()
  if r2 <= r1 then r = r1
  elseif r2 > r1 then r = (1- r1)
  end
  return r
end
  
function pink_noise_fn()
  local r = (2*math.random() -1)
  *(1/100) -- [-1,1] variable.
  local tmax = math.modf(biased_noise() *5)
  for t = 1,tmax+1 do
    x_next = x_pre + r
    x_pre = x_next
  end
  
  if x_next >1 then
    x_next = 1
  elseif x_next < -1 then
   x_next = -1
  end 
  return x_next
end


