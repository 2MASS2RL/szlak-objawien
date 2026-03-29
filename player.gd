extends CharacterBody2D

@export var speed: float = 300.0

# Stałe - dostosuj do swojej sceny
const SPEED = 300.0 
const Y_MIN = 100.0   # górna krawędź mapy
const Y_MAX = 900.0   # dolna krawędź mapy
const SCALE_MIN = 0.3 # rozmiar gdy daleko
const SCALE_MAX = 1.0 # rozmiar gdy blisko

func _physics_process(delta):
	# Blokuj ruch gdy inventory otwarte
	if InventoryUI and InventoryUI.visible:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * SPEED
	move_and_slide()
	
	var t = (position.y - Y_MIN) / (Y_MAX - Y_MIN)
	t = clamp(t, 0.0, 1.0)
	var new_scale = lerp(SCALE_MIN, SCALE_MAX, t)
	scale = Vector2(new_scale, new_scale)
	
	z_index = int(position.y)
func _ready():
	add_to_group("Player")
	position = Global.spawn_position
	print("Gracz respawn na: ", Global.spawn_position)
