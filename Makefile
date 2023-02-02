ARKOS_HOST=192.168.68.61
ARKOS_INSTALL_DIR=/roms2/tools

install-arkos:
	ssh ark@$(ARKOS_HOST) "mkdir -p $(ARKOS_INSTALL_DIR)/SyncSaveGames"
	scp -P 22 -r -p $(CURDIR)/SyncSaveGames.sh ark@$(ARKOS_HOST):$(ARKOS_INSTALL_DIR)/SyncSaveGames.sh
	scp -P 22 -r -p $(CURDIR)/SyncSaveGames ark@$(ARKOS_HOST):$(ARKOS_INSTALL_DIR)/

	scp -P 22 -r -p $(CURDIR)/arkos-config ark@$(ARKOS_HOST):$(ARKOS_INSTALL_DIR)/SyncSaveGames/config
