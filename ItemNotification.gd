extends CanvasLayer

const FONT         := "res://fonts/medieval.ttf"
const DURATION     := 2.5

var _label : Label

func _ready() -> void:
	layer = 20
	_label = Label.new()
	_label.add_theme_font_override("font", load(FONT))
	_label.add_theme_font_size_override("font_size", 20)
	_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_label.offset_left  = -320
	_label.offset_top   = 20
	_label.offset_right = -20
	_label.offset_bottom = 60
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.visible = false
	add_child(_label)

func show_item(item_id: String) -> void:
	var data = ItemManager.get_item(item_id)
	var name = data.get("name", item_id)
	_label.text    = "Otrzymano: " + name
	_label.visible = true
	await get_tree().create_timer(DURATION).timeout
	_label.visible = false
