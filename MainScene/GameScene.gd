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
#static var Transition_toRiver_Button: GoodButton
static var Transition_BackToBoard_Button: GoodButton
static var DiscardButton: GoodButton
static var GameShop: Shop
static var currSelectScreen: SelectScreen = null

static var usingItem: ItemContainer
static var interPlayer_rotationStep: float
static var BoardRadius: float

static var inProximity_ofTransButton: bool = false

signal StartOfRound
signal EndOfRound

func _init() -> void:
	modulate = Color(0, 0, 0)
	Game = self
	
	MainPlayer = Player.new(MultiplayerHandler.currPlayer)
	MainPlayer.name = "MainPlayer"
	add_child(MainPlayer)
	
	if(MultiplayerHandler.currPlayer != null && MultiplayerHandler.players.size() > 0):
		MultiplayerHandler.receivedData.connect(handlePlayerCommands)
		MultiplayerHandler.currPlayer.playerSpace = MainPlayer
		interPlayer_rotationStep = 2*PI/MultiplayerHandler.players.size()
		
		var otherPlayer: Player
		
		for player in MultiplayerHandler.players:
			if(player == MultiplayerHandler.currPlayer):
				continue
			
			otherPlayer = Player.new(player)
			otherPlayer.name = "Player_" + str(player.ID)
			add_child(otherPlayer)
			
			player.playerSpace = otherPlayer
			
	
	if(MultiplayerHandler.players.size() > 1):
		pass
	
	bgObfuscator = Sprite2D.new()
	bgObfuscator.texture = CanvasTexture.new()
	bgObfuscator.region_enabled = true
	bgObfuscator.self_modulate = Color.BLACK
	bgObfuscator.self_modulate.a = 1
	bgObfuscator.z_index = 2
	bgObfuscator.visible = true
	bgObfuscator.name = "bgObfuscator"
	add_child(bgObfuscator)
	
	var bgMouseObfuscator: Control = Control.new()
	bgObfuscator.add_child(bgMouseObfuscator)
	
	PlayerBar = GameBar.new()
	PlayerBar.name = "PlayerBar"
	add_child(PlayerBar)
	
	BaitButton = GoodButton.new(StringsManager.UIStrings["BAIT"]["TEXT"][0]+str(0), Color.TRANSPARENT, Vector2(-1, -1), null, true, ButtonCallables.Callables["BAIT"]["NAME"], ButtonCallables.Callables["BAIT"]["KEYWORDS"], ButtonCallables.Callables["BAIT"]["DESCRIPTION"])#, GoodButton.ButtonType.BAIT
	BaitButton.name = "BaitButton"
	add_child(BaitButton)
	
	PlayerTurnButton = TurnButton.new(TurnButton.ButtonAction.SHOP) #GoodButton.new(StringsManager.UIStrings["SHOP"][0], Color.GOLD)
	PlayerTurnButton.name = "TurnButton"
	add_child(PlayerTurnButton)
	
	#Transition_toRiver_Button = Transition.new(Transition.Target.RIVER, -PI/2, -1, false)#, GoodButton.ButtonType.TRANSITION_RIVER
	#Transition_toRiver_Button.rotation = -PI/2
	#Transition_toRiver_Button.scale = Vector2(0.5, 0.5)
	#Transition_toRiver_Button.name = "Transition_toRiver_Button"
	#add_child(Transition_toRiver_Button)
	
	Transition_BackToBoard_Button = Transition.new(Transition.Target.BOARD, PI/2, -1, false)#, GoodButton.ButtonType.TRANSITION_BOARD
	#Transition_BackToBoard_Button.rotation = PI/2
	#Transition_BackToBoard_Button.scale = Vector2(0.5, 0.5)
	Transition_BackToBoard_Button.name = "Transition_BackToBoard_Button"
	add_child(Transition_BackToBoard_Button)
	
	#DiscardButton = GoodButton.new("Discard", Color.RED)
	#DiscardButton.position = Vector2(10, 40)
	#DiscardButton.visible = false
	#DiscardButton.name = "DiscardButton"
	#add_child(DiscardButton)
	
	GameShop = Shop.new()
	GameShop.visible = false
	GameShop.name = "GameShop"
	add_child(GameShop)
	
	Transition_BackToBoard_Button.press.connect(MainPlayer.moveCamera.bind(Player.CameraPosition.BOARD))
	#Transition_toRiver_Button.press.connect(MainPlayer.moveCamera.bind(Player.CameraPosition.RIVER))
	BaitButton.press.connect(func() -> void: 
		if(BeaverTeeth.Beaver_Teeth_Activated):
			Transition_BackToBoard_Button.visible = false
			for tile in River.river:
				tile.enabled = true
			
			MainPlayer.moveCamera(Player.CameraPosition.RIVER)
			
			while(BeaverTeeth.chosenRiverTile == null):
				await get_tree().create_timer(0.001).timeout
			
			for tile in River.river:
				tile.enabled = false
			
			MainPlayer.Draw_fromRiver(River.bait, BeaverTeeth.chosenRiverTile)
			BeaverTeeth.chosenRiverTile = null
			MainPlayer.moveCamera(Player.CameraPosition.BOARD)
			Transition_BackToBoard_Button.visible = true
			return
		
		MainPlayer.Draw_fromRiver(River.bait))
	
		#inProximity_ofTransButton = true
		#
		#if(proxmityTween != null && proxmityTween.is_running()):
			#proxmityTween.stop()
		#
		#if(!falsePositive):
			#SpreadCameraTransition.visible = true
			#SpreadCameraTransition.modulate.a = 0
		#
		#proxmityTween = create_tween()
		#proxmityTween.tween_property(SpreadCameraTransition, "modulate:a", 1, 1-SpreadCameraTransition.modulate.a))
	#SpreadTransition_ProximitySensor.mouse_exited.connect(_mouse_outsideProximity)
	
	PlayerTurnButton.resized.connect(func() -> void:
		BaitButton.position = PlayerTurnButton.position
		BaitButton.position += (PlayerTurnButton.size.x+10)*Vector2(cos(BaitButton.rotation), sin(BaitButton.rotation))
		BaitButton.position -= (PlayerTurnButton.size.y - BaitButton.size.y)*Vector2(-sin(BaitButton.rotation), cos(BaitButton.rotation))/2)

func _ready() -> void:
	create_tween().tween_property(self, "modulate", Color(1, 1, 1), 2)
	var windowSize: Vector2 = get_viewport_rect().size
	
	bgObfuscator.region_rect = Rect2(Vector2(0, 0), windowSize)
	bgObfuscator.get_child(0).size = windowSize
	
	BoardRadius = CAMERA_WIDE_SHOT_RATIO*windowSize.y/2 - Board.BOARD_HEIGHT/2
	
	var mainPlayerRot: float
	for player in MultiplayerHandler.players:
		player.playerSpace.rotation = -player.order*interPlayer_rotationStep
		if(player == MultiplayerHandler.currPlayer):
			mainPlayerRot = player.playerSpace.rotation
		
		player.playerSpace.position = Vector2(BoardRadius*sin(-player.playerSpace.rotation), BoardRadius*cos(-player.playerSpace.rotation))
	
	#MainPlayer.rotation = -MultiplayerHandler.currPlayer.order*interPlayer_rotationStep
	#MainPlayer.position = Vector2(BoardRadius*sin(MultiplayerHandler.currPlayer.order*interPlayer_rotationStep), BoardRadius*cos(MultiplayerHandler.currPlayer.order*interPlayer_rotationStep))#-----------------------------------------------------------
	
	MainPlayer.GameRiver.position = Vector2(-River.ROW_WIDTH/2, -MainPlayer.position.y)
	
	bgObfuscator.global_position = MainPlayer.Camera.global_position
	bgObfuscator.get_child(0).global_position = bgObfuscator.global_position - windowSize/2
	
	PlayerBar.rotation = mainPlayerRot
	PlayerBar.position = MainPlayer.position
	PlayerBar.position -= (windowSize.y - (Board.BOARD_HEIGHT + GameBar.SLOT_SIZE.y + 5)/2)*Vector2(-sin(mainPlayerRot), cos(mainPlayerRot))
	#var PlayerBarRadius: float = MainPlayer.position.y - windowSize.y + Board.BOARD_HEIGHT/2 + (GameBar.SLOT_SIZE.y+5)/2
	#PlayerBar.position = Vector2(0, PlayerBar_Y)
	#PlayerBar.position = PlayerBarRadius*Vector2(-sin(mainPlayerRot), cos(mainPlayerRot))
	
	#MainPlayer.PlayerAtuu.global_position = PlayerBar.global_position
	#MainPlayer.PlayerAtuu.position -= MainPlayer.PlayerAtuu.scale*TileContainer.BASE_RESOURCE_SIZE/2# (MainPlayer.PlayerAtuu.size - Vector2(MainPlayer.PlayerAtuu.FRAME_EXTRA_SIZE, MainPlayer.PlayerAtuu.FRAME_EXTRA_SIZE)/2)/2
	
	GameShop.rotation = mainPlayerRot
	#GameShop.position = MainPlayer.position
	GameShop.global_position = MainPlayer.Camera.global_position
	GameShop.position -= windowSize.x/2 * Vector2(cos(mainPlayerRot), sin(mainPlayerRot))
	GameShop.position -= windowSize.y/2 * Vector2(-sin(mainPlayerRot), cos(mainPlayerRot))
	
	#var button_y: float
	#var buttonIndex: int = 0
	#for playerButton in PlayerButtons:
		#playerButton.rotation = mainPlayerRot
		#playerButton.position = PlayerBar.position - (windowSize.x/2 - 10)*Vector2(cos(mainPlayerRot), sin(mainPlayerRot)) + ((GameBar.SLOT_SIZE.y+15)/2 + (15+playerButton.CameraTransition.size.y)*buttonIndex)*Vector2(-sin(mainPlayerRot), cos(mainPlayerRot))
		#buttonIndex += 1
	
	#Transition_toRiver_Button.rotation = mainPlayerRot - PI/2
	#Transition_toRiver_Button.position = PlayerBar.position
	#Transition_toRiver_Button.position -= buttonSize.y*Vector2(cos(mainPlayerRot), sin(mainPlayerRot))/2 + buttonSize.x*Vector2(sin(mainPlayerRot), -cos(mainPlayerRot))/2
	#Transition_toRiver_Button.position = Vector2(0, PlayerBar_Y) - Vector2(Transition_toRiver_Button.size.y, -Transition_toRiver_Button.size.x)/4
	#Transition_toRiver_Button.position -= ((GameBar.SLOT_SIZE.y+5) - buttonSize.x)*Vector2(-sin(mainPlayerRot), cos(mainPlayerRot))/2
	
	var buttonSize: Vector2 = Transition_BackToBoard_Button.size
	Transition_BackToBoard_Button.position = Vector2(buttonSize.y/2, windowSize.y/2 - 2*buttonSize.x)#-Transition_BackToBoard_Button.size.y/2
	
	buttonSize = PlayerTurnButton.size
	PlayerTurnButton.rotation = mainPlayerRot
	PlayerTurnButton.position = PlayerBar.position - 5*Vector2(-sin(mainPlayerRot), cos(mainPlayerRot))
	#PlayerTurnButton.position = (PlayerBarRadius-5)*Vector2(-sin(mainPlayerRot), cos(mainPlayerRot)) + (-windowSize.x/2 + buttonSize.x/2 + 5)*Vector2(cos(mainPlayerRot), sin(mainPlayerRot))
	#PlayerTurnButton.position = Vector2(-windowSize.x/2 + PlayerTurnButton.size.x/2 + 5, PlayerBar_Y-5)
	PlayerTurnButton.position += ((buttonSize.x - windowSize.x)/2 + 5)*Vector2(cos(mainPlayerRot), sin(mainPlayerRot))
	
	BaitButton.rotation = mainPlayerRot
	BaitButton.position = PlayerTurnButton.position
	BaitButton.position += (buttonSize.x+10)*Vector2(cos(mainPlayerRot), sin(mainPlayerRot))
	BaitButton.position -= (buttonSize.y - BaitButton.size.y)*Vector2(-sin(mainPlayerRot), cos(mainPlayerRot))/2
	
	#GameShop.position = Vector2(-windowSize.x/2, MainPlayer.position.y - windowSize.y + Board.BOARD_HEIGHT/2)
	
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
	#if()
	if(myTurn):
		myTurn = false
		PlayerTurnButton.changeButtonAction(TurnButton.ButtonAction.SHOP)
		EndOfRound.emit()
		
		MultiplayerHandler.send_data("round_end", "round_end".to_utf8_buffer())
	
	if(MultiplayerHandler.players.size() > 0):
		#var rotStep: float = 2*PI/MultiplayerHandler.players.size()
		
		MultiplayerHandler.player_currTurn += 1
		
		var tween: Tween = create_tween()
		tween.tween_method(func(newRot: float) -> void:
			MainPlayer.GameBoard.rotation = newRot
			MainPlayer.GameBoard.global_position =  Vector2(BoardRadius*sin(-newRot), BoardRadius*cos(-newRot))
		, MainPlayer.GameBoard.rotation, MainPlayer.GameBoard.rotation-interPlayer_rotationStep, 1)
	
	NextPlayer()

##Will have greater multiplayer functionality in the future
func NextPlayer() -> void:
	MainPlayer.PlayerDeck.enabled = true

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

func handlePlayerCommands(source: String, command: String, params: PackedByteArray) -> void:
	match command:
		"round_end":
			EndRound()
		"draw":
			MultiplayerHandler.getPlayer_byID(int(source)).playerSpace.receive_otherPlayer_draw(params.get_string_from_utf8())
		"tile_moved":
			Player.GameBoard.otherPlayer_movedTile(params.get_string_from_utf8())
		"spread":
			var spreadRow: Array[TileContainer] = Player.GameBoard.getTiles_fromMessage(params.get_string_from_utf8())
			MainPlayer.getPlayerButton(int(source)).miniSpreadView(spreadRow)
			MultiplayerHandler.getPlayer_byID(int(source)).playerSpace.SpreadButtonPressed(false, spreadRow)
