extends CanvasLayer

const SAVE_FILE  := "user://savegame.save"
const GAME_SCENE := "res://main.tscn"

# =====================================================
# === STYL — podmień tutaj gdy będziesz miał grafiki ===
# =====================================================
const STYLE_BG_COLOR      := Color(0.08, 0.08, 0.10, 1.0)
const STYLE_PANEL_W       := 340.0
const STYLE_PANEL_H       := 360.0
const STYLE_FONT_SIZE_TTL := 48
const STYLE_FONT_SIZE_BTN := 20
const STYLE_BTN_H         := 52.0
# const STYLE_BG_TEXTURE      := "res://ui/pause_bg.png"
const STYLE_BTN_NORMAL      := "res://ui/button_normal.png"    # ← tekstura normalna
const STYLE_BTN_PRESSED     := "res://ui/button_pressed.png"   # ← tekstura naciśnięta
const STYLE_BTN_HOVER       := "res://ui/button_pressed.png"     # ← tekstura hover (opcjonalnie)
# const STYLE_BTN_DISABLED    := "res://ui/button_disabled.png"  # ← tekstura disabled (opcjonalnie)
const STYLE_FONT_TITLE    := "res://fonts/medieval.ttf"
const STYLE_FONT_BTN      := "res://fonts/medieval.ttf"
# =====================================================

var btn_continue : Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	get_tree().paused = false
	PauseMenu.in_main_menu = true
	Global.current_scene_key = "main"
	_build_ui()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = STYLE_BG_COLOR
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var main_panel := _centered_panel(STYLE_PANEL_W, STYLE_PANEL_H)
	add_child(main_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_panel.add_child(vbox)

	var title := Label.new()
	title.text = "TWOJA GRA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_TTL)
	title.add_theme_font_override("font", load(STYLE_FONT_TITLE))
	vbox.add_child(title)

	vbox.add_child(_spacer(20))

	var btn_new  := _btn("Nowa gra",  vbox)
	btn_continue  = _btn("Kontynuuj", vbox)
	var btn_quit := _btn("Wyjście",   vbox)

	btn_continue.disabled = not FileAccess.file_exists(SAVE_FILE)

	btn_new.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_quit.pressed.connect(_on_quit)

func _centered_panel(w: float, h: float) -> PanelContainer:
	var p := PanelContainer.new()
	p.set_anchors_preset(Control.PRESET_CENTER)
	p.custom_minimum_size = Vector2(w, h)
	p.offset_left   = -w / 2.0
	p.offset_right  =  w / 2.0
	p.offset_top    = -h / 2.0
	p.offset_bottom =  h / 2.0
	p.process_mode  = Node.PROCESS_MODE_ALWAYS
	# === STYL panelu ===
	# var style := StyleBoxTexture.new()
	# style.texture = load(STYLE_BG_TEXTURE)
	# p.add_theme_stylebox_override("panel", style)
	return p

func _btn(label: String, parent: Node) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(STYLE_PANEL_W - 40, STYLE_BTN_H)
	b.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_BTN)
	b.add_theme_font_override("font", load(STYLE_FONT_BTN))
	b.process_mode = Node.PROCESS_MODE_ALWAYS

	# === STYL przycisku — normal ===
	var style_normal := StyleBoxTexture.new()
	style_normal.texture = load(STYLE_BTN_NORMAL)
	b.add_theme_stylebox_override("normal", style_normal)

	# === STYL przycisku — pressed ===
	var style_pressed := StyleBoxTexture.new()
	style_pressed.texture = load(STYLE_BTN_PRESSED)
	b.add_theme_stylebox_override("pressed", style_pressed)

	# === STYL przycisku — hover (najechanie myszą) ===
	var style_hover := StyleBoxTexture.new()
	style_hover.texture = load(STYLE_BTN_HOVER)
	b.add_theme_stylebox_override("hover", style_hover)

	# === STYL przycisku — disabled ===
	var style_disabled := StyleBoxTexture.new()
	# style_disabled.texture = load(STYLE_BTN_DISABLED)
	b.add_theme_stylebox_override("disabled", style_disabled)

	parent.add_child(b)
	return b

func _spacer(h: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, h)
	return s

func _on_new_game() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	Global.spawn_position = Vector2(200, 500)
	Global.current_scene_key = "main"
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
