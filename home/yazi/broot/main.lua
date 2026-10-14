-- Search with broot, then reveal the chosen path in yazi.
-- Enter prints the path and quits broot; Alt-Enter enters a directory instead.

local get_cwd = ya.sync(function()
  return tostring(cx.active.current.cwd)
end)

local CONF = [[
quit_on_last_cancel: true
show_selection_mark: true
show_matching_characters_on_path_searches: false
default_flags: "-hI"
search_modes: {
  "<empty>": "fuzzy path"
}
special_paths: {
  "**/.git": { show: "never", list: "never", sum: "never" }
  "**/node_modules": { list: "never", sum: "never" }
  "/nix/store": { list: "never", sum: "never" }
}
verbs: [
  { key: "enter", internal: ":print_path" }
  { key: "alt-enter", internal: ":focus" }
]
]]

local function entry()
  local _permit = ui.hide()
  local cwd = get_cwd()

  -- skin, icons and previews, as standalone broot has them (home/terminal/broot.nix)
  local look = (os.getenv("YAZI_CONFIG_HOME") or (os.getenv("HOME") .. "/.config/yazi")) .. "/broot-look.hjson"
  -- broot picks the format from the extension, which tmpname() lacks
  local base = os.tmpname()
  local conf = base .. ".hjson"
  os.remove(base)
  local f = io.open(conf, "w")
  if f then
    f:write(CONF)
    f:close()
  end

  -- broot draws its UI on stderr, so stdout carries only the printed path
  local child, err = Command("broot")
    :arg({ "--conf", conf .. ";" .. look })
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
