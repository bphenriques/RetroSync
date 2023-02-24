# Retro Games Sync

A personal **experimental tool** to synchronize files between my retro-handhelds using [rclone](https://rclone.org/bisync/). 

<img width="744" alt="image" src="https://user-images.githubusercontent.com/4727729/220428384-0ddb0063-cda0-4424-b93b-1958716dbbd2.png">

It is potentially extensible to other systems as long as they are based on GNU Linux and have at least `bash` 4 available.
I will not extend this _more_ without considering re-writing it: better cross-platform GUI, less `bash`ing and better packaging.

Use-cases:
* Backup save games.
* Cross-system save games (depends on how the saves are structured).

## Disclaimer

This is a experimental tool. For now, I will do minor adjustment so that I focus on playing the games :) If you want something more stable consider the alternatives:
- SteamDeck: https://github.com/DavidDeSimone/OpenCloudSaves
- ArkOS: https://github.com/ridgekuhn/arklone-arkos
- JELOS: https://github.com/JustEnoughLinuxOS/distribution/wiki/Using-Cloud-Drives

# Installation

Tested systems:
- [Anbernic RG353M](https://anbernic.com/products/rg353m)([ArkOS](https://github.com/christianhaitian/arkos))
- [Steam Deck using Emudeck](https://store.steampowered.com/steamdeck)[EmuDeck](https://github.com/dragoonDorise/EmuDeck)

Requirements:
- SSH connection to the device.
- **ATTENTION**: A backup!
- Bash > 4.0

Information:
- `rg353m` and `deck` are my SSH aliases. Use your own SSH targets.
- The Steam Deck installation will disable read-only FS temporarily.

Install:

- ArkOS: 
   `$ ./bin/dev-install.sh rg353m arkos "/opt/system/Tools"`

- Steam Deck:
  1. If-first-time: `sudo steamos-readonly disable && sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman -S jq rclone dialog && sudo steamos-readonly enable`
  2. Install: `$ ./bin/dev-install.sh deck steamdeck "/home/deck/.bin"`

Post Installation:
1. Go to `Options > Tools` and open `RetroSync-GUI.sh` and optionally go to `Configure > Setup retroarch...` to organize save-games.
2. Setup rclone (for dropbox I suggest [this guide](https://rclone.org/dropbox/#get-your-own-dropbox-app-id)).
3. Add locations to sync under `${XDG_CONFIG_HOME:-$HOME/.config}/retrosync/locations`:
  
   ```json
   {
     "from": "/roms2/arcade",
     "to": "dropbox:roms/arcade",
     "filter": "retroarch-default.txt",
     "on_conflict": "manual"
   }
   ```

Notes: I do not recommend setting up cross-saving for systems where:
- All the saves are stored in a specific set of files (e.g., dreamcast).

# Basic configuration

ArkOS:
```shell    
scp -r config-library/arkos-secondary-sd/locations rg353m:/home/ark/.config/retrosync/
````

SteamDeck:
```shell
scp -r config-library/emudeck-sdcard/locations deck:/home/deck/.config/retrosync/
````

# TODO:
- [ ] Automate file renaming between NDS emuladors (Drastic `.dsv` <-> melonDS `.sav`).
- [ ] GUI: Force-Sync.
- [ ] GUI: Have better logs in case something goes wrong.
- [ ] GUI: See configured locations and delete/disable them.
