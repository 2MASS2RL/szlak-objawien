# SaveManager.gd
# Autoload → Project Settings → Autoload → Nazwa: SaveManager

extends Node

const SAVE_FILE := "user://savegame.save"

# ─────────────────────────────────────────────
#  ZAPIS
# ─────────────────────────────────────────────
func save() -> void:
	var player_node = get_tree().get_first_node_in_group("Player")
	var quests_active    = QuestManager._active.duplicate()
	var quests_completed = QuestManager._completed.duplicate()

	# Pozycja — z węzła gracza jeśli istnieje, fallback na Global
	var pos: Vector2 = Global.spawn_position
	if player_node:
		pos = player_node.position

	# Serializacja slotów inventory do zwykłych słowników (bez referencji)
	var slots_data: Array = []
	for slot in InventoryManager.slots:
		if slot == null:
			slots_data.append(null)
		else:
			slots_data.append({
				"item_id": slot["item_id"],
				"count":   slot["count"],
			})

	# Serializacja podniesionych itemów (_picked)
	var picked_data: Array = []
	for item_id in ItemManager._picked.keys():
		picked_data.append(item_id)

	# Głośność
	var volume: float = db_to_linear(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	)

	var data := {
		"version":        1,                          # wersja formatu zapisu
		"scene_key":      Global.current_scene_key,
		"spawn_position": { "x": pos.x, "y": pos.y },
		"inventory":      slots_data,
		"picked_items":   picked_data,
		"volume":         volume,
		"quests_active":    quests_active,
		"quests_completed": quests_completed,
	}

	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: nie można otworzyć pliku zapisu!")
		return
	file.store_var(data)
	file.close()
	print("SaveManager: gra zapisana ✓")

# ─────────────────────────────────────────────
#  WCZYTYWANIE
# ─────────────────────────────────────────────
func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_FILE):
		return false

	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		push_error("SaveManager: nie można odczytać pliku zapisu!")
		return false

	var data = file.get_var()
	file.close()

	if not data is Dictionary:
		push_error("SaveManager: uszkodzony plik zapisu!")
		return false

	# ── Scena i pozycja ──
	if data.has("scene_key"):
		Global.current_scene_key = data["scene_key"]

	if data.has("spawn_position"):
		var p = data["spawn_position"]
		Global.spawn_position = Vector2(p["x"], p["y"])

	# ── Inventory — przebuduj sloty ──
	if data.has("inventory"):
		var slots_data: Array = data["inventory"]
		# Resetuj do pustych slotów
		for i in range(InventoryManager.MAX_SLOTS):
			InventoryManager.slots[i] = null
		# Wczytaj zapisane dane
		for i in range(min(slots_data.size(), InventoryManager.MAX_SLOTS)):
			if slots_data[i] != null:
				InventoryManager.slots[i] = {
					"item_id": slots_data[i]["item_id"],
					"count":   slots_data[i]["count"],
				}
		InventoryManager.emit_signal("inventory_changed")

	# ── Podniesiete itemy (_picked) ──
	if data.has("picked_items"):
		ItemManager._picked.clear()
		for item_id in data["picked_items"]:
			ItemManager._picked[item_id] = true

	# ── Głośność ──
	if data.has("volume"):
		var vol: float = data["volume"]
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Master"),
			linear_to_db(vol)
		)
	
	if data.has("quests_active"):
		QuestManager._active = data["quests_active"]
	if data.has("quests_completed"):
		QuestManager._completed = data["quests_completed"]
	print("SaveManager: gra wczytana ✓")
	return true

# ─────────────────────────────────────────────
#  USUNIĘCIE ZAPISU
# ─────────────────────────────────────────────
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

func reset_all() -> void:
	InventoryManager.reset()
	ItemManager.reset()
	QuestManager.reset()
	Global.spawn_position = Vector2(960, 900)
	Global.current_scene_key = "main"
