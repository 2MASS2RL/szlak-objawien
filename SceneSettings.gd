extends Node

@export var y_min      : float = 100.0
@export var y_max      : float = 900.0
@export var scale_min  : float = 0.3
@export var scale_max  : float = 1.0
@export var camera_zoom: float = 1.0

func _ready() -> void:
	# Czekaj aż WSZYSTKIE węzły sceny mają _ready() za sobą
	await get_tree().process_frame
	_setup()

func _setup() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		players[0].apply_scene_settings(self)
		print("✓ Settings zastosowane do gracza")
	else:
		print("✗ Gracz nie znaleziony!")

	var cameras = get_tree().get_nodes_in_group("GameCamera")
	if cameras.size() > 0:
		cameras[0].apply_scene_settings(self)
