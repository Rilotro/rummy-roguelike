extends Control

class_name Shop

#var buttons: Array[Tile_Info]-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
var TipTexts: Array[String] = ["You need to select [b]3 or more Tiles[/b] in a [b]Same Color[/b] or [b]Same Number[/b] pattern to [b]Spread[/b]",
							   "Once you have [b]Discarded[/b] enough [b]Tiles[/b], you can [b]Spread[/b] using a single [b]Tile[/b] from the [b]Discard River[/b]",
							   "When you [b]Spread[/b] using a [b]Tile[/b] from the [b]Discard River[/b], [i]all[/i] [b]Tiles Discarded[/b] after that [b]one[/b] are [b]Drained[/b] into your [b]Board[/b]",
							   "Winning [b]Points[/b] also wins you [b]Currency[/b] to use in the [b]Shop[/b], so keep [b]Spreading Tiles[/b]!",
							   "When you [i]run out of [b]Tiles[/b][/i] in your [b]Deck[/b] you [b][color=red]LOSE[/color][/b]",
							   "Don't worry about [i]running out of space[/i] on your [b]Board[/b], new [b]Rows[/b] are created [i]automaticaly[/i]",
							   "Take note of your [b]Score[/b] and the [b]Progress Bar[/b] [i]atop[/i] your [b]Board[/b], with each new [b]Level[/b] you gain more [i]boons and curses[/i], like [b]Drawing[/b] more [b]Tiles[/b]",
							   "Each time you [b]Drain the River[/b] the number of [b]Tiles[/b] that need to be [b]Discarded[/b] to [i]do it again[/i] [b]increases[/b]",
							   "Each [b]Tile Rarity[/b] awards [i]different amounts[/i] of [b]Points[/b], in ascending order: [b]Porcelain[/b], [b]Bronze[/b], [b]Silver[/b] and [b]Gold[/b]",
							   "[rainbow freq=1.0 sat=0.8 val=0.8 speed=0.0]The Joker[/rainbow] counts as any [b]Tile[/b]",
							   "When you [b]Buy[/b] a [b]Tile[/b] it is added somewhere below the [i]top 10 [b]Positions[/b][/i] and above the [i]bottom 10 [b]Positions[/b][/i] of the deck, if there are more than [i]20[/i] [b]Tiles[/b] in the [b]Deck[/b]",
							   "The chances for [b]Tiles[/b] with [b]Effects[/b] and higher [b]Rarity[/b] to appear increase with your [b]Level[/b]",
							   "When [b]Consumable Items[/b] [i]run out of [b]Uses[/b][/i], they dissapear",
							   "You can [b]Append Board Tiles[/b] to [b]Spread Rows[/b], if they are [b]Eligible[/b], and gain their [b]Points[/b] and [b]On Spread Effects[/b] that way",
							   "[b]Append Eligibility Rules[/b] are the same as [b]Spread Eligibility Rules[/b]",
							   "If you [b]Append[/b] a [b]Tile[/b] to [b]Another Player's Spread Row[/b], the [b]Tile[/b] becomes a [b]Leech[/b] and will limit that [b]Player's[/b] ability to [b]Append[/b] to that [b]Row[/b]",
							   "[b]Leeches[/b] can be stacked, even if they don't originate from the same [b]Player[/b]",
							   "Once [b]Bought[/b], some [b]Items[/b] won't show up in the [b]Shop[/b] [i]again[/b]"]

var TipCheck: Array[bool]

var currency: int = 0

const MAX_TILE_SELECTIONS: int = 10
const MAX_JOKER_SELECTIONS: int = 3
const MAX_ITEM_SELECTIONS: int = 8

var TileSelections: Array[Tile_Selection]
var JokerSelections: Array[Tile_Selection]
var ItemSelections: Array[Item_Selection]

@export var Shop_BG: Sprite2D

func _ready() -> void:
	#.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	TipCheck.resize(TipTexts.size())
	TipCheck.fill(false)
	var TipIndex: int = randi_range(0, TipTexts.size()-1)
	TipCheck[TipIndex] = true
	$TipText.text = "Tip: " + TipTexts[TipIndex]
	
	for Selections in $Tile_Selections.get_children():
		for button in Selections.get_children():
			if("tile_cost" in button || "item_info" in button):
				button.parentEffector = self
	
	TileSelections.append($Tile_Selections/TileSelections/Tile_Selection_1)
	TileSelections.append($Tile_Selections/TileSelections/Tile_Selection_2)
	TileSelections.append($Tile_Selections/TileSelections/Tile_Selection_3)
	
	JokerSelections.append($Tile_Selections/JokerSelections/Joker_Selection)
	
	ItemSelections.append($Tile_Selections/ItemSelections/ItemSelection)
	ItemSelections.append($Tile_Selections/ItemSelections/ItemSelectio2)
	ItemSelections.append($Tile_Selections/ItemSelections/ItemSelection3)

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("Left_Click")):
		if(inside_TS_S):
			still_inside_TS_S = true
		
		if(inside_JS_S):
			still_inside_JS_S = true
		
		if(inside_IS_S):
			still_inside_IS_S = true
	
	if(Input.is_action_just_released("Left_Click")):
		if(inside_TS_S && still_inside_TS_S && $Tile_Selections/TileSelections.get_child_count()-1 < MAX_TILE_SELECTIONS):
			still_inside_TS_S = false
			var Game: GameScene = get_parent()
			if(Game.usingItem != null && Game.usingItem.item_info.target == Item.ItemTarget.ANY_HIGHLIGHT):
				Game.usingItem.item_info.useOnHighlight($Tile_Selections/TileSelections, Vector2(0, 35))
				await get_tree().create_timer(1.8).timeout
				add_TileSelection()
			#get_parent().HammerTime(false, $Tile_Selections/TileSelections)
		
		if(inside_JS_S && still_inside_JS_S && $Tile_Selections/JokerSelections.get_child_count()-1 < MAX_JOKER_SELECTIONS):
			still_inside_JS_S = false
			var Game: GameScene = get_parent()
			if(Game.usingItem != null && Game.usingItem.item_info.target == Item.ItemTarget.ANY_HIGHLIGHT):
				Game.usingItem.item_info.useOnHighlight($Tile_Selections/JokerSelections, Vector2(0, 35))
				await get_tree().create_timer(1.8).timeout
				add_JokerSelection()
			#get_parent().HammerTime(false, $Tile_Selections/JokerSelections)
		
		if(inside_IS_S && still_inside_IS_S && $Tile_Selections/ItemSelections.get_child_count()-1 < MAX_ITEM_SELECTIONS):
			still_inside_IS_S = false
			var Game: GameScene = get_parent()
			if(Game.usingItem != null && Game.usingItem.item_info.target == Item.ItemTarget.ANY_HIGHLIGHT):
				Game.usingItem.item_info.useOnHighlight($Tile_Selections/ItemSelections, Vector2(0, 35))
				await get_tree().create_timer(1.8).timeout
				add_ItemSelection()
			#get_parent().HammerTime(false, $Tile_Selections/ItemSelections)

func add_TileSelection() -> void:
	var new_TileSelection: Button = load("res://TileSelection.tscn").instantiate()
	$Tile_Selections/TileSelections.add_child(new_TileSelection)
	new_TileSelection.parentEffector = self
	new_TileSelection.REgenerate_selection()
	
	await get_tree().create_timer(0.001).timeout
	
	const EndSize: float = 500
	var SizeDiff: float = $Tile_Selections/TileSelections.size.x - EndSize
	if(SizeDiff > 0):
		var Separation: int = $Tile_Selections/TileSelections.get_theme_constant("separation")
		var SeparationCount: int = $Tile_Selections/TileSelections.get_child_count()-2
		$Tile_Selections/TileSelections.add_theme_constant_override("separation", int((Separation*SeparationCount - SizeDiff)/SeparationCount))
	
	TileSelections.append(new_TileSelection)

func add_JokerSelection() -> void:
	var new_JokerSelection: Button = load("res://TileSelection.tscn").instantiate()
	$Tile_Selections/JokerSelections.add_child(new_JokerSelection)
	new_JokerSelection.parentEffector = self
	new_JokerSelection.joker_tile = true
	var joker_ids: Array[int]
	for JokerSlot in $Tile_Selections/JokerSelections.get_children():
		if("tile_cost" in JokerSlot && JokerSlot != new_JokerSelection):
			joker_ids.append(JokerSlot.get_TileData().joker_id)
	
	var curr_id: int
	curr_id = new_JokerSelection.REgenerate_selection()
	while(joker_ids.find(curr_id) >= 0):
		curr_id = new_JokerSelection.REgenerate_selection()
	
	await get_tree().create_timer(0.001).timeout
	
	const EndSize: float = 310.0
	var SizeDiff: float = $Tile_Selections/JokerSelections.size.y - EndSize
	if(SizeDiff > 0):
		var Separation: int = $Tile_Selections/JokerSelections.get_theme_constant("separation")
		var SeparationCount: int = $Tile_Selections/JokerSelections.get_child_count()-2
		$Tile_Selections/JokerSelections.add_theme_constant_override("separation", int((Separation*SeparationCount - SizeDiff)/SeparationCount))
	
	JokerSelections.append(new_JokerSelection)

func add_ItemSelection() -> void:
	var new_ItemSelection: Button = load("res://ItemSelection.tscn").instantiate()
	$Tile_Selections/ItemSelections.add_child(new_ItemSelection)
	new_ItemSelection.parentEffector = self
	
	var item_ids: Array[int]
	for ItemSlot in $Tile_Selections/JokerSelections.get_children():
		if("item_info" in ItemSlot && ItemSlot != new_ItemSelection):
			item_ids.append(ItemSlot.item_info.id)
	
	var curr_id: int
	curr_id = new_ItemSelection.REgenerate_selection()
	if(7-Item.singularItems.size() <= $Tile_Selections/JokerSelections.get_child_count()-1):
		while(item_ids.find(curr_id) >= 0):
			curr_id = new_ItemSelection.REgenerate_selection()
	
	await get_tree().create_timer(0.001).timeout
	
	const EndSize: float = 333.333
	var SizeDiff: float = $Tile_Selections/ItemSelections.size.x - EndSize
	if(SizeDiff > 0):
		var Separation: int = $Tile_Selections/ItemSelections.get_theme_constant("separation")
		var SeparationCount: int = $Tile_Selections/ItemSelections.get_child_count()-2
		$Tile_Selections/ItemSelections.add_theme_constant_override("separation", int((Separation*SeparationCount - SizeDiff)/SeparationCount))
	
	ItemSelections.append(new_ItemSelection)

func get_TileSelections() -> HBoxContainer:
	return $Tile_Selections/TileSelections

func get_JokerSelecions() -> VBoxContainer:
	return $Tile_Selections/JokerSelections

func get_ItemSelections() -> HBoxContainer:
	return $Tile_Selections/ItemSelections

func getItemSlot(item: Item) -> Item_Selection:
	for Slot in $Tile_Selections/ItemSelections.get_children():
		if("item_info" in Slot && Slot.item_info != null && Slot.item_info == item):
			return Slot
	
	return null

func REgenerate_selections() -> void:
	var joker_ids: Array[int]
	var item_ids: Array[int]
	var curr_id: int
	
	for Selections in $Tile_Selections.get_children():
		for button in Selections.get_children():
			if("tile_cost" in button || "item_info" in button):
				curr_id = button.REgenerate_selection()
				if(curr_id >= 0):
					if("tile_cost" in button):
						while(joker_ids.find(curr_id) >= 0):
							curr_id = button.REgenerate_selection()
						
						joker_ids.append(curr_id)
					elif("item_info" in button):
						while(item_ids.find(curr_id) >= 0):
							curr_id = button.REgenerate_selection()
						
						item_ids.append(curr_id)

func update_currency(newCurrency: int) -> void:
	currency += newCurrency
	$Currency_Text.text = "Current Funds: " + str(currency)
	checkButtons()

func checkButtons() -> void:
	#var firstChild: bool = true
	for Selections in $Tile_Selections.get_children():
		#firstChild = true
		for button in Selections.get_children():
			#if(firstChild):
				#firstChild = false
				#continue
			if("tile_cost" in button || "item_info" in button):
				button.check_access(currency)

func tile_select(_button: Button, tile_bought: Tile_Info, cost: int) -> void:
	if(get_parent().getTurn()):
		return
	
	if(freebies > 0):
		freebies -= 1
	else:
		currency -= cost
		$"../ShopCurrency".text = "Current Funds: " + str(currency)
		update_currency(0)
	
	var animationTile: Tile = load("res://Tile.tscn").instantiate()
	add_child(animationTile)
	animationTile.change_info(tile_bought)
	animationTile.scale = Vector2(2, 2)
	animationTile.global_position = _button.global_position + Vector2(25, 35)*animationTile.scale/2.0
	
	var displacement: Vector2 = Vector2(randf_range(-60, 60), randf_range(-70, 0))
	while(displacement.length() < 50):
		displacement = Vector2(randf_range(-60, 0), randf_range(-60, 30))
	
	var tween = get_tree().create_tween()
	animationTile.moveTile(animationTile.global_position + displacement, 0.5)
	tween.tween_property(animationTile, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	
	get_parent().buy_tile(tile_bought, animationTile)
	if(freebies <= 0):
		for Selections in $Tile_Selections.get_children():
			#if("tile_cost" in button || "item_info" in button):
			for button in Selections.get_children():
				if("tile_cost" in button || "item_info" in button):
					button.freebie(false, currency)

func item_select(button: Button, item_bought: Item, cost: int) -> void:
	if(get_parent().getTurn()):
		return
	
	if(freebies > 0):
		freebies -= 1
	else:
		currency -= cost
		$"../ShopCurrency".text = "Current Funds: " + str(currency)
		update_currency(0)
	
	get_parent().buy_item(item_bought)
	if(freebies <= 0):
		for Selections in $Tile_Selections.get_children():
			for selection in Selections.get_children():
				if("tile_cost" in selection || "item_info" in selection):
					selection.freebie(false, currency)

func Beaver_Break(IS: Button) -> void:
	pass

func ToggleHighlight(toggleTiles: bool = false, toggleJokers: bool = false, toggleItems: bool = false):
	$TileSelection_Sensor.visible = toggleTiles
	$JokerSelection_Sensor.visible = toggleJokers
	$ItemSelection_Sensor.visible = toggleItems
	if(toggleTiles):
		move_child($ShopMain_BackGround, 0)
		if($Tile_Selections/TileSelections.get_child_count()-1 >= MAX_TILE_SELECTIONS):
			$Tile_Selections/TileSelections/TileSelections_Highlight.self_modulate = Color(1, 0, 0, 1)
		else:
			$Tile_Selections/TileSelections/TileSelections_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	
	if(toggleJokers):
		if($Tile_Selections/JokerSelections.get_child_count()-1 >= MAX_JOKER_SELECTIONS):
			$Tile_Selections/JokerSelections/JokerSelections_Highlight.self_modulate = Color(1, 0, 0, 1)
		else:
			$Tile_Selections/JokerSelections/JokerSelections_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	
	if(toggleItems):
		if($Tile_Selections/ItemSelections.get_child_count()-1 >= MAX_ITEM_SELECTIONS):
			$Tile_Selections/ItemSelections/TileSelections_Highlight.self_modulate = Color(1, 0, 0, 1)
		else:
			$Tile_Selections/ItemSelections/TileSelections_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	
	if(!toggleItems && !toggleJokers && !toggleTiles):
		move_child($ShopMain_BackGround, 1)

func addShopUses() -> void:
	for ItemSlots in $Tile_Selections/ItemSelections.get_children():
		if("item_info" in ItemSlots):
			ItemSlots.add_uses(1)

var freebies: int = 0

func Gain_Freebie(extra_freebies: int = 1) -> void:
	freebies += extra_freebies
	for Selections in $Tile_Selections.get_children():
		for button in Selections.get_children():
			if("tile_cost" in button || "item_info" in button):
				button.freebie(true, currency)

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

var inside_TS_S: bool = false
var still_inside_TS_S: bool = false

func _on_TileSelection_Sensor_mouse_entered() -> void:
	inside_TS_S = true
	$Tile_Selections/TileSelections/TileSelections_Highlight.visible = true

func _on_TileSelection_Sensor_mouse_exited() -> void:
	inside_TS_S = false
	still_inside_TS_S = false
	$Tile_Selections/TileSelections/TileSelections_Highlight.visible = false

var inside_JS_S: bool = false
var still_inside_JS_S: bool = false

func _on_JokerSelection_Sensor_mouse_entered() -> void:
	inside_JS_S = true
	$Tile_Selections/JokerSelections/JokerSelections_Highlight.visible = true

func _on_JokerSelection_Sensor_mouse_exited() -> void:
	inside_JS_S = false
	still_inside_JS_S = false
	$Tile_Selections/JokerSelections/JokerSelections_Highlight.visible = false

var inside_IS_S: bool = false
var still_inside_IS_S: bool = false

func _on_ItemSelection_Sensor_mouse_entered() -> void:
	inside_IS_S = true
	$Tile_Selections/ItemSelections/TileSelections_Highlight.visible = true

func _on_ItemSelection_Sensor_mouse_exited() -> void:
	inside_IS_S = false
	still_inside_IS_S = false
	$Tile_Selections/ItemSelections/TileSelections_Highlight.visible = false
