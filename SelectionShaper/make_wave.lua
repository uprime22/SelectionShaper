require ('globals')
require ('selection_with_upbeat')
require ('waves')
-- fn:wave form function .see 'waves.lua'
-- 選択範囲で描く曲線の形の定義。
-- 0~1のX軸で選択範囲の時間、Y軸でVolume(liner)を表すような関数を与える。
-- x=0:選択範囲の始点、x=1:選択範囲の終点。
-- y=0:silence、y=±1:Max Volume,または元のVolume。
-----------------------------------------------------



-- making up the function for modulating
function mod_fn_shaped (mod_fn)
  local type_x = type(mod_fn)
  if
    type_x == "number"
  then return
    function (x) return mod_fn*x end
  elseif
    type_x == "function"
  then return
    mod_fn
  else return
    function (x) return x end
  end
end

-- ステレオ対応用に、選択chに応じて、fnを変換する
--  meta-function,for make_wave。
-- モノラルのselected_channel が3なのに注意。
--  mod_fn: function modulating frequency  
function fn_with_ch_in_make_wave (fn,ch,mod_fn)
  if ch == init_selected_channel or init_selected_channel == 3 then
    return
    function (fr)
      local x = (fr-selection_start)/init_range
      return fn(mod_fn_shaped (mod_fn)(x),ch)
    end
  else
    return
    function (fr)
      return init_buffer:sample_data(ch,fr)
    end
  end
end



-- 新たなSampleを作ってそこからコピーして、し終わったら消す、
-- というよな事をしてます。

-- 選択範囲に波形を作成。
function make_wave (fn,mod_fn)
  get_init_env()
  if smpl_ok == false then return nil end
  

  create_new (init_number_of_frames,init_number_of_channels)
  new_buffer:prepare_sample_data_changes()

  for ch = 1,init_number_of_channels do
    local fn_shpd = fn_with_ch_in_make_wave (fn,ch,mod_fn)
    for fr = 1,selection_start-1 do
      new_buffer
      :set_sample_data(
        ch,fr,
        init_buffer
        :sample_data(ch,fr))
    end
    for fr = selection_start,selection_end do
      new_buffer
      :set_sample_data(
        ch,fr,
        fn_shpd(fr))
    end        
    for fr = selection_end+1,init_number_of_frames do
      new_buffer
      :set_sample_data(
        ch,fr,
        init_buffer
        :sample_data(ch,fr))  
    end
  end      
  new_buffer:finalize_sample_data_changes()
  if init_loop_start >init_number_of_frames or
    init_loop_end > init_number_of_frames
  then
      init_loop_start = 1 ; init_loop_start = init_number_of_frames
  end
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


-- 選択chによってfnを変換するmeta-function,for set_fade。
function fn_with_ch_in_set_fade (fn,ch,mod_fn)
  if ch == init_selected_channel or init_selected_channel == 3 then return
    function (fr)
      local x = (fr-selection_start)/init_range
      return fn(mod_fn_shaped (mod_fn)(x),ch)
    end
  else return
    function ()
      return 1
    end
  end
end

-- 関数fnを使って、選択範囲をFadeする。(掛け算）
--  mod_fn: function modulating frequency  
function set_fade (fn,mod_fn)
  get_init_env()
  if smpl_ok == false then return nil end
  
  local selection_range = init_range -1
  
  create_new (init_number_of_frames,init_number_of_channels)
  new_buffer:prepare_sample_data_changes()
  
  
  for ch = 1,init_number_of_channels do
    local fn_shpd = fn_with_ch_in_set_fade (fn,ch,mod_fn)
    for fr = 1,selection_start-1 do
      new_buffer
      :set_sample_data(
        ch,fr,
        init_buffer
        :sample_data(ch,fr))
    end
    for fr = selection_start,selection_end do
      new_buffer
      :set_sample_data(
        ch,fr,
        (fn_shpd(fr)
          *(init_buffer
            :sample_data(ch,fr))))
    end        
    for fr = selection_end+1,init_number_of_frames do
      new_buffer
      :set_sample_data(
        ch,fr,
        init_buffer
        :sample_data(ch,fr))  
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


