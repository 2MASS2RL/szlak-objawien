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
		"KS Ł 1":
			start_quest("znajdz_klucz", {
				"name": "Znajdź klucz od zakrystii",
				"goal": "Znajdź klucz leżący przy kościele",
				"description": "Ksiądz Łukasz powiedział żebym poszukał klucza od zakrystii na tyle kościoła.",
			})
		"KS Ł Quest Done":
			start_quest("dostac_sie_do_zakrystii", {
				"name": "Dostań się do zakrystii",
				"goal": "Wejdź do zakrystii używając znalezionego klucza",
				"description": "Ksiądz Łukasz powiedział żebym poszukał kogoś w zakrystii żeby zdobyć więcej informacji o kościele.",
			})
		"KS M 1":
			start_quest("znajdz_wino_mszalne", {
				"name": "Znajdź wino mszalne",
				"goal": "Znajdź wino mszalne w drodze na plebanię",
				"description": "Ksiądz Mateusz kazał mi znaleźć wino mszalne i przynieść mu z powrotem.",
			})
		"KS M Quest Done":
			start_quest("pomoz_potrzebujacym", {
				"name": "Pomóż potrzebującym",
				"goal": "Znajdź księdza Dominika w auli franciszkańskiej",
				"description": "Ksiądz Mateusz powiedział żebym pomógł księdzu Dominikowi w auli franciszkańskiej.",
			})
		"KS D 1":
			start_quest("idz_do_ksiedza_lukasza", {
				"name": "Idź do księdza Łukasza",
				"goal": "Przynieś dokumenty od księdza Łukasza do księdza Dominika",
				"description": "Ksiądz Dominik kazał mi pójść po dokumenty do księdza Łukasza. Na szczęście wiem gdzie go znaleźć.",
			})
		"KS D Quest Done":
			start_quest("znajdz_ksiedza_mateusza", {
				"name": "Poszukaj księdza Mateusza",
				"goal": "Znajdź księdza Mateusza i poproś go o kazanie",
				"description": "Ksiądz Dominik kazał mi poszukać księdza Mateusza i zapytać się o jego kazanie.",
			})
		"KS D Kazanie":
			start_quest("idz_do_kapliczki", {
				"name": "Zajrzyj do kapliczki",
				"goal": "Otwórz kapliczkę kluczem od księdza Dominika",
				"description": "Ksiądz Dominik dał mi klucz do kapliczki. Powiedział, że jeśli chcę dowiedzieć się czegoś więcej o tym miejscu, powinienem się tam udać.",
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
