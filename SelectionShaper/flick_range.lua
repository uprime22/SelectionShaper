require ('selection_with_upbeat')
require ('set_end')
require ('insert_delete')

function flick_range ()
  get_init_env()
  if smpl_ok == false then return nil end  
  local i_r,i_f = init_range ,init_number_of_frames
  if selection_end +1 < i_f then
    init_buffer.selection_end = selection_end +1
    init_buffer.selection_start = selection_end +1
    set_end_point_with_frame (i_r)
  else 
    init_buffer.selection_start = i_f
    set_end_point_with_frame (2)
    init_buffer.selection_start = i_f +1
    set_end_point_with_frame (i_r)
  end
end


function flick_range_back ()
  get_init_env()
  if smpl_ok == false then return nil end  
  local i_r,i_f = init_range ,init_number_of_frames
  if selection_start -1 >= i_r then
    init_buffer.selection_start = selection_start -i_r
    init_buffer.selection_end = selection_start -1
  elseif selection_start -1 < i_r then
    init_buffer.selection_start = 1
    init_buffer.selection_end = i_r - (selection_start -1)
    sweep_ins()
    init_buffer.selection_start = 1
    init_buffer.selection_end = i_r
  else
  end
end

function set_loop ()
  get_init_env()
  if smpl_ok == false then return nil end  
  init_sample.loop_start = selection_start
  init_sample.loop_end = selection_end
end

  