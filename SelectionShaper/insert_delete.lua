require ('globals')
require ('selection_with_upbeat')

-- Insert_silence

-- sweep_ins()の際のLOOP位置再計算。
function set_new_loop_sweep (on_off)
  local new_loop_start
  local new_loop_end
  if
    -- ss se ls le
    init_loop_start >= selection_end
    then
      new_loop_start =
      (selection_end - selection_start +1) +
      init_loop_start
      new_loop_end =
     (selection_end - selection_start +1) +
      init_loop_end
    elseif
      -- ss ls se le
      init_loop_start >= selection_start and
      init_loop_start <= selection_end and
      init_loop_end >= selection_end 
    then
      new_loop_start =
      (init_loop_start - selection_start +1) +
      selection_end
      new_loop_end =
      (selection_end - selection_start +1) +
      init_loop_end 
    elseif
      -- ss ls le se
      init_loop_start >= selection_start and
      init_loop_start <= selection_end and      
      init_loop_end <= selection_end 
    then
      new_loop_start =
      (init_loop_start - selection_start +1) +
      selection_end      
      new_loop_end =
      (init_loop_end - selection_start +1) +
      selection_end        
    elseif
      -- ls ss se le
      init_loop_start <= selection_start and
      init_loop_end >= selection_end
    then
      new_loop_start = init_loop_start
      new_loop_end =
      (selection_end - selection_start +1) +
      init_loop_end
    elseif
      -- ls ss le se
      init_loop_start <= selection_start and
      init_loop_end >= selection_start and
      init_loop_end <= selection_end    
    then
      new_loop_start = init_loop_start
      new_loop_end =
      (init_loop_end - selection_start +1) +
      selection_end        
    elseif
      -- ls le ss se
      init_loop_end <= selection_start
    then
      new_loop_start = init_loop_start
      new_loop_end = init_loop_end
    else
      return nil
    end
  if on_off == false then
    new_loop_start = init_loop_start
    new_loop_end = init_loop_end
  end
  new_sample.loop_start
  = new_loop_start
  new_sample.loop_end
  = new_loop_end  
end


function ins_in_all_ch()
  get_init_env()
  if smpl_ok == false then return nil end
  
  local end_point = init_number_of_frames + init_range
  create_new (end_point,init_number_of_channels)
  new_buffer:prepare_sample_data_changes()
  
  for ch = 1,init_number_of_channels do
    for fr = 1,selection_start -1 do
      new_buffer
      :set_sample_data(
        ch,fr,
        init_buffer
        :sample_data(ch,fr))
    end
    for fr = selection_start ,selection_end do
      new_buffer
      :set_sample_data(
        ch,fr,0)
    end
    for fr = selection_end +1,end_point do
      new_buffer
      :set_sample_data(
        ch,fr,
        init_buffer
        :sample_data(ch,fr - init_range))
    end        
  end      
  new_buffer:finalize_sample_data_changes()
  set_new_loop_sweep ()
  init_sample:copy_from(new_sample)
  init_inst:delete_sample_at(init_sample_index + 1)
  
  init_buffer.selection_start = selection_start
  init_buffer.selection_end = selection_end
  init_buffer.selected_channel = init_selected_channel
  init_sample.loop_mode = init_loop_mode
end

function ins_in_one_ch()
  get_init_env()
  if smpl_ok == false then return nil end
  
  local end_point = init_number_of_frames + init_range
  local ch1,ch2
  ch1 = ch_util[init_number_of_channels][init_selected_channel][1][1]  
  ch2 = ch_util[init_number_of_channels][init_selected_channel][1][2]   
  create_new (end_point,init_number_of_channels)
  new_buffer:prepare_sample_data_changes()
  
  -- in selected channel
  for fr = 1,selection_start -1 do
    new_buffer
    :set_sample_data(
      ch1,fr,
      init_buffer
      :sample_data(ch1,fr))
  end
  for fr = selection_start ,selection_end do
    new_buffer
    :set_sample_data(
      ch1,fr,0)
  end
  for fr = selection_end +1,end_point do
    new_buffer
    :set_sample_data(
      ch1,fr,
      init_buffer
      :sample_data(ch1,fr - init_range))
  end        

  -- in another channel
  for fr = 1,init_number_of_frames do
      new_buffer
      :set_sample_data(
        ch2,fr,
        init_buffer
        :sample_data(ch2,fr))
  end
  for fr = init_number_of_frames +1 ,end_point do
    new_buffer
    :set_sample_data(
      ch2,fr,0)
  end  
  new_buffer:finalize_sample_data_changes()
  set_new_loop_sweep ()
  init_sample:copy_from(new_sample)
  init_inst:delete_sample_at(init_sample_index + 1)
  
  init_buffer.selection_start = selection_start
  init_buffer.selection_end = selection_end
  init_buffer.selected_channel = init_selected_channel
  init_sample.loop_mode = init_loop_mode
end

function sweep_ins()
  get_init_env()
  if smpl_ok == false then return nil end
  
  if init_selected_channel == 3 then
    ins_in_all_ch()
  else
    ins_in_one_ch()
  end
end

------------------------------------

-- sync_del()の際のLOOP位置再計算。
function set_new_loop_del (on_off)
  local new_loop_start
  local new_loop_end
  if
    -- ss se ls le
    init_loop_start >= selection_end
    then
      new_loop_start =
      (init_loop_start - selection_end) +
      selection_start -1
      new_loop_end =
      (init_loop_end - selection_end) +
      selection_start -1
     
    elseif
      -- ss ls se le
      init_loop_start >= selection_start and
      init_loop_start <= selection_end and
      init_loop_end > selection_end 
    then
      new_loop_start = 1
      new_loop_end =
      (init_loop_end - selection_end) +
      selection_start -1
      
    elseif
      -- ss ls le se
      init_loop_start >= selection_start and
      init_loop_start <= selection_end and      
      init_loop_end <= selection_end 
    then
      new_loop_start = 1
      new_loop_end = init_number_of_frames - init_range
      
    elseif
      -- ls ss se le
      init_loop_start <= selection_start and
      init_loop_end >= selection_end
    then
      new_loop_start = init_loop_start
      new_loop_end =
      (init_loop_end - selection_end) +
      selection_start -1
      
    elseif
      -- ls ss le se
      init_loop_start <= selection_start and
      init_loop_end >= selection_start and
      init_loop_end <= selection_end    
    then
      new_loop_start = init_loop_start
      new_loop_end = init_number_of_frames - init_range
      
    elseif
      -- ls le ss se
      init_loop_end <= selection_start
    then
      new_loop_start = init_loop_start
      new_loop_end = init_loop_end
      
    else
      return nil
    end
  if new_loop_start <= 1
  then new_loop_start = 1
  end
  if on_off == false then
    new_loop_start = init_loop_start
    new_loop_end = init_loop_end
  end
  new_sample.loop_start
  = new_loop_start
  new_sample.loop_end
  = new_loop_end  
end

-- Create no sound data
function empty_smple ()
  create_new (init_number_of_frames,init_number_of_channels)
  new_buffer:prepare_sample_data_changes()
  for ch = 1,init_number_of_channels do
    for fr = 1,init_number_of_frames do
      new_buffer
      :set_sample_data(ch,fr,0)
    end
  end
  new_buffer:finalize_sample_data_changes()
  new_sample.loop_start = 1
  new_sample.loop_end = init_number_of_frames
  init_sample:copy_from(new_sample)
  init_inst:delete_sample_at(init_sample_index + 1)
end


-- Delete 
function del_in_all_ch()
--  get_init_env()
--  not_sliced_ok ()
  local end_point = init_number_of_frames - init_range
  if end_point <= 0 then empty_smple() return end
  
  create_new (end_point,init_number_of_channels)
  new_buffer:prepare_sample_data_changes()
  
  for ch = 1,init_number_of_channels do
    for fr = 1,selection_start -1 do
      new_buffer
      :set_sample_data(
        ch,fr,
        init_buffer
        :sample_data(ch,fr))
    end
    
    for fr = selection_start,end_point do
      new_buffer
      :set_sample_data(
        ch,fr,
        init_buffer
        :sample_data(ch,fr+init_range))
    end
  end      
  new_buffer:finalize_sample_data_changes()
  set_new_loop_del ()
  
  init_sample:copy_from(new_sample)
  init_inst:delete_sample_at(init_sample_index + 1)
  init_sample.loop_mode = init_loop_mode
end

-- ch_util is in 'global.lua'

function del_in_one_ch ()
--  get_init_env()
--  not_sliced_ok ()
  local ch1,ch2
  ch1 = ch_util[init_number_of_channels][init_selected_channel][1][1]  
  ch2 = ch_util[init_number_of_channels][init_selected_channel][1][2] 
  create_new (init_number_of_frames,init_number_of_channels)
  new_buffer:prepare_sample_data_changes()
  
  --in selected channel
  if selection_start > 1 then
    for fr = 1, selection_start -1 do
      new_buffer
      :set_sample_data(
        ch1,fr,
        init_buffer
        :sample_data(ch1,fr))
    end
  end
  for fr = selection_start, init_number_of_frames -init_range do
    new_buffer
    :set_sample_data(
      ch1,fr,
      init_buffer
      :sample_data(ch1,(fr+init_range)))
  end
  if init_number_of_frames -init_range +1 <  init_number_of_frames then
    for fr = init_number_of_frames -init_range +1,init_number_of_frames do
      new_buffer
      :set_sample_data(
        ch1,fr,0)
    end
  end
    
  -- in another channel
  for fr = 1,init_number_of_frames do
      new_buffer
      :set_sample_data(
        ch2,fr,
        init_buffer
        :sample_data(ch2,fr))
  end          
  new_buffer:finalize_sample_data_changes()
  set_new_loop_del (false)
  
  init_sample:copy_from(new_sample)
  init_inst:delete_sample_at(init_sample_index + 1)
  init_buffer.selection_start = selection_start
  init_buffer.selection_end = selection_start
  init_buffer.selected_channel = init_selected_channel
  init_sample.loop_mode = init_loop_mode
end

function sync_del ()
  get_init_env()
  if smpl_ok == false then return nil end
  
  if init_selected_channel == 3 then
    del_in_all_ch()
  else
    del_in_one_ch()
  end
end

  
