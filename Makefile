ARKOS_HOST=192.168.68.61
ARKOS_INSTALL_DIR=/roms2/tools

STEAMDECK_HOST=192.168.68.67
STEAMDECK_INSTALL_DIR=/roms2/tools

deploy-arkos:
	ssh ark@$(ARKOS_HOST) "rm -rf $(ARKOS_INSTALL_DIR)/SyncSaveGames"
	ssh ark@$(ARKOS_HOST) "rm -f $(ARKOS_INSTALL_DIR)/SyncSaveGames.sh"
	ssh ark@$(ARKOS_HOST) "mkdir -p $(ARKOS_INSTALL_DIR)/SyncSaveGames"

	scp -P 22 -r -p $(CURDIR)/SyncSaveGames.sh ark@$(ARKOS_HOST):$(ARKOS_INSTALL_DIR)/SyncSaveGames.sh
	scp -P 22 -r -p $(CURDIR)/SyncSaveGames ark@$(ARKOS_HOST):$(ARKOS_INSTALL_DIR)/
	scp -P 22 -r -p $(CURDIR)/arkos.env ark@$(ARKOS_HOST):$(ARKOS_INSTALL_DIR)/SyncSaveGames/config/config.env

deploy-steamdeck:
	ssh steamdeck@$(STEAMDECK_HOST) "mkdir -p $(STEAMDECK_INSTALL_DIR)/SyncSaveGames"

	# On /home/deck/.var/app.org.libretro.RetroArch/config.retroarch/retroarch.cfg
	# Replace savefile_directory = "..." with an empty string
	# Replace savefiles_in_content_dir = "..." with a "true"
	# Replace savefile_directory = "..." with an empty string
	# Replace savestates_in_content_dir = "..." with a "true"
	ssh steamdeck@$(STEAMDECK_HOST) "mkdir -p $(STEAMDECK_INSTALL_DIR)/SyncSaveGames"
