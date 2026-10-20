# Upgrade checklist

What to look at when an input or nixpkgs moves. A build that passes is not
enough for these: lnav, yazi, television and IRIS ignore keys they do not know
without a word, and the patches below only fail the build when an anchor moves.

| When this moves | Look at | In |
|---|---|---|
| nixpkgs' yazi | The yazi-rs/plugins pin must track yazi's version: the plugin API is versioned and a mismatch only fails at runtime. | `home/yazi/default.nix` (`officialPlugins`) |
| nixpkgs' yazi | Theme keys. An unknown or renamed key silently reverts to the preset (v26 moved the hover styles from `[mgr]` to `[indicator]`). | `home/yazi/theme.nix` |
| IRIS (`iris` input, pinned) | Upstream pins a vendorHash, so an update that changes go.mod without bumping it fails to build: re-pin the previous rev. | `flake.nix` |
| IRIS | Re-read the control flow around each `--replace-fail` anchor, and re-diff the hook half of `iris init zsh` (root/init.go). An unknown config or theme key is ignored without a word. | `home/terminal/iris.nix` |
| lnav | Keep the theme's keys equal to the union of the bundled themes (`~/.config/lnav/configs/default/*.json.sample`; 43/26/15/4 per section as of 0.14.1). lnav does not validate a theme. | `home/lnav.nix` |
| television | `theme_overrides` holds every key tv 0.15.9's ThemeOverrides accepts; unknown names are ignored. `settings` holds only non-defaults, which rests on `merge_with_default` (television/config/mod.rs): keybindings merge key by key, `channel_triggers` replaces the default table whole, other keys come from the built-in defaults. Re-read it on a bump. | `home/terminal/television.nix` |
| tmux-continuum | The patch deletes two calls and the build fails if either moves: re-read `continuum.tmux` then. | `home/tmux/default.nix` |
| nixpkgs | Move the `pkgs.multiverse.at "<date>"` date along with it (grayjay). | `home/apps.nix` |
| IPython | The traceback colouring rebinds private names (`ultratb.get_style_by_name`, `VerboseTB._tb_highlight_style`). It is wrapped in try/except, so a rename shows only as wrong colours. | `home/ipython/ipython_config.py` |
| Hyprland, hy3 | Pin both revs and move them together, to a Hyprland rev hy3 supports. | `flake.nix` |
| hy3 | The follow patch is outfoxxed/hy3#343, unmerged: drop it once that lands, and re-apply it by hand if the rev moves past its context. | `pkgs/overlay.nix`, `home/hyprland/hy3-follow-without-node.patch` |
| share picker (input) | `--replace-fail` names the vendored `hyprland-0.4.0-beta.2` crate path, so the build fails when the crate moves: check then whether workspace `id` still needs `#[serde(default)]`. | `home/hyprland/share-picker/package.nix` |
| nixpkgs' broot | The icon-table patch `--replace-fail`s one code point and appends entries to two Rust arrays; a failure means the tables moved. | `home/terminal/broot.nix` |
| wl-kbptr | A `fetchFromGitHub` rev, not a flake input: `nix flake update` never moves it. Bump rev and hash by hand and re-check both patches (and the PR #80 TODO). | `home/hyprland/wl-kbptr/package.nix` |
| penguin-mail (input) | The rev is in the input URL, so `nix flake update` keeps it: move it by hand. The overlay appends to its `preFixup`. | `flake.nix`, `pkgs/overlay.nix` |
| noctalia | Re-check the hand-written plugin API definitions; a stale entry type-checks and then fails at runtime. | `home/noctalia/noctalia.d.luau` |
| kernel, GRUB | A generation with its own kernel costs about 116 MB of the 1 GB ESP; `configurationLimit` and `nh`'s `--keep` are sized for that. | `hosts/lenovo/hardware.nix` (`configurationLimit`), `nixos/nix.nix` (`--keep`), `nixos/esp-check.nix` |
