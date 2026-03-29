# InventoryManager.gd
# Autoload: Project > Project Settings > Autoload
# Nazwa: InventoryManager

extends Node

signal inventory_changed

const MAX_SLOTS = 12  # maksymalna liczba slotów

# Slot: { "item_id": String, "count": int } lub null
var slots: Array = []

func _ready() -> void:
	for i in range(MAX_SLOTS):
		slots.append(null)

# ─────────────────────────────────────────────
# API
# ─────────────────────────────────────────────

# Dodaj item — zwraca true jeśli się udało
func add_item(item_id: String) -> bool:
	var data = ItemManager.get_item(item_id)
	if data.is_empty():
		push_warning("InventoryManager: nieznany item '%s'" % item_id)
		return false

	# Stackowanie — znajdź istniejący slot z tym itemem
	if data.get("stackable", false):
		for i in range(MAX_SLOTS):
			if slots[i] != null and slots[i]["item_id"] == item_id:
				if slots[i]["count"] < data.get("max_stack", 99):
					slots[i]["count"] += 1
					emit_signal("inventory_changed")
					return true

	# Znajdź pusty slot
	for i in range(MAX_SLOTS):
		if slots[i] == null:
			slots[i] = { "item_id": item_id, "count": 1 }
			emit_signal("inventory_changed")
			return true

	print("Inventory pełne!")
	return false

# Usuń item ze slotu
func remove_item(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return
	if slots[slot_index] == null:
		return
	if slots[slot_index]["count"] > 1:
		slots[slot_index]["count"] -= 1
	else:
		slots[slot_index] = null
	emit_signal("inventory_changed")

# Czy gracz ma dany item?
func has_item(item_id: String) -> bool:
	for slot in slots:
		if slot != null and slot["item_id"] == item_id:
			return true
	return false

# Ile sztuk danego itemu ma gracz?
func count_item(item_id: String) -> int:
	var total := 0
	for slot in slots:
		if slot != null and slot["item_id"] == item_id:
			total += slot["count"]
	return total

# Pobierz itemy z danej kategorii
func get_items_by_category(category: String) -> Array:
	print("slots.size(): ", slots.size(), " | slots: ", slots)
	var result := []
	for i in range(slots.size()):
		var slot = slots[i]
		if slot != null:
			var data = ItemManager.get_item(slot["item_id"])
			if data.get("category", "") == category:
				result.append({ "slot": i, "item_id": slot["item_id"], "count": slot["count"] })
	return result
