extends Area2D

func _on_body_entered(body):
	if "Player" in body.get_groups():
		if QuestManager.is_completed("znajdz_klucz"):
			Global.go("up")
		else:
			print("Zakrystia jest zamknięta!")

func _ready():
	body_entered.connect(_on_body_entered)
