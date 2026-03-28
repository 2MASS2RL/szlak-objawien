# QuestJournal.gd
# Podepnij do Control w UI.tscn

extends Control

var _vbox_active : VBoxContainer
var _vbox_done   : VBoxContainer

func _ready() -> void:
	_build_ui()
	QuestManager.quest_started.connect(_refresh)
	QuestManager.quest_completed.connect(_refresh)
	hide()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Ciemne tło
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	# Panel
	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(600, 500)
	panel.offset_left   = -300
	panel.offset_top    = -250
	panel.offset_right  =  300
	panel.offset_bottom =  250
	add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   25)
	margin.add_theme_constant_override("margin_right",  25)
	margin.add_theme_constant_override("margin_top",    20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Tytuł
	var title := Label.new()
	title.text = "📜  Dziennik questów"
	title.add_theme_font_size_override("font_size", 26)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	# Aktywne
	var lbl_a := Label.new()
	lbl_a.text = "Aktywne questy"
	lbl_a.add_theme_font_size_override("font_size", 18)
	lbl_a.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(lbl_a)

	_vbox_active = VBoxContainer.new()
	_vbox_active.add_theme_constant_override("separation", 10)
	vbox.add_child(_vbox_active)

	vbox.add_child(HSeparator.new())

	# Ukończone
	var lbl_d := Label.new()
	lbl_d.text = "Ukończone questy"
	lbl_d.add_theme_font_size_override("font_size", 18)
	lbl_d.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	vbox.add_child(lbl_d)

	_vbox_done = VBoxContainer.new()
	_vbox_done.add_theme_constant_override("separation", 10)
	vbox.add_child(_vbox_done)

	# Przycisk zamknij
	var close_btn := Button.new()
	close_btn.text = "Zamknij  [ J ]"
	close_btn.pressed.connect(hide)
	vbox.add_child(close_btn)

func _refresh(_id = "") -> void:
	for c in _vbox_active.get_children(): c.queue_free()
	for c in _vbox_done.get_children():   c.queue_free()

	var active = QuestManager.get_active_quests()
	if active.is_empty():
		_add_empty_label(_vbox_active, "Brak aktywnych questów")
	else:
		for id in active:
			_add_quest_entry(_vbox_active, active[id], false)

	var done = QuestManager.get_completed_quests()
	if done.is_empty():
		_add_empty_label(_vbox_done, "Brak ukończonych questów")
	else:
		for id in done:
			_add_quest_entry(_vbox_done, done[id], true)

func _add_quest_entry(parent: VBoxContainer, data: Dictionary, completed: bool) -> void:
	var entry := VBoxContainer.new()
	entry.add_theme_constant_override("separation", 2)
	parent.add_child(entry)

	# Nazwa questa
	var name_lbl := Label.new()
	name_lbl.text = ("✓  " if completed else "▶  ") + data.get("name", "")
	name_lbl.add_theme_font_size_override("font_size", 17)
	if completed:
		name_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	entry.add_child(name_lbl)

	# Pełny opis
	var desc_lbl := Label.new()
	desc_lbl.text = "      " + data.get("description", "")
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry.add_child(desc_lbl)

func _add_empty_label(parent: VBoxContainer, text: String) -> void:
	var lbl := Label.new()
	lbl.text = "  " + text
	lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	lbl.add_theme_font_size_override("font_size", 14)
	parent.add_child(lbl)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("journal"):
		if visible:
			hide()
		else:
			_refresh()
			show()
