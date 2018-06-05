-- When you customize local key bindings in this tool,
--  please change this file.

-- Key passthrough function for keyboard piano,etc.  
key_handle =
function(dialog,key)
  -- entered keys can be watched in console
  rprint(key)
  
  --[
  --for flick and paste
  if key.modifiers == 'control' and key.name == 'v'
    and flick_paste_check_value == true then
    flick_range ()
  end
  --]]
  
  renoise.app().window.active_middle_frame =
  renoise.ApplicationWindow.MIDDLE_FRAME_INSTRUMENT_SAMPLE_EDITOR
  return key
end


  