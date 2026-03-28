# QuestHUD.gd
extends Control

var _vbox : VBoxContainer

func _ready() -> void:
	_build_ui()
	QuestManager.quest_started.connect(_refresh)
	QuestManager.quest_completed.connect(_refresh)
	hide()

func _build_ui() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Pozycja: prawy górny róg, rozmiar automatyczny
	anchor_left   = 1.0
	anchor_top    = 0.0
	anchor_right  = 1.0
	anchor_bottom = 0.0
	offset_left   = -320
	offset_top    =  20
	offset_right  = -20
	offset_bottom =  20  # będzie rósł automatycznie

	# Zaokrąglone tło
	var bg := Panel.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.5)
	style.corner_radius_top_left     = 12
	style.corner_radius_top_right    = 12
	style.corner_radius_bottom_left  = 12
	style.corner_radius_bottom_right = 12
	bg.add_theme_stylebox_override("panel", style)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   14)
	margin.add_theme_constant_override("margin_right",  14)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 10)
	_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(_vbox)

func _refresh(_id = "") -> void:
	for c in _vbox.get_children():
		c.queue_free()

	var active = QuestManager.get_active_quests()
	if active.is_empty():
		hide()
		return

	show()

	var header := Label.new()
	header.text = "📜 Questy"
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_vbox.add_child(header)

	var count := 0
	for id in active:
		if count >= 3:
			break
		var data = active[id]

		var entry := VBoxContainer.new()
		entry.add_theme_constant_override("separation", 2)
		_vbox.add_child(entry)

		var name_lbl := Label.new()
		name_lbl.text = "▶ " + data.get("name", "")
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		entry.add_child(name_lbl)

		var goal_lbl := Label.new()
		goal_lbl.text = "   " + data.get("goal", "")
		goal_lbl.add_theme_font_size_override("font_size", 11)
		goal_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		entry.add_child(goal_lbl)

		count += 1

	var hint := Label.new()
	hint.text = "[J] Dziennik"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_vbox.add_child(hint)

	# Dopasuj wysokość do zawartości
	await get_tree().process_frame
	await get_tree().process_frame
	var h = _vbox.size.y + 24
	offset_bottom = offset_top + h
