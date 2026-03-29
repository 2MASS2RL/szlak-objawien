extends CanvasLayer

const SAVE_FILE  := "user://savegame.save"
const GAME_SCENE := "res://main.tscn"

var btn_continue : Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	get_tree().paused = false

	# Zablokuj PauseMenu gdy jesteśmy w main menu
	PauseMenu.in_main_menu = true

	Global.current_scene_key = "main"
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.08, 0.10, 1.0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.custom_minimum_size = Vector2(340, 0)
	vbox.offset_left   = -170
	vbox.offset_right  =  170
	vbox.offset_top    = -200
	vbox.offset_bottom =  200
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	var title := Label.new()
	title.text = "TWOJA GRA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)

	var btn_new  := _btn("Nowa gra",  vbox)
	btn_continue  = _btn("Kontynuuj", vbox)
	var btn_quit := _btn("Wyjście",   vbox)

	btn_continue.disabled = not FileAccess.file_exists(SAVE_FILE)

	btn_new.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_quit.pressed.connect(_on_quit)


func _btn(label: String, parent: Node) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(320, 52)
	b.add_theme_font_size_override("font_size", 20)
	b.process_mode = Node.PROCESS_MODE_ALWAYS
	parent.add_child(b)
	return b


func _on_new_game() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	Global.spawn_position = Vector2(200, 500)
	Global.current_scene_key = "main"
	# Odblokuj PauseMenu gdy wchodzimy do gry
	PauseMenu.in_main_menu = false
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_continue() -> void:
	_load_game()
	PauseMenu.in_main_menu = false
	get_tree().change_scene_to_file(Global.scenes[Global.current_scene_key])


func _on_quit() -> void:
	get_tree().quit()


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
