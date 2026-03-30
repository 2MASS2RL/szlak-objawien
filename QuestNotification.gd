# QuestNotification.gd
extends Control

# =====================================================
# === STYL — podmień tutaj gdy będziesz miał grafiki ===
# =====================================================
const STYLE_FONT_SIZE_NAME := 16                      # rozmiar nazwy questa
const STYLE_FONT_SIZE_GOAL := 12                      # rozmiar celu questa
const STYLE_COLOR_NEW      := Color(1.0, 0.85, 0.3)  # kolor nowego questa
const STYLE_COLOR_DONE     := Color(0.4, 0.9, 0.4)   # kolor ukończonego questa
const STYLE_COLOR_GOAL     := Color(0.8, 0.8, 0.8)   # kolor celu
const STYLE_ANIM_IN        := 0.3                     # czas pojawiania się
const STYLE_ANIM_STAY      := 3.0                     # czas wyświetlania
const STYLE_ANIM_OUT       := 0.5                     # czas znikania
# const STYLE_BG_TEXTURE   := "res://ui/notification_bg.png" # <- własna tekstura
# const STYLE_FONT_NAME    := "res://fonts/medieval.ttf"     # <- własna czcionka
# =====================================================

var _label_name : Label
var _label_goal : Label
var _tween      : Tween

func _ready() -> void:
	_build_ui()
	QuestManager.quest_started.connect(_on_quest_started)
	QuestManager.quest_completed.connect(_on_quest_completed)
	modulate.a = 0.0

func _build_ui() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	offset_left   =  660
	offset_top    =  20
	offset_right  = -660
	offset_bottom =  90

	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# === STYL panelu ===
	# Własna tekstura — odkomentuj:
	# var style := StyleBoxTexture.new()
	# style.texture = load(STYLE_BG_TEXTURE)
	# panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",  15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top",   10)
	margin.add_theme_constant_override("margin_bottom",10)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vbox)

	_label_name = Label.new()
	_label_name.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_NAME)
	_label_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Własna czcionka — odkomentuj:
	# _label_name.add_theme_font_override("font", load(STYLE_FONT_NAME))
	vbox.add_child(_label_name)

	_label_goal = Label.new()
	_label_goal.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_GOAL)
	_label_goal.add_theme_color_override("font_color", STYLE_COLOR_GOAL)
	_label_goal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_label_goal)

func _on_quest_started(quest_id: String) -> void:
	var data = QuestManager.get_quest_data(quest_id)
	_label_name.text = "📜 Nowy quest: " + data.get("name", "")
	_label_name.add_theme_color_override("font_color", STYLE_COLOR_NEW)
	_label_goal.text = "Cel: " + data.get("goal", "")
	_animate()

func _on_quest_completed(quest_id: String) -> void:
	var data = QuestManager.get_quest_data(quest_id)
	_label_name.text = "✓ Ukończono: " + data.get("name", "")
	_label_name.add_theme_color_override("font_color", STYLE_COLOR_DONE)
	_label_goal.text = ""
	_animate()

func _animate() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, STYLE_ANIM_IN)
	_tween.tween_interval(STYLE_ANIM_STAY)
	_tween.tween_property(self, "modulate:a", 0.0, STYLE_ANIM_OUT)
