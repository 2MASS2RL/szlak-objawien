extends Area2D

@export var dialogue_tag: String = ""
@export var quest_id_to_check: String = ""
@export var dialogue_tag_active: String = ""
@export var dialogue_tag_completed: String = ""

enum ZoomMode { NONE, PLAYER, POINT, NPC }
@export var zoom_mode  : ZoomMode = ZoomMode.NONE
@export var zoom_value : float    = 1.8
@export var zoom_point : Vector2  = Vector2.ZERO

var _player_nearby: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if _player_nearby and event.is_action_pressed("interact"):
		if not DialogueManager.is_active():
			var req := _build_zoom_request()
			DialogueManager.start_dialogue(_get_dialogue_tag(), global_position, req)

func _get_dialogue_tag() -> String:
	if quest_id_to_check == "":
		return dialogue_tag
	if QuestManager.is_completed(quest_id_to_check) and dialogue_tag_completed != "":
		return dialogue_tag_completed
	elif QuestManager.has_quest(quest_id_to_check) and dialogue_tag_active != "":
		return dialogue_tag_active
	return dialogue_tag

func _build_zoom_request() -> Dictionary:
	match zoom_mode:
		ZoomMode.NONE:   return { "mode": "none" }
		ZoomMode.PLAYER: return { "mode": "player", "zoom": zoom_value }
		ZoomMode.POINT:  return { "mode": "point",  "zoom": zoom_value, "pos": zoom_point }
		ZoomMode.NPC:    return { "mode": "npc",    "zoom": zoom_value, "pos": zoom_point }
	return { "mode": "none" }

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_nearby = false
