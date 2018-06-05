require ('selection_with_upbeat')


-- ˆÈ‰º‚Ìset_new_with_upbeat ‚Å‚Ì LoopˆÊ’uÄŒvŽZB
function set_new_loop_replace ()
  local new_loop_start, new_loop_end
  if
    -- ss ls se le
    init_loop_end > selection_end and
    init_loop_start > selection_start and
    init_loop_start <= selection_end
    then
      new_loop_start = init_loop_start - selection_start +1
      new_loop_end = init_range
    elseif
      -- ss ls le se
      init_loop_end <= selection_end and
      init_loop_start >= selection_start
    then
      new_loop_start = init_loop_start - selection_start +1
      new_loop_end = init_loop_end - selection_start +1
    elseif
      -- ls ss le se
      init_loop_end < selection_end and
      init_loop_end > selection_start and
      init_loop_start < selection_start
    then
      new_loop_start = 1
      new_loop_end = init_loop_end - selection_start +1
    else
      new_loop_start = 1
      new_loop_end = init_range      
    end
  new_sample.loop_start
  = new_loop_start
  new_sample.loop_end
  = new_loop_end
end


-- Add new sample 
function add_new ()
  get_init_env()
  if smpl_ok == false then return nil end
  local ch_tbl = ch_util[init_number_of_channels][init_selected_channel]

  create_new (init_range,ch_tbl[2])   
  new_buffer:prepare_sample_data_changes()
      for ch = 1,ch_tbl[2] do
        for fr = 1,init_range do
          new_buffer
          :set_sample_data(ch,fr,
           init_buffer:sample_data(ch_tbl[1][ch], fr+selection_start -1))
        end
      end
  new_buffer:finalize_sample_data_changes()
  set_new_loop_replace ()
  new_sample.name = init_sample_name.."#"
  new_sample.loop_mode = init_loop_mode
end

