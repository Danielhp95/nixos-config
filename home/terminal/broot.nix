# broot, skinned from the palette. Its config is broot's shipped defaults with
# these settings merged on top, key by key. The yazi plugin (../yazi/broot)
# reuses the skin, icons and previews.
{
  pkgs,
  lib,
  theme,
  ...
}:
let
  c = slot: "rgb(${theme.colour.rgbCommas theme.${slot}})";

  # A transformer that renders the file to a PNG, previewed as an image
  toImage = input_extensions: command: {
    inherit input_extensions command;
    output_extension = "png";
    mode = "image";
  };

  # broot hardcodes its icons, and its nerdfont table leaves these types on
  # the plain file icon though most of the glyphs ship with it. Extension ->
  # icon name; the names typst and subtitle are added below.
  extraIcons = {
    xml = "xml";
    tex = "tex";
    sty = "tex";
    cls = "tex";
    bib = "tex";
    typ = "typst";
    conf = "config";
    cfg = "config";
    ini = "ini";
    bash = "shell";
    zsh = "shell";
    jsx = "reactjs";
    tsx = "reactts";
    mjs = "js";
    cjs = "js";
    scss = "scss";
    sass = "sass";
    pyi = "python";
    pyw = "python";
    pyx = "cython";
    pxd = "cython";
    graphql = "graphql";
    gql = "graphql";
    proto = "protobuf";
    ps1 = "powershell";
    psm1 = "powershell_psm";
    psd1 = "powershell_psd";
    bat = "bat";
    cmd = "bat";
    hjson = "hjson";
    jsonl = "json";
    ndjson = "json";
    jsonnet = "jsonnet";
    libsonnet = "jsonnet";
    srt = "subtitle";
    vtt = "subtitle";
    ass = "subtitle";
    heic = "image";
    heif = "image";
    jxl = "image";
    lzma = "zip2";
    lz4 = "zip2";
    parquet = "db";
    npy = "binary";
    npz = "binary";
    pkl = "binary";
    pickle = "binary";
    pth = "binary";
    onnx = "binary";
  };

  # Each table is a Rust array literal: drop its closing bracket, append, close.
  # A later entry wins. .ipynb pointed at 0x10018B, a code point no font has
  # (E80F is dev-jupyter), and ini and protobuf at F15B, the plain file icon.
  broot = pkgs.broot.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      data=resources/icons/nerdfont/data
      append() { sed -i '$d' "$1"; cat >> "$1"; echo ']' >> "$1"; }
      substituteInPlace $data/icon_name_to_icon_code_point_map.rs \
        --replace-fail 0x10018B 0xE80F
      append $data/icon_name_to_icon_code_point_map.rs <<'EOF'
      ( "file_type_typst", 0xF37F ),
      ( "file_type_subtitle", 0xF0A16 ),
      ( "file_type_ini", 0xE615 ),
      ( "file_type_protobuf", 0xEA8B ),
      EOF
      append $data/extension_to_icon_name_map.rs <<'EOF'
      ${
        lib.concatStrings (
          lib.mapAttrsToList (ext: name: "( \"${ext}\", \"file_type_${name}\" ),\n") extraIcons
        )
      }EOF
    '';
  });
in
{
  programs.broot = {
    enable = true;
    package = broot;
    # No `br` cd-on-exit function, as yazi has none either
    enableZshIntegration = false;
    enableNushellIntegration = false;
    settings = {
      # The defaults also import skins/dark-blue.hjson (white.hjson on a light
      # terminal), and an import overrides this file's skin.
      imports = [ "verbs.hjson" ];

      # The terminal font (fonts.nix) is a Nerd Font; the table is patched above
      icon_theme = "nerdfont";

      # Image previews as kitty's Unicode placeholders, the only kitty
      # placement tmux redraws, scrolls and hides with its pane.
      kitty_graphics_display = "unicode";

      # Run when a matching file is previewed (cached for the session); on
      # failure broot previews the file as it is.
      preview_transformers = [
        # PDFs: the first page. {output-dir}, as pdftoppm adds the extension.
        (toImage
          [ "pdf" ]
          [
            "${pkgs.poppler-utils}/bin/pdftoppm"
            "-png"
            "-singlefile"
            "-scale-to"
            "1500"
            "{input-path}"
            "{output-dir}/page"
          ]
        )
        # Videos: a frame 10% in
        (toImage
          [ "mp4" "mkv" "webm" "mov" "avi" "m4v" ]
          [
            (lib.getExe pkgs.ffmpegthumbnailer)
            "-i"
            "{input-path}"
            "-o"
            "{output-path}"
            "-s"
            "1024"
          ]
        )
        # Image formats broot cannot decode itself
        (toImage
          [ "heic" "heif" "avif" "jxl" ]
          [
            (lib.getExe' pkgs.imagemagick "magick")
            "{input-path}"
            "{output-path}"
          ]
        )
        # Notebooks as markdown, as yazi shows them; stdin to stdout
        {
          input_extensions = [ "ipynb" ];
          output_extension = "md";
          mode = "text";
          command = [
            (lib.getExe pkgs.jq)
            "-r"
            "-f"
            "${./notebook-cells.jq}"
          ];
        }
        # JSON pretty-printed, as minified JSON is one long line
        {
          input_extensions = [ "json" ];
          output_extension = "json";
          mode = "text";
          command = [
            (lib.getExe pkgs.jq)
            "."
          ];
        }
      ];

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
