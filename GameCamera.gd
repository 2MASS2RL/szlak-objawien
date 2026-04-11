# GameCamera.gd
extends Camera2D

@export var default_zoom  : float = 1.0
@export var zoom_speed    : float = 2.0

var _target_zoom     : float
var _follow_player   : bool   = false
var _returning       : bool   = false
var _player          : Node2D = null
var _original_parent : Node   = null
var _detached        : bool   = false

func _ready() -> void:
	add_to_group("GameCamera") 
	_target_zoom     = default_zoom
	_original_parent = get_parent()
	zoom = Vector2(default_zoom, default_zoom)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		_player = players[0]

func _process(delta: float) -> void:
	zoom = zoom.lerp(Vector2(_target_zoom, _target_zoom), zoom_speed * delta)
	if _follow_player and _player != null:
		global_position = global_position.lerp(_player.global_position, zoom_speed * delta)
	elif _returning and _player != null:
		global_position = global_position.lerp(_player.global_position, zoom_speed * delta)
		if global_position.distance_to(_player.global_position) < 2.0:
			_returning = false
			_reattach()

func _on_dialogue_started(_tag: String) -> void:
	var req = DialogueManager.current_zoom_request
	_follow_player = false
	_returning     = false
	_detach()
	match req["mode"]:
		"none":
			_target_zoom = default_zoom
		"player":
			_target_zoom   = req["zoom"]
			_follow_player = true
		"point":
			_target_zoom    = req["zoom"]
			global_position = req["pos"]
		"npc":
			_target_zoom = req["zoom"]
			if _player != null:
				global_position = _player.global_position.lerp(req["pos"], 0.5)

func _on_dialogue_ended(_tag: String) -> void:
	_target_zoom   = default_zoom
	_follow_player = false
	_returning     = true

func _detach() -> void:
	if _detached:
		return
	if get_parent() == null:
		return
	var scene = get_tree().current_scene
	if scene == null:
		return
	if get_parent() == scene:
		return
	var gpos = global_position
	get_parent().remove_child(self)
	scene.add_child(self)
	global_position = gpos
	_detached = true

func _reattach() -> void:
	if not _detached:
		return
	if _original_parent == null or not is_instance_valid(_original_parent):
		_detached = false
		return
	var gpos = global_position
	if get_parent() != null:
		get_parent().remove_child(self)
	_original_parent.add_child(self)
	global_position = gpos
	_detached = false

func apply_scene_settings(settings: Node) -> void:
	default_zoom = settings.camera_zoom
	_target_zoom = settings.camera_zoom
	zoom         = Vector2(settings.camera_zoom, settings.camera_zoom)
