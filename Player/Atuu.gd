extends GoodButton

class_name Atuu

const FRAME_EXTRA_SIZE: float = 50
const COLORS_EDGE_COUNT: int = 4

#var ImageControl: Control
var Frame: Sprite2D
var ColorSquares: Array[Sprite2D]
var ColorHighlight: Sprite2D

var Deck: Array[Tile]
var colorEndCycle: int = -1

func _init() -> void:
	#ImageControl = Control.new()
	#ImageControl.size = TileContainer.BASE_RESOURCE_SIZE
	##ImageControl.position = -ImageControl.size/2
	#ImageControl.mouse_filter = Control.MOUSE_FILTER_PASS
	#ImageControl.name = "ImageControl"
	#add_child(ImageControl)
	
	Frame = Sprite2D.new()
	Frame.texture = CanvasTexture.new()
	Frame.region_enabled = true
	Frame.region_rect.size = TileContainer.BASE_RESOURCE_SIZE + Vector2(FRAME_EXTRA_SIZE, FRAME_EXTRA_SIZE)
	Frame.position = (Frame.region_rect.size - Vector2(FRAME_EXTRA_SIZE, FRAME_EXTRA_SIZE))/2
	Frame.self_modulate = Color.BLACK
	Frame.name = "Frame"
	add_child(Frame)
	
	super("", Color.TRANSPARENT, TileContainer.BASE_RESOURCE_SIZE)#, null, false)
	DisabledColor = Color.TRANSPARENT
	HighlighColor = Color(1, 1, 1, 100.0/255.0)
	PressedColor = Color(1, 1, 1, 150.0/255.0)
	
	var tempColor: Sprite2D
	var startPos: Vector2 = Vector2(FRAME_EXTRA_SIZE, FRAME_EXTRA_SIZE)/4 - Frame.region_rect.size/2
	var currPos: Vector2 = startPos
	var colorStep: Vector2 = Vector2(abs(2*startPos.x/(COLORS_EDGE_COUNT-1)), abs(2*startPos.y/(COLORS_EDGE_COUNT-1)))
	var direction: Vector2i = Vector2i(1, 0)
	for key in Tile.COLORS.keys():
		tempColor = Sprite2D.new()
		tempColor.texture = CanvasTexture.new()
		tempColor.region_enabled = true
		tempColor.region_rect.size = Vector2(FRAME_EXTRA_SIZE, FRAME_EXTRA_SIZE)/4
		tempColor.position = currPos + (Frame.region_rect.size - Vector2(FRAME_EXTRA_SIZE, FRAME_EXTRA_SIZE))/2
		tempColor.self_modulate = Tile.COLORS[key]
		tempColor.z_index = 1
		tempColor.name = key
		add_child(tempColor)
		ColorSquares.append(tempColor)
		
		currPos += Vector2(colorStep.x * direction.x, colorStep.y * direction.y)
		
		if((abs(currPos) as Vector2).is_equal_approx(abs(startPos))):
			match direction:
				Vector2i(1, 0):
					direction = Vector2i(0, 1)
				Vector2i(0, 1):
					direction = Vector2i(-1, 0)
				Vector2i(-1, 0):
					direction = Vector2i(0, -1)
	
	ColorHighlight = Sprite2D.new()
	ColorHighlight.texture = CanvasTexture.new()
	ColorHighlight.region_enabled = true
	ColorHighlight.region_rect.size = Vector2(FRAME_EXTRA_SIZE, FRAME_EXTRA_SIZE)/2
	ColorHighlight.position = ColorSquares[0].position
	ColorHighlight.visible = false
	ColorHighlight.self_modulate.a = 150.0/255.0
	ColorHighlight.name = "ColorHighlight"
	add_child(ColorHighlight)
	
	#var pickedColors: Array[Color]
	#var tileColor: Color
	#for i in range(4):
		#tileColor = Tile.COLORS.values()[(randi_range(0, Tile.COLORS.size()-1))]
		#while(pickedColors.has(tileColor)):
			#tileColor = Tile.COLORS.values()[(randi_range(0, Tile.COLORS.size()-1))]
		#
		#pickedColors.append(tileColor)
		#for j in range(13):
			#Deck.append(Tile.new(j, tileColor))
	#
	#Deck.shuffle()
	
	#cycleColors()

var isRoundStartDraw: bool = false

func finalPress() -> void:
	super()
	
	enabled = false
	var newScale: float
	
	print("HERE0 - " + str(GameScene.myTurn) + " - " + str(GameScene.MainPlayer.hasStartedTurn))
	
	if(GameScene.myTurn && !GameScene.MainPlayer.hasStartedTurn):
		cycleColors()
		var finalA: float = GameScene.bgObfuscator.self_modulate.a
		GameScene.bgObfuscator.self_modulate.a = 0
		GameScene.bgObfuscator.visible = true
		
		var growTween: Tween = create_tween()
		growTween.set_parallel()
		newScale = (GameScene.window_size.y - Board.BOARD_HEIGHT*Player.GameBoard.BoardRows.size())/(BASE_RESOURCE_SIZE.y + FRAME_EXTRA_SIZE)
		growTween.tween_property(self, "scale", Vector2(newScale, newScale), 1)
		growTween.tween_property(self, "position", Vector2(0, -Board.BOARD_HEIGHT*(Player.GameBoard.BoardRows.size()-0.5) - newScale*(BASE_RESOURCE_SIZE.y + FRAME_EXTRA_SIZE)/2) - newScale*BASE_RESOURCE_SIZE/2, 1)
		growTween.tween_property(GameScene.bgObfuscator, "self_modulate:a", finalA, 1)
		
		growTween.finished.connect(func() -> void:
			await cycleTween.finished
			colorEndCycle = Tile.chosenColors.pick_random()
			await cycleTween.finished
			await get_tree().create_timer(0.5).timeout
			isRoundStartDraw = true
			Draw(13))
		
		GameScene.MainPlayer.hasStartedTurn = true
	else:
		var screenSize: Vector2 = GameScene.window_size
		newScale = (screenSize.x + 100)/BASE_RESOURCE_SIZE.x
		
		GameScene.GameShop.scale = Vector2(0, 0)
		GameScene.GameShop.global_position = GameScene.MainPlayer.Camera.global_position
		GameScene.GameShop.z_index = 2
		GameScene.GameShop.visible = true
		
		var transition_toShopTween: Tween = create_tween()
		transition_toShopTween.tween_property(self, "position", GameScene.MainPlayer.Camera.position - scale*BASE_RESOURCE_SIZE/2, 0.3)
		transition_toShopTween.tween_property(self, "scale", Vector2(newScale, newScale), 2)
		transition_toShopTween.parallel().tween_property(self, "position", GameScene.MainPlayer.Camera.position - newScale*BASE_RESOURCE_SIZE/2, 2)
		transition_toShopTween.parallel().tween_property(GameScene.GameShop, "position", Shop.opennedPos, 1).set_delay(1.5)
		transition_toShopTween.parallel().tween_property(GameScene.GameShop, "scale", Vector2(1, 1), 1).set_delay(1.5)

var cycleTween: Tween
var cycleSpeed: float = 6
var startGame_chosenColor: int = -1

func startGameCycle() -> void:
	var cycleCount: int = 0
	
	cycleColors()
	
	while(cycleCount < 2):
		await cycleTween.finished
		cycleCount += 1
	
	while(Tile.chosenColors.size() < 3):
		startGame_chosenColor = randi_range(0, Tile.COLORS.size()-1)
		while(Tile.chosenColors.has(startGame_chosenColor)):
			startGame_chosenColor = randi_range(0, Tile.COLORS.size()-1)
		
		Tile.chosenColors.append(startGame_chosenColor)
		
		while(startGame_chosenColor >= 0):
			await get_tree().create_timer(0.001).timeout
		
		await cycleTween.finished
		await cycleTween.finished
	
	startGame_chosenColor = randi_range(0, Tile.COLORS.size()-1)
	while(Tile.chosenColors.has(startGame_chosenColor)):
		startGame_chosenColor = randi_range(0, Tile.COLORS.size()-1)
	
	Tile.chosenColors.append(startGame_chosenColor)
	colorEndCycle = startGame_chosenColor
	
	while(startGame_chosenColor >= 0):
		await get_tree().create_timer(0.001).timeout
	
	ColorHighlight.visible = false
	
	#print("HERE0 - " + str(Deck.size()))
	#Deck.shuffle()
	
	await get_tree().create_timer(2).timeout
	#
	#DrawInterruptTime = 1
	#Draw(13)

func cycleColors(overrideStartingColor: int = 0) -> void:
	ColorHighlight.visible = true
	
	if(cycleTween != null && cycleTween.is_running()):
		cycleTween.kill()
	
	cycleTween = create_tween()
	cycleTween.tween_method(func(newVal: int) -> void:
		if(newVal >= ColorSquares.size()):
			newVal = 0
		
		ColorHighlight.position = ColorSquares[newVal].position
		
		if(newVal == startGame_chosenColor):
			var chosenColorHighlight: Sprite2D = Sprite2D.new()
			chosenColorHighlight.texture = CanvasTexture.new()
			chosenColorHighlight.region_enabled = true
			chosenColorHighlight.region_rect.size = Vector2(FRAME_EXTRA_SIZE, FRAME_EXTRA_SIZE)/2
			chosenColorHighlight.position = ColorSquares[newVal].position
			chosenColorHighlight.self_modulate.a = 100.0/255.0
			chosenColorHighlight.name = "chosenColorHighlight_" + str(newVal)
			add_child(chosenColorHighlight)
			
			get_tree().create_timer(0.1).timeout.connect(addCrads_intoDeck.bind(startGame_chosenColor))
			startGame_chosenColor = -1
			cycleSpeed -= 1
			cycleColors(newVal)
		
		if(newVal == colorEndCycle):
			cycleTween.finished.emit()
			cycleTween.kill(), overrideStartingColor, ColorSquares.size(), cycleSpeed * ((ColorSquares.size()-1 - overrideStartingColor)/float(ColorSquares.size()-1)))
	
	if(colorEndCycle < 0):
		cycleTween.finished.connect(cycleColors)
	else:
		cycleTween.finished.connect(func() -> void: colorEndCycle = -1)

func addCrads_intoDeck(colorIndex: int) -> void:
	if(colorIndex < 0):
		return
	
	var tempCont: TileContainer
	var angle: float
	var radius: float
	var displacement: Vector2
	var tileScale: float = 0.5/scale.x
	for i in range(13):
		tempCont = TileContainer.new(Tile.new(i+1, Tile.COLORS.values()[colorIndex]))
		tempCont.scale = Vector2()
		tempCont.position = ColorSquares[colorIndex].position
		tempCont.modulate.a = 0
		tempCont.z_index = 4
		tempCont.name = "newDeckTile" + str(i+1) + "_" + str(colorIndex)
		add_child(tempCont)
		
		Deck.insert(randi_range(0, Deck.size()), tempCont.tile)
		#Deck.append()
		
		angle = randf_range(0, PI)
		radius = randf_range(25, 100)
		displacement = Vector2(radius*cos(angle), radius*sin(angle))
		
		var deckAddingTween: Tween = create_tween().set_parallel()
		deckAddingTween.tween_property(tempCont, "position", displacement, 0.3).set_delay(0.1*i)
		deckAddingTween.tween_property(tempCont, "modulate:a", 1, 0.3).set_delay(0.1*i)
		deckAddingTween.tween_property(tempCont, "scale", Vector2(tileScale, tileScale), 0.3).set_delay(0.1*i)
		deckAddingTween.tween_property(tempCont, "position", BASE_RESOURCE_SIZE/2, 0.5).set_delay(0.4 + 0.1*i)
		deckAddingTween.finished.connect(func() -> void: tempCont.queue_free())
	
	GameScene.GameShop.reloadShop()

const STANDARD_DRAW_INTERRUPT_TIME: float = 0.2
var DrawInterruptTime: float = STANDARD_DRAW_INTERRUPT_TIME

func Draw(count: int = 1) -> void:
	if(count <= 0):
		return
	
	var contArray: Array[TileContainer]
	var tileTween: Tween = create_tween().set_parallel()
	var tempCont: TileContainer
	var randX: float
	var randY: float
	for i in range(count):
		tempCont = TileContainer.new(Deck.pop_back())
		contArray.append(tempCont)
		tempCont.enabled = false
		tempCont.position = position
		tempCont.name = "tempCont_" + str(i+1)
		GameScene.MainPlayer.add_child(tempCont)
		
		match randi_range(0, 1):
			0:
				randX = randf_range(-GameScene.window_size.x/2 + 25, -scale.x*(BASE_RESOURCE_SIZE.x+FRAME_EXTRA_SIZE) - BASE_RESOURCE_SIZE.x - 5)
			1:
				randX = randf_range(scale.x*(BASE_RESOURCE_SIZE.x+FRAME_EXTRA_SIZE) + 5, GameScene.window_size.x/2 - 25)
		
		randY = randf_range(-GameScene.window_size.y/2 + 15, -Board.BOARD_HEIGHT*(Player.GameBoard.BoardRows.size()-0.5) - 15)
		
		tileTween.tween_property(tempCont, "position", Vector2(randX, randY), 0.5).set_delay(0.1*i)
	
	GameScene.GameShop.reloadShop()
	
	tileTween.finished.connect(func() -> void:
		await get_tree().create_timer(DrawInterruptTime).timeout
		DrawInterruptTime = STANDARD_DRAW_INTERRUPT_TIME
		
		if(isRoundStartDraw):
			var finalA: float = GameScene.bgObfuscator.self_modulate.a
			var atuuScale: float = GameScene.PlayerBar.Body.region_rect.size.y/(Atuu.BASE_RESOURCE_SIZE.y+Atuu.FRAME_EXTRA_SIZE)
			var atuuPos: Vector2 = -atuuScale*Atuu.BASE_RESOURCE_SIZE/2
			atuuPos.y += Board.BOARD_HEIGHT/2 - GameScene.window_size.y + GameScene.PlayerBar.Body.region_rect.size.y/2
			
			var returnTween: Tween = create_tween().set_parallel()
			returnTween.tween_property(self, "position", atuuPos, 0.5)
			returnTween.tween_property(self, "scale", Vector2(atuuScale, atuuScale), 0.5)
			returnTween.tween_property(GameScene.bgObfuscator, "self_modulate:a", 0, 0.5)
			returnTween.finished.connect(GameScene.StartRound)
		
		isRoundStartDraw = false
		
		var tileStrings = ""
		var tempPos: Vector2i
		var index: int = 0
		for tile in contArray:
			tile.z_index = 1
			tempPos = Player.GameBoard.addTile(tile, Board.TileOrigin.ATUU)
			if(!tileStrings.is_empty()):
				tileStrings += "::"
			
			tileStrings += str(tile.tile) + ":" + str(tempPos.x) + ":" + str(tempPos.y)
			
			if(index == count-1):
				MultiplayerHandler.send_data("draw", (str(count) + "::" + tileStrings).to_utf8_buffer())
			
			index += 1)
