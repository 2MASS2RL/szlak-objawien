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
		{ "speaker": "Główny Bohater", "text": "Gdzie ja jestem…?" },
		{ "speaker": "Główny Bohater", "text": "Chyba pójdę tą ścieżką." },
		  ],
	"GB2": [
		{ "speaker": "Główny Bohater", "text": "Tu nic nie ma, muszę szukać dalej." },
		  ],
	"GB3": [
		{ "speaker": "Główny Bohater", "text": "To chyba ten klucz!" },
		  ],
	"GB4": [
		{ "speaker": "Główny Bohater", "text": "To jest zakrystia. Rozejrzę się tutaj." },
		  ],
	"GB5": [
		{ "speaker": "Główny Bohater", "text": "Znalazłem wino mszalne!" },
		  ],
		
	# ─────────────────────────────────────────────
	#Dialog Przy Drzwiach
	# ─────────────────────────────────────────────	
	
	"Zakrystia1": [
		{ "speaker": "", "text": "To drzwi do zakrystii." },
		  ],
	"Zakrystia2": [
		{ "speaker": "", "text": "Potrzebujesz klucza od zakrystii." },
		  ],
		
	# ─────────────────────────────────────────────
	#Dialogi KS Ł
	# ─────────────────────────────────────────────
	
	"KS Ł 1": [
		{ "speaker": "Główny Bohater", "text": "Szczęść Boże."},
		{ "speaker": "Ks. Łukasz", "text": "Szczęść Boże."},
		{ "speaker": "Główny Bohater", "text": "Czy ksiądz mógłby mi trochę opowiedzieć o tym miejscu?"},
		{ "speaker": "Ks. Łukasz", "text": "Oczywiście. Weź ten list, znajdziesz tam podstawowe informacje.", "give_item": "List1"},
		{ "speaker": "Główny Bohater", "text": "A jeśli chciałbym dowiedzieć się czegoś więcej o historii sanktuarium?"},
		{ "speaker": "Ks. Łukasz", "text": "Wtedy będziesz musiał znaleźć klucz od zakrystii."},
		{ "speaker": "Główny Bohater", "text": "Gdzie mogę go znaleźć?"},
		{ "speaker": "Ks. Łukasz", "text": "Poszukaj przy tylnej części kościoła, koło drzwi od zakrystii."},
	],
	"KS Ł Quest Active": [
		{"speaker": "Główny bohater", "text": "Gdzie mogę znaleźć ten klucz?"},
		{ "speaker": "Ks. Łukasz", "text": "Szukaj koło drzwi od zakrystii, na tyle kościoła."},
	],
	"KS Ł Quest Done": [
		{"speaker": "Główny bohater", "text": "Znalazłem klucz, proszę księdza."},
		{ "speaker": "Ks. Łukasz", "text": "Bardzo dobrze. W nagrodę dostaniesz ode mnie ten list.", "give_item": "List2"},
		{ "speaker": "Ks. Łukasz", "text": "Teraz, mając klucz, możesz wejść do zakrystii. Powinieneś znaleźć tam kogoś, kto powie ci więcej o tym miejscu."},
		{"speaker": "Główny bohater", "text": "Dziękuję."},
	],
	"KS Ł & KS D": [
		{"speaker": "Główny bohater", "text": "Ksiądz Dominik przysłał mnie po dokumenty."},
		{ "speaker": "Ks. Łukasz", "text": "Oczywiście, mam je przy sobie.", "give_item": "Dokumenty1"},
		{"speaker": "Główny bohater", "text": "Dziękuję."},
	],
	
	# ─────────────────────────────────────────────
	#Dialogi KS M
	# ─────────────────────────────────────────────
	
	"KS M 1": [
		{"speaker": "Główny bohater", "text": "Szczęść Boże."},
		{ "speaker": "Ks. Mateusz", "text": "Szczęść Boże. Czego szukasz?"},
		{"speaker": "Główny bohater", "text": "Chciałem dowiedzieć się czegoś więcej o tym kościele."},
		{ "speaker": "Ks. Mateusz", "text": "W takim razie weź ten list.", "give_item": "List3"},
		{ "speaker": "Ks. Mateusz", "text": "Jeśli chcesz dowiedzieć się więcej, przynieś mi jeszcze wino mszalne."},
		{"speaker": "Główny bohater", "text": "A gdzie mogę je znaleźć?"},
		{ "speaker": "Ks. Mateusz", "text": "Poszukaj w drodze prowadzącej na plebanię. Musiało mi tam wypaść."},
	],
	"KS M Quest Active": [
		{"speaker": "Główny bohater", "text": "A gdzie mogę znaleźć wino mszalne?"},
		{ "speaker": "Ks. Mateusz", "text": "Poszukaj w drodze prowadzącej na plebanię. Musiało mi tam wypaść."},
	],
	"KS M Quest Done": [
		{"speaker": "Główny bohater", "text": "Znalazłem wino mszalne."},
		{ "speaker": "Ks. Mateusz", "text": "WDziękuję ci. Weź ten list za pomoc.", "give_item": "List4"},
		{"speaker": "Główny bohater", "text": "Dziękuję za list."},
		{"speaker": "Ks. Mateusz", "text": "Teraz posłuchaj. Chciałbym, żebyś pomógł księdzu Dominikowi w auli franciszkańskiej."},
		{"speaker": "Główny bohater", "text": "Dobrze, pójdę tam od razu."},
	],
	"KS M & D": [
		{"speaker": "Główny bohater", "text": "Nie spodziewałem się księdza tutaj."},
		{"speaker": "Ks. Mateusz", "text": "Tak, przyszedłem się pomodlić. Czego potrzebujesz?"},
		{"speaker": "Główny bohater", "text": "Ksiądz Dominik przysłał mnie po swoje kazanie."},
		{"speaker": "Ks. Mateusz", "text": "A tak, mam je przy sobie.", "give_item": "Kazanie1"},
		{"speaker": "Główny bohater", "text": "Dziękuję bardzo."},
	],
	
	# ─────────────────────────────────────────────
	#Dialogi KS D
	# ─────────────────────────────────────────────
	
	"KS D 1": [
		{"speaker": "Główny bohater", "text": "Szczęść Boże."},
		{ "speaker": "Ks. Dominik", "text": "Szczęść Boże. Ksiądz Mateusz cię przysłał?"},
		{"speaker": "Główny bohater", "text": "Tak, powiedział, że potrzebuje ksiądz mojej pomocy."},
		{ "speaker": "Ks. Dominik", "text": "Dokładnie. Musisz wrócić do księdza Łukasza po dokumenty, które ma dla mnie."},
		{"speaker": "Główny bohater", "text": "Dobrze. Czy coś jeszcze?"},
		{ "speaker": "Ks. Dominik", "text": "Tak, proszę. Weź też ten list.", "give_item": "List5"},
		{"speaker": "Główny bohater", "text": "Dziękuję."},
	],
	"KS D Quest Active": [
		{"speaker": "Główny bohater", "text": "A gdzie mogę znaleźć wino mszalne?"},
		{ "speaker": "Ks. Dominik", "text": "Poszukaj w drodze prowadzącej na plebanię. Musiało mi tam wypaść."},
	],
	"KS D Quest Done": [
		{"speaker": "Główny bohater", "text": "Mam już dokumenty, proszę księdza."},
		{ "speaker": "Ks. Dominik", "text": "Bardzo dobrze. W nagrodę dostaniesz jeszcze ten list.", "give_item": "List6"},
		{"speaker": "Główny bohater", "text": "Co mam zrobić?"},
		{"speaker": "Ks. Dominik", "text": "Idź do księdza Mateusza po moje kazanie."},
		{"speaker": "Główny bohater", "text": "Już się robi."},
	],
	"KS D Kazanie": [
		{"speaker": "Główny bohater", "text": "Mam już kazanie księdza."},
		{ "speaker": "Ks. Dominik", "text": "Wspaniale, bardzo ci dziękuję za całą pomoc. Weź jeszcze ten list.", "give_item": "List7"},
		{"speaker": "Główny bohater", "text": "Czy mogę jeszcze w czymś pomóc?"},
		{"speaker": "Ks. Dominik", "text": "Już nic nie potrzebuję. Ale jeśli chcesz dowiedzieć się czegoś więcej o tym miejscu, możesz zajrzeć do kapliczki. Masz klucz.", "give_item": "Klucz2"},
		{"speaker": "Główny bohater", "text": "Dziękuję bardzo"},
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
