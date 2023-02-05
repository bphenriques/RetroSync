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
- 
Steps:
1. Clone the project: `git clone https://github.com/bphenriques/arkos-emudeck-syncer`
2. Edit `arkos/folders.txt` or `steamdeck/folders.txt` according to your needs ([rclone bisync supported backends](https://rclone.org/bisync/#supported-backends)).
   
   Suggestion: play around with your-save games in each device until you find where exactly each save game is. To be sure, try to copy each save-game manually to confirm cross-compatibility.

3. Install:

    ArkOS: `./install.sh arkos ark@192.168.68.61 /roms2/tools "/home/ark/.config/retroarch/retroarch.cfg"`

    Steam Deck: `./install.sh steamdeck deck@192.168.68.67 /run/media/mmcblk0p1/ /home/deck/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg`

4. Connect to the machine using SSH tunneling (important for [rclone](https://rclone.org/dropbox/#get-your-own-dropbox-app-id)).
5. Go to the installation directory: `cd /roms2/tools/SyncSaveGames`.
6. Run `./setup.sh` which will install `rclone`.
7. Run `/usr/local/bin/rclone config` to setup the remote with the same name, as the one you entered in `folders.txt`. For dropbox, follow this [guide](https://rclone.org/dropbox/#get-your-own-dropbox-app-id).
8. Backup your save-games if you haven't already!
9. Test by doing a initial sync: `cd .. && ./SyncSaveGames.sh`.

# Notes

Sometimes gets finicky with empty folders. For that reason, I suggest adding a `system-info.info` so that at least one file is present.

# Limitations
- PSX: Ensure name ends with `{rom_base_name}_1.mcd`
- NDS: The file must always end with .dsv (Drastic saves as `.dsv` and melonDS as `.sav`)
