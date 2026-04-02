# QuestManager.gd
# Autoload: Project > Project Settings > Autoload
# Nazwa: QuestManager

extends Node

signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)

# Każdy quest to słownik:
# {
#   "name": "Nazwa questa",
#   "goal": "Krótki cel (do HUD)",
#   "description": "Pełny opis (do dziennika)",
# }
var _active: Dictionary = {}    # { quest_id: dane }
var _completed: Dictionary = {} # { quest_id: dane }

func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	_active.clear()
	_completed.clear()

func _on_dialogue_ended(tag: String) -> void:
	match tag:
		"info_zadanie":
			start_quest("znajdz_klucz", {
				"name": "Znajdź klucz",
				"goal": "Idź do kapliczki",
				"description": "Proboszcz poprosił cię o znalezienie klucza do kościoła. Udaj się do kapliczki na lewo od zakrystii.",
			})
		"info_kapliczka":
			start_quest("idz_do_kapliczki", {
				"name": "Idź do kapliczki",
				"goal": "Znajdź kapliczkę na lewo",
				"description": "Wyjdź z zakrystii i udaj się w lewą stronę. Tam znajdziesz kapliczkę z pierwszym przedmiotem.",
			})
		"KS Ł 1":
			start_quest("KS Ł 1", {
				"name": "Klucz do zakrystii",
				"goal": "Znajdź klucz od zakrystii",
				"description": "Ksiądz Łukasz powiedział, żebym poszukał klucza od zakrystii na tyle kościoła.",
			})
		"KS Ł Quest Done":
			start_quest("Dostań się do zakrystii", {
				"name": "Dostań się do zakrystii",
				"goal": "Znajdź zakrystię.",
				"description": "Ksiądz Łukasz powiedział, żebym poszukał kogoś w zakrystii, żeby zdobyć więcej informacji o tym kościele.",
			})
		"KS M 1":
			start_quest("KS M 1", {
				"name": "Znajdź (item2) na plebani",
				"goal": "",
				"description": "Ksiądz Mateusz kazał mi znaleźć (item2) na plebanii i przynieść mu z powrotem.",
			})
		# ── dopisuj kolejne questy tutaj ──
		# "twoj_tag":
		#     start_quest("twoj_id", {
		#         "name": "Nazwa",
		#         "goal": "Krótki cel",
		#         "description": "Pełny opis co robić i gdzie iść.",
		#     })

# ─────────────────────────────────────────────
# API
# ─────────────────────────────────────────────

func start_quest(quest_id: String, data: Dictionary) -> void:
	if _active.has(quest_id) or _completed.has(quest_id):
		return
	_active[quest_id] = data
	emit_signal("quest_started", quest_id)

func complete_quest(quest_id: String) -> void:
	if not _active.has(quest_id):
		return
	var data = _active[quest_id]
	_active.erase(quest_id)
	_completed[quest_id] = data
	emit_signal("quest_completed", quest_id)

func has_quest(quest_id: String) -> bool:
	return _active.has(quest_id)

func is_completed(quest_id: String) -> bool:
	return _completed.has(quest_id)

func get_active_quests() -> Dictionary:
	return _active.duplicate()

func get_completed_quests() -> Dictionary:
	return _completed.duplicate()

func get_quest_data(quest_id: String) -> Dictionary:
	if _active.has(quest_id):
		return _active[quest_id]
	if _completed.has(quest_id):
		return _completed[quest_id]
	return {}

func reset() -> void:
	_active.clear()
	_completed.clear()
