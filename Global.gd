extends Node

var spawn_position: Vector2 = Vector2(200, 500)

var scenes: Dictionary = {
	"main":   "res://main.tscn",
	"right":  "res://SceneRight.tscn",
	"right2":  "res://scene_3.tscn",
	"left":   "res://SceneRight.tscn",
	"top":    "res://SceneTop.tscn",
	"bottom": "res://SceneBottom.tscn",
}

# Mapa połączeń: skąd → [prawo, lewo, góra, dół]
var connections: Dictionary = {
	"main":   {"right": "right",  "left": "left",  "up": "top",   "down": "bottom"},
	"right":  {"left": "main",    "right": "right2",    "up": null,    "down": null},
	"right2":  {"left": "right",    "right": null,    "up": null,    "down": null},
	"left":   {"right": "main",   "left": null,     "up": null,    "down": null},
	"top":    {"down": "main",    "up": null,        "left": null,  "right": null},
	"bottom": {"up": "main",      "down": null,      "left": null,  "right": null},
}

var current_scene_key: String = "main"

func go(direction: String):
	var next = connections[current_scene_key].get(direction, null)
	if next == null:
		print("Brak sceny w kierunku: ", direction)
		return
	# Ustaw spawn po przeciwnej stronie
	match direction:
		"right":  spawn_position = Vector2(100, 500)
		"left":   spawn_position = Vector2(1850, 500)
		"up":     spawn_position = Vector2(960, 900)
		"down":   spawn_position = Vector2(960, 100)
	current_scene_key = next
	get_tree().call_deferred("change_scene_to_file", scenes[next])
