extends Area2D

@export var dialogue_tag  : String = ""
@export var one_shot      : bool   = true

enum ZoomMode { NONE, PLAYER, POINT, NPC }
@export var zoom_mode     : ZoomMode  = ZoomMode.NONE
@export var zoom_value    : float     = 1.8
@export var zoom_point    : Vector2   = Vector2.ZERO  # używane przy POINT i NPC

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return
	if one_shot and ItemManager.is_picked("trigger_" + dialogue_tag):
		return
	if dialogue_tag == "":
		push_warning("DialogAktywacja: nie ustawiono dialogue_tag!")
		return
	if one_shot:
		ItemManager.mark_picked("trigger_" + dialogue_tag)

	var req := _build_zoom_request()
	DialogueManager.start_dialogue(dialogue_tag, zoom_point, req)

func _build_zoom_request() -> Dictionary:
	match zoom_mode:
		ZoomMode.NONE:
			return { "mode": "none" }
		ZoomMode.PLAYER:
			return { "mode": "player", "zoom": zoom_value }
		ZoomMode.POINT:
			return { "mode": "point",  "zoom": zoom_value, "pos": zoom_point }
		ZoomMode.NPC:
			return { "mode": "npc",    "zoom": zoom_value, "pos": zoom_point }
	return { "mode": "none" }
