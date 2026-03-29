extends CanvasLayer

# ================================================
# PAUSE MENU — dopasowane do twojego projektu
# ================================================
# Wrzuć PauseMenu.tscn jako dziecko sceny gry
# (np. main.tscn, SceneRight.tscn itd.)
# LUB dodaj go do każdej sceny przez Autoload
# jako instancja sceny (zalecane dla RPG).
#
# Ten node ma process_mode = ALWAYS żeby działał
# podczas pauzy get_tree().paused = true
# ================================================

const SAVE_FILE    := "user://savegame.save"
const MAIN_MENU    := "res://MainMenu.tscn"  # ← zmień jeśli masz inną ścieżkę

var is_paused := false

@onready var btn_resume         : Button         = $Panel/VBox/BtnResume
@onready var btn_save           : Button         = $Panel/VBox/BtnSave
@onready var btn_settings       : Button         = $Panel/VBox/BtnSettings
@onready var btn_main_menu      : Button         = $Panel/VBox/BtnMainMenu
@onready var settings_sub_panel : PanelContainer = $SettingsSubPanel
@onready var slider_volume      : HSlider        = $SettingsSubPanel/VBox/HBoxVolume/SliderVolume
@onready var btn_close_settings : Button         = $SettingsSubPanel/VBox/BtnCloseSettings
@onready var main_panel         : PanelContainer = $Panel


func _ready() -> void:
	visible = false
	# KLUCZOWE: ten node musi działać nawet gdy gra spauzowana
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Głośność
	var vol := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	slider_volume.value = db_to_linear(vol)

	# Sygnały
	btn_resume.pressed.connect(_on_resume)
	btn_save.pressed.connect(_on_save)
	btn_settings.pressed.connect(_on_settings)
	btn_main_menu.pressed.connect(_on_main_menu)
	btn_close_settings.pressed.connect(_on_close_settings)
	slider_volume.value_changed.connect(_on_volume_changed)


func _unhandled_input(event: InputEvent) -> void:
	# ESC otwiera/zamyka pauzę
	# Blokujemy jeśli inventory jest otwarte (z twojego inventory_ui.gd)
	if event.is_action_pressed("ui_cancel"):
		var inv = get_tree().get_first_node_in_group("InventoryUI")
		if inv and inv.visible:
			return  # nie otwieraj pauzy gdy inventory otwarte
		_toggle_pause()
		get_viewport().set_input_as_handled()


# ─────────────────────────────────────
# LOGIKA PAUZY
# ─────────────────────────────────────

func _toggle_pause() -> void:
	if is_paused:
		_resume()
	else:
		_pause()


func _pause() -> void:
	is_paused = true
	get_tree().paused = true
	visible = true
	main_panel.visible = true
	settings_sub_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _resume() -> void:
	is_paused = false
	get_tree().paused = false
	visible = false
	# Przywróć kursor jeśli potrzebujesz
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# ─────────────────────────────────────
# PRZYCISKI
# ─────────────────────────────────────

func _on_resume() -> void:
	_resume()


func _on_save() -> void:
	_save_game()
	# Wizualna informacja że zapisano
	btn_save.text = "Zapisano! ✓"
	await get_tree().create_timer(1.5).timeout
	btn_save.text = "Zapisz grę"


func _on_settings() -> void:
	main_panel.visible = false
	settings_sub_panel.visible = true


func _on_close_settings() -> void:
	settings_sub_panel.visible = false
	main_panel.visible = true


func _on_main_menu() -> void:
	# WAŻNE: odpauzuj przed zmianą sceny
	get_tree().paused = false
	is_paused = false
	get_tree().change_scene_to_file(MAIN_MENU)


func _on_volume_changed(value: float) -> void:
	var db := linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)


# ─────────────────────────────────────
# SAVE GAME
# ─────────────────────────────────────

func _save_game() -> void:
	# Pobierz gracza z grupy (player.gd dodaje się do grupy "Player")
	var player_node = get_tree().get_first_node_in_group("Player")

	var data := {
		"scene_key":      Global.current_scene_key,
		"spawn_position": Global.spawn_position,
	}

	# Zapisz aktualną pozycję gracza jako spawn przy wczytaniu
	if player_node:
		data["spawn_position"] = player_node.position

	# Opcjonalnie: zapisz aktywne questy
	# data["active_quests"] = QuestManager.get_active_quests()
	# data["completed_quests"] = QuestManager.get_completed_quests()

	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	print("Gra zapisana: ", data)
