extends CanvasLayer

var inventory: Array = [null, null, null, null, null, null]  # 6 slotów

@onready var slots = $Panel/GridContainer.get_children()

func _ready():
	visible = false  # domyślnie ukryte

func _input(event):
	if Input.is_action_just_pressed("ui_focus_next"):  # Tab
		visible = !visible

func add_item(item_name: String, item_texture: Texture2D) -> bool:
	print("Dodaję item: ", item_name)
	print("Slots count: ", slots.size())
	print("Inventory: ", inventory)
	
	for i in range(inventory.size()):
		if inventory[i] == null and i < slots.size():
			print("Wkładam do slotu: ", i)
			inventory[i] = item_name
			var icon = slots[i].get_node("TextureRect")
			print("TextureRect: ", icon)
			icon.texture = item_texture
			return true
	print("Inventory pełne!")
	return false

func remove_item(index: int):
	inventory[index] = null
	slots[index].get_node("TextureRect").texture = null
