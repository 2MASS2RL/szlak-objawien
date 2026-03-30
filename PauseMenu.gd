# PauseMenu.gd
extends CanvasLayer

const SAVE_FILE := "user://savegame.save"
const MAIN_MENU := "res://MainMenu.tscn"

# =====================================================
const STYLE_BG_COLOR       := Color(0, 0, 0, 0.65)
const STYLE_PANEL_W        := 340.0
const STYLE_PANEL_H        := 300.0
const STYLE_PANEL_SETTINGS := 180.0
const STYLE_FONT_SIZE_TTL  := 36
const STYLE_FONT_SIZE_BTN  := 20
const STYLE_BTN_H          := 50.0
# const STYLE_BG_TEXTURE   := "res://ui/pause_bg.png"
const STYLE_BTN_NORMAL   := "res://ui/button_normal.png"
const STYLE_BTN_PRESSED  := "res://ui/button_pressed.png"
const STYLE_BTN_HOVER    := "res://ui/button_pressed.png"
#const STYLE_BTN_DISABLED := "res://ui/button_disabled.png"
const STYLE_FONT_TITLE   := "res://fonts/medieval.ttf"
const STYLE_FONT_BTN     := "res://fonts/medieval.ttf"
# =====================================================

var is_paused      := false
var main_panel     : Control
var settings_panel : Control
var btn_save       : Button
var slider_volume  : HSlider
var in_main_menu   := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	visible = false
	_build_ui()
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node == get_tree().current_scene:
		_force_resume()

func _force_resume() -> void:
	is_paused = false
	get_tree().paused = false
	visible = false

func _build_ui() -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = STYLE_BG_COLOR
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay)

	main_panel = _centered_panel(STYLE_PANEL_W, STYLE_PANEL_H)
	add_child(main_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_panel.add_child(vbox)

	var title := Label.new()
	title.text = "PAUZA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_TTL)
	title.add_theme_font_override("font", load(STYLE_FONT_TITLE))
	vbox.add_child(title)
	vbox.add_child(_spacer(8))

	var btn_resume   := _btn("Wróć do gry", vbox)
	btn_save          = _btn("Zapisz grę",  vbox)
	var btn_settings := _btn("Ustawienia",  vbox)
	var btn_menu     := _btn("Menu główne", vbox)

	btn_resume.pressed.connect(_on_resume)
	btn_save.pressed.connect(_on_save)
	btn_settings.pressed.connect(_on_settings)
	btn_menu.pressed.connect(_on_main_menu)

	settings_panel = _centered_panel(STYLE_PANEL_W, STYLE_PANEL_SETTINGS)
	settings_panel.visible = false
	add_child(settings_panel)

	var svbox := VBoxContainer.new()
	svbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	svbox.add_theme_constant_override("separation", 14)
	svbox.alignment = BoxContainer.ALIGNMENT_CENTER
	settings_panel.add_child(svbox)

	var stitle := Label.new()
	stitle.text = "Ustawienia"
	stitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stitle.add_theme_font_size_override("font_size", 28)
	svbox.add_child(stitle)

	var hbox := HBoxContainer.new()
	svbox.add_child(hbox)

	var lbl := Label.new()
	lbl.text = "Głośność:"
	lbl.custom_minimum_size = Vector2(110, 0)
	hbox.add_child(lbl)

	slider_volume = HSlider.new()
	slider_volume.min_value = 0.0
	slider_volume.max_value = 1.0
	slider_volume.step = 0.05
	slider_volume.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_volume.process_mode = Node.PROCESS_MODE_ALWAYS
	slider_volume.value = db_to_linear(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	)
	hbox.add_child(slider_volume)

	var btn_close := _btn("Zamknij", svbox)
	btn_close.pressed.connect(_on_close_settings)
	slider_volume.value_changed.connect(_on_volume_changed)

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

	# === STYL przycisku — odkomentuj gdy będziesz miał tekstury ===
	var style_normal := StyleBoxTexture.new()
	style_normal.texture = load(STYLE_BTN_NORMAL)
	style_normal.texture_margin_left   = 4.0
	style_normal.texture_margin_right  = 4.0
	style_normal.texture_margin_top    = 4.0
	style_normal.texture_margin_bottom = 4.0
	b.add_theme_stylebox_override("normal", style_normal)

	var style_pressed := StyleBoxTexture.new()
	style_pressed.texture = load(STYLE_BTN_PRESSED)
	style_pressed.texture_margin_left   = 4.0
	style_pressed.texture_margin_right  = 4.0
	style_pressed.texture_margin_top    = 4.0
	style_pressed.texture_margin_bottom = 4.0
	b.add_theme_stylebox_override("pressed", style_pressed)

	var style_hover := StyleBoxTexture.new()
	style_hover.texture = load(STYLE_BTN_HOVER)
	style_hover.texture_margin_left   = 4.0
	style_hover.texture_margin_right  = 4.0
	style_hover.texture_margin_top    = 4.0
	style_hover.texture_margin_bottom = 4.0
	b.add_theme_stylebox_override("hover", style_hover)

	var style_disabled := StyleBoxTexture.new()
	#style_disabled.texture = load(STYLE_BTN_DISABLED)
	style_disabled.texture_margin_left   = 4.0
	style_disabled.texture_margin_right  = 4.0
	style_disabled.texture_margin_top    = 4.0
	style_disabled.texture_margin_bottom = 4.0
	b.add_theme_stylebox_override("disabled", style_disabled)

	parent.add_child(b)
	return b

func _spacer(h: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, h)
	return s

func _unhandled_input(event: InputEvent) -> void:
	if in_main_menu:
		return
	if event.is_action_pressed("ui_cancel"):
		var inv = get_tree().get_first_node_in_group("InventoryUI")
		if inv and inv.visible:
			return
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	if is_paused: _resume()
	else: _pause()

func _pause() -> void:
	is_paused = true
	get_tree().paused = true
	visible = true
	main_panel.visible = true
	settings_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _resume() -> void:
	is_paused = false
	get_tree().paused = false
	visible = false

func _on_resume() -> void: _resume()

func _on_save() -> void:
	_save_game()
	btn_save.text = "Zapisano! ✓"
	await get_tree().create_timer(1.5).timeout
	btn_save.text = "Zapisz grę"

func _on_settings() -> void:
	main_panel.visible = false
	settings_panel.visible = true

func _on_close_settings() -> void:
	settings_panel.visible = false
	main_panel.visible = true

func _on_main_menu() -> void:
	get_tree().paused = false
	is_paused = false
	in_main_menu = true
	get_tree().change_scene_to_file(MAIN_MENU)

func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _save_game() -> void:
	var player_node = get_tree().get_first_node_in_group("Player")
	var data := {
		"scene_key":      Global.current_scene_key,
		"spawn_position": Global.spawn_position,
	}
	if player_node:
		data["spawn_position"] = player_node.position
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_var(data)
	file.close()
