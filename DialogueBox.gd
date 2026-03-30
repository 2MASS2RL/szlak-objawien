# DialogueBox.gd
extends Control

var speaker_label : Label
var text_label    : RichTextLabel
var next_btn      : Button
var choices_box   : VBoxContainer

# =====================================================
# === STYL — podmień tutaj gdy będziesz miał grafiki ===
# Krok 1: Odkomentuj linie z "custom_*"
# Krok 2: Wstaw ścieżki do swoich tekstur
# Krok 3: Usuń lub zakomentuj linie ze StyleBoxFlat
# =====================================================
const STYLE_BG_COLOR        := Color(0.10, 0.08, 0.06, 0.92)  # kolor tła panelu
const STYLE_CORNER_RADIUS   := 0                                # zaokrąglenie rogów
const STYLE_FONT_SIZE_NAME  := 22                               # rozmiar czcionki imienia
const STYLE_FONT_SIZE_TEXT  := 18                               # rozmiar czcionki tekstu
const STYLE_FONT_SIZE_BTN   := 16                               # rozmiar czcionki przycisków
const STYLE_PANEL_HEIGHT    := 200                              # wysokość panelu dialogu
# const STYLE_BG_TEXTURE    := "res://ui/dialogue_bg.png"       # <- własna tekstura tła
# const STYLE_BTN_TEXTURE   := "res://ui/button.png"           # <- własna tekstura przycisku
# const STYLE_FONT_NAME     := "res://fonts/medieval.ttf"      # <- własna czcionka imienia
# const STYLE_FONT_TEXT     := "res://fonts/medieval.ttf"      # <- własna czcionka tekstu
# =====================================================

func _ready() -> void:
	_build_ui()
	DialogueManager.set_box(self)
	hide()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -STYLE_PANEL_HEIGHT
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	# === STYL tła panelu ===
	var style := StyleBoxFlat.new()
	style.bg_color = STYLE_BG_COLOR
	style.corner_radius_top_left     = STYLE_CORNER_RADIUS
	style.corner_radius_top_right    = STYLE_CORNER_RADIUS
	style.corner_radius_bottom_left  = STYLE_CORNER_RADIUS
	style.corner_radius_bottom_right = STYLE_CORNER_RADIUS
	panel.add_theme_stylebox_override("panel", style)
	# Gdy będziesz miał teksturę — zamień powyższe na:
	# var style := StyleBoxTexture.new()
	# style.texture = load(STYLE_BG_TEXTURE)
	# panel.add_theme_stylebox_override("panel", style)
	# ===

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
	# Własna czcionka — odkomentuj gdy będziesz miał:
	# speaker_label.add_theme_font_override("font", load(STYLE_FONT_NAME))
	vbox.add_child(speaker_label)

	text_label = RichTextLabel.new()
	text_label.bbcode_enabled = true
	text_label.scroll_active = false
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.add_theme_font_size_override("normal_font_size", STYLE_FONT_SIZE_TEXT)
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Własna czcionka — odkomentuj gdy będziesz miał:
	# text_label.add_theme_font_override("normal_font", load(STYLE_FONT_TEXT))
	vbox.add_child(text_label)

	choices_box = VBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 6)
	choices_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(choices_box)

	next_btn = Button.new()
	next_btn.text = "Dalej ▶"
	next_btn.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_BTN)
	next_btn.pressed.connect(_on_next_pressed)
	# Własna tekstura przycisku — odkomentuj gdy będziesz miał:
	# var btn_style := StyleBoxTexture.new()
	# btn_style.texture = load(STYLE_BTN_TEXTURE)
	# next_btn.add_theme_stylebox_override("normal", btn_style)
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
			# Własna tekstura przycisków wyborów — odkomentuj gdy będziesz miał:
			# var s := StyleBoxTexture.new()
			# s.texture = load(STYLE_BTN_TEXTURE)
			# btn.add_theme_stylebox_override("normal", s)
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
