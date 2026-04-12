extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if "Player" in body.get_groups():
		if ItemManager.has_item("Klucz2"):
			Global.go("up")
		else:
			print("Brama jest zamknięta!")
