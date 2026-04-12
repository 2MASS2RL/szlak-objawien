extends Area2D

@export var dialogue_tag: String = ""
@export var quest_id_to_check: String = ""
@export var dialogue_tag_active: String = ""
@export var dialogue_tag_completed: String = ""

# Widoczność NPC zależna od questa
@export var visible_quest_id: String = ""
@export var visible_when: String = "always"  # "always" | "before" | "after"

enum ZoomMode { NONE, PLAYER, POINT, NPC }
@export var zoom_mode  : ZoomMode = ZoomMode.NONE
@export var zoom_value : float    = 1.8
@export var zoom_point : Vector2  = Vector2.ZERO

var _player_nearby: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	QuestManager.quest_started.connect(_update_visibility)
	QuestManager.quest_completed.connect(_update_visibility)
	_update_visibility("")

func _update_visibility(_quest_id: String) -> void:
	if visible_quest_id == "" or visible_when == "always":
		visible = true
		return
	match visible_when:
		"before":
			visible = not QuestManager.is_completed(visible_quest_id)
		"after":
			visible = QuestManager.is_completed(visible_quest_id)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("=== INPUT DEBUG ===")
		print("player_nearby: ", _player_nearby)
		print("dialogue_active: ", DialogueManager.is_active())
		print("===================")

		if _player_nearby and not DialogueManager.is_active():
			var req := _build_zoom_request()
			DialogueManager.start_dialogue(_get_dialogue_tag(), global_position, req)

func _get_dialogue_tag() -> String:
	if quest_id_to_check == "":
		return dialogue_tag

	print("=== QUEST DEBUG ===")
	print("Quest ID: ", quest_id_to_check)
	print("is_completed: ", QuestManager.is_completed(quest_id_to_check))
	print("has_quest: ", QuestManager.has_quest(quest_id_to_check))
	print("tag default: ", dialogue_tag)
	print("tag active: ", dialogue_tag_active)
	print("tag completed: ", dialogue_tag_completed)
	print("===================")

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
