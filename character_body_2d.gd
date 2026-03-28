extends CharacterBody2D

@export var speed: float = 300.0

func _physics_process(delta):
	var dir = Vector2.ZERO
	
	# Ruch WASD lub strzałki
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("d"):
		dir.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("a"):
		dir.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("s"):
		dir.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("w"):
		dir.y -= 1
	
	if dir != Vector2.ZERO:
		dir = dir.normalized()
	velocity = dir * speed
	move_and_slide()
