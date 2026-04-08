extends Node2D

class_name Player

const PLAYER_CONTAINER: ResourceContainer.ContainerType = ResourceContainer.ContainerType.PLAYER_TILE#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
const BOARD_SPACE: TileContainer.PlayerSpace = TileContainer.PlayerSpace.BOARD
const SPREAD_SPACE: TileContainer.PlayerSpace = TileContainer.PlayerSpace.SPREAD
const RIVER_SPACE: TileContainer.PlayerSpace = TileContainer.PlayerSpace.RIVER

var SpreadTransition_ProximitySensor: Control
var GameBoard: Board
var PlayerSpread: Spread
var GameRiver: River
var PlayerDeck: Deck
var Camera: Camera2D
var SpreadButton: GoodButton
var DiscardButton: GoodButton
var SpreadCameraTransition: SpreadTransition
var ExpBar: ExperienceBar

static var selectedTiles: Array[TileContainer]
static var isDiscarding: bool = false
static var minMAXTilesToDiscard: Vector2i = Vector2i(1, 2)

var inProximity: bool = false
var currentCameraPos: CameraPosition = CameraPosition.BOARD

signal PlayerDraw(fromDeck: bool)

enum CameraPosition{
	BOARD, SPREAD, ALL_PLAYERS, RIVER
}

func _init() -> void:
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
	
	ExpBar = ExperienceBar.new()
	ExpBar.name = "ExperienceBar"
	add_child(ExpBar)
	
	SpreadTransition_ProximitySensor = Control.new()
	SpreadTransition_ProximitySensor.name = "SpreadTransition_ProximitySensor"
	add_child(SpreadTransition_ProximitySensor)
	
	GameBoard = Board.new()
	GameBoard.name = "GameBoard"
	add_child(GameBoard)
	
	PlayerSpread = Spread.new()
	PlayerSpread.name = "PlayerSpread"
	add_child(PlayerSpread)
	
	GameRiver = River.new()
	GameRiver.name = "GameRiver"
	add_child(GameRiver)
	
	PlayerDeck = Deck.new()
	PlayerDeck.name = "PlayerDeck"
	PlayerDeck.position = Vector2(-Board.BOARD_WIDTH/2 + Board.SPACE_BETWEEN_TILES, -(Board.BOARD_HEIGHT)*(GameBoard.BoardRows.size()-0.5) - ResourceContainer.BASE_RESOURCE_SIZE.y - 10)
	add_child(PlayerDeck)
	
	Camera = Camera2D.new()
	Camera.position = Vector2(0, -264.0)
	add_child(Camera)
	
	SpreadButton = GoodButton.new("Spread!", Color.GOLD, GoodButton.ButtonType.SPREAD)
	SpreadButton.position = Vector2(200, -240)
	SpreadButton.name = "SpreadButton"
	SpreadButton.visible = false
	add_child(SpreadButton)
	SpreadButton.press.connect(SpreadButtonPressed)
	
	DiscardButton = GoodButton.new("Discard!", Color.RED, GoodButton.ButtonType.DISCARD)
	DiscardButton.position = Vector2(-200, -240)
	DiscardButton.name = "DiscardButton"
	DiscardButton.visible = false
	add_child(DiscardButton)
	DiscardButton.press.connect(DiscardButtonPressed)
	
	SpreadCameraTransition = SpreadTransition.new()
	SpreadCameraTransition.name = "SpreadCameraTransition"
	SpreadCameraTransition.visible = false
	add_child(SpreadCameraTransition)
	
	
	SpreadCameraTransition.press.connect(func() -> void:
		if(currentCameraPos != CameraPosition.SPREAD):
			moveCamera(CameraPosition.SPREAD)
		else:
			moveCamera(CameraPosition.BOARD))
	
	SpreadTransition_ProximitySensor.mouse_entered.connect(_mouse_inProximity)
	SpreadTransition_ProximitySensor.mouse_exited.connect(_mouse_outsideProximity)

var SpreadCameraTransition_positionBoard: Vector2
var SpreadCameraTransition_positionSpread: Vector2

func _ready() -> void:
	var windowSize: Vector2 = get_viewport_rect().size
	
	var ExpBar_Y: float = -windowSize.y + Board.BOARD_HEIGHT/2 + ExperienceBar.BAR_SIZE.y/2 + GameBar.SLOT_BAR_SIZE.y+5
	ExpBar.position = Vector2(0, ExpBar_Y)
	
	var PlayerSpread_posX: float = (windowSize.x + Spread.ROW_WIDTH)/2 + 420
	PlayerSpread.position = Vector2(PlayerSpread_posX, 0)
	
	SpreadCameraTransition.position = Vector2(windowSize.x/2 - SpreadCameraTransition.size.x-10, -(windowSize.y - Board.BOARD_HEIGHT + SpreadCameraTransition.size.y)/2)
	SpreadCameraTransition_positionBoard = SpreadCameraTransition.position
	SpreadCameraTransition_positionSpread = SpreadCameraTransition.position + Vector2(PlayerSpread.position.x- windowSize.x + SpreadCameraTransition.size.x + 20, 0)
	
	SpreadTransition_ProximitySensor.custom_minimum_size = Vector2(515, windowSize.y)
	var posX: float = SpreadCameraTransition.position.x - (SpreadTransition_ProximitySensor.custom_minimum_size.x - SpreadCameraTransition.size.x - 10)/2
	SpreadTransition_ProximitySensor.position = Vector2(posX, Board.BOARD_HEIGHT/2 - windowSize.y)
	SpreadTransition_ProximitySensor.custom_minimum_size.x = 700
	
	Draw(14)
	PlayerDeck.DIS_ENable(true)

#var playerTypedLetters: Array[String]
#
#func _input(event: InputEvent) -> void:
	#if(event is InputEventKey && event.is_pressed()):
		#playerTypedLetters.append(event.as_text())
		#print("HERE0 - " + str(playerTypedLetters))

func _process(delta: float) -> void:
	#print("HERE0 - " + str(GameRiver.global_position))
	if(Input.is_action_just_pressed("Debug_Draw")):
		Draw()
		#ExpBar.gainExperience(100)
	
	#ExperienceTest.currScore += 1
	if(falsePositive):
		var distances: Vector2 = SpreadTransition_ProximitySensor.size
		var mousePos: Vector2 = get_global_mouse_position()
		var sensorPos: Vector2 = SpreadTransition_ProximitySensor.global_position
		var diffPos: Vector2 = mousePos - sensorPos
		
		if(diffPos.x < 0 || diffPos.x > distances.x || diffPos.y < 0 || diffPos.y > distances.y):
			falsePositive = false
			_mouse_outsideProximity()

func Draw(drawNumber: int = 1) -> void:
	PlayerDraw.emit(true)
	if(drawNumber <= 0):
		return
	
	if(drawNumber > PlayerDeck.DeckTiles.size()):
		drawNumber = PlayerDeck.DeckTiles.size()
	
	var newTile: TileContainer
	for i in range(drawNumber):
		##THE BACK IS NOT PlayerDeck.DeckTiles[0]!!!
		newTile = TileContainer.new(PlayerDeck.popTile(true), PLAYER_CONTAINER, -1, BOARD_SPACE)
		
		GameBoard.addTile(newTile)

func Draw_fromRiver(baitAmmount: int = 0, startingTile: TileContainer = null) -> void:
	if(baitAmmount <= 0):
		return
	
	PlayerDraw.emit(false)
	River.bait = 0
	
	GameScene.BaitButton.changeVisuals(StringsManager.UIStrings["BAIT"]["TEXT"][0]+str(0))
	
	print("HERE0")
	
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

func containerPressed(tileContainer: TileContainer) -> void:
	if(River.river.has(tileContainer)):
		if(BeaverTeeth.Beaver_Teeth_Activated):
			BeaverTeeth.chosenRiverTile = tileContainer
		
		return
	
	if(GameScene.usingItem != null && GameScene.usingItem.resource.target == Item.ItemTarget.VIABLE_BOARD_TILE):
		if(tileContainer.playerSpace != BOARD_SPACE):
			return
		
		#if(GameScene.usingItem.resource.isTileValid(tile)):
		GameScene.usingItem.resource.useOnTile(tileContainer)
		return
	
	if(selectedTiles.has(tileContainer)):
		selectedTiles.erase(tileContainer)
	else:
		selectedTiles.append(tileContainer)
	
	if(!isDiscarding):
		#if(River.river.has(tileContainer)):
			#for tile in selectedTiles:
				#if(tile != tileContainer && River.river.has(tile)):
					#tile.Highlight.visible = false
					#selectedTiles.erase(tile)
					#break
		
		GameBoard.SpreadHelper(selectedTiles)
		
		if(selectedTiles.size() == 0):
			SpreadButton.visible = false
		else:
			SpreadButton.visible = true
			
			currentSpreadEligibility = Spread_Info.getSpreadEligibility(selectedTiles)
			match currentSpreadEligibility:
				Spread_Info.SpreadCheck.ELIGIBLE:
					SpreadButton.DIS_ENable(true)
					SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][0], SpreadButton.IconOrigColor)
				Spread_Info.SpreadCheck.SHORT:
					SpreadButton.DIS_ENable(false)
					SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][1], SpreadButton.IconOrigColor)
				Spread_Info.SpreadCheck.VAGUE:
					SpreadButton.DIS_ENable(false)
					SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][2], SpreadButton.IconOrigColor)
				Spread_Info.SpreadCheck.NO_PATTERN:
					SpreadButton.DIS_ENable(false)
					SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][3], SpreadButton.IconOrigColor)
				Spread_Info.SpreadCheck.DUPLICATE_COLOR:
					SpreadButton.DIS_ENable(false)
					SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][4], SpreadButton.IconOrigColor)
				Spread_Info.SpreadCheck.TOO_MANY_COLORS:
					SpreadButton.DIS_ENable(false)
					SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][5], SpreadButton.IconOrigColor)
				Spread_Info.SpreadCheck.SEQUENCE_OOB:
					SpreadButton.DIS_ENable(false)
					SpreadButton.changeVisuals(StringsManager.UIStrings["SPREAD"]["TEXT"][6], SpreadButton.IconOrigColor)
	else:
		if(selectedTiles.size() < minMAXTilesToDiscard.x):
			DiscardButton.DIS_ENable(false)
		elif(selectedTiles.size() <= minMAXTilesToDiscard.y):
			DiscardButton.DIS_ENable(true)
		else:
			selectedTiles.erase(tileContainer)
		
		var baseTextSize: Vector2 = DiscardButton.ButtonText.get_theme_font("font").get_string_size("Discard")
		var textSize_X: float = baseTextSize.x
		var textSize_Y: float = 2*baseTextSize.y + DiscardButton.ButtonText.get_theme_constant("line_spacing")
		var newText: String = "Discard\n" + str(selectedTiles.size()) + "/" + str(minMAXTilesToDiscard.x) + "(" + str(minMAXTilesToDiscard.y) + ")"
		DiscardButton.changeVisuals(newText, DiscardButton.IconOrigColor, Vector2(textSize_X, textSize_Y))
	

func SpreadButtonPressed() -> void:
	#var outcome: Spread_Info.SpreadCheck = Spread_Info.getSpreadEligibility(selectedTiles)
	#if(outcome == Spread_Info.SpreadCheck.ELIGIBLE):
		#PlayerSpread.SpreadTiles(selectedTiles.duplicate())
	
	GameBoard.removeTiles(selectedTiles)
	
	PlayerSpread.SpreadTiles(selectedTiles.duplicate())
	
	#for tile in selectedTiles:
		##if(River.river.has(tile)):
			##GameRiver.DrainRiver(tile)
			##break
		##else:
		#tile.resource.onRemovedFromBoard()
	
	
	
	selectedTiles.clear()
	GameBoard.SpreadHelper(selectedTiles)
	#GameBoard.changeHighlightColor()
	SpreadButton.visible = false

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
	DiscardButton.DIS_ENable(false)
	
	if(isDiscarding):
		var textSize_X: float = DiscardButton.ButtonText.get_theme_font("font").get_string_size(StringsManager.UIStrings["TURN"]["TEXT"][2]).x
		var textSize_Y: float = 46+DiscardButton.ButtonText.get_theme_constant("line_spacing")
		var newText: String = StringsManager.UIStrings["TURN"]["TEXT"][2] + "\n0/" + str(minMAXTilesToDiscard.x) + "(" + str(minMAXTilesToDiscard.y) + ")"
		DiscardButton.changeVisuals(newText, DiscardButton.IconOrigColor, Vector2(textSize_X, textSize_Y))
	

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
	
	match newPos:
		CameraPosition.BOARD:
			SpreadCameraTransition.buttonType = GoodButton.ButtonType.TRANSITION_SPREAD
			var windowSize: Vector2 = get_viewport_rect().size
			var tween: Tween = create_tween()
			tween.tween_property(Camera, "position", Vector2(0, Board.BOARD_HEIGHT/2 - windowSize.y/2), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		CameraPosition.SPREAD:
			SpreadCameraTransition.buttonType = GoodButton.ButtonType.TRANSITION_BOARD
			var windowSize: Vector2 = get_viewport_rect().size
			var tween: Tween = create_tween()
			tween.tween_property(Camera, "position", Vector2(PlayerSpread.position.x, Board.BOARD_HEIGHT/2 - windowSize.y/2), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		CameraPosition.RIVER:
			var tween: Tween = create_tween()
			tween.set_parallel()
			tween.tween_property(Camera, "global_position", Vector2(0, 0), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
			#tween.tween_property(Camera, "")

var proxmityTween: Tween

func _mouse_inProximity() -> void:
	inProximity = true
	
	if(proxmityTween != null && proxmityTween.is_running()):
		proxmityTween.stop()
	
	if(!falsePositive):
		SpreadCameraTransition.visible = true
		SpreadCameraTransition.modulate.a = 0
	
	proxmityTween = create_tween()
	proxmityTween.tween_property(SpreadCameraTransition, "modulate:a", 1, 1-SpreadCameraTransition.modulate.a)

var falsePositive: bool = false

func _mouse_outsideProximity() -> void:
	var distances: Vector2 = SpreadTransition_ProximitySensor.size
	var mousePos: Vector2 = get_global_mouse_position()
	var sensorPos: Vector2 = SpreadTransition_ProximitySensor.global_position
	var diffPos: Vector2 = mousePos - sensorPos
	
	if(diffPos.x >= 0 && diffPos.x <= distances.x && diffPos.y >= 0 && diffPos.y <= distances.y):
		falsePositive = true
		return
	
	inProximity = false
	
	if(proxmityTween != null && proxmityTween.is_running()):
		proxmityTween.stop()
	
	proxmityTween = create_tween()
	proxmityTween.tween_property(SpreadCameraTransition, "modulate:a", 0, SpreadCameraTransition.modulate.a)
	proxmityTween.finished.connect(func() -> void:
		SpreadCameraTransition.visible = false
		if currentCameraPos == CameraPosition.SPREAD:
			SpreadCameraTransition.ButtonIcon.flip_h = true
			SpreadCameraTransition.position = SpreadCameraTransition_positionSpread
		else: 
			SpreadCameraTransition.ButtonIcon.flip_h = false
			SpreadCameraTransition.position = SpreadCameraTransition_positionBoard
	)
