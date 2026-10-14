{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.home.sessionVariables) EDITOR TERMINAL;

  types = prefix: map (name: "${prefix}/${name}");
  handledBy = app: mimeTypes: lib.genAttrs mimeTypes (_: [ app ]);

  # What $EDITOR opens. xdg-open matches a type by its exact name, with no
  # fallback from a subtype to text/plain, so each one is spelled out, and an
  # alias (text/x-markdown, application/x-yaml) sits beside its real name.
  # A type missing here still reaches the editor from GTK apps, which do fall
  # back; from xdg-open it lands in $BROWSER.
  textTypes =
    types "text" [
      "plain"
      "markdown"
      "x-markdown"
      "x-readme"
      "x-rst"
      "org"
      "x-log"
      "x-changelog"
      "x-authors"
      "x-copying"
      "x-install"
      # Writing
      "x-tex"
      "x-bibtex"
      "vnd.typst"
      # Data and configuration
      "csv"
      "tab-separated-values"
      "xml"
      "x-systemd-unit"
      "x-dbus-service"
      "x-dockerfile"
      "x-patch"
      "x-diff"
      # Code
      "x-shellscript"
      "x-sh"
      "x-python"
      "x-python3"
      "x-nix"
      "x-lua"
      "rust"
      "x-go"
      "x-c"
      "x-csrc"
      "x-chdr"
      "x-c++src"
      "x-c++hdr"
      "x-moc"
      "x-java"
      "x-kotlin"
      "x-scala"
      "x-csharp"
      "x-haskell"
      "x-ocaml"
      "x-elixir"
      "x-erlang"
      "x-common-lisp"
      "x-scheme"
      "x-emacs-lisp"
      "julia"
      "x-matlab"
      "x-fortran"
      "x-pascal"
      "x-tcl"
      "tcl"
      "javascript"
      "css"
      "x-scss"
      "x-qml"
      "vnd.graphviz"
      "x-makefile"
      "x-cmake"
      "x-meson"
      "x-cython"
      "x-dsrc"
      "x-gradle-kts"
      "x-gettext-translation"
      "vtt"
      "vnd.trolltech.linguist" # what a TypeScript .ts reads as
    ]
    ++ types "application" [
      "json"
      "json5"
      "yaml"
      "x-yaml"
      "toml"
      "xml"
      "sql"
      "x-desktop"
      "x-zerosize" # an empty file
      "x-shellscript"
      "x-nuscript"
      "x-fishscript"
      "javascript"
      "x-javascript"
      "typescript"
      "x-perl"
      "x-ruby"
      "x-php"
      "x-powershell"
      "x-bat"
      "x-subrip"
      "x-troff-man"
      "rss+xml"
      "atom+xml"
      "x-ipynb+json"
      "x-tiled-tsx" # what a React .tsx reads as
      "vnd.dart" # and a Lean .lean
    ];

  # Every picture format gThumb reads (it is built with libheif). Left to
  # themselves, GIF went to Chromium; SVG, TIFF, JPEG XL, AVIF and HEIF to
  # imv; and an icon to $BROWSER, as gThumb lists it as image/x-ico.
  # imv (imv.desktop) is installed too, if gThumb should go.
  imageTypes = types "image" [
    "png"
    "jpeg"
    "webp"
    "bmp"
    "gif"
    "svg+xml"
    "tiff"
    "jxl"
    "avif"
    "heif"
    "vnd.microsoft.icon"
  ];

  # The video and audio types mpv.desktop does not list by the name xdg-open
  # sees, so they went to $BROWSER: Matroska under its name since
  # shared-mime-info 2.4 (mpv lists the x-matroska alias, and xdg-open never
  # resolves an alias), and Ogg's Opus, FLAC and Speex. Every other one finds
  # mpv by itself.
  mediaTypes =
    types "video" [
      "matroska"
      "matroska-3d"
    ]
    ++ types "audio" [
      "matroska"
      "x-opus+ogg"
      "x-flac+ogg"
      "x-speex+ogg"
      "x-speex"
      "x-m4b"
      "x-aifc"
    ];

  # Comic book archives, which zathura-cb lists only by their old x-cbz names
  comicTypes = types "application" [
    "vnd.comicbook+zip"
    "vnd.comicbook-rar"
  ];

  # Spreadsheets, in VisiData (desktopEntries below). Word processor files and
  # slides have no app, so they still land in $BROWSER.
  sheetTypes = types "application" [
    "vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    "vnd.ms-excel"
    "vnd.oasis.opendocument.spreadsheet"
  ];

  # Archives open in File Roller, to browse without unpacking. Nautilus
  # claimed them by default, and it unpacks on open (numpy's .npz is a zip).
  archiveTypes = types "application" [
    "zip"
    "x-tar"
    "x-compressed-tar"
    "x-bzip2-compressed-tar"
    "x-xz-compressed-tar"
    "x-zstd-compressed-tar"
    "x-lzma-compressed-tar"
    "x-7z-compressed"
    "vnd.rar"
    "gzip"
    "x-bzip2"
    "x-xz"
    "zstd"
    "x-lzma"
    "x-lz4"
    "x-cpio"
    "java-archive"
    "vnd.debian.binary-package"
    "x-rpm"
  ];
in
{
  xdg = {
    enable = true;
    mime.enable = true;

    # $EDITOR in a window of its own, in place of the entry the editor's
    # package ships (same file name, and Home Manager's wins). That one says
    # Terminal=true: xdg-open ignores the key and starts nvim with no terminal,
    # and GLib (GTK apps, Firefox, the portal) refuses to start it without a
    # terminal it knows, which kitty is not. Either way a text file opened
    # from an app opened nothing.
    desktopEntries.${EDITOR} = {
      name = EDITOR;
      genericName = "Text Editor";
      exec = "${TERMINAL} -e ${EDITOR} %F";
      icon = EDITOR;
      categories = [
        "Utility"
        "TextEditor"
        "Development"
      ];
      mimeType = textTypes;
    };
    desktopEntries.visidata = {
      name = "VisiData";
      genericName = "Spreadsheet Viewer";
      exec = "${TERMINAL} -e vd %F";
      icon = "x-office-spreadsheet";
      categories = [
        "Office"
        "Spreadsheet"
      ];
      mimeType = sheetTypes;
    };

    mimeApps = {
      enable = true;
      defaultApplications =
        handledBy "${EDITOR}.desktop" textTypes
        // handledBy "org.gnome.gThumb.desktop" imageTypes
        // handledBy "mpv.desktop" mediaTypes
        // handledBy "org.pwmt.zathura-cb.desktop" comicTypes
        // handledBy "visidata.desktop" sheetTypes
        // handledBy "org.gnome.FileRoller.desktop" archiveTypes
        # inode/directory is yazi's: ./yazi/file-manager.nix.
        // {
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
          "x-scheme-handler/mailto" = [ "io.github.c9dev.PenguinMail.desktop" ];
          # GNOME Calendar claims it too
          "text/calendar" = [ "io.github.c9dev.PenguinMail.desktop" ];
          "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/chrome" = [ "firefox.desktop" ];
          "text/html" = [ "firefox.desktop" ];
          "application/x-extension-htm" = [ "firefox.desktop" ];
          "application/x-extension-html" = [ "firefox.desktop" ];
          "application/x-extension-shtml" = [ "firefox.desktop" ];
          "application/xhtml+xml" = [ "firefox.desktop" ];
          "application/x-extension-xhtml" = [ "firefox.desktop" ];
          "application/x-extension-xht" = [ "firefox.desktop" ];
          "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
        };
    };
  };

  home.packages = [
    pkgs.visidata # `vd`, and the spreadsheets above
    pkgs.file-roller # the archives above
  ];
}
