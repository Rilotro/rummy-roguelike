extends Node2D

class_name Player

const PLAYER_CONTAINER: ResourceContainer.ContainerType = ResourceContainer.ContainerType.PLAYER_TILE#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#const BOARD_SPACE: TileContainer.PlayerSpace = TileContainer.PlayerSpace.BOARD
#const SPREAD_SPACE: TileContainer.PlayerSpace = TileContainer.PlayerSpace.SPREAD
#const RIVER_SPACE: TileContainer.PlayerSpace = TileContainer.PlayerSpace.RIVER


static var GameBoard: Board
var SpreadAndBoard_Transition_ProximitySensor: Control
var SpreadCameraTransition: Transition
var BoardCameraTransition: Transition
var PlayerButtons: Array[PlayerTransition]
var PlayerSpread: Spread
var GameRiver: River
#var PlayerDeck: Deck
var otherPlayerDeck: Sprite2D
var Camera: Camera2D
var SpreadButton: GoodButton
var DiscardButton: GoodButton
var ExpBar: ExperienceBar
var PlayerAtuu: Atuu
var PlayerTurnAnnouncer: Label

static var selectedTiles: Array[TileContainer]
static var isDiscarding: bool = false
static var minMAXTilesToDiscard: Vector2i = Vector2i(1, 2)

var inProximity: bool = false
var currentCameraPos: CameraPosition = CameraPosition.BOARD

var isMainPlayer: bool = true
var hasBoard: bool = false

var hasStartedTurn: bool = false

signal PlayerDraw(fromDeck: bool)

enum CameraPosition{
	BOARD, SPREAD, ALL_PLAYERS, RIVER
}

func _init(player: PlayerData = null) -> void:
	isMainPlayer = player == MultiplayerHandler.currPlayer
	#var testArray1: Array[Tile] = [Tile.new(1, Color.BLACK), Tile.new(2, Color.BLUE), Tile.new(3, Color.RED), Tile.new(4, Color.GREEN)]
	#var testArray2: Array[Tile]
	#testArray2.append_array(testArray1)
	#print(testArray1)
	#print(testArray2)
	#
	#testArray1.remove_at(1)
	#testArray2.remove_at(2)
	#
	#print(testArray1)
	#print(testArray2)
	
	SpreadAndBoard_Transition_ProximitySensor = Control.new()
	SpreadAndBoard_Transition_ProximitySensor.name = "SpreadAndBoard_Transition_ProximitySensor"
	add_child(SpreadAndBoard_Transition_ProximitySensor)
	
	ExpBar = ExperienceBar.new()
	ExpBar.name = "ExperienceBar"
	add_child(ExpBar)
	
	#if(isMainPlayer):
	var id: int = -1
	if(player != null):
		id = player.ID
	
	SpreadCameraTransition = Transition.new(Transition.Target.SPREAD, 0, id)
	SpreadCameraTransition.name = "SpreadCameraTransition"
	SpreadCameraTransition.enabled = false
	#SpreadCameraTransition.visible = false
	add_child(SpreadCameraTransition)
	
	BoardCameraTransition = Transition.new(Transition.Target.BOARD, PI, id)
	BoardCameraTransition.name = "BoardCameraTransition"
	BoardCameraTransition.enabled = false
	#BoardCameraTransition.visible = false
	add_child(BoardCameraTransition)
	
	hasBoard = (player == null || player.order == 0)
	if(hasBoard):
		GameBoard = Board.new()
		GameBoard.name = "GameBoard"
		add_child(GameBoard)
	
	PlayerSpread = Spread.new()
	PlayerSpread.name = "PlayerSpread"
	add_child(PlayerSpread)
	
	if(isMainPlayer):
		var newPlayerButton: PlayerTransition
		for playerData in MultiplayerHandler.players:
			if(playerData == player):
				continue
			
			newPlayerButton = PlayerTransition.new(playerData.ID)
			newPlayerButton.modulate.a = 0.5
			newPlayerButton.name = "PlayerButton-" + str(playerData.ID)
			PlayerButtons.append(newPlayerButton)
			add_child(newPlayerButton)
		
		GameRiver = River.new()
		GameRiver.name = "GameRiver"
		add_child(GameRiver)
		
		#PlayerDeck = Deck.new()
		#PlayerDeck.name = "PlayerDeck"
		#PlayerDeck.position = Vector2(-Board.BOARD_WIDTH/2 + Board.SPACE_BETWEEN_TILES, -(Board.BOARD_HEIGHT)*(Board.STARTING_BOARD_ROWS-0.5) - ResourceContainer.BASE_RESOURCE_SIZE.y - 10)
		#add_child(PlayerDeck)
		
		Camera = Camera2D.new()
		Camera.ignore_rotation = false
		Camera.position = Vector2(0, -264.0)
		add_child(Camera)
		
		SpreadButton = GoodButton.new("Spread!", Color.GOLD, Vector2(-1, -1), null, false, ButtonCallables.Callables["SPREAD"]["NAME"], ButtonCallables.Callables["SPREAD"]["KEYWORDS"], ButtonCallables.Callables["SPREAD"]["DESCRIPTION"])#, GoodButton.ButtonType.SPREAD
		SpreadButton.DisabledColor = Color.TRANSPARENT
		SpreadButton.text_color = Color.TRANSPARENT
		SpreadButton.enabled = false
		SpreadButton.position = Vector2(200, -240)
		SpreadButton.name = "SpreadButton"
		add_child(SpreadButton)
		SpreadButton.press.connect(SpreadButtonPressed)
		
		DiscardButton = GoodButton.new("Discard!", Color.RED, Vector2(-1, -1), null, true, ButtonCallables.Callables["DISCARD"]["NAME"], ButtonCallables.Callables["DISCARD"]["KEYWORDS"], ButtonCallables.Callables["DISCARD"]["DESCRIPTION"])#, GoodButton.ButtonType.DISCARD
		DiscardButton.position = Vector2(-200, -240)
		DiscardButton.name = "DiscardButton"
		DiscardButton.visible = false
		add_child(DiscardButton)
		DiscardButton.press.connect(DiscardButtonPressed)
		
		PlayerAtuu = Atuu.new()
		PlayerAtuu.position = Camera.position
		PlayerAtuu.z_index = 3
		PlayerAtuu.name = "PlayerAtuu"
		add_child(PlayerAtuu)
		
		PlayerTurnAnnouncer = Label.new()
		PlayerTurnAnnouncer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		PlayerTurnAnnouncer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		PlayerTurnAnnouncer.add_theme_font_size_override("font_size", 100)
		PlayerTurnAnnouncer.name = "PlayerTurnAnnouncer"
		Camera.add_child(PlayerTurnAnnouncer)
	else:
		var newPlayerButton: PlayerTransition
		newPlayerButton = PlayerTransition.new(MultiplayerHandler.currPlayer.ID)
		newPlayerButton.modulate.a = 0.5
		newPlayerButton.name = "PlayerButton-" + str(MultiplayerHandler.currPlayer.ID)
		PlayerButtons.append(newPlayerButton)
		add_child(newPlayerButton)
		
		otherPlayerDeck = Sprite2D.new()
		otherPlayerDeck.region_enabled = true
		otherPlayerDeck.region_rect = Rect2(Vector2(), ResourceContainer.BASE_RESOURCE_SIZE)
		otherPlayerDeck.texture = CanvasTexture.new()
		otherPlayerDeck.name = "otherPlayerDeck"
		otherPlayerDeck.position = Vector2(-Board.BOARD_WIDTH/2 + Board.SPACE_BETWEEN_TILES, -(Board.BOARD_HEIGHT)*(Board.STARTING_BOARD_ROWS-0.5) - ResourceContainer.BASE_RESOURCE_SIZE.y - 10)
		add_child(otherPlayerDeck)
		
		#SpreadCameraTransition.press.connect(func() -> void:
			#if(currentCameraPos != CameraPosition.SPREAD):
				#moveCamera(CameraPosition.SPREAD)
			#else:
				#moveCamera(CameraPosition.BOARD))
		
		#SpreadTransition_ProximitySensor.mouse_entered.connect(_mouse_inProximity)
		#SpreadTransition_ProximitySensor.mouse_exited.connect(_mouse_outsideProximity)
	
	SpreadAndBoard_Transition_ProximitySensor.mouse_entered.connect(func() -> void:
		SpreadCameraTransition.enabled = true
		BoardCameraTransition.enabled = true)
	
	SpreadAndBoard_Transition_ProximitySensor.mouse_exited.connect(func() -> void:
		await get_tree().create_timer(0.0001).timeout
		if(!SpreadCameraTransition.mouse_inside):
			SpreadCameraTransition.enabled = false
		
		if(!BoardCameraTransition.mouse_inside):
			BoardCameraTransition.enabled = false)

#var SpreadCameraTransition_positionBoard: Vector2
#var SpreadCameraTransition_positionSpread: Vector2

#func _ready() -> void:
	#var windowSize: Vector2 = get_viewport_rect().size
	

#var playerTypedLetters: Array[String]
#
#func _input(event: InputEvent) -> void:
	#if(event is InputEventKey && event.is_pressed()):
		#playerTypedLetters.append(event.as_text())
		#print("HERE0 - " + str(playerTypedLetters))

func window_size_changed() -> void:
	var ExpBar_Y: float = -GameScene.window_size.y + Board.BOARD_HEIGHT/2 + ExperienceBar.BAR_SIZE.y/2 + GameBar.SLOT_BAR_SIZE.y+5
	ExpBar.position = Vector2(0, ExpBar_Y)
	
	var PlayerSpread_posX: float = GameScene.window_size.x + Spread.ROW_WIDTH/2# + 420
	PlayerSpread.position = Vector2(PlayerSpread_posX, 0)
	
	var start_y: float = -GameScene.window_size.y + Board.BOARD_HEIGHT/2 + GameBar.SLOT_SIZE.y+5 + 10
	for button in PlayerButtons:
		button.position = Vector2(10-GameScene.window_size.x/2, start_y)
		
		start_y += button.CameraTransition.size.y + 10
	
	SpreadCameraTransition.position = Vector2(GameScene.window_size.x/2 - SpreadCameraTransition.size.x-10, -(GameScene.window_size.y - Board.BOARD_HEIGHT + SpreadCameraTransition.size.y)/2)
	BoardCameraTransition.position = SpreadCameraTransition.position + Vector2(PlayerSpread.position.x - GameScene.window_size.x + SpreadCameraTransition.size.x + 20, 0)
	BoardCameraTransition.position += BoardCameraTransition.size
	
	SpreadAndBoard_Transition_ProximitySensor.size = Vector2(515, GameScene.window_size.y)
	var posX: float = SpreadCameraTransition.position.x - (SpreadAndBoard_Transition_ProximitySensor.size.x - SpreadCameraTransition.size.x - 10)/2
	SpreadAndBoard_Transition_ProximitySensor.position = Vector2(posX, Board.BOARD_HEIGHT/2 - GameScene.window_size.y)
	SpreadAndBoard_Transition_ProximitySensor.size.x = 700
	
	if(isMainPlayer):
		PlayerTurnAnnouncer.size = GameScene.window_size
		PlayerTurnAnnouncer.position -= PlayerTurnAnnouncer.size/2
		PlayerTurnAnnouncer.position.x -= GameScene.window_size.x
		
		var AtuuScale: float = GameScene.window_size.y/(TileContainer.BASE_RESOURCE_SIZE.y + Atuu.FRAME_EXTRA_SIZE)
		PlayerAtuu.scale = Vector2(AtuuScale, AtuuScale)
		PlayerAtuu.position -= AtuuScale*TileContainer.BASE_RESOURCE_SIZE/2
		handleStartGameAtuu(GameScene.window_size)
		
		#Draw(14)
		#PlayerDeck.DIS_ENable(true)
	
	if(hasBoard):
		GameBoard.position.y = -GameScene.window_size.y
		
		var boardTween: Tween = create_tween()
		boardTween.tween_property(GameBoard, "position:y", 0, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).set_delay(0.1)
		#if(isMainPlayer):
			#boardTween.finished.connect(func() ->void:
				#Draw(14)
				#PlayerDeck.enabled = true
				#)
	
	#var bytes1: PackedByteArray = var_to_bytes(inst_to_dict(test1))
	#test1 = dict_to_inst(bytes_to_var(bytes1))
	#var sentTile: Tile = PlayerDeck.DeckTiles[0]
	#print("Info on sent Tile: " + str(sentTile.number) + ", " + str(sentTile.color))
	#LlmpTest.send_data("tile", var_to_bytes(inst_to_dict(sentTile)))

func handleStartGameAtuu(screenSize: Vector2) -> void:
	await PlayerAtuu.startGameCycle()
	
	var atuuScale: float = GameScene.PlayerBar.Body.region_rect.size.y/(Atuu.BASE_RESOURCE_SIZE.y+Atuu.FRAME_EXTRA_SIZE)
	var atuuPos: Vector2 = -atuuScale*Atuu.BASE_RESOURCE_SIZE/2
	atuuPos.y += Board.BOARD_HEIGHT/2 - screenSize.y + GameScene.PlayerBar.Body.region_rect.size.y/2
	
	var startGame_endSequenceTween: Tween = create_tween().set_parallel()
	startGame_endSequenceTween.tween_property(GameScene.bgObfuscator, "self_modulate:a", 0, 1)
	startGame_endSequenceTween.tween_property(PlayerAtuu, "scale", Vector2(atuuScale, atuuScale), 1)
	startGame_endSequenceTween.tween_property(PlayerAtuu, "position", atuuPos, 1)
	
	await startGame_endSequenceTween.finished
	
	GameScene.bgObfuscator.visible = false
	GameScene.bgObfuscator.self_modulate.a = 100.0/255.0
	PlayerAtuu.z_index = 1
	if(hasBoard):
		PlayerAtuu.enabled = true
	
	GameScene.NextPlayer()
	
	GameScene.GameShop.reloadShop()

func _process(delta: float) -> void:
	#print("HERE0 - " + str(GameRiver.global_position))
	if(Input.is_action_just_pressed("Debug_Draw") && isMainPlayer):
		Draw()
		#ExpBar.gainExperience(100)
	
	#ExperienceTest.currScore += 1
	#if(falsePositive):
		#var distances: Vector2 = SpreadTransition_ProximitySensor.size
		#var mousePos: Vector2 = get_global_mouse_position()
		#var sensorPos: Vector2 = SpreadTransition_ProximitySensor.global_position
		#var diffPos: Vector2 = mousePos - sensorPos
		#
		#if(diffPos.x < 0 || diffPos.x > distances.x || diffPos.y < 0 || diffPos.y > distances.y):
			#falsePositive = false
			#_mouse_outsideProximity()

func getPlayerButton(playerID: int) -> PlayerTransition:
	for PB in PlayerButtons:
		if(PB.playerID == playerID):
			return PB
	
	return null

func Draw(drawNumber: int = 1) -> void:
	PlayerDraw.emit(true)
	if(drawNumber <= 0):
		return
	
	#var tilesDrawn: Array[Tile] = PlayerAtuu.Draw(drawNumber)
	PlayerAtuu.Draw(drawNumber)
	#if(drawNumber > PlayerDeck.DeckTiles.size()):
		#drawNumber = PlayerDeck.DeckTiles.size()
	
	#var lastTile: Tile
	#var drwanTiles: Array[Tile]
	#
	#var tileStrings: String = ""
	#var newTile: TileContainer
	#for tile in tilesDrawn:
		##THE BACK IS NOT PlayerDeck.DeckTiles[0]!!!
		#lastTile = PlayerDeck.popTile(true)
		#drwanTiles.append(lastTile)
		#newTile = TileContainer.new(lastTile)
		#
		#var tilePos: Vector2i = GameBoard.addTile(newTile)
		#
		#if(!tileStrings.is_empty()):
			#tileStrings += "::"
		#
		#tileStrings += str(lastTile) + ":" + str(tilePos.x) + ":" + str(tilePos.y)
	

func receive_otherPlayer_draw(drawnTiles_str: String) -> void:
	var drawSize: int = int(drawnTiles_str.get_slice("::", 0))
	
	var newTile: Tile
	var tilePos: Vector2i
	var argv: Array
	for i in range(drawSize):
		argv = Tile._from_str(drawnTiles_str.get_slice("::", i+1), true)
		newTile = argv[0]
		tilePos = argv[1]
		
		Player.GameBoard.addTile(TileContainer.new(newTile), Board.TileOrigin.OTHER_PLAYER, tilePos, self)

func Draw_fromRiver(baitAmmount: int = 0, startingTile: TileContainer = null) -> void:
	if(baitAmmount <= 0):
		return
	
	PlayerDraw.emit(false)
	River.bait = 0
	
	#GameScene.BaitButton.changeVisuals(StringsManager.UIStrings["BAIT"]["TEXT"][0]+str(0))
	
	var startingIndex: int = River.river.find(startingTile)
	if(startingIndex < 0):
		startingIndex = River.river.size()-1
	
	var drawFromDeck: int = baitAmmount - startingIndex - 1
	if(baitAmmount > startingIndex + 1):
		baitAmmount = startingIndex + 1
	
	#print("HERE1 - " + str(baitAmmount))
	
	GameRiver.Draw(baitAmmount, startingTile)
	
	Draw(drawFromDeck)

static var currentSpreadEligibility: Spread_Info.SpreadCheck

func tilePressed(tile: TileContainer) -> void:
	if(selectedTiles.has(tile)):
		selectedTiles.erase(tile)
	else:
		selectedTiles.append(tile)
	
	GameBoard.SpreadHelper(selectedTiles)
		
	if(selectedTiles.size() == 0):
		SpreadButton.enabled = false
		SpreadButton.text_color = Color.TRANSPARENT
	else:
		SpreadButton.enabled = true
		#SpreadButton.DisabledColor
		SpreadButton.text_color = Color.BLACK
		
		currentSpreadEligibility = Spread_Info.getSpreadEligibility(selectedTiles)
		match currentSpreadEligibility:
			Spread_Info.SpreadCheck.ELIGIBLE:
				SpreadButton.enabled = true
				SpreadButton.text_color = Color.BLACK
				SpreadButton.text = StringsManager.UIStrings["SPREAD"]["TEXT"][0]
				#SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][0], SpreadButton.IconOrigColor)
			Spread_Info.SpreadCheck.SHORT:
				SpreadButton.enabled = false
				SpreadButton.text_color = Color.TRANSPARENT
				SpreadButton.text = StringsManager.UIStrings["SPREAD"]["TEXT"][1]
				#SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][1], SpreadButton.IconOrigColor)
			Spread_Info.SpreadCheck.VAGUE:
				SpreadButton.enabled = false
				SpreadButton.text_color = Color.TRANSPARENT
				SpreadButton.text = StringsManager.UIStrings["SPREAD"]["TEXT"][2]
				#SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][2], SpreadButton.IconOrigColor)
			Spread_Info.SpreadCheck.NO_PATTERN:
				SpreadButton.enabled = false
				SpreadButton.text_color = Color.TRANSPARENT
				SpreadButton.text = StringsManager.UIStrings["SPREAD"]["TEXT"][3]
				#SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][3], SpreadButton.IconOrigColor)
			Spread_Info.SpreadCheck.DUPLICATE_COLOR:
				SpreadButton.enabled = false
				SpreadButton.text_color = Color.TRANSPARENT
				SpreadButton.text = StringsManager.UIStrings["SPREAD"]["TEXT"][4]
				#SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][4], SpreadButton.IconOrigColor)
			Spread_Info.SpreadCheck.TOO_MANY_COLORS:
				SpreadButton.enabled = false
				SpreadButton.text_color = Color.TRANSPARENT
				SpreadButton.text = StringsManager.UIStrings["SPREAD"]["TEXT"][5]
				#SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][5], SpreadButton.IconOrigColor)
			Spread_Info.SpreadCheck.SEQUENCE_OOB:
				SpreadButton.enabled = false
				SpreadButton.text_color = Color.TRANSPARENT
				SpreadButton.text = StringsManager.UIStrings["SPREAD"]["TEXT"][6]
				#SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][6], SpreadButton.IconOrigColor)

var spreadFinishCount: int = 0

func SpreadButtonPressed(byMainPlayer: bool = true, overrideSelectedTiles: Array[TileContainer] = []) -> void:
	if(byMainPlayer):
		SpreadButton.enabled = false
		SpreadButton.text_color = Color.TRANSPARENT
	
	var spreadSpaceSum: float = TileContainer.BASE_RESOURCE_SIZE.x + Spread_Info.SPREAD_SPACING
	var startPosx: float = -(spreadSpaceSum*(selectedTiles.size()-1) + TileContainer.BASE_RESOURCE_SIZE.x)/2
	var spreadTween: Tween = create_tween()
	var spreadDelay: float = 0
	var tempSelectedTiles: Array[TileContainer]
	if(overrideSelectedTiles.is_empty()):
		tempSelectedTiles = selectedTiles.duplicate()
	else:
		tempSelectedTiles = overrideSelectedTiles
	
	if(byMainPlayer):
		var tilePosMessage: String = str(tempSelectedTiles.size())
		var tempPos: Vector2i
		
		for tile in tempSelectedTiles:
			tempPos = GameBoard.getTilePos(tile)
			tilePosMessage += "::" + str(tempPos.x) + ":" + str(tempPos.y)
		
		MultiplayerHandler.send_data("spread", tilePosMessage.to_utf8_buffer())
	
	spreadTween.set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	if(byMainPlayer):
		selectedTiles.clear()
		
		for Row in GameBoard.BoardRows:
			for tile: TileContainer in Row:
				if(tile == null):
					continue
				
				tile.flash(false)
	
	for tile in tempSelectedTiles:
		tile.enabled = false
		tile.z_index = 1
		tile.show_count(-1)
		tile._mouse_exited()
		tile.reparent(self)
		GameBoard.removeTile(tile)
		
		spreadTween.tween_property(tile, "position", Vector2(startPosx, -300), 0.4).set_delay(spreadDelay)
		
		spreadDelay += 0.1
		startPosx += spreadSpaceSum
	
	await spreadTween.finished
	
	spreadFinishCount = 0
	
	for tile in tempSelectedTiles:
		await tile.activate()
	
	while(spreadFinishCount < tempSelectedTiles.size()):
		await get_tree().create_timer(0.001).timeout
	
	spreadTween = create_tween()
	spreadTween.tween_property(TileContainer.pointSumBubble, "position", ExpBar.position, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	spreadTween.finished.connect(func() -> void:
		TileContainer.pointSumBubble.queue_free()
		
		ExpBar.gainExperience(TileContainer.currPointSum)
		
		TileContainer.currPointSum = 0
		TileContainer.currPointVal = 0
		
		PlayerSpread.SpreadTiles(tempSelectedTiles))
	#selectedTiles.clear()
	
	#var tilePoses_string: String = str(selectedTiles.size()) + "::"
	#var tilePose: Vector2i
	#for tile in selectedTiles:
		#tilePose = GameBoard.getTilePos(tile)
		#tilePoses_string += str(tilePose.x) + ":" + str(tilePose.y)
		#if(tile != selectedTiles[selectedTiles.size()-1]):
			#tilePoses_string += "::"
	#
	#MultiplayerHandler.send_data("tiles_spread", tilePoses_string.to_utf8_buffer())
	#
	#GameBoard.removeTiles(selectedTiles)
	#
	#PlayerSpread.SpreadTiles(selectedTiles.duplicate())
	
	#for tile in selectedTiles:
		##if(River.river.has(tile)):
			##GameRiver.DrainRiver(tile)
			##break
		##else:
		#tile.resource.onRemovedFromBoard()
	
	
	
	#selectedTiles.clear()
	#GameBoard.SpreadHelper(selectedTiles)
	##GameBoard.changeHighlightColor()
	#SpreadButton.enabled = false
	#SpreadButton.text_color = Color.TRANSPARENT

func otherPlayer_Spread(tilePoses: String) -> void:
	var tileCount: int = int(tilePoses.get_slice("::", 0))
	
	var slice: String
	#var tilePose: Vector2i
	#var currTile: TileContainer
	var temp_selectedTiles: Array[TileContainer]
	for i in range(tileCount):
		slice = tilePoses.get_slice("::", i+1)
		#tilePose = Vector2(int(slice.get_slice(":", 0)), int(slice.get_slice(":", 1)))
		
		temp_selectedTiles.append(GameBoard.BoardRows[int(slice.get_slice(":", 0))][int(slice.get_slice(":", 1))])
	
	GameBoard.removeTiles(temp_selectedTiles)
	
	PlayerSpread.SpreadTiles(temp_selectedTiles.duplicate())

func EN_DISableDiscarding() -> void:
	isDiscarding = !isDiscarding
	
	selectedTiles.clear()
	var newTileHighlightColor: Color
	if(isDiscarding):
		newTileHighlightColor = TileContainer.HIGHLIGHT_DISCARD_COLOR
	else:
		newTileHighlightColor = TileContainer.HIGHLIGHT_BASE_COLOR
	
	GameBoard.changeHighlightColor(newTileHighlightColor)
	DiscardButton.visible = isDiscarding
	DiscardButton.enabled = false
	
	if(isDiscarding):
		var textSize_X: float = DiscardButton.ButtonText.get_theme_font("font").get_string_size(StringsManager.UIStrings["TURN"]["TEXT"][2]).x
		var textSize_Y: float = 46+DiscardButton.ButtonText.get_theme_constant("line_spacing")
		var newText: String = StringsManager.UIStrings["TURN"]["TEXT"][2] + "\n0/" + str(minMAXTilesToDiscard.x) + "(" + str(minMAXTilesToDiscard.y) + ")"
		
		DiscardButton.text = newText
		DiscardButton.size.y = textSize_Y
		#DiscardButton.changeVisuals(newText, DiscardButton.IconOrigColor, Vector2(textSize_X, textSize_Y))
	

func DiscardButtonPressed() -> void:
	GameBoard.removeTiles(selectedTiles)
	
	GameScene.Game.EndRound()
	
	GameRiver.DiscardTiles(selectedTiles)
	
	EN_DISableDiscarding()
	
	#selectedTiles.clear()
	DiscardButton.visible = false

func moveCamera(newPos: CameraPosition) -> void:
	if(currentCameraPos == newPos):
		return
	
	currentCameraPos = newPos
	
	#match newPos:
		#CameraPosition.BOARD:
			#SpreadCameraTransition.buttonType = GoodButton.ButtonType.TRANSITION_SPREAD
			#var windowSize: Vector2 = get_viewport_rect().size
			#var tween: Tween = create_tween()
			#tween.tween_property(Camera, "position", Vector2(0, Board.BOARD_HEIGHT/2 - windowSize.y/2), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		#CameraPosition.SPREAD:
			#SpreadCameraTransition.buttonType = GoodButton.ButtonType.TRANSITION_BOARD
			#var windowSize: Vector2 = get_viewport_rect().size
			#var tween: Tween = create_tween()
			#tween.tween_property(Camera, "position", Vector2(PlayerSpread.position.x, Board.BOARD_HEIGHT/2 - windowSize.y/2), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		#CameraPosition.RIVER:
			#var tween: Tween = create_tween()
			#tween.set_parallel()
			#tween.tween_property(Camera, "global_position", Vector2(0, 0), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
			##tween.tween_property(Camera, "")

var proxmityTween: Tween

#func _mouse_inProximity() -> void:
	#inProximity = true
	#
	#if(proxmityTween != null && proxmityTween.is_running()):
		#proxmityTween.stop()
	#
	#if(!falsePositive):
		#SpreadCameraTransition.visible = true
		#SpreadCameraTransition.modulate.a = 0
	#
	#proxmityTween = create_tween()
	#proxmityTween.tween_property(SpreadCameraTransition, "modulate:a", 1, 1-SpreadCameraTransition.modulate.a)

var falsePositive: bool = false

#func _mouse_outsideProximity() -> void:
	#var distances: Vector2 = SpreadTransition_ProximitySensor.size
	#var mousePos: Vector2 = get_global_mouse_position()
	#var sensorPos: Vector2 = SpreadTransition_ProximitySensor.global_position
	#var diffPos: Vector2 = mousePos - sensorPos
	#
	#if(diffPos.x >= 0 && diffPos.x <= distances.x && diffPos.y >= 0 && diffPos.y <= distances.y):
		#falsePositive = true
		#return
	#
	#inProximity = false
	#
	#if(proxmityTween != null && proxmityTween.is_running()):
		#proxmityTween.stop()
	#
	#proxmityTween = create_tween()
	#proxmityTween.tween_property(SpreadCameraTransition, "modulate:a", 0, SpreadCameraTransition.modulate.a)
	#proxmityTween.finished.connect(func() -> void:
		#SpreadCameraTransition.visible = false
		#if currentCameraPos == CameraPosition.SPREAD:
			#SpreadCameraTransition.ButtonIcon.flip_h = true
			#SpreadCameraTransition.position = SpreadCameraTransition_positionSpread
		#else: 
			#SpreadCameraTransition.ButtonIcon.flip_h = false
			#SpreadCameraTransition.position = SpreadCameraTransition_positionBoard
	#)
