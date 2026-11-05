# Super+Shift+Y's yazi (hyprland.lua): opening a file closes the window. yazi
# runs as a chooser, so opening (Enter, l, o) quits it and names the files,
# which xdg-open then gets. An app with a window of its own is started apart
# from this terminal, which then closes; one that runs in a terminal (nvim
# for text) takes the window over, and it closes when that app exits.

# Whether the app xdg-open picks for `file` runs in a terminal. xdg-open
# itself ignores Terminal= and runs it in the terminal it was called from.
def in-terminal [file: string] {
  let mime = ^xdg-mime query filetype $file | str trim
  let app = ^xdg-mime query default $mime | str trim
  if $app == "" { return false }
  let data_dirs = (
    [($env.XDG_DATA_HOME? | default $"($env.HOME)/.local/share")]
    ++ ($env.XDG_DATA_DIRS? | default "/usr/share" | split row ":")
  )
  let entry = $data_dirs | each {|dir| $"($dir)/applications/($app)" } | where {|p| $p | path exists } | get 0?
  if $entry == null { return false }
  open --raw $entry | lines | any {|line| ($line | str trim) == "Terminal=true" }
}

def main [] {
  let out = mktemp -t yazi-float.XXXXXX
  try { ^yazi $"--chooser-file=($out)" }
  let chosen = open --raw $out | lines | where {|line| $line != "" }
  rm -f $out

  let terminal = $chosen | where {|file| in-terminal $file }
  for file in ($chosen | where {|file| $file not-in $terminal }) {
    # Its own session and no ties to this terminal, so it outlives the window.
    ^setsid -f sh -c 'exec xdg-open "$1" </dev/null >/dev/null 2>&1' _ $file
  }
  for file in $terminal {
    try { ^xdg-open $file }
  }
}
