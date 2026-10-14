# Strings more than one module quotes.
{
  # The list keys the pickers share, in fzf's --bind syntax: Tab marks the row
  # and moves down, Shift-Tab only moves up (fzf's own default marks on the way
  # up too), Ctrl-J/K move. fzf and fzf-tab quote this; television.nix spells
  # the same keys in tv's syntax.
  fzfListBinds = "tab:toggle+down,btab:up,ctrl-j:down,ctrl-k:up";

  # What zoxide's interactive picker (zi, `z foo<Space><Tab>`) adds to the
  # ambient fzf options. Its lines are "score path", hence {2..}; a bare
  # --icons would eat the path as its WHEN value.
  zoxideFzfOpts = "--height 40% --tmux center,70%,60% --preview-window=down --preview 'eza -1 --color=always --icons=always {2..}'";
}
