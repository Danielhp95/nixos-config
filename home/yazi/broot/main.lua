-- Search with broot, then reveal the chosen path in yazi.
-- Enter on a file, or Alt-Enter on anything, prints the path and quits broot.

local get_cwd = ya.sync(function()
  return tostring(cx.active.current.cwd)
end)

local CONF = [[
verbs: [
  { key: "enter", internal: ":print_path", apply_to: "file" }
  { key: "alt-enter", internal: ":print_path" }
]
]]

local function entry()
  local _permit = ui.hide()
  local cwd = get_cwd()

  local conf = os.tmpname()
  local f = io.open(conf, "w")
  if f then
    f:write(CONF)
    f:close()
  end

  -- broot draws its UI on stderr, so stdout carries only the printed path
  local child, err = Command("broot")
    :arg({ "--conf", conf })
    :cwd(cwd)
    :stdin(Command.INHERIT)
    :stdout(Command.PIPED)
    :stderr(Command.INHERIT)
    :spawn()
  if not child then
    os.remove(conf)
    return ya.notify { title = "broot", content = tostring(err), timeout = 5, level = "error" }
  end

  local output = child:wait_with_output()
  os.remove(conf)
  local target = output and output.stdout:gsub("%s+$", "") or ""
  if target ~= "" then
    ya.emit("reveal", { target })
  end
end

return { entry = entry }
