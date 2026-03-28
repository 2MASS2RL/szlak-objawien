extends Area2D

func _on_body_entered(body):
	if "Player" in body.get_groups():
		Global.go("down")
func _ready():
	body_entered.connect(_on_body_entered)
