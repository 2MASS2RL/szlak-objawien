# InventoryUI.gd
extends CanvasLayer

# =====================================================
const STYLE_BG_OVERLAY     := Color(0, 0, 0, 0.6)
const STYLE_PANEL_W        := 520.0
const STYLE_PANEL_H        := 480.0
const STYLE_SLOT_SIZE      := 100.0
const STYLE_ICON_SIZE      := 64.0
const STYLE_FONT_SIZE_TTL  := 24
const STYLE_FONT_SIZE_ITEM := 11
const STYLE_FONT_SIZE_CNT  := 12
const STYLE_FONT_SIZE_TTP  := 15
const STYLE_FONT_SIZE_DESC := 12
const STYLE_COLOR_STACK    := Color(1.0, 0.85, 0.3)
const STYLE_COLOR_EMPTY    := Color(0.6, 0.6, 0.6)
const STYLE_COLOR_DESC     := Color(0.8, 0.8, 0.8)
# const STYLE_BG_TEXTURE   := "res://ui/inventory_bg.png"
# const STYLE_SLOT_TEXTURE := "res://ui/slot.png"
const STYLE_BTN_NORMAL   := "res://ui/button_normal.png"
const STYLE_BTN_PRESSED  := "res://ui/button_pressed.png"
const STYLE_BTN_HOVER    := "res://ui/button_pressed.png"
#const STYLE_BTN_DISABLED := "res://ui/button_disabled.png"
const STYLE_FONT_TTL     := "res://fonts/medieval.ttf"
const STYLE_FONT_ITEM    := "res://fonts/medieval.ttf"
const STYLE_DOC_COLOR      := Color(0.96, 0.92, 0.82)
const STYLE_DOC_TEXT_COLOR := Color(0.15, 0.1, 0.05)
const STYLE_DOC_ROTATION   := 0
const STYLE_DOC_TEXTURE  := "res://ui/paper.png"
# =====================================================

const CATEGORIES = [
	{ "id": "quest",    "label": "Przedmioty" },
	{ "id": "document", "label": "Dokumenty"  },
]

var _current_category : String = "quest"
var _panel            : Panel
var _grid             : GridContainer
var _tooltip          : Panel
var _tooltip_name     : Label
var _tooltip_desc     : Label
var _tab_buttons      : Dictionary = {}
var _preview          : Control = null
var _root             : Control

func _ready() -> void:
	_build_ui()
	InventoryManager.inventory_changed.connect(_refresh)
	visible = false

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
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = STYLE_BG_OVERLAY
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(bg)

	_panel = Panel.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(STYLE_PANEL_W, STYLE_PANEL_H)
	_panel.offset_left   = -STYLE_PANEL_W / 2
	_panel.offset_top    = -STYLE_PANEL_H / 2
	_panel.offset_right  =  STYLE_PANEL_W / 2
	_panel.offset_bottom =  STYLE_PANEL_H / 2
	# === STYL panelu ===
	# var panel_style := StyleBoxTexture.new()
	# panel_style.texture = load(STYLE_BG_TEXTURE)
	# _panel.add_theme_stylebox_override("panel", panel_style)
	_root.add_child(_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   20)
	margin.add_theme_constant_override("margin_right",  20)
	margin.add_theme_constant_override("margin_top",    15)
	margin.add_theme_constant_override("margin_bottom", 15)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "🎒  Ekwipunek"
	title.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_TTL)
	title.add_theme_font_override("font", load(STYLE_FONT_TTL))
	vbox.add_child(title)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	vbox.add_child(tabs)

	for cat in CATEGORIES:
		var btn := Button.new()
		btn.text = cat["label"]
		btn.toggle_mode = true
		btn.pressed.connect(_on_tab_pressed.bind(cat["id"]))
		_apply_btn_style(btn)
		_tab_buttons[cat["id"]] = btn
		tabs.add_child(btn)

	vbox.add_child(HSeparator.new())

	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(_grid)

	var close := Button.new()
	close.text = "Zamknij  [Tab]"
	close.pressed.connect(func(): visible = false)
	_apply_btn_style(close)
	vbox.add_child(close)

	_tooltip = Panel.new()
	_tooltip.custom_minimum_size = Vector2(220, 80)
	_tooltip.hide()
	_root.add_child(_tooltip)

	var m := MarginContainer.new()
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left",  10)
	m.add_theme_constant_override("margin_right", 10)
	m.add_theme_constant_override("margin_top",    8)
	m.add_theme_constant_override("margin_bottom", 8)
	_tooltip.add_child(m)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	m.add_child(v)

	_tooltip_name = Label.new()
	_tooltip_name.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_TTP)
	v.add_child(_tooltip_name)

	_tooltip_desc = Label.new()
	_tooltip_desc.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_DESC)
	_tooltip_desc.add_theme_color_override("font_color", STYLE_COLOR_DESC)
	_tooltip_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_desc.custom_minimum_size = Vector2(200, 0)
	v.add_child(_tooltip_desc)

	_set_category("quest")

func _show_preview(data: Dictionary) -> void:
	if _preview != null:
		_preview.queue_free()
	if data.get("category", "quest") == "document":
		_show_document_preview(data)
	else:
		_show_item_preview(data)

func _show_item_preview(data: Dictionary) -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed: _close_preview())
	_root.add_child(overlay)
	_preview = overlay

	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(360, 300)
	panel.offset_left   = -180
	panel.offset_top    = -150
	panel.offset_right  =  180
	panel.offset_bottom =  150
	# === STYL panelu podglądu ===
	# var style := StyleBoxTexture.new()
	# style.texture = load(STYLE_BG_TEXTURE)
	# panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   25)
	margin.add_theme_constant_override("margin_right",  25)
	margin.add_theme_constant_override("margin_top",    20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(96, 96)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if data.has("icon"):
		var tex = load(data["icon"])
		if tex: icon.texture = tex
	vbox.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.text = data.get("name", "")
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	vbox.add_child(HSeparator.new())

	var desc := RichTextLabel.new()
	desc.bbcode_enabled = true
	desc.scroll_active = false
	desc.fit_content = true
	desc.text = data.get("description", "")
	desc.add_theme_font_size_override("normal_font_size", 14)
	vbox.add_child(desc)

	var close := Button.new()
	close.text = "Zamknij"
	close.pressed.connect(_close_preview)
	_apply_btn_style(close)
	vbox.add_child(close)

func _show_document_preview(data: Dictionary) -> void:
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed: _close_preview())
	_root.add_child(overlay)
	_preview = overlay

	var paper := Panel.new()
	paper.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	paper.custom_minimum_size = Vector2(400, 500)
	paper.offset_left   = -200
	paper.offset_top    = -250
	paper.offset_right  =  200
	paper.offset_bottom =  250
	paper.rotation_degrees = STYLE_DOC_ROTATION
	var style := StyleBoxFlat.new()
	style.bg_color = STYLE_DOC_COLOR
	style.corner_radius_top_left     = 4
	style.corner_radius_top_right    = 4
	style.corner_radius_bottom_left  = 4
	style.corner_radius_bottom_right = 4
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size  = 8
	paper.add_theme_stylebox_override("panel", style)
	# var style := StyleBoxTexture.new()
	# style.texture = load(STYLE_DOC_TEXTURE)
	# paper.add_theme_stylebox_override("panel", style)
	overlay.add_child(paper)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   30)
	margin.add_theme_constant_override("margin_right",  30)
	margin.add_theme_constant_override("margin_top",    30)
	margin.add_theme_constant_override("margin_bottom", 30)
	paper.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = data.get("name", "")
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", STYLE_DOC_TEXT_COLOR)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 2)
	sep.color = Color(0.5, 0.35, 0.2, 0.5)
	vbox.add_child(sep)

	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.scroll_active = true
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.text = data.get("content", "")
	text.add_theme_font_size_override("normal_font_size", 15)
	text.add_theme_color_override("default_color", STYLE_DOC_TEXT_COLOR)
	text.mouse_filter = Control.MOUSE_FILTER_STOP  
	text.custom_minimum_size = Vector2(0, 300)     
	vbox.add_child(text)

	var close := Button.new()
	close.text = "✕  Zamknij"
	close.pressed.connect(_close_preview)
	_apply_btn_style(close)
	vbox.add_child(close)

func _close_preview() -> void:
	if _preview != null:
		_preview.queue_free()
		_preview = null

func _set_category(category: String) -> void:
	_current_category = category
	for id in _tab_buttons:
		_tab_buttons[id].button_pressed = (id == category)
	_refresh()

func _on_tab_pressed(category: String) -> void:
	_set_category(category)

func _refresh(_ignored = null) -> void:
	if InventoryManager.slots.size() == 0:
		return
	for c in _grid.get_children():
		c.queue_free()

	var items = InventoryManager.get_items_by_category(_current_category)

	if items.is_empty():
		var lbl := Label.new()
		lbl.text = "Brak przedmiotów w tej kategorii."
		lbl.add_theme_color_override("font_color", STYLE_COLOR_EMPTY)
		lbl.add_theme_font_size_override("font_size", 14)
		_grid.add_child(lbl)
		return

	for entry in items:
		_add_slot(entry)

func _add_slot(entry: Dictionary) -> void:
	var data = ItemManager.get_item(entry["item_id"])

	var slot := Panel.new()
	slot.custom_minimum_size = Vector2(STYLE_SLOT_SIZE, STYLE_SLOT_SIZE)
	# === STYL slotu ===
	# var slot_style := StyleBoxTexture.new()
	# slot_style.texture = load(STYLE_SLOT_TEXTURE)
	# slot.add_theme_stylebox_override("panel", slot_style)
	_grid.add_child(slot)

	var v := VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 2)
	slot.add_child(v)

	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(STYLE_ICON_SIZE, STYLE_ICON_SIZE)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if data.has("icon"):
		var tex = load(data["icon"])
		if tex: icon.texture = tex
	v.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.text = data.get("name", entry["item_id"])
	name_lbl.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_ITEM)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.add_theme_font_override("font", load(STYLE_FONT_ITEM))
	v.add_child(name_lbl)

	if entry["count"] > 1:
		var count_lbl := Label.new()
		count_lbl.text = "x" + str(entry["count"])
		count_lbl.add_theme_font_size_override("font_size", STYLE_FONT_SIZE_CNT)
		count_lbl.add_theme_color_override("font_color", STYLE_COLOR_STACK)
		count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(count_lbl)

	slot.mouse_entered.connect(_show_tooltip.bind(data, slot))
	slot.mouse_exited.connect(_hide_tooltip)
	slot.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			_show_preview(data))

func _show_tooltip(data: Dictionary, slot: Panel) -> void:
	_tooltip_name.text = data.get("name", "")
	_tooltip_desc.text = data.get("description", "")
	_tooltip.show()
	await get_tree().process_frame
	var pos = slot.global_position + Vector2(slot.size.x + 8, 0)
	if pos.x + 220 > get_viewport().size.x:
		pos.x = slot.global_position.x - 228
	_tooltip.global_position = pos

func _hide_tooltip() -> void:
	_tooltip.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		visible = !visible
		if visible:
			_refresh()
