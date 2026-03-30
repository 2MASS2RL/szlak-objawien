# QuestJournal.gd
extends Control

# =====================================================
# === STYL — podmień tutaj gdy będziesz miał grafiki ===
# =====================================================
const STYLE_BG_OVERLAY     := Color(0, 0, 0, 0.7)   # przyciemnienie tła
const STYLE_PANEL_W        := 600.0                  # szerokość panelu
const STYLE_PANEL_H        := 500.0                  # wysokość panelu
const STYLE_FONT_SIZE_TTL  := 26                     # rozmiar tytułu
const STYLE_FONT_SIZE_HDR  := 18                     # rozmiar nagłówków sekcji
const STYLE_FONT_SIZE_NAME := 17                     # rozmiar nazwy questa
const STYLE_FONT_SIZE_DESC := 13                     # rozmiar opisu questa
const STYLE_COLOR_ACTIVE   := Color(1.0, 0.85, 0.3) # kolor aktywnych questów
const STYLE_COLOR_DONE     := Color(0.4, 0.9, 0.4)  # kolor ukończonych questów
const STYLE_COLOR_DESC     := Color(0.8, 0.8, 0.8)  # kolor opisu
const STYLE_COLOR_EMPTY    := Color(0.6, 0.6, 0.6)  # kolor "brak questów"
# const STYLE_BG_TEXTURE   := "res://ui/journal_bg.png"  # <- własna tekstura panelu
# const STYLE_BTN_TEXTURE  := "res://ui/button.png"      # <- własna tekstura przycisku
const STYLE_FONT_TTL     := "res://fonts/medieval.ttf" # <- własna czcionka tytułu
const STYLE_FONT_BODY    := "res://fonts/medieval.ttf" # <- własna czcionka tekstu
# =====================================================

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

	# Przyciemnienie tła
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = STYLE_BG_OVERLAY
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	# Panel główny
	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(STYLE_PANEL_W, STYLE_PANEL_H)
	panel.offset_left   = -STYLE_PANEL_W / 2
	panel.offset_top    = -STYLE_PANEL_H / 2
	panel.offset_right  =  STYLE_PANEL_W / 2
	panel.offset_bottom =  STYLE_PANEL_H / 2
	# === STYL panelu ===
	# Własna tekstura — odkomentuj gdy będziesz miał:
	# var style := StyleBoxTexture.new()
	# style.texture = load(STYLE_BG_TEXTURE)
	# panel.add_theme_stylebox_override("panel", style)
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

	var title := Label.new()
	title.text = "📜  Dziennik questów"
	title.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_TTL)
	# Własna czcionka — odkomentuj:
	title.add_theme_font_override("font", load(STYLE_FONT_TTL))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var lbl_a := Label.new()
	lbl_a.text = "Aktywne questy"
	lbl_a.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_HDR)
	lbl_a.add_theme_color_override("font_color", STYLE_COLOR_ACTIVE)
	vbox.add_child(lbl_a)

	_vbox_active = VBoxContainer.new()
	_vbox_active.add_theme_constant_override("separation", 10)
	vbox.add_child(_vbox_active)

	vbox.add_child(HSeparator.new())

	var lbl_d := Label.new()
	lbl_d.text = "Ukończone questy"
	lbl_d.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_HDR)
	lbl_d.add_theme_color_override("font_color", STYLE_COLOR_DONE)
	vbox.add_child(lbl_d)

	_vbox_done = VBoxContainer.new()
	_vbox_done.add_theme_constant_override("separation", 10)
	vbox.add_child(_vbox_done)

	var close_btn := Button.new()
	close_btn.text = "Zamknij  [ J ]"
	close_btn.pressed.connect(hide)
	# === STYL przycisku ===
	# Własna tekstura — odkomentuj:
	# var btn_style := StyleBoxTexture.new()
	# btn_style.texture = load(STYLE_BTN_TEXTURE)
	# close_btn.add_theme_stylebox_override("normal", btn_style)
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

	var name_lbl := Label.new()
	name_lbl.text = ("✓  " if completed else "▶  ") + data.get("name", "")
	name_lbl.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_NAME)
	if completed:
		name_lbl.add_theme_color_override("font_color", STYLE_COLOR_DONE)
	# Własna czcionka — odkomentuj:
	name_lbl.add_theme_font_override("font", load(STYLE_FONT_BODY))
	entry.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = "      " + data.get("description", "")
	desc_lbl.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_DESC)
	desc_lbl.add_theme_color_override("font_color", STYLE_COLOR_DESC)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry.add_child(desc_lbl)

func _add_empty_label(parent: VBoxContainer, text: String) -> void:
	var lbl := Label.new()
	lbl.text = "  " + text
	lbl.add_theme_color_override("font_color", STYLE_COLOR_EMPTY)
	lbl.add_theme_font_size_override("font_size", 14)
	parent.add_child(lbl)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("journal"):
		if visible:
			hide()
		else:
			_refresh()
			show()
