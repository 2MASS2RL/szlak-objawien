# Item.gd
# Podepnij do węzła Area2D
# Każdy przedmiot na scenie to Area2D z tym skryptem

extends Area2D

@export var item_id: String = ""         # ID z ItemManager.items
@export var complete_quest_on_pick: String = ""  # opcjonalnie: ukończ quest po podniesieniu

var _player_nearby: bool = false
var _hint_label: Label

func _ready() -> void:
	# Jeśli item był już podniesiony — usuń ze sceny
	if ItemManager.is_picked(item_id):
		queue_free()
		return

	_build_hint()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _build_hint() -> void:
	_hint_label = Label.new()
	var data = ItemManager.get_item(item_id)
	_hint_label.text = "[E] Podnieś: " + data.get("name", item_id)
	_hint_label.add_theme_font_size_override("font_size", 13)
	_hint_label.position = Vector2(-80, -50)
	_hint_label.hide()
	add_child(_hint_label)

func _input(event: InputEvent) -> void:
	if _player_nearby and event.is_action_pressed("interact"):
		_pick_up()

func _pick_up() -> void:
	if item_id == "":
		push_warning("Item.gd: brak item_id!")
		return

	# Dodaj do inventory
	var added = InventoryManager.add_item(item_id)
	if not added:
		# Inventory pełne
		return

	# Oznacz jako podniesiony
	ItemManager.mark_picked(item_id)

	# Ukończ quest jeśli ustawiony
	if complete_quest_on_pick != "":
		QuestManager.complete_quest(complete_quest_on_pick)

	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_nearby = true
		_hint_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_nearby = false
		_hint_label.hide()
