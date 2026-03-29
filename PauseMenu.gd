extends CanvasLayer

const SAVE_FILE := "user://savegame.save"
const MAIN_MENU := "res://main_menu.tscn"

var is_paused      := false
var main_panel     : Control
var settings_panel : Control
var btn_save       : Button
var slider_volume  : HSlider

# Zablokuj pause menu gdy jesteśmy w main menu
var in_main_menu := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	visible = false
	_build_ui()


func _build_ui() -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay)

	main_panel = _centered_panel(340, 300)
	add_child(main_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_panel.add_child(vbox)

	var title := Label.new()
	title.text = "PAUZA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
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

	settings_panel = _centered_panel(340, 180)
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
	return p


func _btn(label: String, parent: Node) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(300, 50)
	b.add_theme_font_size_override("font_size", 20)
	b.process_mode = Node.PROCESS_MODE_ALWAYS
	parent.add_child(b)
	return b


func _spacer(h: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, h)
	return s


func _unhandled_input(event: InputEvent) -> void:
	# Zablokowane w main menu
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
