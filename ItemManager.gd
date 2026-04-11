# ItemManager.gd
# Autoload: Project > Project Settings > Autoload
# Nazwa: ItemManager

extends Node

signal item_picked(item_id: String)

# Baza wszystkich itemów w grze
# Dodaj tutaj każdy item który istnieje w grze
var items: Dictionary = {
	"klucz_zakrystii": {
		"name":        "Klucz zakrystii",
		"description": "Stary żelazny klucz do drzwi zakrystii.",
		"content":     "",  # przedmioty questowe nie mają treści listu
		"category":    "quest",
		"icon":        "res://icons/klucz.png",
		"stackable":   false,
		"max_stack":   1,
	},
	"notatka_proboszcza": {
		"name":        "Notatka proboszcza",
		"description": "Zapiski proboszcza dotyczące jutrzejszej mszy.",
		"content":     "Drogi bracie,\n\nJutro o świcie odprawiamy mszę ku czci Świętej Marii Magdaleny. Potrzebne będą:\n\n- Kielich z zakrystii\n- Świece z kapliczki\n- Relikwiarz z krypty\n\nProszę o pomoc w ich odnalezieniu.\n\n[i]— Ks. Stanisław[/i]",
		"category":    "document",
		"icon":        "res://icons/notatka.png",
		"stackable":   false,
		"max_stack":   1,
	},
	
	# ─────────────────────────────────────────────
	#Listy
	# ─────────────────────────────────────────────
	
	"List1": {
		"name":        "List 1",
		"description": "Początki sanktuarium",
		"content":     "Drogi wędrowcze,\n\nTrafiłeś do miejsca, które ma za sobą wieki historii. Sanktuarium Świętej Marii Magdaleny w Biłgoraju powstało w XVII wieku, kiedy to miejscowi parafianie ufundowali pierwszy kościół pod wezwaniem tej świętej.\n\nPierwotna świątynia była drewniana — skromna, ale pełna wiary. Z biegiem lat wielokrotnie ją przebudowywano. Każda epoka zostawiła tu swój ślad.\n\nBiłgoraj pamięta wiele — wojny, zniszczenia, odbudowę. A kościół trwał przez to wszystko.\n\n[i]— Ks. Łukasz[/i]",
		"category":    "document",
		"icon":        "res://icons/list.png",
		"stackable":   false,
		"max_stack":   1,
	},
	"List2": {
		"name":        "List 2",
		"description": "Znaczenie miejsca",
		"content":     "Drogi wędrowcze,\n\nTo sanktuarium nie jest zwykłym kościołem. Przez wieki przychodzili tu ludzie z całego regionu — z Biłgoraja, okolicznych wsi i odległych miast.\n\nNajważniejszym dniem w roku jest 22 lipca — wspomnienie Świętej Marii Magdaleny. Wtedy ulice wokół kościoła wypełniają się wiernymi, odbywają się procesje i msze przez cały dzień.\n\nW czasach wojen i prześladowań ten kościół był dla wielu jedynym miejscem, gdzie można było znaleźć nadzieję. Dziś nadal przyciąga wszystkich — młodych, starszych, wierzących i szukających.\n\n[i]— Ks. Łukasz[/i]",
		"category":    "document",
		"icon":        "res://icons/list.png",
		"stackable":   false,
		"max_stack":   1,
	},
	"List3": {
		"name":        "List 3",
		"description": "Święta Maria Magdalena",
		"content":     "Drogi wędrowcze,\n\nZastanawiałeś się pewnie, dlaczego właśnie ona jest patronką tego miejsca?\n\nMaria Magdalena to jedna z najbardziej wyjątkowych postaci Nowego Testamentu. Towarzyszyła Jezusowi, stała pod krzyżem gdy inni uciekli, a rano przy pustym grobie jako pierwsza zobaczyła Zmartwychwstałego.\n\nTo właśnie jej Jezus polecił nieść nowinę apostołom. Dlatego Kościół nazywa ją [i]Apostołką Apostołów[/i].\n\nJej historia to symbol nawrócenia, wierności i nowego początku. Może dlatego tak wiele osób odnajduje tu coś ważnego dla siebie.\n\n[i]— Ks. Mateusz[/i]",
		"category":    "document",
		"icon":        "res://icons/list.png",
		"stackable":   false,
		"max_stack":   1,
	},
	"List4": {
		"name":        "List 4",
		"description": "Życie parafii",
		"content":     "Drogi wędrowcze,\n\nSanktuarium żyje — nie tylko murami, ale przede wszystkim ludźmi.\n\nNa co dzień odbywają się tu:\n\n- Msze święte i nabożeństwa różańcowe\n- Spotkania wspólnot i grup młodzieżowych\n- Zbiórki żywności i odzieży dla potrzebujących\n- Pielgrzymki do sanktuariów całego regionu\n\nDziała tu chór i schola, a muzyka od pokoleń towarzyszy modlitwie. Parafia angażuje się też w pomoc lokalnej społeczności — szczególnie osobom starszym i samotnym.\n\nTo miejsce łączy pokolenia.\n\n[i]— Ks. Mateusz[/i]",
		"category":    "document",
		"icon":        "res://icons/list.png",
		"stackable":   false,
		"max_stack":   1,
	},
	"List5": {
		"name":        "List 5",
		"description": "Aula franciszkańska",
		"content":     "Drogi wędrowcze,\n\nAula franciszkańska to stosunkowo nowe, ale ważne miejsce przy sanktuarium. Jej nazwa nawiązuje do ducha franciszkańskiego — prostoty, radości i służby drugiemu człowiekowi.\n\nOdbywają się tu:\n\n- Katechezy dla dzieci i młodzieży\n- Warsztaty biblijne i spotkania formacyjne\n- Wykłady i projekcje filmów historycznych\n- Akcje charytatywne i zbiórki dla potrzebujących\n\nW trudnych czasach — pandemii czy kryzysu uchodźczego — aula stała się centrum lokalnej pomocy. To dowód, że wiara bez czynów jest martwa.\n\n[i]— Ks. Dominik[/i]",
		"category":    "document",
		"icon":        "res://icons/list.png",
		"stackable":   false,
		"max_stack":   1,
	},
	"List6": {
		"name":        "List 6",
		"description": "Architektura kościoła",
		"content":     "Drogi wędrowcze,\n\nKościół, który widzisz, to efekt wielu wieków budowy i przebudów. Każda epoka zostawiła tu coś swojego.\n\nWarto zwrócić uwagę na:\n\n- Ołtarz główny z wizerunkiem Świętej Marii Magdaleny\n- Boczne ołtarze i chrzcielnicę — dzieła dawnych rzemieślników\n- Obrazy i rzeźby ofiarowane przez parafian przez stulecia\n- Witraże, przez które światło wpada do wnętrza o świcie i zmierzchu\n\nKażdy element opowiada jakąś historię — o fundatorze, o epoce, o wierze ludzi, którzy tu przychodzili przed tobą.\n\n[i]— Ks. Dominik[/i]",
		"category":    "document",
		"icon":        "res://icons/list.png",
		"stackable":   false,
		"max_stack":   1,
	},
	"List7": {
		"name":        "List 7",
		"description": "Duchowe znaczenie",
		"content":     "Drogi wędrowcze,\n\nNie wiem, co cię tu przyprowadziło. Może ciekawość, może wiara, może przypadek.\n\nAle to miejsce istnieje od wieków. Modliły się tu pokolenia ludzi, którzy przeżywali radości i tragedie, wzloty i upadki, wojnę i pokój. Ich modlitwy zdają się wciąż tu być — wbudowane w mury, w powietrze, w ciszę.\n\nSanktuarium działa na człowieka powoli i cicho. Nie przez spektakl, ale przez spokój.\n\nJeśli chcesz poczuć to jeszcze głębiej — jest tu kapliczka. Małe, ciche miejsce. Klucz do niej właśnie trzymasz w ręku.\n\nCzego tam szukasz — to już twoja sprawa.\n\n[i]— Ks. Dominik[/i]",
		"category":    "document",
		"icon":        "res://icons/list.png",
		"stackable":   false,
		"max_stack":   1,
	},
	# ── Dodawaj kolejne itemy tutaj ──
	# "twoj_item_id": {
	#     "name":        "Nazwa itemu",
	#     "description": "Opis itemu widoczny w inventory.",
	#     "category":    "quest",       # "quest" lub "document"
	#     "icon":        "res://icons/twoj_icon.png",
	#     "stackable":   false,
	#     "max_stack":   1,
	# },
}

# Zbiór podniesionych itemów — persystuje przez całą grę
var _picked: Dictionary = {}  # { item_id: true }

# ─────────────────────────────────────────────
# API
# ─────────────────────────────────────────────

# Czy item został już podniesiony?
func is_picked(item_id: String) -> bool:
	return _picked.has(item_id)

# Oznacz item jako podniesiony (wywołuje Item.gd automatycznie)
func mark_picked(item_id: String) -> void:
	if _picked.has(item_id):
		return
	_picked[item_id] = true
	emit_signal("item_picked", item_id)

# Pobierz dane itemu
func get_item(item_id: String) -> Dictionary:
	return items.get(item_id, {})

# Czy item istnieje w bazie?
func has_item(item_id: String) -> bool:
	return items.has(item_id)

func reset() -> void:
	_picked.clear()
