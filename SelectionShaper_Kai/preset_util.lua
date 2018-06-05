-- For adding property & data typing.
function create_preset(name)
  return
  renoise.Document.create(name){
    A4hz =440,
    get_x_frame ="168",
    get_x_beat ="1",
    multiply_setend ="1", 
    mod_cycle ="1",
    mod_shift =0,
    mod_duty_onoff =false,
    mod_duty =50,
    mod_duty_var =0,
    mod_duty_var_frq =1,
    mod_fade_cycle ="1",
    mod_fade_shift =0,
    mod_pd_duty_onoff =false,
    mod_pd_duty =50,
    mod_pd_duty_var =0,
    mod_pd_duty_var_frq =1,
    sig =6,
    flick_paste_check_value = false,
    band_limited = true,
    
    ks_len_var ="168",
    ks_mix_var =0,
    ks_amp_var =0,
    }
end