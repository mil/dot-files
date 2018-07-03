require('vis')
local current_file = "nofile"

function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

function set_title()
  local f_name = current_file.name
  local abs_path = current_file.path
  local title = f_name .. " (" .. abs_path .. ")"
  vis:command("!xdotool getactivewindow set_window --name '" .. title .. "'")
end

function load_extras()
  local extras = "/home/mil/.config/vis_additional/visrc.lua"
  if file_exists(extras) then 
    dofile(extras)
  end
end

function cb_win_open()
  vis:command('set number')
  vis:command('set colorcolumn 80')
  vis:command('set tabwidth 2')
  vis:command('set cursorline')
  vis:command('set autoindent on')
  vis:command('set shell /bin/sh')
  --vis:command('set th d')
  vis:command('set th l')
  vis:command('set show-tabs on')
  vis:command('set show-eof on')
  vis:command('set savemethod inplace')
  vis:command('set show-newlines off')

  --#File.lines

  if current_file and #current_file.lines > 1000 then
    vis:command('set syntax off')
  end

  if current_file and current_file.path ~= nil then
    local extension = current_file.name:match("^.+(%..+)$")
    if extension == ".ebuild" then vis:command('set syntax bash') end
  end

  --vis:command('set show-spaces on')
  pcall(set_title)
end

function cb_file_open(file)
  current_file  = file
  if file == nil or file.path == nil then return end

  local fmt_macro = ""
  local marker_string = "XQX"
  local pipes = {}
  pipes[".go"] = "gofmt"
  pipes[".dart"] = "dartfmt"
  pipes[".java"] = "cat"

  vis:command('set expandtab on')
  if string.match(file.path, "/home/mil/Mixtapes/Programming") then 
    pipes[".sc"] = "colfmt"
    marker_string = "၃"
    fmt_macro = "$"
    vis:command('set expandtab on')
  elseif string.match(file.path, "Makefile") then 
    vis:command('set expandtab off')
  end


  local extension = file.name:match("^.+(%..+)$")
  if (pipes[extension] ~= nil) then
    fmt_macro = (
      fmt_macro ..
      "<Escape>a" .. 
      marker_string .. 
      "<Escape>vae:|" .. 
      pipes[extension] .. 
      "<Enter><Escape>:x/" .. 
      marker_string ..
      "/<Enter>x"
    )
    vis:command('map! normal ff \'' .. fmt_macro .. "'")
  end
end

function cb_file_save_post(file, path)
  forks = {}
  forks[".java"]  = { }
  forks[".sc"]  = { 
    "oscsend localhost 57120 /reloadFile s " .. path
  }  

  local extension = path:match("^.+(%..+)$")
  if (forks[extension] ~= nil) then for cmdI = 1, #forks[extension] do
      local fork_command = forks[extension][cmdI]
      vis:feedkeys(":!" .. fork_command .. "<Enter><Escape>")
  end end

  return true
end

--if (pipes[extension] ~= nil) then for cmdI = 1, #pipes[extension] do
--  local old_line = vis.win.selection.line
--  local old_col = vis.win.selection.col
--  vis:feedkeys("vae")
--  local pipes_command = pipes[extension][cmdI]
--  local sel = vis.win.selection
--  local code, pipe_res, pipe_stderr = vis:pipe(vis.win.file, sel.range, "dartfmt") 
--  vis.win.file:delete(sel.range)
--  vis.win.file:insert(0, pipe_res)
--  vis.win.selection:to(old_line, old_col)
--  --vis:feedkeys("vae:|" .. pipes_command .. "<Enter>")
--end end


vis.events.subscribe(vis.events.INIT, function()
  vis.events.subscribe(vis.events.WIN_OPEN, cb_win_open)
  vis.events.subscribe(vis.events.FILE_OPEN, cb_file_open)
  vis.events.subscribe(vis.events.FILE_SAVE_POST, cb_file_save_post)
  load_extras()
end)
