# Arkos Emudeck Syncer

Personal tool to sync my savegames across my systems using [rclone](https://rclone.org/bisync/):
- [Anbernic RG353M](https://anbernic.com/products/rg353m) using [ArkOS](https://github.com/christianhaitian/arkos).
- [Steam Deck](https://store.steampowered.com/steamdeck) using [EmuDeck](https://github.com/dragoonDorise/EmuDeck).

The goal is to be able to resume games in any device. This is tailored for my use-case, however things should be relatively
extensible.

# ArkOS

Install:
1. Open `Makefile` and change the `ARKOS_HOST` and `ARKOS_INSTALL_DIR` accordingly.
2. Run `make install-arkos`
3. Enter your password as prompted.

At this stage, you have installed everything.

Setup:
1. Enable remote services under `Options`
2. On your machine, ssh inside the device: `ssh ark@HOST` (for Dropbox setup, tunnel the port by runnign `ssh -L localhost:53682:localhost:53682 username@remote_server`)
3. Go to the tools directory under `/roms2/tools` or `/roms/tools`.
4. Run `./setup.sh` which will install `rclone` and setup some directories.
5. Run `./rclone config` to setup your backend as required. This step is important to run on a separate machine as you may need a internet browser.

Note: for dropbox follow the official [guide](Follow the following guide to setup `dropbox` backend in rclone: https://rclone.org/dropbox/#get-your-own-dropbox-app-id).

Running:
1. Open `SyncSaveGames` under `Options`.
