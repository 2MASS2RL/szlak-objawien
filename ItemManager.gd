# ItemManager.gd
# Autoload: Project > Project Settings > Autoload
# Nazwa: ItemManager

extends Node

signal item_picked(item_id: String)

# Baza wszystkich itemów w grze
# Dodaj tutaj każdy item który istnieje w grze
var items: Dictionary = {
	"klucz_zakrystii": {
		"name":        "Klucz zakrystii",
		"description": "Stary żelazny klucz do drzwi zakrystii.",
		"content":     "",  # przedmioty questowe nie mają treści listu
		"category":    "quest",
		"icon":        "res://icons/klucz.png",
		"stackable":   false,
		"max_stack":   1,
	},
	"notatka_proboszcza": {
		"name":        "Notatka proboszcza",
		"description": "Zapiski proboszcza dotyczące jutrzejszej mszy.",
		"content":     "Drogi bracie,\n\nJutro o świcie odprawiamy mszę ku czci Świętej Marii Magdaleny. Potrzebne będą:\n\n- Kielich z zakrystii\n- Świece z kapliczki\n- Relikwiarz z krypty\n\nProszę o pomoc w ich odnalezieniu.\n\n[i]— Ks. Stanisław[/i]",
		"category":    "document",
		"icon":        "res://icons/notatka.png",
		"stackable":   false,
		"max_stack":   1,
	},
	# ── Dodawaj kolejne itemy tutaj ──
	# "twoj_item_id": {
	#     "name":        "Nazwa itemu",
	#     "description": "Opis itemu widoczny w inventory.",
	#     "category":    "quest",       # "quest" lub "document"
	#     "icon":        "res://icons/twoj_icon.png",
	#     "stackable":   false,
	#     "max_stack":   1,
	# },
}

# Zbiór podniesionych itemów — persystuje przez całą grę
var _picked: Dictionary = {}  # { item_id: true }

# ─────────────────────────────────────────────
# API
# ─────────────────────────────────────────────

# Czy item został już podniesiony?
func is_picked(item_id: String) -> bool:
	return _picked.has(item_id)

# Oznacz item jako podniesiony (wywołuje Item.gd automatycznie)
func mark_picked(item_id: String) -> void:
	if _picked.has(item_id):
		return
	_picked[item_id] = true
	emit_signal("item_picked", item_id)

# Pobierz dane itemu
func get_item(item_id: String) -> Dictionary:
	return items.get(item_id, {})

# Czy item istnieje w bazie?
func has_item(item_id: String) -> bool:
	return items.has(item_id)
