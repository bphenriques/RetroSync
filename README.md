# Retro Games Sync

A personal tool to synchronize files between my retro-handhelds using [rclone](https://rclone.org/bisync/). It is potentially
extensible to other systems as long as they are based on GNU Linux and have at least `bash` 4 available.

Tested systems:
- [Anbernic RG353M](https://anbernic.com/products/rg353m)([ArkOS](https://github.com/christianhaitian/arkos))
- [Steam Deck using Emudeck](https://store.steampowered.com/steamdeck)[EmuDeck](https://github.com/dragoonDorise/EmuDeck)

Does not support:
- Android
- Windows (maybe through [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)).

Use-cases (see more below):
* Sync ROMs across your devices.
* Backup save games.
* Cross-system save games.

# Installation

Requirements:
- SSH connection to the device.
- **ATTENTION**: A backup!

1. SSH to the device (you may want to SSH tunneling `ssh -L localhost:53682:localhost:53682 <host>`)
2. Install:

    ArkOS: `$ export INSTALL_DIR=/opt/system/Tools && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bphenriques/RetroSync/development/bin/install.sh)"`

    Steam Deck: `...`

3. Run `${HOME}/.bin/rclone config` to setup the remotes you need. For dropbox, follow this [guide](https://rclone.org/dropbox/#get-your-own-dropbox-app-id).
4. ...

# TODO:
- [ ] Automate file renaming between NDS emuladors (Drastic `.dsv` <-> melonDS `.sav`).
