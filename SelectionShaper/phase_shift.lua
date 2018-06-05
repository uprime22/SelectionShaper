require ('globals')
require ('selection_with_upbeat')

-- 選択されたch に応じてpointを変換。phase_shift用。
-- point: 選択範囲内のShift目的位置。
function pt_with_ch_in_phase_shift (point,ch)
  if ch == init_selected_channel or init_selected_channel == 3 then
    return point
  else return 0
  end
end


function phase_shift (frame)
--  local frm = math.floor(frame)  
--  get_init_env()
  
  local range = init_range
  local point = round(math.fmod(math.fmod(frame,range)+range,range)) -- frame:+or-,OK
  if point == 0 then
    return nil
  end
  
  create_new (init_number_of_frames,init_number_of_channels)
  new_buffer:prepare_sample_data_changes()
  
  if selection_start >1 then
    for ch = 1,init_number_of_channels do
      for fr = 1,(selection_start -1) do
        new_buffer
        :set_sample_data(
          ch,fr,
          init_buffer
          :sample_data(ch,fr))
      end
    end
  end
    
  if selection_end < init_number_of_frames then
    for ch = 1,init_number_of_channels do
      for fr = (selection_end +1),init_number_of_frames do
        new_buffer
          :set_sample_data(
            ch,fr,
            init_buffer
            :sample_data(ch,fr))
      end
    end
  end

  for ch = 1,init_number_of_channels do
    for fr =(selection_start
      + pt_with_ch_in_phase_shift (point,ch)),selection_end do
      new_buffer
      :set_sample_data(
        ch,(fr - pt_with_ch_in_phase_shift (point,ch)),
        init_buffer
        :sample_data(ch,fr))
    end
  end      
      
  for ch = 1,init_number_of_channels do
    if pt_with_ch_in_phase_shift (point,ch) >=1 
    then
      for fr = selection_start,(selection_start
        + pt_with_ch_in_phase_shift (point,ch) -1) do
          new_buffer
          :set_sample_data(
            ch,(fr + range - pt_with_ch_in_phase_shift (point,ch)),
            init_buffer
            :sample_data(ch,fr))
        end
    end      
  end
  
  new_buffer:finalize_sample_data_changes()
      
  new_sample.loop_start
  = init_loop_start
  new_sample.loop_end
  = init_loop_end        

  init_sample:copy_from(new_sample)
  init_inst:delete_sample_at(init_sample_index + 1)
  init_buffer.selection_start = selection_start
  init_buffer.selection_end = selection_end
  init_buffer.selected_channel = init_selected_channel
  init_sample.loop_mode = init_loop_mode
end

-------------------------------------
function phase_shift_with_ratio (ratio)
  get_init_env()
  if smpl_ok == false then return nil end
  phase_shift (init_range * ratio)
end

function phase_shift_fine (frame)
  get_init_env()
  if smpl_ok == false then return nil end  
  phase_shift (frame)
end


