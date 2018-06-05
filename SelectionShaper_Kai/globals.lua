-- the state of the sample
smpl_ok = false
is_not_sliced = nil
init_sample_name = ""
init_inst , init_inst_index = nil,nil
init_sample_index , init_sample , init_buffer, init_mapping = nil,nil,nil,nil
init_map_velocity_to_volume, init_map_key_to_pitch = nil, nil
init_base_note, init_note_range, init_velocity_range = 48, {}, {}
init_display_range = {}
init_vertical_zoom_factor = nil


init_interpolation_mode , init_new_note_action = nil,nil
init_autoseek , init_autofade = nil,nil
init_panning , init_volume = nil,nil
init_loop_mode , init_loop_release = nil,nil

init_loop_start , init_loop_end = nil,nil
init_sample_rate , init_bit_depth = nil,nil
init_number_of_channels , init_number_of_frames = nil,nil
init_selected_channel = nil

-- utility table for channel selecting
ch_util ={}
ch_util[1] = {0,0,{{1,1},1}} -- In monoral,selected_channel is 3
ch_util[2] = {{{1,2},1},{{2,1},1},{{1,2},2}} -- stereo

init_sync_enabled , init_sync_lines = nil,nil

-- base_note -> tranpose
-- http://forum.renoise.com/index.php?/topic/31452-base-note-always-returns-48/
init_transpose , init_fine_tune = nil,nil

new_sample , new_buffer , new_mapping = nil,nil,nil
upbeat_frames = nil

bpm, lpb, selection_start, selection_end,init_range = nil,nil,nil,nil,nil

-------------------------------
-- for rondom wolking and chaos
random_seed = 0
x_pre, x_next = 0, 0
brown_parameter = (1/6)


-------------------------------
-- for add flick to default paste key-binding
flick_paste_check_value = nil




