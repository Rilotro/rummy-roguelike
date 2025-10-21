extends Control

#var buttons: Array[Tile_Info]
var TipTexts: Array[String] = ["You need to select [b]3 or more Tiles[/b] in a [b]Same Color[/b] or [b]Same Number[/b] pattern to [b]Spread[/b]",
							   "Once you have [b]Discarded[/b] enough [b]Tiles[/b], you can [b]Spread[/b] using a single [b]Tile[/b] from the [b]Discard River[/b]",
							   "When you [b]Spread[/b] using a [b]Tile[/b] from the [b]Discard River[/b], [i]all[/i] [b]Tiles Discarded[/b] after that [b]one[/b] are [b]Drained[/b] into your [b]Board[/b]",
							   "Winning [b]Points[/b] also wins you [b]Currency[/b] to use in the [b]Shop[/b], so keep [b]Spreading Tiles[/b]!",
							   "When you [i]run out of [b]Tiles[/b][/i] in your [b]Deck[/b] you [b][color=red]LOSE[/color][/b]",
							   "Don't worry about [i]running out of space[/i] on your [b]Board[/b], new [b]Rows[/b] are created [i]automaticaly[/i]",
							   "Take note of your [b]Score[/b] and the [b]Progress Bar[/b] to your [i]left[/i], with each new [b]Level[/b] you [i][b]Draw[/b] more [b]Tiles[/b][/i] from your [b]Deck[/b] and also get more [b]Tiles[/b] of greater value in the [b]Shop[/b]",
							   "Each time you [b]Drain the River[/b] the number of [b]Tiles[/b] that need to be [b]Discarded[/b] to [i]do it again[/i] [b]increases[/b]",
							   "Each [b]Tile Rarity[/b] awards [i]different amounts[/i] of [b]Points[/b], in ascending order: [b]Porcelain[/b], [b]Bronze[/b], [b]Silver[/b] and [b]Gold[/b]",
							   "[rainbow freq=1.0 sat=0.8 val=0.8 speed=0.0]The Joker[/rainbow] counts as any [b]Tile[/b]",
							   "When you [b]Buy[/b] a [b]Tile[/b] it is added somewhere below the [i]top 10 [b]Tiles[/b][/i] and above the [i]bottom 10 [b]Tiles[/b][/i] of the deck, if there are more than [i]20[/i] [b]Tiles[/b] in the [b]Deck[/b]"]

var TipCheck: Array[bool]

func _ready() -> void:
	TipCheck.resize(TipTexts.size())
	TipCheck.fill(false)
	var TipIndex: int = randi_range(0, TipTexts.size()-1)
	TipCheck[TipIndex] = true
	$TipText.text = "Tip: " + TipTexts[TipIndex]

func REgenerate_selections() -> void:
	for button in $Tile_Selections.get_children():
		button.REgenerate_selection()

func update_currency(newCurrency: int) -> void:
	$Currency_Text.text = "Current Funds: " + str(newCurrency)
	checkButtons(newCurrency)

func checkButtons(currentCurrency: int) -> void:
	for button in $Tile_Selections.get_children():
		button.check_access(currentCurrency)

func tile_select(_button: Button, tile_bought: Tile_Info, cost: int) -> void:
	if(freebies > 0):
		cost = 0
		freebies -= 1
	get_parent().buy_tile(tile_bought, cost)
	if(freebies <= 0):
		for selection in $Tile_Selections.get_children():
			selection.freebie(false, get_parent().currency)

func item_select(_button: Button, item_bought: Item, cost: int) -> void:
	if(freebies > 0):
		cost = 0
		freebies -= 1
	get_parent().buy_item(item_bought, cost)
	if(freebies <= 0):
		for selection in $Tile_Selections.get_children():
			selection.freebie(false, get_parent().currency)
	

var freebies: int = 0

func Gain_Freebie(extra_freebies: int = 1) -> void:
	freebies += extra_freebies
	for selection in $Tile_Selections.get_children():
		selection.freebie(true, get_parent().currency)

func _on_exit_shop_pressed() -> void:
	get_parent().exit_shop()
	var TipIndex: int = randi_range(0, TipTexts.size()-1)
	while(TipCheck[TipIndex] == true):
		TipIndex = randi_range(0, TipTexts.size()-1)
	TipCheck[TipIndex] = true
	$TipText.text = "Tip: " + TipTexts[TipIndex]
	
	for check in TipCheck:
		if(check == false):
			return
	
	TipCheck.fill(false)
