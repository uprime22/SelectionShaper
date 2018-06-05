require ('globals')

-- 長い。

-- init sample settings
function get_init_env()
  init_inst = renoise.song().selected_instrument
  init_sample_index = renoise.song().selected_sample_index
  init_sample = renoise.song().selected_sample
  if init_sample ~= nil
  then
    init_buffer = renoise.song().selected_sample.sample_buffer
  end
  -- Is there sample ？
  if init_sample == nil or init_buffer == nil or
    init_buffer.has_sample_data ~= true
  then
    renoise.app():show_error(" There is no sample data. Please create.")
    smpl_ok =  false
    return nil
  end
  
  -- cannot use in sliced samle
  if
    #(renoise.song().selected_sample.slice_markers) >1
  then
    renoise.app():show_error(
      [[Sorry, sliced sample cannot be modified]])      
    smpl_ok = false
    return nil
  end  

  smpl_ok = true

  init_mapping = init_sample.sample_mapping
  init_map_velocity_to_volume = init_mapping.map_velocity_to_volume
  init_map_key_to_pitch = init_mapping.map_key_to_pitch
  init_base_note = init_mapping.base_note
  init_note_range = init_mapping.note_range
  init_velocity_range = init_mapping.velocity_range

  
  init_sample_rate =
       init_buffer.sample_rate
  init_bit_depth =
       init_buffer.bit_depth
  init_number_of_channels =
  init_buffer.number_of_channels
  init_selected_channel =
  init_buffer.selected_channel
  
  init_number_of_frames =
  init_buffer.number_of_frames

  init_display_range = init_buffer.display_range
  init_vertical_zoom_factor = init_buffer.vertical_zoom_factor

  init_interpolation_mode = init_sample.interpolation_mode
  init_new_note_action = init_sample.new_note_action
  
  init_autoseek = init_sample.autoseek
  init_autofade = init_sample.autofade
  init_panning = init_sample.panning
  init_volume = init_sample.volume
  init_loop_mode = init_sample.loop_mode
  init_loop_release = init_sample.loop_release
  
  init_sync_enabled = init_sample.beat_sync_enabled
  init_sync_lines = init_sample.beat_sync_lines

  init_sample_name = init_sample.name
  init_loop_start = init_sample.loop_start
  init_loop_end = init_sample.loop_end  
  init_transpose = init_sample.transpose
  init_fine_tune = init_sample.fine_tune

  selection_start =
          init_buffer.selection_start
  selection_end =
          init_buffer.selection_end
  init_range = selection_end - selection_start +1
  bpm = renoise.song().transport.bpm
  lpb = renoise.song().transport.lpb
  return true
end

function has_sample_ok ()
  if init_buffer == nil or
    init_buffer.has_sample_data ~= true
  then
    renoise.app():show_error(" No sample data.")
    smpl_ok = false
  else return true
  end
end

-- Make new sample, and inherit sample settings from init. 
function get_new_env()
  has_sample_ok ()
  if smpl_ok == false then return nil end
  
  init_inst:insert_sample_at(init_sample_index +1)
  new_sample =
          init_inst.samples[init_sample_index +1]
          
  new_sample.beat_sync_enabled =  init_sync_enabled
  --  new_sample.beat_sync_lines =  init_sync_lines

  new_sample.transpose = init_transpose
  new_sample.fine_tune = init_fine_tune
  new_sample.name = init_sample_name

  new_sample.interpolation_mode = init_interpolation_mode
  new_sample.new_note_action = init_new_note_action
  
  new_sample.oneshot= init_sample.oneshot
  new_sample.mute_group = init_sample.mute_group
  new_sample.modulation_set_index = init_sample.modulation_set_index
  new_sample.device_chain_index = init_sample.device_chain_index
  
  new_sample.autoseek = init_autoseek
  new_sample.autofade = init_autofade
  new_sample.panning = init_panning
  new_sample.volume = init_volume
  new_sample.loop_mode = init_loop_mode
  new_sample.loop_release = init_loop_release

  new_mapping = new_sample.sample_mapping
  new_mapping.map_velocity_to_volume = init_map_velocity_to_volume 
  new_mapping.map_key_to_pitch = init_map_key_to_pitch
  new_mapping.base_note = init_base_note
  new_mapping.note_range = init_note_range
  new_mapping.velocity_range = init_velocity_range
  
  new_buffer = new_sample.sample_buffer
end

-----------------------------------
-- 数値を丸めます。
-- http://lua-users.org/wiki/SimpleRound
function round(num, idp)
  if type(num)~='number' then return nil end
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- transposeで変わるビートの割合の計算
function beat_unit_with_base_tune ()
--  get_init_env()
  local bn = init_transpose
  local ft = init_fine_tune

  if
    (bn == 0 and ft == 0) or
    init_sync_enabled == true
  then return 1
  else return
  math.pow ((1/2),(bn-(ft/128))/12)
  end
end

-- syncで変わるビートの割合を計算
function beat_unit_with_sync ()
--  get_init_env()
  if init_sync_enabled == false
  then return 1
  else
    return
    (init_number_of_frames * (lpb / init_sync_lines))/
    ((1 / bpm * 60) * init_sample_rate)
  end
end

-- sync やtrancepose 後に変化するビート単位を再計算
function beat_orgn (beat)
  return
  beat * beat_unit_with_sync () * beat_unit_with_base_tune ()
end

----------------------------------
-- そのbeatが何frameか？
function frames_per_xbeat (beat)
  if type(beat)~= 'number' or  smpl_ok == false then return nil end
  bpm = renoise.song().transport.bpm
  local seconds_per_beat = 1 / bpm * 60
  return round((seconds_per_beat * init_sample_rate * beat))
end

-- selection range をbeat へ
function selection2beat ()
  get_init_env()
  if smpl_ok == false then return 0 end
  
  local val
  val = ((selection_end - selection_start +1) /
    ((1 / bpm * 60) * init_sample_rate)) *
  (beat_unit_with_sync () * beat_unit_with_base_tune ())
  return val
end

function selection_frames()
  get_init_env()
  if smpl_ok == false then return nil end  
  return init_range
end


---------------------------------

-- Create new sample buffer
function create_new (num_frames,num_channel)
--  get_init_env()
--  init_inst:insert_sample_at(init_sample_index+1)
  get_new_env()

  local new_sync_val =
          init_sync_lines * (num_frames/init_number_of_frames) 
  if init_sync_enabled == false or new_sync_val > 256 
    then
      new_sample.beat_sync_lines = init_sync_lines
    else
      new_sample.beat_sync_lines = new_sync_val
  end 

  new_buffer:create_sample_data(
                 init_sample_rate,init_bit_depth,num_channel,
                 num_frames)
end


