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

var currency: int = 0

func _ready() -> void:
	TipCheck.resize(TipTexts.size())
	TipCheck.fill(false)
	var TipIndex: int = randi_range(0, TipTexts.size()-1)
	TipCheck[TipIndex] = true
	$TipText.text = "Tip: " + TipTexts[TipIndex]

func REgenerate_selections() -> void:
	var item_ids: Array[int]
	var curr_id: int
	for button in $Tile_Selections.get_children():
		curr_id = button.REgenerate_selection()
		if(curr_id >= 0):
			while(item_ids.find(curr_id) >= 0):
				curr_id = button.REgenerate_selection()
			
			item_ids.append(curr_id)

func update_currency(newCurrency: int) -> void:
	currency += newCurrency
	$Currency_Text.text = "Current Funds: " + str(currency)
	checkButtons()

func checkButtons() -> void:
	for button in $Tile_Selections.get_children():
		button.check_access(currency)

func tile_select(_button: Button, tile_bought: Tile_Info, cost: int) -> void:
	if(freebies > 0):
		freebies -= 1
	else:
		currency -= cost
		update_currency(0)
	get_parent().buy_tile(tile_bought)
	if(freebies <= 0):
		for selection in $Tile_Selections.get_children():
			selection.freebie(false, currency)

func item_select(button: Button, item_bought: Item, cost: int) -> void:
	if(freebies > 0):
		freebies -= 1
	else:
		currency -= cost
		update_currency(0)
	match item_bought.id:
		4:
			Beaver_Break(button)
	get_parent().buy_item(item_bought)
	if(freebies <= 0):
		for selection in $Tile_Selections.get_children():
			selection.freebie(false, currency)

func Beaver_Break(IS: Button) -> void:
	var tween =  get_tree().create_tween()
	tween.set_parallel()
	for shopUI in get_children():
		tween.tween_property(shopUI, "modulate:a", 0, 0.5)
	
	var BTU: Sprite2D = Sprite2D.new()
	var BTD: Sprite2D = Sprite2D.new()
	BTU.texture = preload("res://Items/Beaver_Teeth_UP.png")
	BTD.texture = preload("res://Items/Beaver_Teeth_DOWN.png")
	
	add_child(BTU)
	add_child(BTD)
	
	BTU.scale = Vector2(0.3, 0.3)
	BTD.scale = Vector2(0.3, 0.3)
	
	BTU.material = ShaderMaterial.new()
	BTU.material.shader = preload("res://shaders/test.gdshader")
	
	BTD.material = ShaderMaterial.new()
	BTD.material.shader = preload("res://shaders/test.gdshader")
	
	BTU.global_position = IS.global_position
	BTD.global_position = IS.global_position
	
	tween.tween_property(BTU, "global_position", get_parent().PB.get_DrainCounter().global_position + Vector2(0, -20), 0.65)
	tween.tween_property(BTU, "scale", Vector2(0.5, 0.5), 0.3)
	tween.tween_property(BTD, "global_position", get_parent().PB.get_DrainCounter().global_position + Vector2(0, 20), 0.65)
	tween.tween_property(BTD, "scale", Vector2(0.5, 0.5), 0.3)
	
	await tween.finished
	tween =  get_tree().create_tween()
	
	tween.set_parallel()
	
	tween.tween_property(BTU, "global_position", get_parent().PB.get_DrainCounter().global_position, 0.01)
	tween.tween_property(BTD, "global_position", get_parent().PB.get_DrainCounter().global_position, 0.01)
	
	await tween.finished
	
	const BGOrigAlpha: float = 100.0/255.0
	$Shop_BackGround.self_modulate.a = 1
	$Shop_BackGround.modulate.a = 1
	await get_tree().create_timer(0.15).timeout
	$Shop_BackGround.modulate.a = 0
	await get_tree().create_timer(0.075).timeout
	$Shop_BackGround.modulate.a = 1
	await get_tree().create_timer(0.15).timeout
	
	BTU.queue_free()
	BTD.queue_free()
	
	tween =  get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($Shop_BackGround, "self_modulate:a", BGOrigAlpha, 0.5)
	var first: bool = true
	for shopUI in get_children():
		if(first):
			first = false
			continue
		tween.tween_property(shopUI, "modulate:a", 1, 0.5)
	

func addShopUses() -> void:
	for ItemSlots in $Tile_Selections.get_children():
		if("item_info" in ItemSlots):
			ItemSlots.add_uses(1)

var freebies: int = 0

func Gain_Freebie(extra_freebies: int = 1) -> void:
	freebies += extra_freebies
	for selection in $Tile_Selections.get_children():
		selection.freebie(true, currency)

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
