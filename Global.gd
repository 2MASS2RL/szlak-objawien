extends Node

var spawn_position: Vector2 = Vector2(960, 900)

var scenes: Dictionary = {
	"main":   "res://scena_1.tscn",
	"top":    "res://scena_2.tscn",
	"scena3": "res://scena_3.tscn",
	"scena4": "res://scena_4.tscn",
}

# Mapa połączeń: skąd → [prawo, lewo, góra, dół]
var connections: Dictionary = {
	"main":   {"right": null,  "left": null,  "up": "top",   "down": null},
	"top":    {"down": "main",    "up": "scena3",        "left": null,  "right": null},
	"scena3": {"up": "scena4",      "down": "top",      "left": null,  "right": null},
	"scena4": {"up": null,      "down": "scena3",      "left": null,  "right": null},
}

# Pozycja spawnu gdy WCHODZISZ do sceny z danego kierunku
# Klucz: "scena_docelowa:kierunek_wejscia"
var spawn_overrides: Dictionary = {
	"main:left":    Vector2(200, 500),
	"main:right":   Vector2(1800, 500),
	"main:down":    Vector2(960, 900),
	"main:up":      Vector2(960, 100),
	"right:left":   Vector2(100, 500),
	"right:right":  Vector2(1800, 500),
	"right2:left":  Vector2(100, 500),
	"top:down":     Vector2(960, 900),
	"bottom:up":    Vector2(960, 100),
	# ← dodawaj kolejne tutaj w formacie "scena:kierunek_wejscia"
}

var current_scene_key: String = "main"

# Kierunek przeciwny — skąd przychodzimy = gdzie stoimy
var _opposite: Dictionary = {
	"right": "left",
	"left":  "right",
	"up":    "down",
	"down":  "up",
}

func go(direction: String) -> void:
	var next = connections[current_scene_key].get(direction, null)
	if next == null:
		print("Brak sceny w kierunku: ", direction)
		return

	# Kierunek wejścia do nowej sceny = przeciwny do kierunku wyjścia
	var entry_dir = _opposite.get(direction, "")
	var key = next + ":" + entry_dir

	if spawn_overrides.has(key):
		spawn_position = spawn_overrides[key]
	else:
		# Fallback jeśli nie ma wpisu w spawn_overrides
		match direction:
			"right": spawn_position = Vector2(100, 500)
			"left":  spawn_position = Vector2(1850, 500)
			"up":    spawn_position = Vector2(960, 900)
			"down":  spawn_position = Vector2(960, 100)

	current_scene_key = next
	get_tree().call_deferred("change_scene_to_file", scenes[next])
