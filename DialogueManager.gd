# DialogueManager.gd
# Autoload: Project > Project Settings > Autoload
# Nazwa: DialogueManager

extends Node

signal dialogue_started(npc_tag: String)
signal dialogue_ended(npc_tag: String)
signal choice_made(npc_tag: String, choice_index: int)

var current_zoom_request : Dictionary = { "mode": "none" }
var _box: Control = null
var _current_tag: String = ""
var _current_lines: Array = []
var _current_index: int = 0
var current_npc_pos: Vector2 = Vector2.ZERO
var dialogues: Dictionary = {

	"koscielny_stroz": [
		{ "speaker": "Strażnik", "text": "Witaj, podróżniku. To kościół Świętej Marii Magdaleny w Biłgoraju." },
		{ "speaker": "Strażnik", "text": "Zbudowany w XVII wieku, jest jednym z najcenniejszych zabytków w regionie. O czym chciałbyś się dowiedzieć?",
		  "choices": [
			{ "label": "Kiedy powstał kościół?", "next": "info_historia" },
			{ "label": "Co kryje wnętrze?",      "next": "info_wnetrze"  },
			{ "label": "Dziękuję, do widzenia.",  "next": ""             }
		  ]
		}
	],

	"info_historia": [
		{ "speaker": "Strażnik", "text": "Budowę rozpoczęto w 1640 roku. Kościół przetrwał wiele wojen i pożarów, zachowując swój barokowy charakter." },
		{ "speaker": "Strażnik", "text": "Czy chcesz wiedzieć coś jeszcze?",
		  "choices": [
			{ "label": "Co kryje wnętrze?",      "next": "info_wnetrze" },
			{ "label": "Dziękuję, do widzenia.", "next": ""             }
		  ]
		}
	],

	"info_wnetrze": [
		{ "speaker": "Strażnik", "text": "Wewnątrz znajdują się barokowe ołtarze, XVII-wieczne freski oraz bezcenne relikwiarze." },
		{ "speaker": "Strażnik", "text": "Jeden z artefaktów podobno czeka na odkrycie przez godnego gościa..." },
	],

	"Proboszcz": [
		{ "speaker": "Proboszcz", "text": "Witaj, pielgrzymie co cię tutaj sprowadza?",
		  "choices": [
			{ "label": "Szukam schronienia.", "next": "info_schronienie" },
			{ "label": "Do widzenia",         "next": ""                 }
		  ]
		}
	],

	"info_zadanie": [
		{ "speaker": "Proboszcz", "text": "Potrzebuje twojej pomocy w odnalezieniu przedmiotów potrzebnych do mszy św jutro rano." },
		{ "speaker": "Proboszcz", "text": "Zacznij od kapliczki tam powinieneś znaleźć pierwszy przedmiot.",
		  "choices": [
			{ "label": "Gdzie znajdę kapliczke?", "next": "info_kapliczka" },
			{ "label": "Biore się do roboty.",    "next": ""               }
		  ]
		}
	],

	"info_schronienie": [
		{ "speaker": "Proboszcz", "text": "Jak pomożesz mi odnaleźć wszystkie przedmioty przenocuje cię.",
		  "choices": [
			{ "label": "Co muszę znaleźć",  "next": "info_zadanie" },
			{ "label": "Zastanowie się.",    "next": ""             }
		  ]
		}
	],

	"info_kapliczka": [
		{ "speaker": "Proboszcz", "text": "Jak wyjdziesz z zakrysti udaj się w lewą stronę tam znajdziesz kapliczkę.",
		  "choices": [
			{ "label": "Biorę się do roboty.", "next": "" },
		  ]
		}
	],
	# ─────────────────────────────────────────────
	#Dialogi Gracza/Narratora
	# ─────────────────────────────────────────────
	"GB1": [
		{ "speaker": "Główny Bohater", "text": "Gdzie ja jestem...? Ta droga musi gdzieś prowadzić." },
		  ],
	"GB2": [
		{ "speaker": "Główny Bohater", "text": "Sanktuarium... Może ktoś tam mi powie, gdzie się znalazłem." },
		  ],
	"GB3": [
		{ "speaker": "Główny Bohater", "text": "To musi być ten klucz. Czas wracać do księdza Łukasza." },
		  ],
	# ─────────────────────────────────────────────
	#Dialogi KS Ł
	# ─────────────────────────────────────────────
		"KS Ł 1": [
		{ "speaker": "Główny Bohater", "text": "Szczęść Boże, proszę księdza."},
		{ "speaker": "Ks. Łukasz", "text": "Szczęść Boże. Rzadko ktoś tu przybywa o tej porze. W czym mogę pomóc?"},
		{ "speaker": "Główny Bohater", "text": "Trafiłem tu przez przypadek. Może ksiądz mi opowiedzieć o tym miejscu?"},
		{ "speaker": "Ks. Łukasz", "text": "Chętnie. Mam list który zostawił poprzedni proboszcz — jest tam trochę historii. Weź.", "give_item": "List1"},
		{ "speaker": "Główny Bohater", "text": "Dzięki. Ale to budzi więcej pytań niż odpowiedzi... Czy jest tu ktoś, kto mógłby powiedzieć mi więcej?"},
		{ "speaker": "Ks. Łukasz", "text": "W zakrystii jest stara kronika parafialna. Ale zakrystia jest zamknięta, a klucz gdzieś zaginął. Znajdziesz go — kronika jest do twojej dyspozycji."},
		{ "speaker": "Główny Bohater", "text": "Rozumiem. Poszukam."},
	],
	"KS Ł Quest Active": [
		{"speaker": "Główny bohater", "text": "Gdzie szukać tego klucza?"},
		{ "speaker": "Ks. Łukasz", "text": "Przy drzwiach zakrystii — od tyłu kościoła. Tam ktoś go odkładał."},
	],
	"KS Ł Quest Done": [
		{"speaker": "Główny bohater", "text": "Znalazłem klucz, proszę księdza."},
		{ "speaker": "Ks. Łukasz", "text": "To dobrze. Za trud należy ci się nagroda.", "give_item": "List2"},
	],
}

# ─────────────────────────────────────────────
# PRYWATNE
# ─────────────────────────────────────────────

func _is_box_valid() -> bool:
	return _box != null and is_instance_valid(_box)

func _show_line() -> void:
	if not _is_box_valid():
		return
	var line: Dictionary = _current_lines[_current_index]
	_box.display_line(line)

func _end_dialogue() -> void:
	if _is_box_valid():
		_box.hide()
	emit_signal("dialogue_ended", _current_tag)
	_current_tag    = ""
	_current_lines  = []
	_current_index  = 0
	current_npc_pos = Vector2.ZERO

# ─────────────────────────────────────────────
# API PUBLICZNE
# ─────────────────────────────────────────────

func set_box(box: Control) -> void:
	_box = box

func is_active() -> bool:
	return _is_box_valid() and _box.visible

func start_dialogue(tag: String, npc_pos: Vector2 = Vector2.ZERO, zoom_request: Dictionary = { "mode": "none" }) -> void:
	current_npc_pos    = npc_pos
	current_zoom_request = zoom_request
	if not dialogues.has(tag):
		push_warning("DialogueManager: brak dialogu dla tagu '%s'" % tag)
		return
	if not _is_box_valid():
		push_error("DialogueManager: DialogueBox jest null lub zniszczony!")
		return
	current_npc_pos = npc_pos
	_current_tag    = tag
	_current_lines  = dialogues[tag]
	_current_index  = 0
	emit_signal("dialogue_started", tag)
	_show_line()

func next_line() -> void:
	var current_line = _current_lines[_current_index]
	if current_line.has("give_item"):
		var item_id : String = current_line["give_item"]
		InventoryManager.add_item(item_id)
		ItemNotification.show_item(item_id)   

	_current_index += 1
	if _current_index >= _current_lines.size():
		_end_dialogue()
	else:
		_show_line()

func pick_choice(choice_index: int) -> void:
	var line = _current_lines[_current_index]
	if not line.has("choices"):
		return
	var choice = line["choices"][choice_index]
	emit_signal("choice_made", _current_tag, choice_index)
	var next_tag: String = choice.get("next", "")
	if next_tag == "":
		_end_dialogue()
	else:
		_current_tag   = next_tag
		_current_lines = dialogues[next_tag]
		_current_index = 0
		_show_line()
