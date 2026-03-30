# DialogueBox.gd
extends Control

var speaker_label : Label
var text_label    : RichTextLabel
var next_btn      : Button
var choices_box   : VBoxContainer

# =====================================================
const STYLE_BG_COLOR        := Color(0.10, 0.08, 0.06, 0.92)
const STYLE_CORNER_RADIUS   := 0
const STYLE_FONT_SIZE_NAME  := 22
const STYLE_FONT_SIZE_TEXT  := 18
const STYLE_FONT_SIZE_BTN   := 16
const STYLE_PANEL_HEIGHT    := 200
# const STYLE_BG_TEXTURE    := "res://ui/dialogue_bg.png"
const STYLE_BTN_NORMAL   := "res://ui/button_normal.png"
const STYLE_BTN_PRESSED  := "res://ui/button_pressed.png"
const STYLE_BTN_HOVER    := "res://ui/button_pressed.png"
#const STYLE_BTN_DISABLED := "res://ui/button_disabled.png"
const STYLE_FONT_NAME     := "res://fonts/medieval.ttf"
const STYLE_FONT_TEXT     := "res://fonts/medieval.ttf"
# =====================================================

func _ready() -> void:
	_build_ui()
	DialogueManager.set_box(self)
	hide()

func _apply_btn_style(b: Button) -> void:
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

	# var style_disabled := StyleBoxTexture.new()
	# style_disabled.texture = load(STYLE_BTN_DISABLED)
	# style_disabled.texture_margin_left   = 4.0
	# style_disabled.texture_margin_right  = 4.0
	# style_disabled.texture_margin_top    = 4.0
	# style_disabled.texture_margin_bottom = 4.0
	# b.add_theme_stylebox_override("disabled", style_disabled)
	pass

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -STYLE_PANEL_HEIGHT
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var style := StyleBoxFlat.new()
	style.bg_color = STYLE_BG_COLOR
	style.corner_radius_top_left     = STYLE_CORNER_RADIUS
	style.corner_radius_top_right    = STYLE_CORNER_RADIUS
	style.corner_radius_bottom_left  = STYLE_CORNER_RADIUS
	style.corner_radius_bottom_right = STYLE_CORNER_RADIUS
	panel.add_theme_stylebox_override("panel", style)
	# var style := StyleBoxTexture.new()
	# style.texture = load(STYLE_BG_TEXTURE)
	# panel.add_theme_stylebox_override("panel", style)

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
	speaker_label.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_NAME)
	speaker_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speaker_label.add_theme_font_override("font", load(STYLE_FONT_NAME))
	vbox.add_child(speaker_label)

	text_label = RichTextLabel.new()
	text_label.bbcode_enabled = true
	text_label.scroll_active = false
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.add_theme_font_size_override("normal_font_size", STYLE_FONT_SIZE_TEXT)
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_label.add_theme_font_override("normal_font", load(STYLE_FONT_TEXT))
	vbox.add_child(text_label)

	choices_box = VBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 6)
	choices_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(choices_box)

	next_btn = Button.new()
	next_btn.text = "Dalej ▶"
	next_btn.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_BTN)
	next_btn.pressed.connect(_on_next_pressed)
	_apply_btn_style(next_btn)
	vbox.add_child(next_btn)

func display_line(line: Dictionary) -> void:
	speaker_label.text = line.get("speaker", "")
	text_label.text    = line.get("text",    "")

	for child in choices_box.get_children():
		child.queue_free()

	if line.has("choices"):
		next_btn.hide()
		choices_box.show()
		var idx := 0
		for choice in line["choices"]:
			var btn := Button.new()
			btn.text = choice["label"]
			btn.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_BTN)
			_apply_btn_style(btn)
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
