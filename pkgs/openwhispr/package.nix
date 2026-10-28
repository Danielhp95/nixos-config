# OpenWhispr's AppImage in an FHS sandbox. Upstream's nix/package.nix wraps it
# the same way but still pins 1.7.4, whose Hyprland hotkey code crashes on
# Electron 41 (dbus-next's usocket calls util.isError, gone from Node 24) and
# hangs startup before any model is pre-warmed. Bump version and hash from
# https://github.com/OpenWhispr/openwhispr/releases.
{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "openwhispr";
  version = "1.10.4";

  src = fetchurl {
    url = "https://github.com/OpenWhispr/openwhispr/releases/download/v${version}/OpenWhispr-${version}-linux-x86_64.AppImage";
    hash = "sha256-54SUDZioTBpTHXUPyyxILgiFYBn4ZjiwvQzr/I83WHY=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Runtime tools and libraries the AppImage shells out to or loads but does
  # not bundle; the FHS env already has the Chromium/GTK/X11/nss stack.
  extraPkgs =
    pkgs: with pkgs; [
      xdotool
      wtype
      ydotool
      wl-clipboard # auto-paste on Hyprland needs it since 1.10.4
      xclip
      xsel
      kdotool
      playerctl
      libsecret # safeStorage keyring (API keys at rest)
      libnotify
      libpulseaudio # Chromium mic capture
      pipewire # linux-system-audio-helper (meeting system audio)
      stdenv.cc.cc.lib # libstdc++/libgomp for the bundled whisper/llama/sherpa
    ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/open-whispr.desktop \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=${pname} --no-sandbox'
    cp -r ${appimageContents}/usr/share/icons $out/share/icons
  '';

  meta = {
    description = "Voice dictation, meeting transcription and notes";
    homepage = "https://openwhispr.com/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
