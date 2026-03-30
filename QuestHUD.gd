# QuestHUD.gd
extends Control

# =====================================================
# === STYL — podmień tutaj gdy będziesz miał grafiki ===
# =====================================================
const STYLE_BG_COLOR      := Color(0, 0, 0, 0.5)   # kolor tła
const STYLE_CORNER_RADIUS := 12                      # zaokrąglenie rogów
const STYLE_WIDTH         := 300                     # szerokość panelu
const STYLE_OFFSET_RIGHT  := 20                      # odstęp od prawej krawędzi
const STYLE_OFFSET_TOP    := 20                      # odstęp od góry
const STYLE_FONT_SIZE_HDR := 14                      # rozmiar nagłówka
const STYLE_FONT_SIZE_NAME:= 13                      # rozmiar nazwy questa
const STYLE_FONT_SIZE_GOAL:= 11                      # rozmiar celu questa
const STYLE_FONT_SIZE_HINT:= 13                      # rozmiar podpowiedzi
const STYLE_COLOR_HDR     := Color(1.0, 0.85, 0.3)  # kolor nagłówka
const STYLE_COLOR_NAME    := Color(1, 1, 1)          # kolor nazwy questa
const STYLE_COLOR_GOAL    := Color(0.7, 0.7, 0.7)   # kolor celu questa
const STYLE_COLOR_HINT    := Color(0.8, 0.8, 0.8)   # kolor podpowiedzi
# const STYLE_BG_TEXTURE  := "res://ui/hud_bg.png"  # <- własna tekstura tła
# =====================================================

var _vbox : VBoxContainer

func _ready() -> void:
	_build_ui()
	QuestManager.quest_started.connect(_refresh)
	QuestManager.quest_completed.connect(_refresh)
	hide()

func _build_ui() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left   = 1.0
	anchor_top    = 0.0
	anchor_right  = 1.0
	anchor_bottom = 0.0
	offset_left   = -STYLE_WIDTH - STYLE_OFFSET_RIGHT
	offset_top    =  STYLE_OFFSET_TOP
	offset_right  = -STYLE_OFFSET_RIGHT
	offset_bottom =  STYLE_OFFSET_TOP

	# === STYL tła ===
	var bg := Panel.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = STYLE_BG_COLOR
	style.corner_radius_top_left     = STYLE_CORNER_RADIUS
	style.corner_radius_top_right    = STYLE_CORNER_RADIUS
	style.corner_radius_bottom_left  = STYLE_CORNER_RADIUS
	style.corner_radius_bottom_right = STYLE_CORNER_RADIUS
	bg.add_theme_stylebox_override("panel", style)
	# Własna tekstura — zamień na:
	# var style := StyleBoxTexture.new()
	# style.texture = load(STYLE_BG_TEXTURE)
	# bg.add_theme_stylebox_override("panel", style)
	add_child(bg)
	# ===

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
	header.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_HDR)
	header.add_theme_color_override("font_color", STYLE_COLOR_HDR)
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
		name_lbl.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_NAME)
		name_lbl.add_theme_color_override("font_color", STYLE_COLOR_NAME)
		entry.add_child(name_lbl)

		var goal_lbl := Label.new()
		goal_lbl.text = "   " + data.get("goal", "")
		goal_lbl.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_GOAL)
		goal_lbl.add_theme_color_override("font_color", STYLE_COLOR_GOAL)
		entry.add_child(goal_lbl)

		count += 1

	var hint := Label.new()
	hint.text = "[J] Dziennik"
	hint.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_HINT)
	hint.add_theme_color_override("font_color", STYLE_COLOR_HINT)
	_vbox.add_child(hint)

	await get_tree().process_frame
	await get_tree().process_frame
	var h = _vbox.size.y + 24
	offset_bottom = offset_top + h
