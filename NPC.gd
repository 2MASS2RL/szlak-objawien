# NPC.gd
# Podepnij do węzła Area2D (każdy NPC to osobny Area2D)

extends Area2D

@export var dialogue_tag: String = ""           # domyślny dialog
@export var quest_id_to_check: String = ""      # który quest sprawdzać
@export var dialogue_tag_active: String = ""    # gdy quest w trakcie
@export var dialogue_tag_completed: String = "" # gdy quest ukończony

var _player_nearby: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if _player_nearby and event.is_action_pressed("interact"):
		if not DialogueManager.is_active():
			DialogueManager.start_dialogue(_get_dialogue_tag(), global_position)

func _get_dialogue_tag() -> String:
	if quest_id_to_check == "":
		return dialogue_tag
	if QuestManager.is_completed(quest_id_to_check) and dialogue_tag_completed != "":
		return dialogue_tag_completed
	elif QuestManager.has_quest(quest_id_to_check) and dialogue_tag_active != "":
		return dialogue_tag_active
	else:
		return dialogue_tag

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_nearby = false
