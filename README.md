# Arkos Emudeck Syncer

Personal tool to sync my savegames across my systems using [rclone](https://rclone.org/bisync/):
- [Anbernic RG353M](https://anbernic.com/products/rg353m) using [ArkOS](https://github.com/christianhaitian/arkos).
- [Steam Deck](https://store.steampowered.com/steamdeck) using [EmuDeck](https://github.com/dragoonDorise/EmuDeck).

The goal is to be able to resume games in any device. This is tailored for my use-case, however things should be relatively
extensible.

**ATTENTION**: This requires having RetroArch setup to write the save games onto the same directories as the roms! If you have already save games, back them up!

# Installation

Requirements:
- SSH connection to the target machine


1. Clone the project.
2. Edit `arkos/folders.txt` or `steamdeck/folders.txt` according to your needs. See [rclone bisync supporterd backends](https://rclone.org/bisync/#supported-backends).
3. Install:

    ArkOS: `./install.sh arkos ark@192.168.68.61 /roms2/tools "/home/ark/.config/retroarch/retroarch.cfg"`

    Steam Deck: `./install.sh arkos 192.168.68.67 TODO`

4. Connect to the machine using SSH and SSH tunneling (important for [rclone](https://rclone.org/dropbox/#get-your-own-dropbox-app-id)). Skip this if you have already `rclone.conf` and you know where to copy it to.
5. Go to the installation directory. E.g., `cd /roms2/tools/SyncSaveGames`.
6. Run `./setup.sh` which will install `rclone`.
7. Run `/usr/local/bin/rclone config` and setup the remote with the same name as you entered in `folders.txt`. For dropbox, follow this [guide](https://rclone.org/dropbox/#get-your-own-dropbox-app-id).
8. Finally, let's do a initial sync: `cd .. && ./SyncSaveGames.sh`

# Notes

Sometimes gets finicky with empty folders. For that reason, I suggest adding a `system-info.info` so that at least one file is present.

# Advanced

You can skip the `rclone` backend setup if you just copy `rclone.conf` to one of the default directories.
