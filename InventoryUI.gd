# InventoryUI.gd
extends CanvasLayer

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

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.6)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(bg)

	_panel = Panel.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(520, 480)
	_panel.offset_left   = -260
	_panel.offset_top    = -240
	_panel.offset_right  =  260
	_panel.offset_bottom =  240
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
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	vbox.add_child(tabs)

	for cat in CATEGORIES:
		var btn := Button.new()
		btn.text = cat["label"]
		btn.toggle_mode = true
		btn.pressed.connect(_on_tab_pressed.bind(cat["id"]))
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
	vbox.add_child(close)

	# Tooltip
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
	_tooltip_name.add_theme_font_size_override("font_size", 15)
	v.add_child(_tooltip_name)

	_tooltip_desc = Label.new()
	_tooltip_desc.add_theme_font_size_override("font_size", 12)
	_tooltip_desc.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_tooltip_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_desc.custom_minimum_size = Vector2(200, 0)
	v.add_child(_tooltip_desc)

	_set_category("quest")

# ─── PODGLĄD ITEMU ───────────────────────────

func _show_preview(data: Dictionary) -> void:
	if _preview != null:
		_preview.queue_free()

	var category = data.get("category", "quest")

	if category == "document":
		_show_document_preview(data)
	else:
		_show_item_preview(data)

func _show_item_preview(data: Dictionary) -> void:
	# Ciemne tło
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			_close_preview())
	_root.add_child(overlay)
	_preview = overlay

	# Panel podglądu
	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(360, 300)
	panel.offset_left   = -180
	panel.offset_top    = -150
	panel.offset_right  =  180
	panel.offset_bottom =  150
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

	# Ikonka
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(96, 96)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if data.has("icon"):
		var tex = load(data["icon"])
		if tex:
			icon.texture = tex
	vbox.add_child(icon)

	# Nazwa
	var name_lbl := Label.new()
	name_lbl.text = data.get("name", "")
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)

	vbox.add_child(HSeparator.new())

	# Opis
	var desc := RichTextLabel.new()
	desc.bbcode_enabled = true
	desc.scroll_active = false
	desc.fit_content = true
	desc.text = data.get("description", "")
	desc.add_theme_font_size_override("normal_font_size", 14)
	vbox.add_child(desc)

	# Zamknij
	var close := Button.new()
	close.text = "Zamknij"
	close.pressed.connect(_close_preview)
	vbox.add_child(close)

func _show_document_preview(data: Dictionary) -> void:
	# Ciemne tło
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			_close_preview())
	_root.add_child(overlay)
	_preview = overlay

	# Kartka — lekko obrócona
	var paper := Panel.new()
	paper.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	paper.custom_minimum_size = Vector2(400, 500)
	paper.offset_left   = -200
	paper.offset_top    = -250
	paper.offset_right  =  200
	paper.offset_bottom =  250
	paper.rotation_degrees = 0 # lekkie pochylenie

	# Styl kartki — kremowy kolor
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.96, 0.92, 0.82)
	style.corner_radius_top_left     = 4
	style.corner_radius_top_right    = 4
	style.corner_radius_bottom_left  = 4
	style.corner_radius_bottom_right = 4
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size  = 8
	paper.add_theme_stylebox_override("panel", style)
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

	# Tytuł notatki
	var title := Label.new()
	title.text = data.get("name", "")
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Linia dekoracyjna
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 2)
	sep.color = Color(0.5, 0.35, 0.2, 0.5)
	vbox.add_child(sep)

	# Treść notatki
	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.scroll_active = true
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.text = data.get("content", data.get("description", ""))
	text.add_theme_font_size_override("normal_font_size", 15)
	text.add_theme_color_override("default_color", Color(0.15, 0.1, 0.05))
	vbox.add_child(text)

	# Zamknij
	var close := Button.new()
	close.text = "✕  Zamknij"
	close.pressed.connect(_close_preview)
	vbox.add_child(close)

func _close_preview() -> void:
	if _preview != null:
		_preview.queue_free()
		_preview = null

# ─── RESZTA ──────────────────────────────────

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
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		lbl.add_theme_font_size_override("font_size", 14)
		_grid.add_child(lbl)
		return

	for entry in items:
		_add_slot(entry)

func _add_slot(entry: Dictionary) -> void:
	var data = ItemManager.get_item(entry["item_id"])

	var slot := Panel.new()
	slot.custom_minimum_size = Vector2(100, 100)
	_grid.add_child(slot)

	var v := VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 2)
	slot.add_child(v)

	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(64, 64)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if data.has("icon"):
		var tex = load(data["icon"])
		if tex:
			icon.texture = tex
	v.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.text = data.get("name", entry["item_id"])
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(name_lbl)

	if entry["count"] > 1:
		var count_lbl := Label.new()
		count_lbl.text = "x" + str(entry["count"])
		count_lbl.add_theme_font_size_override("font_size", 12)
		count_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(count_lbl)

	# Hover tooltip
	slot.mouse_entered.connect(_show_tooltip.bind(data, slot))
	slot.mouse_exited.connect(_hide_tooltip)
	# Kliknięcie = podgląd
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
