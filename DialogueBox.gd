# DialogueBox.gd
extends Control

var speaker_label : Label
var text_label    : RichTextLabel
var next_btn      : Button
var choices_box   : VBoxContainer

func _ready() -> void:
	_build_ui()
	DialogueManager.set_box(self)
	hide()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -200
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   20)
	margin.add_theme_constant_override("margin_right",  20)
	margin.add_theme_constant_override("margin_top",    10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vbox)

	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 22)
	speaker_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(speaker_label)

	text_label = RichTextLabel.new()
	text_label.bbcode_enabled = true
	text_label.scroll_active = false
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.add_theme_font_size_override("normal_font_size", 18)
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(text_label)

	choices_box = VBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 6)
	choices_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(choices_box)

	next_btn = Button.new()
	next_btn.text = "Dalej ▶"
	next_btn.pressed.connect(_on_next_pressed)
	vbox.add_child(next_btn)

func display_line(line: Dictionary) -> void:
	speaker_label.text = line.get("speaker", "")
	text_label.text    = line.get("text",    "")

	# Usuń stare przyciski
	for child in choices_box.get_children():
		child.queue_free()

	if line.has("choices"):
		next_btn.hide()
		choices_box.show()
		var idx := 0
		for choice in line["choices"]:
			var btn := Button.new()
			btn.text = choice["label"]
			var i := idx
			btn.pressed.connect(func(): DialogueManager.pick_choice(i))
			choices_box.add_child(btn)
			idx += 1
	else:
		choices_box.hide()
		next_btn.show()

	show()

func _on_next_pressed() -> void:
	DialogueManager.next_line()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") and next_btn.visible:
		DialogueManager.next_line()
		get_viewport().set_input_as_handled()
