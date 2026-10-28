# Higanbana: the red spider lily, the flower of the dead, as Silent Hill f
# paints it (wallpapers/silent_hill_f_dead_parents_hinato.jpg). A wine-black
# ground, pallid bone text, and one living colour: a scarlet accent, with
# every other hue muted the way the game's red fog mutes it.
#
# Contrast follows Ember and Tokyo Night Violet slot for slot: surfaces and
# text sit within 0.1 of both, accents and hues inside the band the two span.
#
# The shape is fixed by ./lib.nix, which rejects a missing, misspelt or
# malformed entry. Colours are bare lowercase hex.
let
  dark = {
    # Surfaces, darkest to lightest: wine-black, lightening toward the mauve of
    # the misty path. Wine, not brown: a brown ground reads as cosy.
    bgDeep = "1a0d10";
    bg = "25161a";
    bgAlt = "2e1e22";
    surface = "352328";
    border = "442f36";
    divider = "5e454e";

    # Text: bone, fading through rose-grey to fog. Pallor, not a petal pink:
    # pink text reads as healthy skin.
    fg = "dacfc6";
    fgSoft = "bdaea8";
    fgDim = "a38f8e";
    muted = "7c656a";

    # Accent: the lily's scarlet, 緋 (hi-iro) at its own hue, lifted to 6.3:1
    # with the most chroma sRGB holds at that lightness. The deep scarlet
    # lives below it: accentDim is 猩々緋 (shōjōhi), ash 臙脂 (enji).
    # accentBright is a lightness step, so colour-blind eyes keep it.
    accent = "ff6e57";
    accentBright = "ff9175";
    accentDim = "dd463c";
    ash = "b03d3d"; # dried blood: ramp tails (tmux/starship); decorative only — 3:1 on bg

    # One semantic slot each (see ember.nix), muted so the scarlet is the only
    # saturated thing on screen: olive the bamboo, gold the geta wood, steel
    # the 紺 (kon) navy of the uniform, mauve a bruise-plum, sage a cold
    # celadon. error is crimson, past 紅 (kurenai) toward rose and the most
    # saturated red here: 11 dE from the accent (Ember's coral and red: 9.4),
    # so never tell the two apart by hue alone.
    olive = "9da97b";
    gold = "dbb279";
    steel = "8f9dc4";
    mauve = "ab7a9a";
    sage = "86bab5";
    error = "ea497d";

    # Bright ANSI companions.
    oliveBright = "b9c98c";
    goldBright = "f4c987";
    steelBright = "a0b0dc";
    mauveBright = "cf96bb";
    sageBright = "94d5d0";
  };

  # Petal paper, wine-black ink, and the accent turned 朱 (shu), the vermilion
  # of seal paste. Used by noctalia, vicinae and GTK4's light mode; no
  # terminal uses it.
  light = {
    bgDeep = "efe0de";
    bg = "f9eeec";
    bgAlt = "f2e4e2";
    surface = "e8d7d6";
    border = "d8c2c3";
    divider = "c3a9ac";

    fg = "342126";
    fgSoft = "563f44";
    fgDim = "775e62";
    muted = "977b7e";

    accent = "c03709";
    accentBright = "a11d0b";
    accentDim = "da7d6b";
    ash = "b2584f";

    olive = "556631";
    gold = "8c641b";
    steel = "4e6197";
    mauve = "864776";
    sage = "266c67";
    error = "b01357";

    oliveBright = "415117";
    goldBright = "734e00";
    steelBright = "3b4d81";
    mauveBright = "6e315f";
    sageBright = "045652";
  };
in
{
  inherit dark light;

  # The 16 ANSI colours, where they are not ./lib.nix's ansiDefaults. Ember's
  # way: the terminal's red IS the accent, and the crimson error has no slot,
  # so a program that prints its errors in red prints them scarlet.
  ansi = {
    red = "accent";
    brightRed = "accentBright";
  };

  # Colours outside the 25 slots, each with one or two consumers.
  extra = {
    # noctalia's error role (urgent workspaces, notification badges): the
    # crimson pushed brighter and pinker, so an urgent pill is not one more
    # scarlet pill in a scarlet bar.
    urgent = {
      dark = "f976ad";
      light = "error";
    };
    # vicinae's orange accent and danvim's constants and numbers: 狐色
    # (kitsune-iro), the fox's amber, clear of both the scarlet and the gold.
    orange = {
      dark = "e18c22";
      light = "aa4f03";
    };
    # danvim's types and specials: the Fox Mask's blue lantern, the one cold
    # light in the Dark Shrine.
    cyan = "8cd1fa";
    # The start page's fog veil: the wallpaper's red haze.
    fog = "ceb7ba";
    # The Claude statusline's high / xhigh / max effort pills: the scarlet
    # catching fire, never toward the crimson error.
    heat = [
      "ff774b"
      "ff8c4a"
      "ffa449"
    ];
    # The start page's five-stop grade for the painting, from the wallpaper's
    # own tone curve; the last stop stays darker than fg.
    artRamp = [
      "0e0506"
      "34181c"
      "66383c"
      "9b6c6d"
      "cdb0aa"
    ];
  };

  # Which name plays which part, stated once for both halves.
  roles = {
    # role -> ANSI colour name (IPython, prompt_toolkit, glamour): Ember's
    # table, since the ANSI slots are Ember's.
    ansi = {
      accent = "red";
      accentBright = "brightRed";
      definition = "red";
      failure = "brightRed"; # error has no slot; bright red is the nearest
      structure = "magenta";
      metadata = "blue";
      emphasis = "yellow";
      value = "cyan";
      string = "green";
    };

    # hue name -> slot name (vicinae accents; its orange is extra.orange).
    hues = {
      red = "accent";
      yellow = "gold";
      green = "olive";
      cyan = "sage";
      blue = "steel";
      purple = "mauve";
      magenta = "mauve";
    };

    # tmux copy mode. The current match is the brighter fill; not the accent,
    # which tmux's mark already uses.
    search = {
      match = "sage";
      current = "gold";
    };
  };

  # Everything that is not a colour.
  meta = {
    name = "Higanbana";
    description = "Dried blood and ash, with a single scarlet bloom";
    light.description = "Petal paper with vermilion seal ink";
    gtk = {
      package = pkgs: pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
      # See tokyo-night-violet.nix: libadwaita's own sheet must not be shadowed,
      # and every adw-gtk3 colour is a named-colour reference.
      gtk4Import = false;
      paletteCss = {
        gtk3 = true;
        gtk4 = true;
      };
    };
    # Only seen where ~/.config/gtk-4.0/gtk.css is not read.
    adwaitaAccent = "red";
    # Ember's pointer with the amber swapped for the scarlet (./bibata.nix).
    cursor = rec {
      package =
        pkgs:
        pkgs.callPackage ./bibata.nix { } {
          inherit name;
          body = dark.accent;
          outline = "ffffff";
          watch = dark.bg;
        };
      name = "Bibata-Modern-Scarlet";
      size = 20;
    };
    icons = {
      package = pkgs: pkgs.papirus-icon-theme;
      name = "Papirus";
    };
    # tokyonight is danvim's palette-driven base: every colour in the buffer
    # comes from the slots above (danvim's theme/tokyonight.lua).
    nvim.family = "tokyonight";
    # kitty's cursor trail: scarlet body, deeper scarlet edge.
    trail = {
      fill = "accent";
      rim = "accentDim";
    };
  };
}
