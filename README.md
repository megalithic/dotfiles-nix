```bash
┌┬┐┌─┐┌─┐┌─┐┬  ┬┌┬┐┬ ┬┬┌─┐
│││├┤ │ ┬├─┤│  │ │ ├─┤││   (nix'd)
┴ ┴└─┘└─┘┴ ┴┴─┘┴ ┴ ┴ ┴┴└─┘
@megalithic 🗿
```

<p align="center">

![alt text](https://raw.githubusercontent.com/megalithic/dotfiles/main/screenshot.png "screenshot")

</p>

## 🚀 Installation

Install [Determinate `nix`](https://github.com/DeterminateSystems/nix-installer).

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Run the installer

```bash
nix run --option eval-cache false github:megalithic/dotfiles-nix --refresh
```

## Usage

You can see the current tasks by running `just --list`

```bash
$ just --list
Available recipes:
    default
    fix-shell-files # fix shell files. this happens sometimes with nix-darwin
    hm              # run home-manager switch
    news
    rebuild         # rebuild nix darwin
    uninstall       # uninstalls the nix determinate installer
    update          # updates brew, flake, and runs home-manager
    update-brew     # update and upgrade homebrew packages
    update-flake    # update your flake.lock
    upgrade-nix     # upgrades nix

```

> **_NOTE_**: this nix setup is super unstable at the moment.

---

### 🐉 Thar be dragons

I am pushing updates _constantly_, so there are **NO** guarantees of stability
with my config!

> **Warning**
>
> I highly recommend you dig into the scripts and configs to see what all is
> going on (because it does a lot more than what I'm describing in this README)
> before you -- all willy-nilly, throw caution to the wind -- install a
> stranger's shell scripts. 🤣

---

## ✨ Accoutrements

A few of the _must-have_ tools I roll with:

- nix (home-manager/nix-darwin)
- [ghostty](https://github.com/ghostty-org/ghostty)
- [homebrew](https://brew.sh/)
- [mise](https://github.com/jdx/mise)
- [tmux](https://github.com/tmux/tmux/wiki)
- [zsh](https://www.zsh.org/)
- [neovim](https://github.com/neovim/neovim)
- [weechat](https://www.weechat.org/)
- `megaforest` for all the colours/themes
- [jetbrains mono](https://www.jetbrains.com/lp/mono/) font
  ([nerd-fonts](https://github.com/ryanoasis/nerd-fonts#font-patcher) patched)
- [hammerspoon](https://github.com/megalithic/dotfiles/tree/main/config/hs)
- [karabiner-elements](https://github.com/tekezo/Karabiner-Elements)
  ([leeloo ZMK](https://github.com/megalithic/zmk-config))
- [gpg/yubikey/encryption](https://github.com/drduh/YubiKey-Guide)
- `vim`-esque control
  - [surfingkeys (in-browser)](https://github.com/brookhong/Surfingkeys)
  - [homerow (macos-wide)](https://homerow.app)

<p align="center" style="margin-top: 20px; text-align:center; display: flex; align-items: center; justify-content: center;">
  <a href="https://megalithic.io" target="_blank" style="display:block; height:150px;">
    <img src="https://raw.githubusercontent.com/megalithic/dotfiles/main/megadotfiles.png" alt="megadotfiles logo" height="150px" />
  </a>
</p>
