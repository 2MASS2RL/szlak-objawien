extends CharacterBody2D

@export var speed: float = 300.0

var Y_MIN     : float = 100.0
var Y_MAX     : float = 900.0
var SCALE_MIN : float = 0.3
var SCALE_MAX : float = 1.0

func apply_scene_settings(settings: Node) -> void:
	Y_MIN     = settings.y_min
	Y_MAX     = settings.y_max
	SCALE_MIN = settings.scale_min
	SCALE_MAX = settings.scale_max

func _ready() -> void:
	add_to_group("Player")
	position = Global.spawn_position

func _physics_process(delta):
	if InventoryUI and InventoryUI.visible:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()
	
	var t = clamp((position.y - Y_MIN) / (Y_MAX - Y_MIN), 0.0, 1.0)
	scale = Vector2(lerp(SCALE_MIN, SCALE_MAX, t), lerp(SCALE_MIN, SCALE_MAX, t))
	z_index = int(position.y)
