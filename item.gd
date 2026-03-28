extends Area2D

@export var item_name: String = "Przedmiot"
@export var item_texture: Texture2D

@onready var label = $Label

var player_nearby = false

func _ready():
	label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if "Player" in body.get_groups():
		player_nearby = true
		label.text = "[E] " + item_name
		label.visible = true

func _on_body_exited(body):
	if "Player" in body.get_groups():
		player_nearby = false
		label.visible = false

func _input(event):
	if player_nearby and Input.is_action_just_pressed("interact"):
		if InventoryUI.add_item(item_name, item_texture):
			queue_free()  # usuń item ze sceny
