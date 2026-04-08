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

const MAX_HORIZONTAL_SELECTIONS: int = 10
#const MAX_TILE_SELECTIONS: int = 10
const MAX_JOKER_SELECTIONS: int = 3
#const MAX_ITEM_SELECTIONS: int = 10
const STARTING_TILE_CONTAINERS: int = 5
const STARTING_JOKER_CONTAINERS: int = 1
const STARTING_ITEM_CONTAINERS: int = 3
# JOKER_BOX_SEPARATION: int = 25
const HORIZONTAL_SELECTIONS_BOX_WIDTH: float = 840
const VERTICAL_SELECTIONS_BOX_HEIGHT: float = 365
const SIMPLE_HORIZONTAL_SELECTION_EXPANSION: int = 25
const TILE_SELECTION_START_SEPARATION: int = 50
const ITEM_SELECTION_START_SEPARATION: int = 100
const HORIZONTAL_FINAL_SEPARATION: int = 10
const TILE_SEPARATION_STEP: int = roundi(float(TILE_SELECTION_START_SEPARATION-HORIZONTAL_FINAL_SEPARATION)/(MAX_HORIZONTAL_SELECTIONS-STARTING_TILE_CONTAINERS))
const ITEM_SEPARATION_STEP: int = roundi(float(ITEM_SELECTION_START_SEPARATION-HORIZONTAL_FINAL_SEPARATION)/(MAX_HORIZONTAL_SELECTIONS-STARTING_ITEM_CONTAINERS))

const MAIN_BACKGROUND_COLOR: Color = Color(0, 0.31, 0.53, 1)

static var TileSelections: Array[TileContainer]
static var JokerSelections: Array[TileContainer]
static var ItemSelections: Array[ItemContainer]

static var currency: int = 0

#@export var Shop_BG: Sprite2D

var Background: Sprite2D
var MainShopBackground: Sprite2D
var TileSelection_Sensor: GoodButton
var JokerSelection_Sensor: GoodButton
var ItemSelection_Sensor: GoodButton
var TileSelections_Box: HBoxContainer
var TileSelections_Highlight: Sprite2D
var JokerSelections_Box: VBoxContainer
var JokerSelections_Highlight: Sprite2D
var ItemSelections_Box: HBoxContainer
var ItemSelections_Highlight: Sprite2D
var ExitShop: GoodButton
var CurrencyText: Label
#var ShopSelections: Control

func _init() -> void:
	Background = Sprite2D.new()
	Background.texture = CanvasTexture.new()
	Background.region_enabled = true
	Background.self_modulate = Color.BLACK
	Background.self_modulate.a = 100.0/255
	Background.name = "Background"
	add_child(Background)
	
	MainShopBackground = Sprite2D.new()
	MainShopBackground.texture = CanvasTexture.new()
	MainShopBackground.region_enabled = true
	MainShopBackground.self_modulate = MAIN_BACKGROUND_COLOR
	MainShopBackground.name = "MainShopBackground"
	add_child(MainShopBackground)
	
	#TS_B START
	TileSelections_Box = HBoxContainer.new()
	TileSelections_Box.alignment = BoxContainer.ALIGNMENT_CENTER
	TileSelections_Box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	TileSelections_Box.custom_minimum_size = Vector2(HORIZONTAL_SELECTIONS_BOX_WIDTH, ResourceContainer.BASE_RESOURCE_SIZE.y)
	TileSelections_Box.position = Vector2(225, 150)
	TileSelections_Box.add_theme_constant_override("separation", 50)
	#TileSelections_Box.self_modulate = Color.BLUE
	TileSelections_Box.name = "TileSelections_Box"
	
	var currSelectionSize: float = STARTING_TILE_CONTAINERS*(ResourceContainer.BASE_RESOURCE_SIZE.x + 50)# - 20
	TileSelection_Sensor = GoodButton.new("", Color(MAIN_BACKGROUND_COLOR, 0), GoodButton.ButtonType.SENSOR_TILE, Vector2(currSelectionSize, ResourceContainer.BASE_RESOURCE_SIZE.y+15))
	TileSelection_Sensor.IconHighlightColor = MAIN_BACKGROUND_COLOR
	TileSelection_Sensor.visible = false
	#TileSelection_Sensor.position = TileSelections_Box.position
	#TileSelection_Sensor.position.x += HORIZONTAL_SELECTIONS_BOX_WIDTH - currSelectionSize
	#TileSelection_Sensor.position.y -= 7.5
	TileSelection_Sensor.name = "TileSelection_Sensor"
	add_child(TileSelection_Sensor)
	
	add_child(TileSelections_Box)
	
	#JS_B START
	JokerSelections_Box = VBoxContainer.new()
	JokerSelections_Box.alignment = BoxContainer.ALIGNMENT_CENTER
	JokerSelections_Box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	JokerSelections_Box.custom_minimum_size = Vector2(ResourceContainer.BASE_RESOURCE_SIZE.x, VERTICAL_SELECTIONS_BOX_HEIGHT)
	JokerSelections_Box.position = Vector2(100, 140)
	JokerSelections_Box.add_theme_constant_override("separation", 25)
	#JokerSelections_Box.self_modulate = Color.BLUE
	JokerSelections_Box.name = "JokerSelections_Box"
	
	JokerSelection_Sensor = GoodButton.new("", Color(MAIN_BACKGROUND_COLOR, 0), GoodButton.ButtonType.SENSOR_JOKER, Vector2(ResourceContainer.BASE_RESOURCE_SIZE.x+15, VERTICAL_SELECTIONS_BOX_HEIGHT+50))
	JokerSelection_Sensor.IconHighlightColor = MAIN_BACKGROUND_COLOR
	JokerSelection_Sensor.visible = false
	JokerSelection_Sensor.position = JokerSelections_Box.position
	JokerSelection_Sensor.position.y -= 25
	JokerSelection_Sensor.position.x -= 7.5
	JokerSelection_Sensor.name = "JokerSelection_Sensor"
	add_child(JokerSelection_Sensor)
	
	add_child(JokerSelections_Box)
	
	#IS_B START
	ItemSelections_Box = HBoxContainer.new()
	ItemSelections_Box.alignment = BoxContainer.ALIGNMENT_CENTER
	ItemSelections_Box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ItemSelections_Box.custom_minimum_size = Vector2(HORIZONTAL_SELECTIONS_BOX_WIDTH, ResourceContainer.BASE_RESOURCE_SIZE.y)
	ItemSelections_Box.position = Vector2(225, 390)
	ItemSelections_Box.add_theme_constant_override("separation", 100)
	#ItemSelections_Box.self_modulate = Color.BLUE
	ItemSelections_Box.name = "ItemSelections_Box"
	
	currSelectionSize = STARTING_ITEM_CONTAINERS*(ResourceContainer.BASE_RESOURCE_SIZE.x + 100)# - 20
	ItemSelection_Sensor = GoodButton.new("", Color(MAIN_BACKGROUND_COLOR, 0), GoodButton.ButtonType.SENSOR_ITEM, Vector2(currSelectionSize, ResourceContainer.BASE_RESOURCE_SIZE.y+15))
	ItemSelection_Sensor.IconHighlightColor = MAIN_BACKGROUND_COLOR
	ItemSelection_Sensor.visible = false
	ItemSelection_Sensor.position = ItemSelections_Box.position
	ItemSelection_Sensor.position.x += HORIZONTAL_SELECTIONS_BOX_WIDTH - currSelectionSize
	ItemSelection_Sensor.position.y -= 7.5
	ItemSelection_Sensor.name = "ItemSelection_Sensor"
	add_child(ItemSelection_Sensor)
	
	add_child(ItemSelections_Box)
	
	ExitShop = GoodButton.new("", Color.WHITE, GoodButton.ButtonType.EXIT_SHOP, Vector2(-1, -1), load("res://UI/Exit.png"))
	ExitShop.scale = Vector2(0.5, 0.5)
	ExitShop.name = "ExitShop"
	add_child(ExitShop)
	
	CurrencyText = Label.new()
	CurrencyText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CurrencyText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var currencyText: String = StringsManager.UIStrings["SHOP"][1] + str(0)
	var textSize: Vector2 = CurrencyText.get_theme_font("font").get_string_size(currencyText)
	CurrencyText.text = currencyText
	CurrencyText.size = textSize
	CurrencyText.position = Vector2(57.6, 32.4)
	CurrencyText.mouse_filter = Control.MOUSE_FILTER_IGNORE
	CurrencyText.name = "CurrencyText"
	add_child(CurrencyText)
	
	var newTile: TileContainer
	for i in range(STARTING_TILE_CONTAINERS):
		newTile = TileContainer.new(Tile.getRandomTile(3), ResourceContainer.ContainerType.SHOP)
		
		#newTile.price = 0
		#newTile.checkShopAffordability()
		
		TileSelections_Box.add_child(newTile)
		TileSelections.append(newTile)
		newTile.name = "TileSelection" + str(STARTING_TILE_CONTAINERS-i)
	
	TileSelection_Sensor.global_position = TileSelections[0].global_position
	#TileSelection_Sensor.position.x += 15
	#TileSelection_Sensor.position.y -= 7.5
	
	var newJoker: TileContainer
	var jokerIDs: Array[int]
	var joker: Tile
	for i in range(STARTING_JOKER_CONTAINERS):
		joker = Tile.getRandomJoker()
		while(jokerIDs.has(joker.joker_id)):
			joker = Tile.getRandomJoker()
		
		jokerIDs.append(joker.joker_id)
		newJoker = TileContainer.new(joker, ResourceContainer.ContainerType.SHOP)
		
		newJoker.price = 0
		
		JokerSelections_Box.add_child(newJoker)
		JokerSelections.append(newJoker)
		newJoker.name = "JokerSelection" + str(STARTING_JOKER_CONTAINERS-i)
	
	var newItem: ItemContainer
	var itemIDs: Array[int]
	var item: Item
	for i in range(STARTING_ITEM_CONTAINERS):
		item = Item.getRandomItem(GameScene.Game, true)
		while(itemIDs.has(item.id)):
			item = Item.getRandomItem(GameScene.Game, true)
		
		itemIDs.append(item.id)
		newItem = ItemContainer.new(item, ResourceContainer.ContainerType.SHOP)
		
		newItem.price = 0
		
		ItemSelections_Box.add_child(newItem)
		ItemSelections.append(newItem)
		newItem.name = "ItemSelection" + str(STARTING_ITEM_CONTAINERS-i)
	
	ItemSelection_Sensor.global_position = ItemSelections[0].global_position
	ItemSelection_Sensor.position.x += 15
	ItemSelection_Sensor.position.y -= 7.5
	
	ExitShop.press.connect(func() -> void: visible = false)
	
	TileSelection_Sensor.press.connect(func() -> void:
		if(GameScene.usingItem == null):
			return
		
		await GameScene.usingItem.resource.useOnHighlight(TileSelection_Sensor)
		add_TileSelection())
		
	JokerSelection_Sensor.press.connect(func() -> void:
		if(GameScene.usingItem == null):
			return
		
		await GameScene.usingItem.resource.useOnHighlight(JokerSelection_Sensor)
		add_JokerSelection())
		
	ItemSelection_Sensor.press.connect(func() -> void:
		if(GameScene.usingItem == null):
			return
		
		await GameScene.usingItem.resource.useOnHighlight(ItemSelection_Sensor)
		add_ItemSelection())

func _ready() -> void:
	var windowSize: Vector2 = get_viewport_rect().size
	
	custom_minimum_size = windowSize
	
	Background.region_rect = Rect2(Vector2(0, 0), windowSize)
	Background.position = windowSize/2
	
	MainShopBackground.region_rect = Rect2(Vector2(0, 0), windowSize*0.9)
	MainShopBackground.position = windowSize/2
	
	ExitShop.position = Vector2(windowSize.x*0.95 - ExitShop.size.x/2, windowSize.y*0.05)
	
	while(TileSelections[0].position == Vector2(0, 0)):
		await get_tree().create_timer(0.001).timeout
	
	TileSelection_Sensor.global_position = TileSelections[0].global_position
	TileSelection_Sensor.position.x -= 25
	TileSelection_Sensor.position.y -= 7.5
	
	ItemSelection_Sensor.global_position = ItemSelections[0].global_position
	ItemSelection_Sensor.position.x -= 50
	ItemSelection_Sensor.position.y -= 7.5

#var oldValue: int = -1
#func _process(delta: float) -> void:
	#if(ItemSelections.size() != oldValue):
		#print("HERE0 - " + str(oldValue) + " - " + str(ItemSelections.size()))
		#oldValue = ItemSelections.size()

func add_TileSelection() -> void:
	var origPos: Vector2 = TileSelections[0].global_position
	var new_TileSelection: TileContainer = TileContainer.new(null, ResourceContainer.ContainerType.SHOP, 3)#load("res://TileSelection.tscn").instantiate()
	TileSelections.append(new_TileSelection)
	TileSelections_Box.add_child(new_TileSelection)
	TileSelections_Box.move_child(new_TileSelection, TileSelections.size()-1)
	
	var newCount: int = TileSelections.size()
	
	var separation: int = TileSelections_Box.get_theme_constant("separation") - TILE_SEPARATION_STEP
	
	TileSelections_Box.add_theme_constant_override("separation", separation)
	
	while(TileSelections[0].global_position == origPos):
		await get_tree().create_timer(0.001).timeout
	
	var currSelectionSize: float = newCount*(ResourceContainer.BASE_RESOURCE_SIZE.x + separation) + separation
	TileSelection_Sensor.changeVisuals("", TileSelection_Sensor.IconOrigColor, Vector2(currSelectionSize, ResourceContainer.BASE_RESOURCE_SIZE.y+15))
	TileSelection_Sensor.IconHighlightColor = MAIN_BACKGROUND_COLOR
	TileSelection_Sensor.global_position = TileSelections[0].global_position
	TileSelection_Sensor.position.x -= separation#/2.0
	TileSelection_Sensor.position.y -= 7.5

func add_JokerSelection() -> void:
	var joker_ids: Array[int]
	for jokerSlot in JokerSelections:
		joker_ids.append(jokerSlot.resource.joker_id)
	
	var newJoker: Tile = Tile.getRandomJoker()
	while(joker_ids.has(newJoker.joker_id)):
		newJoker = Tile.getRandomJoker()
	
	var new_JokerSelection: TileContainer = TileContainer.new(newJoker, ResourceContainer.ContainerType.SHOP)
	JokerSelections.append(new_JokerSelection)
	JokerSelections_Box.add_child(new_JokerSelection)
	
	#await get_tree().create_timer(0.001).timeout
	#
	#const EndSize: float = 310.0
	#var SizeDiff: float = JokerSelections_Box.size.y - EndSize
	#if(SizeDiff > 0):
		#var Separation: int = JokerSelections_Box.get_theme_constant("separation")
		#var SeparationCount: int = JokerSelections_Box.get_child_count()-2
		#JokerSelections_Box.add_theme_constant_override("separation", int((Separation*SeparationCount - SizeDiff)/SeparationCount))

func add_ItemSelection() -> void:
	var origPos: Vector2 = ItemSelections[0].global_position
	var item_ids: Array[int]
	for ItemSlot in ItemSelections:
		item_ids.append(ItemSlot.resource.id)
	
	var newItem: Item = Item.getRandomItem(GameScene.Game, true)
	#while(item_ids.has(newItem.id)):
		#newItem = Item.getRandomItem(GameScene.Game, true)
	
	var new_ItemSelection: ItemContainer = ItemContainer.new(newItem, ResourceContainer.ContainerType.SHOP)
	ItemSelections.append(new_ItemSelection)
	ItemSelections_Box.add_child(new_ItemSelection)
	
	#await get_tree().create_timer(0.001).timeout
	
	var newCount: int = ItemSelections.size()
	
	var separation: int = ItemSelections_Box.get_theme_constant("separation") - ITEM_SEPARATION_STEP
	
	ItemSelections_Box.add_theme_constant_override("separation", separation)
	
	while(ItemSelections[0].global_position == origPos):
		await get_tree().create_timer(0.001).timeout
	
	var currSelectionSize: float = newCount*(ResourceContainer.BASE_RESOURCE_SIZE.x + separation) + separation
	ItemSelection_Sensor.changeVisuals("", ItemSelection_Sensor.IconOrigColor, Vector2(currSelectionSize, ResourceContainer.BASE_RESOURCE_SIZE.y+15))
	ItemSelection_Sensor.IconHighlightColor = MAIN_BACKGROUND_COLOR
	ItemSelection_Sensor.global_position = ItemSelections[0].global_position
	ItemSelection_Sensor.position.x -= separation#/2.0
	ItemSelection_Sensor.position.y -= 7.5

func REgenerateResources() -> void:
	var joker_ids: Array[int]
	var item_ids: Array[String]
	#var curr_id: int
	
	for TileSlot in TileSelections:
		TileSlot.REgenerateResource(null, 3)
	
	var newJoker: Tile
	for JokerSelection in JokerSelections:
		newJoker = Tile.getRandomJoker()
		while(joker_ids.has(newJoker.joker_id)):
			newJoker = Tile.getRandomJoker()
		
		JokerSelection.REgenerateResource(newJoker)
	
	var newItem: Item
	for ItemSlot in ItemSelections:
		newItem = Item.getRandomItem(GameScene.Game, true)
		while(item_ids.has(newItem.itemID)):
			newItem = Item.getRandomItem(GameScene.Game, true)
		
		ItemSlot.REgenerateResource(newItem)

func containerPressed(container: ResourceContainer) -> void:
	if(GameScene.myTurn):
		return
	
	if(freebies > 0):
		freebies -= 1
		update_currency(0)
	else:
		update_currency(-container.price)
	
	match container.resource_type:
		ResourceContainer.ResourceType.TILE:
			GameScene.MainPlayer.PlayerDeck.addTile(container, Deck.TileSource.SHOP)
			container.REgenerateResource(Tile.getRandomJoker())
		ResourceContainer.ResourceType.ITEM:
			GameScene.PlayerBar.add_item(container.resource)

func update_currency(newCurrency: int) -> void:
	currency += newCurrency
	CurrencyText.text = "Current Funds: " + str(currency)
	checkButtons()

func checkButtons() -> void:
	var Selections: Array[ResourceContainer]
	Selections.append_array(TileSelections)
	Selections.append_array(ItemSelections)
	
	for selection in Selections:
		selection.checkShopAffordability()

func ToggleHighlight(toggle: bool):
	TileSelection_Sensor.visible = toggle
	JokerSelection_Sensor.visible = toggle
	ItemSelection_Sensor.visible = toggle
	
	if(toggle):
		MainShopBackground.self_modulate -= Color(0.3, 0.3, 0.3, 0)
	else:
		MainShopBackground.self_modulate = MAIN_BACKGROUND_COLOR
	
	if(TileSelections.size() >= MAX_HORIZONTAL_SELECTIONS):
		TileSelection_Sensor.DIS_ENable(false)
		TileSelection_Sensor.changeVisuals("", Color(Color.DARK_RED, 0), TileSelection_Sensor.size)
		TileSelection_Sensor.IconHighlightDisabledColor = Color.DARK_RED
	else:
		TileSelection_Sensor.DIS_ENable(true)
		TileSelection_Sensor.changeVisuals("", Color(MAIN_BACKGROUND_COLOR, 0), TileSelection_Sensor.size)
		TileSelection_Sensor.IconHighlightColor = MAIN_BACKGROUND_COLOR
	
	if(JokerSelections.size() >= MAX_JOKER_SELECTIONS):
		JokerSelection_Sensor.DIS_ENable(false)
		JokerSelection_Sensor.changeVisuals("", Color(Color.DARK_RED, 0), JokerSelection_Sensor.size)
		JokerSelection_Sensor.IconHighlightDisabledColor = Color.DARK_RED
	else:
		JokerSelection_Sensor.DIS_ENable(true)
		JokerSelection_Sensor.changeVisuals("", Color(MAIN_BACKGROUND_COLOR, 0), JokerSelection_Sensor.size)
		JokerSelection_Sensor.IconHighlightColor = MAIN_BACKGROUND_COLOR
	
	if(ItemSelections.size() >= MAX_HORIZONTAL_SELECTIONS):
		ItemSelection_Sensor.DIS_ENable(false)
		ItemSelection_Sensor.changeVisuals("", Color(Color.DARK_RED, 0), ItemSelection_Sensor.size)
		ItemSelection_Sensor.IconHighlightDisabledColor = Color.DARK_RED
	else:
		ItemSelection_Sensor.DIS_ENable(true)
		ItemSelection_Sensor.changeVisuals("", Color(MAIN_BACKGROUND_COLOR, 0), ItemSelection_Sensor.size)
		ItemSelection_Sensor.IconHighlightColor = MAIN_BACKGROUND_COLOR
	
	for tile in TileSelections:
		if(toggle):
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			tile.mouse_filter = Control.MOUSE_FILTER_STOP
		#tile.DIS_ENable(!toggle)
	
	for joker in JokerSelections:
		if(toggle):
			joker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			joker.mouse_filter = Control.MOUSE_FILTER_STOP
		#joker.DIS_ENable(!toggle)
	
	for item in ItemSelections:
		if(toggle):
			item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			item.mouse_filter = Control.MOUSE_FILTER_STOP
		#item.DIS_ENable(!toggle)
	
	#if(toggleTiles):
		#move_child($ShopMain_BackGround, 0)
		#if($ShopSelections/TileSelections.get_child_count()-1 >= MAX_TILE_SELECTIONS):
			#$ShopSelections/TileSelections/TileSelections_Highlight.self_modulate = Color(1, 0, 0, 1)
		#else:
			#$ShopSelections/TileSelections/TileSelections_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	#
	#if(toggleJokers):
		#if($ShopSelections/JokerSelections.get_child_count()-1 >= MAX_JOKER_SELECTIONS):
			#$ShopSelections/JokerSelections/JokerSelections_Highlight.self_modulate = Color(1, 0, 0, 1)
		#else:
			#$ShopSelections/JokerSelections/JokerSelections_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	#
	#if(toggleItems):
		#if($ShopSelections/ItemSelections.get_child_count()-1 >= MAX_ITEM_SELECTIONS):
			#$ShopSelections/ItemSelections/TileSelections_Highlight.self_modulate = Color(1, 0, 0, 1)
		#else:
			#$ShopSelections/ItemSelections/TileSelections_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	#
	#if(!toggleItems && !toggleJokers && !toggleTiles):
		#move_child($ShopMain_BackGround, 1)

var freebies: int = 0

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
