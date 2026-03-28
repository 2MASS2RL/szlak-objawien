# GameCamera.gd
# Podepnij do swojego węzła Camera2D na scenie

extends Camera2D

@export var default_zoom   : float = 1.0   # normalny zoom
@export var dialogue_zoom  : float = 1.8   # zoom podczas dialogu (im wyżej tym bliżej)
@export var zoom_speed     : float = 2.0   # szybkość przejścia

var _target_zoom    : float
var _target_pos     : Vector2
var _dialogue_mode  : bool = false
var _npc_pos        : Vector2 = Vector2.ZERO
var _player         : Node2D = null

var _default_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	_target_zoom = default_zoom
	_target_pos  = global_position
	_default_pos = global_position

	# Podepnij sygnały DialogueManager
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# Znajdź gracza automatycznie przez grupę
	await get_tree().process_frame
	_default_pos = global_position
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		_player = players[0]

func _process(delta: float) -> void:
	zoom = zoom.lerp(Vector2(_target_zoom, _target_zoom), zoom_speed * delta)
	if _dialogue_mode and _player != null and _npc_pos != Vector2.ZERO:
		var mid = _player.global_position.lerp(_npc_pos, 0.5)
		global_position = global_position.lerp(mid, zoom_speed * delta)
	else:
		if Input.is_action_just_pressed("ui_accept"):
			print("pozycja kamery teraz: ", global_position)

func _on_dialogue_started(npc_tag: String) -> void:
	_dialogue_mode = true
	_target_zoom   = dialogue_zoom
	# Pobierz pozycję NPC który wywołał dialog
	# NPC.gd zapisuje swoją pozycję do DialogueManager — patrz niżej
	_npc_pos = DialogueManager.current_npc_pos

func _on_dialogue_ended(npc_tag: String) -> void:
	_dialogue_mode = false
	_target_zoom   = default_zoom
	zoom = Vector2(default_zoom, default_zoom)
	await get_tree().process_frame
	global_position = _default_pos
