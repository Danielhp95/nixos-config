# A notebook as the markdown it reads as: prose and raw cells as they are,
# code cells fenced in the notebook's own language. Previews in yazi
# (../yazi/default.nix) and broot (./broot.nix) run it with `jq -r -f`.
(.metadata.language_info.name // .metadata.kernelspec.language // "python" | ascii_downcase) as $lang
| .cells[]
| (.source | if type == "array" then join("") else . end) as $src
| if .cell_type == "code" then "```\($lang)", $src, "```", "" else $src, "" end
