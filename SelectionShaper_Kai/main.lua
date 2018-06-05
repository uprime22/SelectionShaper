require ('load_all')


function gui ()
  local vb = renoise.ViewBuilder()
  local ini =
  create_preset('preset')
  ini:load_from('preset.xml')

  local A4hz=ini.A4hz.value
  -- selection length default
  local get_x_frame = ini2wvnum(ini.get_x_frame.value,A4hz)
  local get_x_beat = ini2num(ini.get_x_beat.value)
  -- Multiplying range
  local multiply_setend = ini2num(ini.multiply_setend.value)
  
  -- Draw modulated wave
  local wave_fn,mod_fn = nil,nil
  -- mod_shift:[-1,1]
  local mod_cycle, mod_shift
  = ini2num(ini.mod_cycle.value),ini.mod_shift.value
  -- Duty cycle
  local mod_duty_onoff, mod_duty
  = ini.mod_duty_onoff.value, ini.mod_duty.value
  local mod_duty_var, mod_duty_var_frq
  = ini.mod_duty_var.value, ini.mod_duty_var_frq.value
  
  -- fade with modulated wave
  local mod_fade_fn = nil
  -- mod_fade_shift:[-1,1]
  local mod_fade_cycle,mod_fade_shift
  = ini2num(ini.mod_fade_cycle.value),ini.mod_fade_shift.value
  -- Duty cycle for phase-distortion copy
  local mod_pd_duty_onoff, mod_pd_duty
  = ini.mod_pd_duty_onoff.value, ini.mod_pd_duty.value
  local mod_pd_duty_var, mod_pd_duty_var_frq
  = ini.mod_pd_duty_var.value, ini.mod_pd_duty_var_frq.value
  -- Karplus-Strong string pulse length & dry-mix value
  local ks_len_var,ks_mix_var,ks_amp_var
  = ini2wvnum('C-4',A4hz),0,0

  -- Significant figure
  local sig = ini.sig.value

  -- flick_paste_check_value(global)
  flick_paste_check_value = ini.flick_paste_check_value.value

  -- Band limiting fundamental waves
  local band_limited = ini.band_limited.value

  -- Bitmap location table
  local btmp = bitmap_util()

  -- === Add new, Insert, Delete, help ===
  -- Add New button
  local addnew_bt=    
  vb:button
  {
    width = 80,
    text = " Add New ",
    tooltip =
    "Copy the selection range into new sample.",
    
    notifier =
    function()
      add_new()
    end,
  }
  -- Insert silence 
  local insert_bt =    
    vb:button
    { 
      width = 80,
      text = " Insert ",
      tooltip =
      "Insert silence, \nits length is same as the selection range.",
      
      notifier =
      function ()  
        sweep_ins()
      end,
    }
  -- delete the selection
  local del_bt=    
    vb:button
    {
      width = 80,
      text = " Delete ",
      tooltip =
      "Clear the selection range.",
      
      notifier = 
      function()
        sync_del()
      end,          
    }
  --help
  local help =
  vb:button
  {
    width = 6,
    text = ("?"),
    notifier = 
    function()
        renoise.app():show_message(
          [[For sample offset etc.,set the selection range
          and input some value measured in beats(or samples).
          If the total length protrudes from the original sample,
          this tool automatically inserts  silence.
          According to the length, this tries to change
          the sync value (when beatsync on).]])
    end
  }      
  
  -- === Reset the selection end point ===
  local setend_txt =
  vb:text
  {
    text = "selection length:"
  }
  
  --set end with frame
  local setend_frame_in =
  vb:row
  { 
    vb:textfield
    { 
      id = "set_end_val_frame",
      edit_mode = true,
      width = 160,
      text = tostring(ini.get_x_frame.value),
      tooltip = 
      [[Input the string or the number or the formula that represents
      the selection range.
      e.g.
      '168*4' , 'c#4' , '400*((1/2)^(7/12))'.
      ]], 
      
      notifier =
      function(x)
        local xx = str2wvnum(x,A4hz) 
        if xx == nil
        then
          renoise.app():show_error(
            [[Enter a number greater than zero,
            or a numerical formula.
            e.g.
            '162*8' , '400*1.4/4' , '400*((1/2)^(7/12))'              
            
            ]])
        else get_x_frame= xx
        end
      end
    },
    
    vb:text
    {
      text = "sample"
    },
    vb:button
    {
      width = 6,
      text = "Get",
      tooltip =
      "Get the length of the selection range ,measured in sample.",
      
      notifier = 
      function()
        get_init_env()
        if smpl_ok == false then return nil end
        local val = round(init_range,sig)
        vb.views.set_end_val_frame.text = tostring(val)
        get_x_frame = tonumber(val)
      end,
    },
  }
  
  local setend_frame_bt =
  vb:button
  {
    width = 80,
    text = " Set End ",
    tooltip =
    "Reset the selection end point.",
    
    notifier =
    function()
      set_end_point_with_frame (get_x_frame)
    end
  }
  
  -- set end with beat
  local setend_beat_in =
  vb:row
  { 
    vb:textfield
    { 
      id = "set_end_val_beat",
      edit_mode = true,
      width = 160,
      text = tostring(ini.get_x_beat.value),
      tooltip = 
      [[
      Input the number or the formula that represents
      the selection range. \n e.g.\n  '4.5' , '1/4' , '16*3/4'.
      ]], 
      
      notifier =
      function(x)
        local xx = vb_tonumber(x) 
        if xx == nil
        then
          renoise.app():show_error(
            [[Enter a number greater than zero,
            or a numerical formula.
            e.g.
            '2.5' , '1/4' , '(32-18)/3'  
            ]])
        else get_x_beat= xx
        end
      end
    },
    
    vb:text
    {
      text = "beat"
    },
    vb:button
    {
      width = 6,
      text = "Get",
      tooltip =
      "Get the length of the selection range ,measured in beats.",
      
      notifier = 
      function()
        get_init_env()
        if smpl_ok == false then return nil end        
        local val = round(selection2beat (),sig)
        vb.views.set_end_val_beat.text = tostring(val)
        get_x_beat = tonumber(val)
      end,
    },
  }
  
  local setend_beat_bt =
  vb:button
  {
    width = 80,
    text = " Set End ",
    tooltip =
    "Reset the selection end point.",
    
    notifier =
    function()
      set_end_point_with_beat (get_x_beat)
    end
  }
  
  -- Multiply the selection end point
  local multiply_setend =
  vb:row
  {
    vb:button
    {
      width = 35,
      text = " * ",
      tooltip =
      "Multiply the length of the selection range .",
      
      notifier = 
      function()
        get_init_env()
        if smpl_ok == false then return nil end
        local val = round(multiply_setend*init_range,0)
        set_end_point_with_frame (val)
      end,
    },
    vb:button
    {
      width = 35,
      text = " / ",
      tooltip =
      "Reset the length of the selection range with reciprocal number.",
      
      notifier = 
      function()
        get_init_env()
        if smpl_ok == false then return nil end
        local val = round((1/multiply_setend)*init_range,0)
        set_end_point_with_frame (val)
      end,
    },
    vb:textfield
    { 
      id = "multiply_setend",
      edit_mode = true,
      width = 80,
      text = tostring(ini.multiply_setend.value),
      tooltip = 
      [[
      Input the number or the formula by that
      the selection range is multiplied.
      e.g. '44800/200' , '(1/2)^(7/12)']] ,
      
      notifier =
      function(x)
        local xx = vb_tonumber(x) 
        if xx == nil
        then
          renoise.app():show_error(
            [[Enter a number that is greater than zero,
            or a numerical formula.
            e.g.
             '44100/168' ,'(1/2)^(7/12)' 
            ]])
        else multiply_setend = xx
        end
      end
    },
    

  }

  -- === Flick ===
  -- Flick the selection range rightward
  local flick_range=    
    vb:button
    {
      width = 80,
      bitmap = btmp.flick_range,
      text = " Flick forward ",
      tooltip =
      "Flick the selection range rightward.",
      
      notifier = 
      function()
        flick_range()
      end,          
    }
  
  -- Flick the selection range backward
  local flick_range_back=    
    vb:button
    {
      width = 80,
      bitmap = btmp.flick_range_back,
      text = " Flick back ",
      tooltip =
      "Flick the selection range leftward.",
      
      notifier = 
      function()
        flick_range_back()
      end,          
    }
  
  -- Set the range as loop
  local set_loop =    
    vb:button
    {
      width = 80,
      text = " Set loop ",
      tooltip =
      "Set the range as loop.",
      
      notifier = 
      function()
        set_loop()
      end,          
    }

  -- Paste + flick forward
  local flick_paste_txt =
  vb:text
  {
    text = " Add FlickPaste: "
  }
  local flick_paste_check  =
  vb:checkbox 
  {
    value = ini.flick_paste_check_value.value,
    tooltip =
    "When on, add flicking forward to Renoise default pasting.",
    notifier = 
    function(x)
      flick_paste_check_value = x
    end,         
  }
  
  -- === Making waves ====
  -- Draw sin wave 2pi
  local sin_2pi =    
  vb:button
  {
    width = 80,
    bitmap = btmp.sin_2pi,
    text = " Draw sin ",
    tooltip =
    "Draw sin wave.",
    
    notifier =
    function()
      wave_fn ,mod_fn =
      wave_fn_fn('sin',mod_cycle,mod_shift,mod_duty_onoff,
        mod_duty,mod_duty_var,mod_duty_var_frq,band_limited)
      make_wave(wave_fn,mod_fn)
    end,
  }
  
  -- saw wave
  local saw =    
  vb:button
  {
    width = 80,
    bitmap = btmp.saw,
    text = " Draw saw ",
    tooltip =
    "Draw saw wave.",
    
    notifier =
    function()
      wave_fn ,mod_fn =
      wave_fn_fn('saw',mod_cycle,mod_shift,mod_duty_onoff,
        mod_duty,mod_duty_var,mod_duty_var_frq,band_limited)
      make_wave(wave_fn,mod_fn)
    end,
  }
  
  -- square wave
  local square =    
  vb:button
  {
    width = 80,
    bitmap = btmp.square,
    text = " Draw square ",
    tooltip =
    "Draw square wave.",
    
    notifier =
    function()
      wave_fn ,mod_fn =
      wave_fn_fn('square',mod_cycle,mod_shift,mod_duty_onoff,
        mod_duty,mod_duty_var,mod_duty_var_frq,band_limited)
      make_wave(wave_fn,mod_fn)
    end,
  }
  
  -- triangle wave
  local triangle =    
  vb:button
  {
    width = 80,
    bitmap = btmp.triangle,
    text = " Draw triangle ",
    tooltip =
    "Draw triangle wave.",
    
    notifier =
    function()
      wave_fn ,mod_fn =
      wave_fn_fn('triangle',mod_cycle,mod_shift,mod_duty_onoff,
        mod_duty,mod_duty_var,mod_duty_var_frq,band_limited)
      make_wave(wave_fn,mod_fn)
    end,
  }

  -- Band limiting check box
  local band_limited_check =
  vb:row
  {
    vb:text
    {
      text = " Band limit:"
    },  
    vb:checkbox
    {
      id = 'band_limited',
      value = band_limited,
      notifier =
      function(x)       
        band_limited = x
      end    
      
    }  
  }
  -- Wave modulating values input
  local cycle_shift_set =
  vb:row
  {
    vb:text
    {
      text = "Cycle:"
    },
    -- Input cycle of the wave 
    vb:textfield
    {
      id = 'mod_cycle',
      edit_mode = true,
      width = 40,
      text = tostring(ini.mod_cycle.value),
      tooltip = 
      [[
      Input the number or the formula that
      represet the cycle of the wave.
      1 means 1cycle.
      e.g. '1/2' , '44100/168']] ,
      
      notifier =
      function(x)
        local xx = vb_tonumber(x)
        if xx == nil
        then
          renoise.app():show_error(
            [[Enter a number 
            or a numerical formula.
            1 means 1cycle
            e.g.
            '1/4' , '44100/168' 
            ]])
        else
          mod_cycle = xx
        end
      end
    },
    
    -- Input phase shift value of the wave
    vb:text
    {
      text = " Shift:"
    },
    vb:valuebox
    {
      id = 'mod_shift',
      value = mod_shift *100,
      min = -100,
      max = 100,
      tostring =
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,
      tooltip = 
      [[
      Input number or formula that
      represent the starting phase point of the wave.
      100% means 1cycle .
      ]] ,
      
      notifier =
      function(x)       
        mod_shift = x/100
      end
    },
    vb:text
    {
      text = "% "
    },    

    vb:button
    {
      width = 3,
      text = "Reset",
      tooltip =
      "Reset values.",
      
      notifier = 
      function()
        vb.views.mod_cycle.text = '1'
        vb.views.mod_shift.value= 0
      end,
    },
  }

  -- Duty cycle
  local duty_fiducial =
  vb:row
  {
    vb:text
    {
      text = " Duty cycle:"
    },  
    vb:checkbox
    {
      id = 'duty_onoff',
      value = mod_duty_onoff,
      notifier =
      function(x)       
        mod_duty_onoff = x
      end    
      
    },  
    -- Input duty cycle 
    vb:valuebox
    {
      id = 'duty_fiducial',
      value = mod_duty,
      min = 0,
      max = 100,
      tostring = 
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,
      tooltip = 
      [[
      Input duty cycle (fiducial value)
      ]],
      
      notifier =
      function(x)       
        mod_duty = tonumber(x)
      end
    },
    vb:text
    {
      text = "% "
    },
  }
  -- Duty Cycle variation in the range
  local duty_variation =
  vb:row
  {
    vb:text
    {
      text = " var:"
    },
    
    vb:valuebox
    {
      id = 'duty_variation',
      value = mod_duty_var,
      min = -100,
      max = 100,
      tostring = 
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,
      tooltip =
      [[
      Input duty cycle variation value.
      Duty cycle fluctuates between fiducial value
      and this value plus fiducial value with minus cosine curve.
      ]],
      notifier =
      function(x)       
        mod_duty_var = x
      end
    },
    vb:text
    {
      text = "% "
    },
    
    vb:text
    {
      text = " frq:"
    },
  
    vb:valuebox
    {
      id = 'duty_var_frq',
      value = mod_duty_var_frq,
      min = -10000,
      max = 10000,
      tostring = 
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,
      tooltip =
      [[
      Input duty variation frequency.
      Duty cycle fluctuates between fiducial value
      and variation value plus fiducial value with minus cosine curve.
      this frequency is used in this cosine curve. 
      ]],
      notifier =
      function(x)       
        mod_duty_var_frq = x
      end
    },
  }
  
  local reset_duty =
  vb:button
  {
    width = 3,
    text = "Reset",
    tooltip =
    "Reset values.",
    
    notifier = 
    function()
      vb.views.duty_fiducial.value
      = 50
      vb.views.duty_variation.value
      = 0
      vb.views.duty_var_frq.value
      = 1
    end,
  }
  
  -- == noises ==
  -- White noise
  local white_noise =    
  vb:button
  {
    width = 80,
    bitmap = btmp.white_noise,
    text = " White noise ",
    tooltip =
    "White noise",
    
    notifier =
    function()
      make_wave(white_noise_fn)
    end,
  }
  
  -- Brown noise
  local brown_noise =    
  vb:button
  {
    width = 80,
    bitmap = btmp.brown_noise,
    text = " Brown noise ",
    tooltip =
    "Brown noise",
    notifier =
    function()
      make_wave(brown_noise_fn)
    end,
  }
  
  -- Violet noise
  local violet_noise =    
  vb:button
  {
    width = 80,
    bitmap = btmp.violet_noise,
    text = " Violet noise ",
    tooltip =
    "Violet noise",
    notifier =
    function()
      make_wave(violet_noise_fn)
    end,
  }
  
  -- Pink noise ( Unfinished)
  local pink_noise =    
  vb:button
  {
    width = 80,
    text = " Pink noise ",
    tooltip =
    "Pink noise",
    notifier =
    function()
      make_wave(pink_noise_fn)
      random_seed = 0
    end,
  }
  
 -- === Phase shifting ===
  -- Phase shift 1/24 +
  local phase_shift_1on24_plus =    
  vb:button
  {
    width = 80,
    bitmap = btmp.phase_shift_1on24_plus,
    text = " PS +1/24 ",
    tooltip =
    "Phase shift +1/24",
    
    notifier =
    function()
      phase_shift_with_ratio (1/24)
    end,
  }
  
  -- Phase shift 1/24 +
  local phase_shift_1on24_minus =    
  vb:button
  {
    width = 80,
    bitmap = btmp.phase_shift_1on24_minus,
    text = " PS -1/24 ",
    tooltip =
    "Phase shift -1/24",
    
    notifier =
    function()
      phase_shift_with_ratio (-1/24)
    end,
  }
  
  --  Phase shift +1sample
  local phase_shift_fine_plus =    
  vb:button
  {
    width = 80,
    bitmap = btmp.phase_shift_fine_plus,
    text = " PS +1sample ",
    tooltip =
    "Phase shift +1sample",
    
    notifier =
    function()
      phase_shift_fine (1)
    end,
  }
  
  -- Phase shift -1sample
  local phase_shift_fine_minus =    
  vb:button
  {
    width = 80,
    bitmap = btmp.phase_shift_fine_minus,
    text = " PS -1sample ",
    tooltip =
    "Phase shift -1sample",
    
    notifier =
    function()
      phase_shift_fine (-1)
    end,
  }
  
 -- === Fading ===
  -- Fade center 7/8
  local fade_center_7on8 =    
  vb:button
  {
    width = 80,
    bitmap = btmp.fade_center_7on8,
    text = " Fade center ",
    tooltip =
    "Fade center 7/8.",
    
    notifier =
    function()
      set_fade(center_7on8_fn)
    end,
  }
  
  -- Amplify center 9/8
  local fade_center_9on8 =    
  vb:button
  {
    width = 80,
    bitmap = btmp.fade_center_9on8,
    text = " Amplify center ",
    tooltip =
    "Amplify center 9/8.",
    
    notifier =
    function()
      set_fade(center_9on8_fn)
    end,
  }
  
  -- Fade out 7/8
  local fade_out_7on8 =    
  vb:button
  {
    width = 80,
    bitmap = btmp.fade_out_7on8,
    text = " Fade out 7/8 ",
    tooltip =
    "Fade out 7/8.",
    
    notifier =
    function()
      set_fade(fade_out_7on8_fn)
    end,
  }
  
  -- Fade in 7/8
  local fade_in_7on8 =    
  vb:button
  {
    width = 80,
    bitmap = btmp.fade_in_7on8,
    text = " Fade in 7/8 ",
    tooltip =
    "Fade in 7/8.",
    
    notifier =
    function()
      set_fade(fade_in_7on8_fn)
    end,
  }
  

  -- Multiply 11/12
  local multiply_11on12 =    
  vb:button
  {
    width = 80,
    bitmap = btmp.multiply_11on12,
    text = " Multiply 11/12 ",
    tooltip =
    " multiply 11/12.",
    
    notifier =
    function()
      set_fade(multiply_11on12_fn)
    end,
  }
  
  --  multiply 13/12
  local multiply_13on12 =    
  vb:button
  {
    width = 80,
    bitmap = btmp.multiply_13on12,
    text = " Multiply 13/12 ",
    tooltip =
    " multiply 13/12.",
    
    notifier =
    function()
      set_fade(multiply_13on12_fn)
    end,
  }


  --Fade with sin wave
  local ring_mod_sin =    
  vb:button
  {
    width = 80,
    bitmap = btmp.ring_mod_sin,
    text = " RM sin ",
    tooltip =
    "Fade (Ring modulation) with sin",
    
    notifier =
    function()
      mod_fade_fn = mod_fn_fn(
        mod_fade_cycle,mod_fade_shift,mod_pd_duty_onoff
        ,mod_pd_duty,mod_pd_duty_var,mod_pd_duty_var_frq)
      set_fade(sin_2pi_fn,mod_fade_fn)
    end,
  }
  
  -- Fade with saw wave
  local ring_mod_saw =    
  vb:button
  {
    width = 80,
    bitmap = btmp.ring_mod_saw,
    text = " RM saw ",
    tooltip =
    "Fade (Ring modulation) witn saw",
    
    notifier =
    function()
      mod_fade_fn = mod_fn_fn(
        mod_fade_cycle,mod_fade_shift,mod_pd_duty_onoff
        ,mod_pd_duty,mod_pd_duty_var,mod_pd_duty_var_frq)
      set_fade(saw_fn,mod_fade_fn)
    end,
  }
  
  -- Fade with square wave
    local ring_mod_square =    
  vb:button
  {
    width = 80,
    bitmap = btmp.ring_mod_square,
    text = " RM square ",
    tooltip =
    "Fade (Ring modulation) witn square",
    
    notifier =
    function()
      mod_fade_fn = mod_fn_fn(
        mod_fade_cycle,mod_fade_shift,mod_pd_duty_onoff
        ,mod_pd_duty,mod_pd_duty_var,mod_pd_duty_var_frq)
      set_fade(square_fn,mod_fade_fn)
    end,
  }
  -- Fade with triangle wave
  local ring_mod_triangle =    
  vb:button
  {
    width = 80,
    bitmap = btmp.ring_mod_triangle,
    text = " RM tri ",
    tooltip =
    "Fade (Ring modulation) witn triangle",
    
    notifier =
    function()
      mod_fade_fn = mod_fn_fn(
        mod_fade_cycle,mod_fade_shift,mod_pd_duty_onoff
        ,mod_pd_duty,mod_pd_duty_var,mod_pd_duty_var_frq)
      set_fade(triangle_fn,mod_fade_fn)
    end,
  }

  -- Superscribing copy with phase distortion
  local pd_copy =    
  vb:button
  {
    bitmap = btmp.pd_copy,
    width = 70,
    text = "PD Copy",
    tooltip =
    "Superscribing copy with phase distortion (Useful for using with Duty cycle settings)",
    notifier =
    function()
      local mod = mod_fn_fn(
        mod_fade_cycle,mod_fade_shift,mod_pd_duty_onoff
        ,mod_pd_duty,mod_pd_duty_var,mod_pd_duty_var_frq)
      local fn = copy_fn_fn()
      make_wave(fn,mod)
    end,
  }
  
  -- Set phase distortion values in feding & PD-copy 
  local fade_cycle_shift_set =
  vb:row
  {
    vb:text
    {
      text = "Cycle:"
    },
    
    -- Input cycle of the wave 
    vb:textfield
    {
      id = 'mod_fade_cycle',
      edit_mode = true,
      width = 40,
      text = tostring(ini.mod_fade_cycle.value),
      tooltip = 
      [[
      Input the number or the formula that
      represet the cycle of the wave.
      1 means 1cycle.
      e.g. '1/2' , '44100/168']] ,
      
      notifier =
      function(x)
        local xx = vb_tonumber(x)
        if xx == nil
        then
          renoise.app():show_error(
            [[Enter a number that is non-zero,
            or a numerical formula.
            1 means 1cycle
            e.g.
            '1/4' , '44100/168' 
            ]])
        else
          mod_fade_cycle = xx
        end
      end
    },
    
    
    -- Input phase shift value of the wave
    vb:text
    {
      text = " Shift:"
    },
    vb:valuebox
    {
      id = 'mod_fade_shift',
      value = mod_fade_shift*100,
      min = -100,
      max = 100,
      tostring = 
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,
      tooltip = 
      [[
      Input the number or the formula that
      represent the starting phase point of the wave.
      100%  means 1cycle .
      ]] ,
      
      notifier =
      function(x)       
        mod_fade_shift = x/100
      end
    },
    vb:text
    {
      text = "% "
    },
    
    vb:button
    {
      width = 3,
      text = "Reset",
      tooltip =
      "Reset values.",
      
      notifier = 
      function()
        vb.views.mod_fade_cycle.text
        = '1'
        vb.views.mod_fade_shift.value
        = 0
      end,
    },
  }
  
  -- Duty cycle for fade & phase distortion copy
  local pd_duty_fiducial=
  vb:row
  {
    vb:text
    {
      text = " Duty cycle:"
    },  
    vb:checkbox
    {
      id = 'pd_duty_onoff',
      value = mod_pd_duty_onoff,
      notifier =
      function(x)       
        mod_pd_duty_onoff = x
      end    
      
    },  
    
    
    -- Input duty cycle 
    vb:valuebox
    {
      id = 'pd_duty_fiducial',
      value = mod_pd_duty,
      min = 0,
      max = 100,
      tostring = 
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,
      tooltip = 
      [[
      Input duty cycle (fiducial value)
      ]],
      
      notifier =
      function(x)       
        mod_pd_duty = tonumber(x)
      end
    },
    
    vb:text
    {
      text = "% "
    },
  }
  
  -- Duty cycle variation 
  local pd_duty_variation =
  vb:row
  {
    vb:text
    {
      text = " var:"
    },
    
    vb:valuebox
    {
      id = 'pd_duty_variation',
      value = mod_pd_duty_var,
      min = -100,
      max = 100,
      tostring = 
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,
      tooltip =
      [[
      Input duty cycle variation value.
      Duty cycle fluctuates between fiducial value
      and this value plus fiducial value with minus cosine curve.
      ]],
      
      notifier =
      function(x)       
        mod_pd_duty_var = tonumber(x)
      end
    },
    vb:text
    {
      text = "% "
    },
    
    vb:text
    {
      text = " frq:"
    },
    
    vb:valuebox
    {
      id = 'pd_duty_var_frq',
      value = mod_pd_duty_var_frq,
      min = -10000,
      max = 10000,
      tostring = 
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,      
      tooltip =
      [[
      Input duty variation frequency.
      Duty cycle fluctuates between fiducial value
      and variation value plus fiducial value with minus cosine curve.
      this frequency is used in this cosine curve. 
      ]],
      
      notifier =
      function(x)       
        mod_pd_duty_var_frq = x
      end
    },
  }
  
  local pd_reset_duty =
  vb:button
  {
    width = 3,
    text = "Reset",
    tooltip =
    "Reset values.",
    
    notifier = 
    function()
      vb.views.pd_duty_fiducial.value
      = 50
      vb.views.pd_duty_variation.value
      = 0
      vb.views.pd_duty_var_frq.value
      = 1
    end,
  }

  -- Karplus-Strong String
  local ks_btn =
  vb:button
  {
    width = 80,
    text = 'KS String',
    tooltip =
    [[
    This modulates the sample with Karplus-Strong string synthesis.
    Please prepare selection length that is longer than ks-length value.
    ]],
    notifier =
    function(x)       
      local fn = ks_copy_fn_fn(ks_len_var,ks_mix_var,ks_amp_var)
      make_wave(fn)
    end    
    
  }  
  
  -- Input K-s string first pulse length
  local ks_len_input =
  vb:row
  {
    vb:text
    {
      text = "length:"
    },
    vb:textfield
    {
      id = 'ks_len',
      edit_mode = true,
      width = 40,
      text = tostring(ks_len_var),
      tooltip = 
      [[
      Input the length of K-S synthesis first pulse.
      This determines the pitch.
      You can use some letters that represents pitch, e.g.'C#4'.
      ]] ,
      
      notifier =
      function(x)
        local xx = str2wvnum(x,A4hz) 
        if xx == nil
        then
          renoise.app():show_error(
            [[Enter a  non-zero number,
            or a numerical formula.
            This decides string pitch. 
            ]])
        else
          ks_len_var = xx
        end
      end
    }
  }
  
  -- Input dry-mix value in K-s string
  local ks_mix_input =
  vb:row
  {
    vb:text
    {
      text = " mix:"
    },
    
    vb:valuebox
    {
      id = 'ks_mix',
      value = ks_mix_var,
      min = 0,
      max = 100,
      tostring = 
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,
      tooltip =
      [[
      Input dry-mix value for K-S string.
      ]],
      
      notifier =
      function(x)       
        ks_mix_var = x/100
      end
    },
    vb:text
    {
      text = "% "
    }
  }

  
  -- Input amplification value in K-s string
  local ks_amp_input =
  vb:row
  {
    vb:text
    {
      text = "amp:"
    },
    
    vb:valuebox
    {
      id = 'ks_amp',
      value = ks_amp_var,
      min = 0,
      max = 1000,
      tostring = 
      function(x)
        return tostring(round(x,3))
      end,
      tonumber =
      function(x)
        return vb_tonumber(x)
      end,
      tooltip =
      [[
      Input amplification value for K-S string.
      ]],
      
      notifier =
      function(x)       
        ks_amp_var = x/1000
      end
    },
    
  }

  -- Reset K-S string values 
  local ks_reset =

  vb:button
  {
    width = 3,
    text = "Reset",
    tooltip =
    "Reset values.",
    
    notifier = 
    function()
      vb.views.ks_len.text = tostring(str2wvnum('C-4',A4hz))
      vb.views.ks_mix.value = 0
      vb.views.ks_amp.value = 0
    end,
  }

  local appendix
  = vb:row{
    id = 'appendix',
    visible = false,
    ks_btn, ks_len_input, ks_mix_input, ks_amp_input, ks_reset,
    margin = 6}

  
  local app_btn =
  vb:button
  {
    id = 'app_btn',
    width = 3,
    text = "App.",
    tooltip =
    "Appendix",
    
    notifier = 
    function()
      if
        vb.views.appendix.visible == false
      then
        vb.views.appendix.visible = true
        vb.views.app_btn.text = 'close'
      else
        vb.views.appendix.visible = false
        vb.views.app_btn.text = 'app.'
      end
    end
  }

  -- Clip & redraw the wave form 
  local clip_wv_tbl = nil
  local clip_wv_fn = nil
  local is_clipped = false
  local clip_wave =
  vb:button
  {
    id = 'clip_wave',
    width = 80,
    text = 'Clip wave',
    tooltip =
    [[
    Memorize the waveform in a selection area.
    ]],
    notifier =
    function(x)
      clip_wv_tbl = wave2tbl()
      clip_wv_fn = tbl2fn(clip_wv_tbl)
      is_clipped = true
    end
  }

  local redraw_txt =
  vb:text
  {
    text = " Draw mode:"
  }
  local redraw =
  vb:button
  {
    width = 80,
    text = 'Re-draw',
    tooltip =
    [[
    Redraw the memorized (clipped) waveform to a new selection area.
    ]],
    notifier =
    function(x)
      if is_clipped == true 
      then
        make_wave(clip_wv_fn)
      end
    end
  }

  local mixdraw  =
  vb:button
  {
    width = 80,
    text = 'Mix-draw',
    tooltip =
    [[
    Mix the memorized (clipped) waveform with an another waveform in a selection area.
    ]],
    notifier =
    function(x)
      if is_clipped == true 
      then
        local fn = copy_fn_fn()
        local mix = mix_fn_fn(fn,clip_wv_fn)
        make_wave(mix)
      end
    end
  }
  
  -- Make random waves
  local random_wave =
  vb:button
  {
    bitmap = btmp.random_wave,
    width = 80,
    height = 80,
    text = 'Random',
    tooltip =
    [[
    Make random waves
    ]],
    notifier =
    function(x)
      rndm_wv()
    end
  }

  local run_dialog 
  local run_random =
  vb:button
  {
    bitmap = btmp.run_random,
    width = 80,
    text = 'Rndm',
    tooltip =
    [[
    Make random waves
    ]],
    notifier =
    function(x)
      if run_dialog == nil then
        run_dialog =
        renoise.app():show_custom_dialog("Random waves" , random_wave,key_handle)
      elseif run_dialog ~= nil and run_dialog.visible == true then
        run_dialog:close()
        run_dialog = nil
      else run_dialog =
        renoise.app():show_custom_dialog("Random waves" , random_wave,key_handle)
      end
    end
  }

  -- Save the values as preset
  local save_preset =
  function(doc_name,xml_name)
    local doc =
    renoise.Document.create(doc_name){}
    doc:add_property("A4hz",A4hz)
    doc:add_property("get_x_frame",vb.views.set_end_val_frame.text)
    doc:add_property("get_x_beat",vb.views.set_end_val_beat.text)
    doc:add_property("multiply_setend",vb.views.multiply_setend.text)
    doc:add_property("mod_cycle",vb.views.mod_cycle.text)
    doc:add_property("mod_shift",mod_shift)
    doc:add_property("mod_duty_onoff",mod_duty_onoff)
    doc:add_property("mod_duty",mod_duty)
    doc:add_property("mod_duty_var",mod_duty_var)
    doc:add_property("mod_duty_var_frq",mod_duty_var_frq)
    doc:add_property("mod_fade_cycle",vb.views.mod_fade_cycle.text)
    doc:add_property("mod_fade_shift",mod_fade_shift)
    doc:add_property("mod_pd_duty_onoff",mod_pd_duty_onoff)
    doc:add_property("mod_pd_duty",mod_pd_duty)
    doc:add_property("mod_pd_duty_var",mod_pd_duty_var)
    doc:add_property("mod_pd_duty_var_frq",mod_pd_duty_var_frq)
    doc:add_property("sig",sig)
    doc:add_property("flick_paste_check_value",flick_paste_check_value)
    doc:add_property("band_limited",band_limited)    
    doc:save_as(xml_name)
  end
  local save_btn =
  vb:button
  {
    width = 30,
    text = 'Save',
    tooltip =
    [[
    Save values as preset
    ]],
    notifier =
    function(x)
      save_preset('preset','preset.xml')
    end
  }


  
  -- === Making GUI ===

-- これ以下のGUI部分で、オリジナルのrow部分を入れ子にしてグループ化しました。
-- 結果オーライなので、これで良いのかどうか分かりません。(satobox)
 
  local s1,s2,s3,s4,s5
  
  s1 = vb:column{
  style = "panel",
  margin = 3,
  vb:column{setend_txt,setend_frame_in,setend_frame_bt,margin = 6},
  vb:column{setend_beat_in,setend_beat_bt,margin = 6},
  vb:row{multiply_setend, margin = 6,},
  vb:row{flick_range_back,flick_range,set_loop,
    flick_paste_txt, flick_paste_check, margin = 6}
  }  

  s2 = vb:column{
  style = "panel",
  margin = 8,
  vb:row{clip_wave, redraw_txt, redraw, mixdraw, margin =6}
  }

  s3 = vb:column{
  style = "panel",
  margin = 8,
  vb:row{sin_2pi,saw,square,triangle, margin = 6},
  vb:row{cycle_shift_set,band_limited_check, margin = 6},
  vb:row{duty_fiducial, duty_variation, reset_duty, margin = 6},
  vb:row{white_noise,brown_noise, violet_noise, margin = 6}
  }

  s4 = vb:column{
  style = "panel",
  margin = 8,
  vb:row{phase_shift_1on24_plus,phase_shift_1on24_minus,
    phase_shift_fine_plus,phase_shift_fine_minus, margin = 6},
  vb:row{fade_center_7on8,fade_center_9on8, margin = 6},
  vb:row{multiply_11on12,multiply_13on12,
    fade_in_7on8, fade_out_7on8, margin = 6},
  vb:row{ring_mod_sin,ring_mod_saw,
    ring_mod_square,ring_mod_triangle,pd_copy, margin = 6},
  vb:row{fade_cycle_shift_set, margin = 6},
  vb:row{pd_duty_fiducial, pd_duty_variation,
    pd_reset_duty, margin = 6}
  }

  s5 = vb:row{addnew_bt,insert_bt,del_bt,
    run_random,save_btn, help, margin = 6}


-- ここでグループ枠の見た目を整える為に spacing と uniform を追加。(satobox)

  local dialog_content = vb:column{s1,s2,s3,s4,s5,margin = 6, spacing = 6, uniform = true,}
  renoise.app():show_custom_dialog("Selection Shaper Kai" , dialog_content,key_handle)
end

-- === Menu entry ===
renoise.tool():add_menu_entry{
  name = "Sample Editor:Process:Selection shaper Kai ...",
  invoke = function() 
    gui()
  end
}

-- === Key bindings ===
renoise.tool():add_keybinding {
  name = "Sample Editor:Selection Shaper:Flick range forward",
  invoke = function()
    flick_range()
  end
}

renoise.tool():add_keybinding {
  name = "Sample Editor:Selection Shaper:Flick range backward",
  invoke = function()
    flick_range_back()
  end
}
--[[
renoise.tool():add_keybinding {
  name = "Sample Editor:Selection Shaper:Flickback and Setloop",
  invoke = function()
    flick_range_back()
    set_loop()
  end
}

renoise.tool():add_keybinding {
  name = "Sample Editor:Selection Shaper:Flick and Setloop",
  invoke = function()
    flick_range()
    set_loop()
  end
}

--]]

