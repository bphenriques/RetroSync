# Arkos Emudeck Syncer

Personal tool to sync my savegames across my systems using [rclone](https://rclone.org/bisync/):
- [Anbernic RG353M](https://anbernic.com/products/rg353m) using [ArkOS](https://github.com/christianhaitian/arkos).
- [Steam Deck](https://store.steampowered.com/steamdeck) using [EmuDeck](https://github.com/dragoonDorise/EmuDeck).

The goal is to be able to resume games in any device. This is tailored for my use-case, however things should be relatively
extensible. This works as long as the save-games are compatible between devices.

**ATTENTION**: This requires having RetroArch setup to write the save games onto the same directories as the roms! If you have already save games, back them up!

# Installation

Requirements:
- SSH connection to the target machine

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

# Issues

- PSX: Ensure name endes with `{rom_base_name}_1.mcd`
- NDS: The file must always end with .dsv (Drastic saves as `.dsv` and melonDS as `.sav`)
