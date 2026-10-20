# fcitx5's settings, as data: what ./default.nix hands to
# i18n.inputMethod.fcitx5.settings. Only what differs from the defaults of
# fcitx5 5.1.23 and chinese-addons 5.1.14 (globalconfig.cpp, classicui.h,
# keyboard.h, pinyin.h): a missing key is the default. A change made in
# fcitx5-configtool has to be ported here as its difference from the default
# (docs/manual-steps.md).
{ theme }:
let
  inherit (theme.fonts) ui;
in
{
  # ~/.config/fcitx5/config
  globalOptions."Hotkey/TriggerKeys"."0" = "Alt+space"; # Trigger fcitx5

  # ~/.config/fcitx5/profile (the input method list)
  inputMethod = {
    GroupOrder."0" = "Default";
    "Groups/0" = {
      Name = "Default";
      "Default Layout" = "us";
      DefaultIM = "pinyin";
    };
    "Groups/0/Items/0" = {
      Name = "keyboard-us";
      Layout = "";
    };
    "Groups/0/Items/1" = {
      Name = "pinyin";
      Layout = "";
    };
  };

  # ~/.config/fcitx5/conf/*.conf
  addons = {
    classicui.globalSection = {
      Font = "\"${ui} 14\"";
      MenuFont = "\"${ui} 14\"";
      TrayFont = "\"${ui} Bold 14\"";
      Theme = "Ember";
      DarkTheme = "Ember";
    };

    # keyboard-us's spell-completion "hint" mode: its two hotkeys fire
    # whenever fcitx5 has focus, so they are cleared (empty = no keys).
    keyboard.globalSection = {
      "Hint Trigger" = ""; # was Control+Alt+H (toggle completion)
      "One Time Hint Trigger" = ""; # was Control+Alt+J (one word)
    };

    pinyin = {
      globalSection = {
        CloudPinyinEnabled = "True";
        # Hidden: the first-run setup already happened.
        FirstRun = "False";
      };
      # [ and ] pick the first and second character of the phrase.
      sections.ChooseCharFromPhrase = {
        "0" = "bracketleft";
        "1" = "bracketright";
      };
    };

    notifications.sections.HiddenNotifications."0" = "wayland-diagnose-other";
  };
}
