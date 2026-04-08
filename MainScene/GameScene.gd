extends Node2D

class_name GameScene

static var Game: GameScene

const CAMERA_WIDE_SHOT_RATIO: float = 3.5

static var myTurn: bool = false

static var bgObfuscator: Sprite2D
static var MainPlayer: Player
static var PlayerBar: GameBar
static var BaitButton: GoodButton
static var PlayerTurnButton: TurnButton
static var Transition_toRiver_Button: GoodButton
static var Transition_BackToBoard_Button: GoodButton
static var DiscardButton: GoodButton
static var GameShop: Shop
static var currSelectScreen: SelectScreen = null

static var usingItem: ItemContainer

signal StartOfRound
signal EndOfRound

func _init() -> void:
	Game = self
	
	MainPlayer = Player.new()
	MainPlayer.name = "MainPlayer"
	add_child(MainPlayer)
	
	bgObfuscator = Sprite2D.new()
	bgObfuscator.texture = CanvasTexture.new()
	bgObfuscator.region_enabled = true
	bgObfuscator.self_modulate = Color.BLACK
	bgObfuscator.self_modulate.a = 0.5
	bgObfuscator.visible = false
	bgObfuscator.name = "bgObfuscator"
	add_child(bgObfuscator)
	
	var bgMouseObfuscator: Control = Control.new()
	bgObfuscator.add_child(bgMouseObfuscator)
	
	PlayerBar = GameBar.new()
	PlayerBar.name = "PlayerBar"
	add_child(PlayerBar)
	
	BaitButton = GoodButton.new(StringsManager.UIStrings["BAIT"]["TEXT"][0]+str(0), Color.TRANSPARENT, GoodButton.ButtonType.BAIT)
	BaitButton.name = "BaitButton"
	add_child(BaitButton)
	
	PlayerTurnButton = TurnButton.new(TurnButton.ButtonAction.SHOP) #GoodButton.new(StringsManager.UIStrings["SHOP"][0], Color.GOLD)
	PlayerTurnButton.name = "TurnButton"
	add_child(PlayerTurnButton)
	
	Transition_toRiver_Button = GoodButton.new("", Color.WHITE, GoodButton.ButtonType.TRANSITION_RIVER, Vector2(-1, -1), load("res://UI/TrabsitionArraows.png"))
	Transition_toRiver_Button.rotation = -PI/2
	Transition_toRiver_Button.scale = Vector2(0.5, 0.5)
	Transition_toRiver_Button.name = "Transition_toRiver_Button"
	add_child(Transition_toRiver_Button)
	
	Transition_BackToBoard_Button = GoodButton.new("", Color.WHITE, GoodButton.ButtonType.TRANSITION_BOARD, Vector2(-1, -1), load("res://UI/TrabsitionArraows.png"))
	Transition_BackToBoard_Button.rotation = PI/2
	Transition_BackToBoard_Button.scale = Vector2(0.5, 0.5)
	Transition_BackToBoard_Button.name = "Transition_BackToBoard_Button"
	add_child(Transition_BackToBoard_Button)
	
	DiscardButton = GoodButton.new("Discard", Color.RED)
	DiscardButton.position = Vector2(10, 40)
	DiscardButton.visible = false
	DiscardButton.name = "DiscardButton"
	add_child(DiscardButton)
	
	GameShop = Shop.new()
	GameShop.visible = false
	GameShop.name = "GameShop"
	add_child(GameShop)
	
	Transition_BackToBoard_Button.press.connect(MainPlayer.moveCamera.bind(Player.CameraPosition.BOARD))
	Transition_toRiver_Button.press.connect(MainPlayer.moveCamera.bind(Player.CameraPosition.RIVER))
	BaitButton.press.connect(func() -> void: 
		if(BeaverTeeth.Beaver_Teeth_Activated):
			Transition_BackToBoard_Button.visible = false
			for tile in River.river:
				tile.DIS_ENable(true)
			
			MainPlayer.moveCamera(Player.CameraPosition.RIVER)
			
			while(BeaverTeeth.chosenRiverTile == null):
				await get_tree().create_timer(0.001).timeout
			
			for tile in River.river:
				tile.DIS_ENable(false)
			
			MainPlayer.Draw_fromRiver(River.bait, BeaverTeeth.chosenRiverTile)
			BeaverTeeth.chosenRiverTile = null
			MainPlayer.moveCamera(Player.CameraPosition.BOARD)
			Transition_BackToBoard_Button.visible = true
			return
		
		MainPlayer.Draw_fromRiver(River.bait))
	
	PlayerTurnButton.resized.connect(func() -> void:
		BaitButton.position = PlayerTurnButton.position
		BaitButton.position.x += PlayerTurnButton.size.x+10
		BaitButton.position.y -= (PlayerTurnButton.size.y - BaitButton.size.y)/2)

func _ready() -> void:
	var windowSize: Vector2 = get_viewport_rect().size
	
	bgObfuscator.region_rect = Rect2(Vector2(0, 0), windowSize)
	bgObfuscator.get_child(0).size = windowSize
	
	MainPlayer.position = Vector2(0, CAMERA_WIDE_SHOT_RATIO*windowSize.y/2 - Board.BOARD_HEIGHT/2)#-----------------------------------------------------------
	MainPlayer.GameRiver.position = Vector2(-River.ROW_WIDTH/2, -MainPlayer.position.y)
	
	bgObfuscator.global_position = MainPlayer.Camera.global_position
	bgObfuscator.get_child(0).global_position = bgObfuscator.global_position - windowSize/2
	
	var PlayerBar_Y: float = MainPlayer.position.y - windowSize.y + Board.BOARD_HEIGHT/2 + (GameBar.SLOT_SIZE.y+5)/2
	PlayerBar.position = Vector2(0, PlayerBar_Y)
	
	Transition_toRiver_Button.position = Vector2(0, PlayerBar_Y) - Vector2(Transition_toRiver_Button.size.y, -Transition_toRiver_Button.size.x)/4
	Transition_toRiver_Button.position.y -= (GameBar.SLOT_SIZE.y+5)/2 - Transition_toRiver_Button.size.x/4
	
	Transition_BackToBoard_Button.position = Vector2(Transition_BackToBoard_Button.size.y/4, windowSize.y/2 - Transition_BackToBoard_Button.size.x)#-Transition_BackToBoard_Button.size.y/2
	
	PlayerTurnButton.position = Vector2(-windowSize.x/2 + PlayerTurnButton.size.x/2 + 5, PlayerBar_Y-5)
	
	BaitButton.position = PlayerTurnButton.position
	BaitButton.position.x += PlayerTurnButton.size.x+10
	BaitButton.position.y -= (PlayerTurnButton.size.y - BaitButton.size.y)/2
	
	GameShop.position = Vector2(-windowSize.x/2, MainPlayer.position.y - windowSize.y + Board.BOARD_HEIGHT/2)
	
	#PlayerBar.addModifier(ArchitectsForge.new())

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("Debug_Draw")):
		var newRiches: Riches = Riches.new()
		newRiches.rounds = 1
		PlayerBar.addModifier(newRiches)
	
	if(usingItem != null):
		usingItem.resource.updateWhileUsing(delta)

func StartRound() -> void:
	myTurn = true
	PlayerTurnButton.changeButtonAction(TurnButton.ButtonAction.END_TURN)#changeVisuals(StringsManager.UIStrings["TURN"][0], Color.BLACK)
	StartOfRound.emit()

static func startItemUse(item: ItemContainer):
	usingItem = item
	
	if(MainPlayer.isDiscarding):
		GameScene.MainPlayer.EN_DISableDiscarding()
		PlayerTurnButton.changeVisuals(StringsManager.UIStrings["TURN"][0], Color.BLACK)
	else:
		MainPlayer.selectedTiles.clear()
		MainPlayer.GameBoard.changeHighlightColor(TileContainer.HIGHLIGHT_BASE_COLOR)
	
	if(item.resource.target == Item.ItemTarget.VIABLE_BOARD_TILE):
		MainPlayer.GameBoard.showViableTiles()
	#if(item.item_info.target == Item.ItemTarget.VIABLE_BOARD_TILE):
		#MainPlayer.show_possible_selections(true)

static func endItemUse() -> void:
	var tempItem: ItemContainer = usingItem
	usingItem = null
	
	if(tempItem.resource.target == Item.ItemTarget.VIABLE_BOARD_TILE):
		MainPlayer.GameBoard.changeHighlightColor(TileContainer.HIGHLIGHT_BASE_COLOR)
	#$Turn_Button.disabled = false
	#$Turn_Button.text = "End Turn"
	
	#if(tempItem.item_info.target == Item.ItemTarget.VIABLE_BOARD_TILE):#Item.hasSpecialHighlight.find(item.item_info.id) >= 0):
		#MainPlayer.show_possible_selections(true)
	
	#PlayerBar.endItemUse(tempItem)

func createSelectionScreen(option: SelectScreen.SelectOption, selectionOptions: Vector3i, flags: Dictionary) -> void:
	currSelectScreen = SelectScreen.new(option, selectionOptions, flags)
	var windowSize: Vector2 = get_viewport_rect().size
	currSelectScreen.position = MainPlayer.position
	currSelectScreen.position.y += Board.BOARD_HEIGHT/2 - windowSize.y/2 
	add_child(currSelectScreen)

func EndRound() -> void:
	myTurn = false
	PlayerTurnButton.changeButtonAction(TurnButton.ButtonAction.SHOP)
	EndOfRound.emit()
	
	NextPlayer()

##Will have greater multiplayer functionality in the future
func NextPlayer() -> void:
	MainPlayer.PlayerDeck.DIS_ENable(true)

#func onTurnButtonPressed() -> void:
	#if(!myTurn):
		#GameShop.visible = true
	#else:
		#MainPlayer.EN_DISableDiscarding()
		#
		#if(Player.isDiscarding):
			#TurnButton.changeVisuals(StringsManager.UIStrings["TURN"][1], Color.RED)
		#else:
			#TurnButton.changeVisuals(StringsManager.UIStrings["TURN"][0], Color.BLACK)
