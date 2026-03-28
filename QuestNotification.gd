# QuestNotification.gd
# Podepnij do Control w UI.tscn (osobny węzeł)

extends Control

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
	_label_name.add_theme_font_size_override("font_size", 16)
	_label_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_label_name)

	_label_goal = Label.new()
	_label_goal.add_theme_font_size_override("font_size", 12)
	_label_goal.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_label_goal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_label_goal)

func _on_quest_started(quest_id: String) -> void:
	var data = QuestManager.get_quest_data(quest_id)
	_label_name.text = "📜 Nowy quest: " + data.get("name", "")
	_label_name.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	_label_goal.text = "Cel: " + data.get("goal", "")
	_animate()

func _on_quest_completed(quest_id: String) -> void:
	var data = QuestManager.get_quest_data(quest_id)
	_label_name.text = "✓ Ukończono: " + data.get("name", "")
	_label_name.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	_label_goal.text = ""
	_animate()

func _animate() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.3)
	_tween.tween_interval(3.0)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5)
