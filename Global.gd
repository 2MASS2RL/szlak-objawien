extends Node

var spawn_position: Vector2 = Vector2(960, 900)

var scenes: Dictionary = {
	"main":   "res://scena_1.tscn",
	"top":    "res://scena_2.tscn",
	"scena3": "res://scena_3.tscn",
	"scena4": "res://scena_4.tscn",
	"scena5": "res://scena_5.tscn",
	"scena6": "res://scena_6.tscn",
	"scena7": "res://scena_7.tscn",
	"scena8": "res://scena_8.tscn",
	"scena9": "res://scena_9.tscn",
	"scena10": "res://scena_10.tscn",
	"wejscie_do_zakrtystii": "res://wejscie_do_zakrystii.tscn",
	"zakrystia1": "res://zakrystia1.tscn",
	"zakrystia2": "res://zakrystia2.tscn",
	"scena11": "res://scena11.tscn",
	"drzwi_aulii": "res://drzwi_aulii.tscn",
	"kapliczka_wejscie": "res://kapliczka_wejscie.tscn",
	"aula_1": "res://aula_wejscie.tscn",
	"aula_2": "res://aula2.tscn",
	"pelabnia1": "res://plebania1.tscn",
	"plebania2": "res://plebania2.tscn",
	"plebania3": "res://plebania3.tscn",
	"drzwi_kapliczka": "res://drzwi kapliczka.tscn",
	"kapliczka_srodek": "res://kapliczka_srodek.tscn"
}

# Mapa połączeń: skąd → [prawo, lewo, góra, dół]
var connections: Dictionary = {
	"main":   {"right": null, "left": null, "up": "top", "down": null},
	"top":    {"down": "main", "up": "scena3",  "left": null, "right": null},
	"scena3": {"up": "scena4", "down": "top", "left": null, "right": null},
	"scena4": {"up": null, "down": "scena3", "left": "scena5", "right": null},
	"scena5": {"up": "scena6", "down": null, "left": null, "right": "scena4"},
	"scena6": {"up": "scena7", "down": "scena5", "left": null, "right": null},
	"scena7": {"up": "scena8", "down": "scena6", "left": "scena11", "right": "wejscie_do_zakrtystii"},
	"scena8": {"up": "scena9", "down":"scena7", "left": "scena10", "right": null},
	"scena9": {"up": "drzwi_aulii", "down": "scena8", "left": null, "right": null},
	"scena10": {"up": "drzwi_kapliczka", "down": "scena8", "left": null, "right": null},
	"wejscie_do_zakrtystii": {"up": "zakrystia1",  "down": "scena11",  "left": null,  "right": null},
	"zakrystia1": {"up": "zakrystia2",  "down": "wejscie_do_zakrtystii",  "left": null,  "right": null},
	"zakrystia2": {"up": null,  "down": null,  "left": null,  "right": "zakrystia1"},
	"scena11": {"up": "plebania1",  "down": "wejscie_do_zakrtystii",  "left": null,  "right": null},
	"drzwi_aulii": {"up": "aula_wejscie",  "down": "scena9",  "left": null,  "right": null},
	"kapliczka_wejscie": {"up": null,  "down": null,  "left": null,  "right": null},
	"aula_1": {"up": "drzwi_aulii",  "down": "aula_2",  "left": null,  "right": null},
	"aula_2": {"up": null,  "down": "aula_1",  "left": null,  "right": null},
	"plebania1": {"up": "plebania2",  "down": null,  "left": null,  "right": null},
	"plebania2": {"up": null,  "down": "plebania1",  "left": null,  "right": "plebania3"},
	"plebania3": {"up": null,  "down": "plebania2",  "left": null,  "right": null},
	"drzwi_kapliczka": {"up": "kapliczka_srodek",  "down": "scena10",  "left": null,  "right": null},
	"kapliczka_srodek": {"up": null,  "down": "drzwi_kapliczka",  "left": null,  "right": null},
	
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
	print("current_scene_key: ", current_scene_key, " | kierunek: ", direction)
	var next = connections[current_scene_key].get(direction, null)
	print("next: ", next)
	
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
