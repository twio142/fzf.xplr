local q = xplr.util.shell_quote

local function fzf(args, paths)
  local cmd = q(args.bin) .. " " .. args.args
  if paths ~= nil then
    cmd = cmd .. " <<< " .. q(paths)
  end

  local p = io.popen(cmd, "r")
  local output = p:read("*a")
  p:close()

  local lines = {}
  for line in output:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  local count = #lines

  if count == 0 then
    return
  elseif args.callback then
    local func = xplr.fn
    for part in string.gmatch(args.callback, "[^%.]+") do
      if type(func) == "table" and func[part] then
        func = func[part]
      else
        break
      end
    end

    if type(func) == "function" then
      return func(lines)
    end
  elseif count == 1 then
    local path = lines[1]
    local msg = { FocusPath = path }

    if args.enter_dir then
      local isdir = xplr.util.shell_execute("test", { "-d", path }).returncode == 0
      if isdir then
        msg = { ChangeDirectory = path }
      end
    end

    return { msg }
  else
    local msgs = {}
    for i, line in ipairs(lines) do
      table.insert(msgs, { SelectPath = line })
      if i == count then
        table.insert(msgs, { FocusPath = line })
      end
    end
    return msgs
  end
end

local function setup(args)
  local xplr = xplr

  args = args or {}
  args.name = args.name or "fzf"
  local name = args.name
  args.name = args.name:gsub("%W", "_")
  args.mode = args.mode or "default"
  args.key = args.key or "ctrl-f"
  args.bin = args.bin or "fzf"
  args.args = args.args or ""
  args.callback = args.callback or nil

  if args.recursive == nil then
    args.recursive = false
  end

  if args.enter_dir == nil then
    args.enter_dir = false
  end

  local m = {}
  if string.find(args.mode, "custom.") == 1 then
    m = { "custom", string.match(args.mode, "custom%.(.+)") }
  else
    m = { "builtin", string.gsub(args.mode, "^builtin%.", "") }
  end
  if xplr.config.modes[m[1]][m[2]] == nil then
    xplr.util.debug("Mode not found: " .. args.mode)
    return
  end
  xplr.config.modes[m[1]][m[2]].key_bindings.on_key[args.key] = {
    help = name,
    messages = {
      "PopMode",
      { CallLua = "custom." .. args.name .. ".search" },
    },
  }

  xplr.fn.custom[args.name] = {}
  xplr.fn.custom[args.name].search = function(app)
    if args.recursive then
      return fzf(args)
    else
      local paths = {}
      for _, n in ipairs(app.directory_buffer.nodes) do
        table.insert(paths, n.relative_path)
      end
      return fzf(args, table.concat(paths, "\n"))
    end
  end
end

return { setup = setup }
