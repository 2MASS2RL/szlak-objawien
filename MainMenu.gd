extends Control

# ================================================
# MAIN MENU — dopasowane do twojego projektu
# ================================================
# Autoloady których używasz:
#   Global          → res://Global.gd
#   QuestManager    → res://QuestManager.gd
#   DialogueManager → res://DialogueManager.gd
#
# Scena startowa gry wg twojego Global.gd = "res://main.tscn"
# ================================================

const SAVE_FILE := "user://savegame.save"

@onready var btn_new_game   : Button         = $CenterContainer/BtnNewGame
@onready var btn_continue   : Button         = $CenterContainer/BtnContinue
@onready var btn_settings   : Button         = $CenterContainer/BtnSettings
@onready var btn_quit       : Button         = $CenterContainer/BtnQuit
@onready var settings_panel : PanelContainer = $SettingsPanel
@onready var slider_volume  : HSlider        = $SettingsPanel/VBox/HBoxVolume/SliderVolume
@onready var btn_close_set  : Button         = $SettingsPanel/VBox/BtnCloseSettings


func _ready() -> void:
	# Zawsze odpauzuj grę wracając do menu
	get_tree().paused = false

	# Reset Global do sceny startowej
	Global.current_scene_key = "main"

	# Odblokuj "Kontynuuj" tylko jeśli istnieje save
	btn_continue.disabled = not FileAccess.file_exists(SAVE_FILE)

	# Wczytaj zapisaną głośność
	var vol := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	slider_volume.value = db_to_linear(vol)

	# Sygnały
	btn_new_game.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_settings.pressed.connect(_on_settings)
	btn_quit.pressed.connect(_on_quit)
	btn_close_set.pressed.connect(_on_close_settings)
	slider_volume.value_changed.connect(_on_volume_changed)


# ─────────────────────────────────────
# PRZYCISKI
# ─────────────────────────────────────

func _on_new_game() -> void:
	# Usuń stary zapis
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)

	# Resetuj Global (wartości domyślne z twojego Global.gd)
	Global.spawn_position = Vector2(200, 500)
	Global.current_scene_key = "main"

	get_tree().change_scene_to_file(Global.scenes["main"])


func _on_continue() -> void:
	_load_game()
	get_tree().change_scene_to_file(Global.scenes[Global.current_scene_key])


func _on_settings() -> void:
	settings_panel.visible = true


func _on_quit() -> void:
	get_tree().quit()


func _on_close_settings() -> void:
	settings_panel.visible = false


func _on_volume_changed(value: float) -> void:
	var db := linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)


# ─────────────────────────────────────
# SAVE / LOAD
# ─────────────────────────────────────

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		return
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	var data : Dictionary = file.get_var()
	file.close()

	if data.has("scene_key"):
		Global.current_scene_key = data["scene_key"]
	if data.has("spawn_position"):
		Global.spawn_position = data["spawn_position"]
