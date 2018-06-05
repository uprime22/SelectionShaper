require ('globals')
require ('selection_with_upbeat')

-- reset selection end with frame(sample)
function set_end_point_with_frame (frame)
  get_init_env()
  if tonumber(frame)== nil or  smpl_ok == false then return nil end
  
  local end_point = selection_start + round(frame) -1

  if frame <= 0
    then renoise.app():show_error('Enter the number greater than zero')
  elseif
    end_point <= init_number_of_frames
    then
    init_buffer.selection_end  = end_point
  elseif
    end_point > init_number_of_frames
    then
    create_new (end_point,init_number_of_channels)
    new_buffer:prepare_sample_data_changes()
      for ch = 1,init_number_of_channels do
        for fr = 1,init_number_of_frames do
          new_buffer
          :set_sample_data(
            ch,fr,
            init_buffer:sample_data(ch,fr))
        end
        for fr = init_number_of_frames+1,end_point do
          new_buffer
          :set_sample_data(ch,fr,0)
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
      init_buffer.selected_channel = init_selected_channel
      init_sample.loop_mode = init_loop_mode
  else return nil
  end
end

-- reset the selection range with beat
function set_end_point_with_beat (beat)
  get_init_env()
  if smpl_ok == false then return nil end  
  local x = frames_per_xbeat (beat/beat_orgn(1))
  set_end_point_with_frame (x)
end

