# caracole: the nightly run that builds the chord sheet library, its page on
# this machine and the tailnet, and `sudo caracole-admin <command>` for the
# rest. Everything lives in /var/lib/caracole, as the units' sandbox hides
# /home; docs/manual-steps.md moves a library in.
{ inputs, host, ... }:
{
  imports = [ inputs.caracole.nixosModules.default ];

  # No ntfy topic: this repo is public, and a topic's URL is all it takes to
  # read it. A failed unit says so in the journal alone.
  services.caracole = {
    enable = true;
    web = {
      enable = true;
      # Every address, which the firewall keeps to this machine and the
      # tailnet: port 8737 stays shut, and tailscale0 is trusted
      # (./tailscale.nix). Listening on the tailnet address alone would fail
      # the unit for good when tailscale is not up 5 minutes after boot.
      address = "0.0.0.0";
    };
    # Chords worked out from audio: the caracole-autochords unit after each
    # nightly run, the YouTube step, and the page's sheet from a YouTube video.
    # Brings torch, beat_this, librosa, yt-dlp and the two model files.
    autochords.enable = true;
  };

  # The library is group caracole, setgid, mode 2775: wanted.txt,
  # overrides.toml and _inbox/ are editable without sudo.
  users.users.${host.user}.extraGroups = [ "caracole" ];
}
