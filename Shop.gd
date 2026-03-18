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

const STARTING_TILE_CONTAINERS: int = 3
const STARTING_JOKER_CONTAINERS: int = 3
const STARTING_ITEM_CONTAINERS: int = 3

var TileSelections: Array[TileContainer]
var JokerSelections: Array[TileContainer]
var ItemSelections: Array[ItemContainer]

@export var Shop_BG: Sprite2D

func _ready() -> void:
	#.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	TipCheck.resize(TipTexts.size())
	TipCheck.fill(false)
	var TipIndex: int = randi_range(0, TipTexts.size()-1)
	TipCheck[TipIndex] = true
	$TipText.text = "Tip: " + TipTexts[TipIndex]
	
	if(TileSelections.is_empty()):
		var newTileContainer: TileContainer
		#var tiles: Array[Tile_Info]
		var newTile: Tile_Info
		for i in range(STARTING_TILE_CONTAINERS):
			newTile = Tile_Info.getRandomTile(3)
			newTileContainer = TileContainer.new(null, ResourceContainer.ContainerType.SHOP, 3)
			TileSelections.append(newTileContainer)
			$ShopSelections/TileSelections.add_child(newTileContainer)
			$ShopSelections/TileSelections.move_child(newTileContainer, 0)
			newTileContainer.name = "TileContainer" + str(STARTING_TILE_CONTAINERS-i)
	
	if(ItemSelections.is_empty()):
		var newItemContainer: ItemContainer
		var items: Array[String]
		var newItem: Item
		for i in range(STARTING_ITEM_CONTAINERS):
			newItem = Item.getRandomItem(GameScene.Game, true)
			while(items.has(newItem.itemID)):
				newItem = Item.getRandomItem(GameScene.Game, true)
			
			items.append(newItem.itemID)
			newItemContainer = ItemContainer.new(newItem, ResourceContainer.ContainerType.SHOP)
			ItemSelections.append(newItemContainer)
			$ShopSelections/ItemSelections.add_child(newItemContainer)
			$ShopSelections/ItemSelections.move_child(newItemContainer, 0)
			newItemContainer.name = "ItemContainer" + str(STARTING_ITEM_CONTAINERS-i)

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("Left_Click")):
		if(inside_TS_S):
			still_inside_TS_S = true
		
		if(inside_JS_S):
			still_inside_JS_S = true
		
		if(inside_IS_S):
			still_inside_IS_S = true
	
	if(Input.is_action_just_released("Left_Click")):
		if(inside_TS_S && still_inside_TS_S && $ShopSelections/TileSelections.get_child_count()-1 < MAX_TILE_SELECTIONS):
			still_inside_TS_S = false
			var Game: GameScene = get_parent()
			if(Game.usingItem != null && Game.usingItem.item_info.target == Item.ItemTarget.ANY_HIGHLIGHT):
				Game.usingItem.item_info.useOnHighlight($ShopSelections/TileSelections, Vector2(0, 35))
				await get_tree().create_timer(1.8).timeout
				add_TileSelection()
			#get_parent().HammerTime(false, $ShopSelections/TileSelections)
		
		if(inside_JS_S && still_inside_JS_S && $ShopSelections/JokerSelections.get_child_count()-1 < MAX_JOKER_SELECTIONS):
			still_inside_JS_S = false
			var Game: GameScene = get_parent()
			if(Game.usingItem != null && Game.usingItem.item_info.target == Item.ItemTarget.ANY_HIGHLIGHT):
				Game.usingItem.item_info.useOnHighlight($ShopSelections/JokerSelections, Vector2(0, 35))
				await get_tree().create_timer(1.8).timeout
				add_JokerSelection()
			#get_parent().HammerTime(false, $ShopSelections/JokerSelections)
		
		if(inside_IS_S && still_inside_IS_S && $ShopSelections/ItemSelections.get_child_count()-1 < MAX_ITEM_SELECTIONS):
			still_inside_IS_S = false
			var Game: GameScene = get_parent()
			if(Game.usingItem != null && Game.usingItem.item_info.target == Item.ItemTarget.ANY_HIGHLIGHT):
				Game.usingItem.item_info.useOnHighlight($ShopSelections/ItemSelections, Vector2(0, 35))
				await get_tree().create_timer(1.8).timeout
				add_ItemSelection()
			#get_parent().HammerTime(false, $ShopSelections/ItemSelections)

func add_TileSelection() -> void:
	var new_TileSelection: TileContainer = TileContainer.new(null, ResourceContainer.ContainerType.SHOP, 3)#load("res://TileSelection.tscn").instantiate()
	TileSelections.append(new_TileSelection)
	$ShopSelections/TileSelections.add_child(new_TileSelection)
	$ShopSelections/TileSelections.move_child(new_TileSelection, TileSelections.size()-1)
	new_TileSelection.parentEffector = self
	new_TileSelection.REgenerate_selection()
	
	await get_tree().create_timer(0.001).timeout
	
	const EndSize: float = 500
	var SizeDiff: float = $ShopSelections/TileSelections.size.x - EndSize
	if(SizeDiff > 0):
		var Separation: int = $ShopSelections/TileSelections.get_theme_constant("separation")
		var SeparationCount: int = $ShopSelections/TileSelections.get_child_count()-2
		$ShopSelections/TileSelections.add_theme_constant_override("separation", int((Separation*SeparationCount - SizeDiff)/SeparationCount))
	
	TileSelections.append(new_TileSelection)

func add_JokerSelection() -> void:
	var new_JokerSelection: Button = load("res://TileSelection.tscn").instantiate()
	$ShopSelections/JokerSelections.add_child(new_JokerSelection)
	new_JokerSelection.parentEffector = self
	new_JokerSelection.joker_tile = true
	var joker_ids: Array[int]
	for JokerSlot in $ShopSelections/JokerSelections.get_children():
		if("tile_cost" in JokerSlot && JokerSlot != new_JokerSelection):
			joker_ids.append(JokerSlot.get_TileData().joker_id)
	
	var curr_id: int
	curr_id = new_JokerSelection.REgenerate_selection()
	while(joker_ids.find(curr_id) >= 0):
		curr_id = new_JokerSelection.REgenerate_selection()
	
	await get_tree().create_timer(0.001).timeout
	
	const EndSize: float = 310.0
	var SizeDiff: float = $ShopSelections/JokerSelections.size.y - EndSize
	if(SizeDiff > 0):
		var Separation: int = $ShopSelections/JokerSelections.get_theme_constant("separation")
		var SeparationCount: int = $ShopSelections/JokerSelections.get_child_count()-2
		$ShopSelections/JokerSelections.add_theme_constant_override("separation", int((Separation*SeparationCount - SizeDiff)/SeparationCount))
	
	JokerSelections.append(new_JokerSelection)

func add_ItemSelection() -> void:
	var new_ItemSelection: Button = ItemContainer.new(null, ResourceContainer.ContainerType.GAMEBAR) #load("res://ItemSelection.tscn").instantiate()
	$ShopSelections/ItemSelections.add_child(new_ItemSelection)
	
	var item_ids: Array[int]
	for ItemSlot in ItemSelections:
		if(ItemSlot != new_ItemSelection):
			item_ids.append(ItemSlot.item_info.id)
	
	var curr_id: int
	curr_id = new_ItemSelection.REgenerate_selection()
	if(7-Item.singularItems.size() <= $ShopSelections/JokerSelections.get_child_count()-1):
		while(item_ids.find(curr_id) >= 0):
			curr_id = new_ItemSelection.REgenerate_selection()
	
	await get_tree().create_timer(0.001).timeout
	
	const EndSize: float = 333.333
	var SizeDiff: float = $ShopSelections/ItemSelections.size.x - EndSize
	if(SizeDiff > 0):
		var Separation: int = $ShopSelections/ItemSelections.get_theme_constant("separation")
		var SeparationCount: int = $ShopSelections/ItemSelections.get_child_count()-2
		$ShopSelections/ItemSelections.add_theme_constant_override("separation", int((Separation*SeparationCount - SizeDiff)/SeparationCount))
	
	ItemSelections.append(new_ItemSelection)

func get_TileSelections() -> HBoxContainer:
	return $ShopSelections/TileSelections

func get_JokerSelecions() -> VBoxContainer:
	return $ShopSelections/JokerSelections

func get_ItemSelections() -> HBoxContainer:
	return $ShopSelections/ItemSelections

func getItemSlot(item: Item) -> ItemContainer:
	for Slot in ItemSelections:
		if(Slot.resource == item):
			return Slot
	
	return null

func REgenerate_selections() -> void:
	#var joker_ids: Array[int]
	var item_ids: Array[String]
	#var curr_id: int
	
	for TileSlot in TileSelections:
		TileSlot.REgenerateResource(null, 3)
	
	var newItem: Item
	for ItemSlot in ItemSelections:
		newItem = Item.getRandomItem(GameScene.Game, true)
		while(item_ids.has(newItem.itemID)):
			newItem = Item.getRandomItem(GameScene.Game, true)
		
		ItemSlot.REgenerateResource(newItem)

func update_currency(newCurrency: int) -> void:
	currency += newCurrency
	$Currency_Text.text = "Current Funds: " + str(currency)
	checkButtons()

func checkButtons() -> void:
	var Selections: Array[ResourceContainer]
	Selections.append_array(TileSelections)
	Selections.append_array(ItemSelections)
	
	for selection in Selections:
		selection.checkShopAffordability()

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
		for Selections in $ShopSelections.get_children():
			#if("tile_cost" in button || "item_info" in button):
			for button in Selections.get_children():
				if("tile_cost" in button || "item_info" in button):
					button.freebie(false, currency)

func containerPressed(button: ResourceContainer) -> void:
	if(get_parent().getTurn()):
		return
	
	if(freebies > 0):
		freebies -= 1
	else:
		currency -= button.price
		$"../ShopCurrency".text = "Current Funds: " + str(currency)
		update_currency(0)
	
	match button.resource_type:
		ResourceContainer.ResourceType.ITEM:
			GameScene.Game.buy_item(button.resource)
		ResourceContainer.ResourceType.TILE:
			GameScene.Game.buy_tile(button.resource)
	
	checkButtons()

func ToggleHighlight(toggleTiles: bool = false, toggleJokers: bool = false, toggleItems: bool = false):
	$TileSelection_Sensor.visible = toggleTiles
	$JokerSelection_Sensor.visible = toggleJokers
	$ItemSelection_Sensor.visible = toggleItems
	if(toggleTiles):
		move_child($ShopMain_BackGround, 0)
		if($ShopSelections/TileSelections.get_child_count()-1 >= MAX_TILE_SELECTIONS):
			$ShopSelections/TileSelections/TileSelections_Highlight.self_modulate = Color(1, 0, 0, 1)
		else:
			$ShopSelections/TileSelections/TileSelections_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	
	if(toggleJokers):
		if($ShopSelections/JokerSelections.get_child_count()-1 >= MAX_JOKER_SELECTIONS):
			$ShopSelections/JokerSelections/JokerSelections_Highlight.self_modulate = Color(1, 0, 0, 1)
		else:
			$ShopSelections/JokerSelections/JokerSelections_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	
	if(toggleItems):
		if($ShopSelections/ItemSelections.get_child_count()-1 >= MAX_ITEM_SELECTIONS):
			$ShopSelections/ItemSelections/TileSelections_Highlight.self_modulate = Color(1, 0, 0, 1)
		else:
			$ShopSelections/ItemSelections/TileSelections_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	
	if(!toggleItems && !toggleJokers && !toggleTiles):
		move_child($ShopMain_BackGround, 1)

func addShopUses() -> void:
	for ItemSlot in ItemSelections:
		if(ItemSlot.resource.uses >= 1):
			ItemSlot.resource.uses += 1

var freebies: int = 0

func Gain_Freebie(extra_freebies: int = 1) -> void:
	freebies += extra_freebies
	
	checkButtons()

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
	$ShopSelections/TileSelections/TileSelections_Highlight.visible = true

func _on_TileSelection_Sensor_mouse_exited() -> void:
	inside_TS_S = false
	still_inside_TS_S = false
	$ShopSelections/TileSelections/TileSelections_Highlight.visible = false

var inside_JS_S: bool = false
var still_inside_JS_S: bool = false

func _on_JokerSelection_Sensor_mouse_entered() -> void:
	inside_JS_S = true
	$ShopSelections/JokerSelections/JokerSelections_Highlight.visible = true

func _on_JokerSelection_Sensor_mouse_exited() -> void:
	inside_JS_S = false
	still_inside_JS_S = false
	$ShopSelections/JokerSelections/JokerSelections_Highlight.visible = false

var inside_IS_S: bool = false
var still_inside_IS_S: bool = false

func _on_ItemSelection_Sensor_mouse_entered() -> void:
	inside_IS_S = true
	$ShopSelections/ItemSelections/TileSelections_Highlight.visible = true

func _on_ItemSelection_Sensor_mouse_exited() -> void:
	inside_IS_S = false
	still_inside_IS_S = false
	$ShopSelections/ItemSelections/TileSelections_Highlight.visible = false
