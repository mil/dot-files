require('vis')
local current_file = "nofile"
local sc_fmt_macro = "<Escape>v\"myr၃vae:|colfmt<Enter><Escape>/၃<Enter>x\"mP"


vis.events.subscribe(vis.events.INIT, function()
 -- Your global configuration options

  vis.events.subscribe(vis.events.FILE_OPEN, function(file)
    current_file  = file
  end)

  vis.events.subscribe(vis.events.FILE_SAVE_POST, function(file, path)
    pipes = {}
    pipes[".go"] =   { "gofmt" } 
    pipes[".java"] = { "cat" } 
    if string.match(path, "/home/mil/Mixtapes/Programming") then 
      pipes[".sc"] =   { "colfmt" }
    end

    forks = {}
    forks[".java"]  = { }
    forks[".sc"]  = { "oscsend localhost 57120 /reloadFile s " .. path }

    local extension = path:match("^.+(%..+)$")
    if (forks[extension] ~= nil) then for cmdI = 1, #forks[extension] do
        local fork_command = forks[extension][cmdI]
        vis:feedkeys(":!" .. fork_command .. "<Enter><Escape>")
    end end

    --if (pipes[extension] ~= nil) then for cmdI = 1, #pipes[extension] do
        --local pipes_command = pipes[extension][cmdI]
        --vis:feedkeys("Escape>v\"myr၃vae:|" .. pipes_command .. "<Enter><Escape>/၃<Enter>x\"mP")
        --vis:feedkeys("vae:|" .. pipes_command .. "<Enter>")
    --end end

    return true
  end)
end)

function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  vis:command('set number')
  vis:command('set colorcolumn 80')
  vis:command('set expandtab')
  vis:command('set tabwidth 2')
  vis:command('set cursorline')
  vis:command('set autoindent on')
  vis:command('set shell /bin/sh')
  vis:command('set theme miles')
  vis:command('set show-tabs on')
  vis:command('set show-eof on')

  vis:command('map! normal ff \'' .. sc_fmt_macro .. "'")
  vis:command('map! normal fF :w<Enter>\'' .. sc_fmt_macro .. "'")

  function set_title()
    local f_name = current_file.name
    local abs_path = current_file.path
    local title = f_name .. " (" .. abs_path .. ")"
    vis:command("!xdotool getactivewindow set_window --name '" .. title .. "'")
  end
  pcall(set_title)
end)

local extras = "/home/mil/.config/vis_additional/visrc.lua"
if file_exists(extras) then 
  dofile(extras)
end
