# Retro Games Sync

A tool to synchronize files between my retro-handhelds using [rclone](https://rclone.org/bisync/). It is potentially
extensible to other systems but, for now, only supports the systems I use.

Systems supported:
- [Anbernic RG353M](https://anbernic.com/products/rg353m)([ArkOS](https://github.com/christianhaitian/arkos))
- [Steam Deck](https://store.steampowered.com/steamdeck)[EmuDeck](https://github.com/dragoonDorise/EmuDeck)
- Theoretically any Unix device.

Does not support:
- Android
- Windows (maybe through [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)).

Use-cases (see more below):
* Sync ROMs across your devices.
* Cross-system save games.
* Backup save games.

Fair warnings:
- This will change retroArch settings to write the save games onto the same directories as the roms.

# Installation

Requirements:
- SSH connection to the target machine
- **ATTENTION**: A backup!

1. SSH to the device (you may want [SSH tunneling](https://rclone.org/dropbox/#get-your-own-dropbox-app-id))
2. Install:

    ArkOS: `$ export INSTALL_DIR=/opt/system/Tools && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bphenriques/RetroSync/development/bin/install.sh)"`

    Steam Deck: `...`

3. Run `${HOME}/.bin/rclone config` to setup the remotes you need. For dropbox, follow this [guide](https://rclone.org/dropbox/#get-your-own-dropbox-app-id).
4. Edit ...

# Notes

Sometimes gets finicky with empty folders. For that reason, I suggest adding a `system-info.info` so that at least one file is present.

# Limitations
- PSX: Ensure name ends with `{rom_base_name}_1.mcd`
- NDS: The file must always end with .dsv (Drastic saves as `.dsv` and melonDS as `.sav`)

# Development Notes

The bash version used in RG353M is `5.0.3(1)-release`.
