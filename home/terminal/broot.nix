# broot, skinned from the palette. Its config is broot's shipped defaults with
# these settings merged on top, key by key. The yazi plugin (../yazi/broot)
# reuses the skin.
{ theme, ... }:
let
  c = slot: "rgb(${theme.colour.rgbCommas theme.${slot}})";
in
{
  programs.broot = {
    enable = true;
    settings = {
      # The defaults also import skins/dark-blue.hjson (white.hjson on a light
      # terminal), and an import overrides this file's skin.
      imports = [ "verbs.hjson" ];

      # An element is "fg bg attrs"; broot never validates the names, so a typo
      # silently keeps its default.
      skin = {
        default = "${c "fg"} none";
        tree = "${c "border"} none";
        parent = "${c "fgDim"} none";
        file = "${c "fg"} none";
        directory = "${c "gold"} none bold";
        exe = "${c "olive"} none";
        link = "${c "mauve"} none";
        pruning = "${c "muted"} none italic";
        perm__ = "${c "muted"} none";
        owner = "${c "muted"} none";
        dates = "${c "muted"} none";
        sparse = "${c "muted"} none";
        git_branch = "${c "mauve"} none";
        git_insertions = "${c "olive"} none";
        git_deletions = "${c "error"} none";
        git_status_current = "${c "muted"} none";
        git_status_modified = "${c "gold"} none";
        git_status_new = "${c "olive"} none bold";
        git_status_ignored = "${c "muted"} none";
        git_status_conflicted = "${c "error"} none";
        git_status_other = "${c "error"} none";
        selected_line = "none ${c "surface"}";
        char_match = "${c "accent"} none bold underlined";
        file_error = "${c "error"} none italic";
        flag_label = "${c "muted"} none";
        flag_value = "${c "accent"} none bold";
        input = "${c "fg"} none";
        status_error = "${c "error"} ${c "bgAlt"}";
        status_job = "${c "gold"} ${c "bgAlt"}";
        status_normal = "${c "fgDim"} ${c "bgAlt"}";
        status_italic = "${c "accent"} ${c "bgAlt"}";
        status_bold = "${c "fg"} ${c "bgAlt"} bold";
        status_code = "${c "gold"} ${c "bgAlt"}";
        status_ellipsis = "${c "muted"} ${c "bgAlt"}";
        purpose_normal = "${c "fgDim"} none";
        purpose_italic = "${c "accent"} none";
        purpose_bold = "${c "fg"} none bold";
        purpose_ellipsis = "${c "muted"} none";
        scrollbar_track = "${c "border"} none";
        scrollbar_thumb = "${c "accent"} none";
        help_paragraph = "${c "fg"} none";
        help_bold = "${c "accent"} none bold";
        help_italic = "${c "mauve"} none italic";
        help_code = "${c "gold"} ${c "bgAlt"}";
        help_headers = "${c "accent"} none bold";
        help_table_border = "${c "border"} none";
        preview = "${c "fg"} none";
        preview_title = "${c "fgDim"} ${c "bgAlt"}";
        preview_line_number = "${c "muted"} none";
        preview_match = "${c "accent"} none bold";
      };
    };
  };
}
