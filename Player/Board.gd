extends Node2D

class_name Board

const STARTING_BOARD_ROWS: int = 2
const BOARD_COLOR: Color = Color(0.588, 0.431, 0.294, 1)#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
const ROW_TILE_SIZE: int = 10
const SPACE_BETWEEN_TILES: float = 20
const BOARD_HEIGHT: float = 120
const BOARD_WIDTH: float = ROW_TILE_SIZE*ResourceContainer.BASE_RESOURCE_SIZE.x + (ROW_TILE_SIZE+1)*SPACE_BETWEEN_TILES
const MAX_BOARD_ROWS: int = 5

var BoardRows: Array[Array]

func _init() -> void:
	var newBoard: Sprite2D
	var RowArray: Array[TileContainer]
	for i in range(STARTING_BOARD_ROWS):
		newBoard = Sprite2D.new()
		newBoard.texture = CanvasTexture.new()
		newBoard.region_enabled = true
		newBoard.region_rect = Rect2(0, 0, BOARD_WIDTH, BOARD_HEIGHT)
		newBoard.position = Vector2(0, -BOARD_HEIGHT*i)
		newBoard.self_modulate = BOARD_COLOR - i*BOARD_COLOR/MAX_BOARD_ROWS
		newBoard.name = "BoardRow" + str(i+1)
		RowArray = []
		RowArray.resize(ROW_TILE_SIZE)
		RowArray.fill(null)
		BoardRows.append(RowArray)
		add_child(newBoard)

enum TileOrigin{
	DECK, DECK_BURNING_SHOES, RIVER, SELECTION, SHOP
}

var delayForAdditionalDraw: float = 0

func addTile(newTile: TileContainer, tileOrigin: TileOrigin = TileOrigin.DECK) -> void:
	var boardSpace: bool
	var index: Vector2i = Vector2(-1, -1)
	for i in range(BoardRows.size()):
		if(getActualBoardSpace(i) > 0):
			#index.x = i
			boardSpace = true
			break
	
	if(!boardSpace):
		addBoard()
		index.x = BoardRows.size()-1
	else:
		index.x = randi_range(0, BoardRows.size()-1)
		while(getActualBoardSpace(index.x) <= 0):
			index.x = randi_range(0, BoardRows.size()-1)
	
	index.y = randi_range(0, ROW_TILE_SIZE-1)
	while(BoardRows[index.x][index.y] != null):
		index.y = randi_range(0, ROW_TILE_SIZE-1)
	
	BoardRows[index.x][index.y] = newTile
	
	newTile.name = "BoardTile" + str(index.y+1)
	if(tileOrigin == TileOrigin.DECK || tileOrigin == TileOrigin.DECK_BURNING_SHOES):
		get_child(index.x).add_child(newTile)
	else:
		newTile.reparent(get_child(index.x))
	
	var endPos: Vector2 = Vector2(95*index.y - 465, -ResourceContainer.BASE_RESOURCE_SIZE.y/2)
	delayForAdditionalDraw += 0.1
	match tileOrigin:
		TileOrigin.DECK:
			newTile.modulate.a = 0
			newTile.scale = Vector2(0.1, 0.1)
			newTile.global_position = GameScene.MainPlayer.PlayerDeck.global_position
			
			await get_tree().create_timer(delayForAdditionalDraw).timeout
			
			var displacement: Vector2 = Vector2(randf_range(0, 170), randf_range(-230, 0))
			while(displacement.length() < 150):
				displacement = Vector2(randf_range(-170, 0), randf_range(-230, 0))
			
			var tween: Tween = create_tween()
			tween.set_parallel()
			tween.tween_property(newTile, "modulate:a", 1, TileContainer.MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(newTile, "scale", Vector2(1, 1), TileContainer.MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			
			await newTile.moveTile(newTile.position+displacement, tween, Tween.TRANS_QUINT, Tween.EASE_OUT)
			await newTile.moveTile(endPos, null, Tween.TRANS_QUINT, Tween.EASE_IN)
		TileOrigin.DECK_BURNING_SHOES:
			var BurningTile: Sprite2D = Sprite2D.new()
			BurningTile.texture = load(BurningShoes.SPRITE_BASE_PATH + "01.png")
			BurningTile.name = "BurningTile"
			BurningTile.scale = Vector2(0.5, 0.5)
			
			newTile.modulate.a = 0
			#newTile.scale = Vector2(0.1, 0.1)
			
			await get_tree().create_timer((delayForAdditionalDraw+0.5)*1.5).timeout
			
			add_child(BurningTile)
			BurningTile.global_position = GameScene.MainPlayer.PlayerDeck.global_position
			
			var radius: float = randf_range(135, 160)
			var angle: float = randf_range(-3.0*PI/4, -PI/6.0)
			
			var displacement: Vector2 = Vector2(radius*cos(angle), radius*sin(angle))
			#while(displacement.length() < 150):
				#displacement = Vector2(randf_range(-170, 0), randf_range(-230, 0))
			
			newTile.global_position = GameScene.MainPlayer.PlayerDeck.global_position + displacement
			
			var tween: Tween = create_tween()
			tween.set_parallel()
			#tween.tween_property(newTile, "modulate:a", 1, TileContainer.MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			#tween.tween_property(newTile, "scale", Vector2(1, 1), TileContainer.MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			
			tween.tween_property(BurningTile, "position", BurningTile.position+displacement+ResourceContainer.BASE_RESOURCE_SIZE/2, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_method(func(index: int) -> void:
				BurningShoes.Manage_ButningTile_Sprite(BurningTile, index),
				1, BurningShoes.SPRITE_COUNT, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
			
			await tween.finished
			
			tween = create_tween()
			tween.set_parallel()
			
			tween.tween_property(newTile, "modulate:a", 1, 0.15)
			tween.tween_property(BurningTile, "modulate:a", 0, 0.15)
			
			await tween.finished
			
			BurningTile.queue_free()
			
			#await newTile.moveTile(newTile.position+displacement, tween, Tween.TRANS_QUINT, Tween.EASE_OUT)
			await newTile.moveTile(endPos, null, Tween.TRANS_QUINT, Tween.EASE_IN)
		TileOrigin.RIVER, TileOrigin.SELECTION:
			await get_tree().create_timer(delayForAdditionalDraw).timeout
			newTile.Highlight.visible = false
			newTile.Highlight.self_modulate = TileContainer.HIGHLIGHT_BASE_COLOR
			await newTile.moveTile(endPos, null, Tween.TRANS_BACK, Tween.EASE_IN, 0.3)
	
	delayForAdditionalDraw -= 0.1

func addBoard() -> void:
	var newBoard: Sprite2D = Sprite2D.new()
	newBoard.texture = CanvasTexture.new()
	newBoard.region_enabled = true
	newBoard.region_rect = Rect2(0, 0, BOARD_WIDTH, BOARD_HEIGHT)
	newBoard.position = Vector2(0, -BOARD_HEIGHT*BoardRows.size())
	newBoard.self_modulate = BOARD_COLOR - BoardRows.size()*BOARD_COLOR/MAX_BOARD_ROWS
	newBoard.name = "BoardRow" + str(BoardRows.size())
	var RowArray: Array[TileContainer]
	RowArray.resize(ROW_TILE_SIZE)
	RowArray.fill(null)
	BoardRows.append(RowArray)
	add_child(newBoard)

func removeTile(tile: TileContainer) -> void:
	for Row in BoardRows:
		for i in range(Row.size()):
			if(Row[i] == tile):
				Row[i] = null
				break

func removeTiles(tiles: Array[TileContainer]) -> void:
	for Row in BoardRows:
		for i in range(Row.size()):
			if(Row[i] != null && tiles.has(Row[i])):
				Row[i].resource.onRemovedFromBoard()
				Row[i] = null
	
	GameScene.MainPlayer.Draw(Tile.accumulatedWingedDraw)
	Tile.accumulatedWingedDraw = 0

func getActualBoardSpace(index: int) -> int:
	var space: int = 0
	for tile in BoardRows[index]:
		if(tile == null):
			space += 1
	
	return space

func getTilePos(boardTile: TileContainer) -> Vector2i:
	for i in range(BoardRows.size()):
		for j in range(BoardRows[i].size()):
			if(BoardRows[i][j] == boardTile):
				return Vector2i(i, j)
	
	return Vector2i(-1, -1)

var endPosHighlight: SparkleContainer

func SpreadHelper(selectedTiles: Array[TileContainer]) -> void:
	var rainbowEffect: Tile.Effect = Tile.Effect.RAINBOW
	
	var tile_info: Tile
	var other_tile_info: Tile = null
	var tempArray: Array[TileContainer]
	var Outcome:Spread_Info.SpreadCheck
	
	for Row in BoardRows:
		for tile in Row:
			if(tile == null):
				continue
			
			tile.EN_DISablePeriodicHighlight(false, selectedTiles.has(tile))
			
			if(selectedTiles.has(tile)):
				tile.showSpreadSelectionCount(selectedTiles.find(tile)+1)
				continue
			
			tile_info = tile.resource
			
			if(selectedTiles.size() <= 0):
				continue
			
			if(selectedTiles.size() == 1):
				if(other_tile_info == null):
					other_tile_info = selectedTiles[0].resource
				
				if(other_tile_info.joker_id >= 0 || tile_info.joker_id >= 0):
					tile.EN_DISablePeriodicHighlight(true)
					continue
				
				if(tile_info.number == other_tile_info.number+1):
					if(tile_info.effects.has(rainbowEffect) || other_tile_info.effects.has(rainbowEffect) || tile_info.color == other_tile_info.color):
						tile.EN_DISablePeriodicHighlight(true)
				
				if(tile_info.number == other_tile_info.number):
					if(tile_info.effects.has(rainbowEffect) || other_tile_info.effects.has(rainbowEffect) || tile_info.color != other_tile_info.color):
						tile.EN_DISablePeriodicHighlight(true)
			
			if(selectedTiles.size() >= 2):
				tempArray.clear()
				tempArray.append_array(selectedTiles)
				tempArray.append(tile)
				Outcome = Spread_Info.getSpreadEligibility(tempArray)
				
				if(Outcome == Spread_Info.SpreadCheck.ELIGIBLE || Outcome == Spread_Info.SpreadCheck.VAGUE):
					tile.EN_DISablePeriodicHighlight(true)

#func disableAllHighlights() -> void:
	#for Row in BoardRows:
		#for tile in Row:
			#if(tile == null):
				#continue
			#
			#tile.EN_DISablePeriodicHighlight(false, false)

func showViableTiles() -> void:
	for Row in BoardRows:
		for tile in Row:
			if(tile == null):
				continue
			
			if(GameScene.usingItem.resource.isTileValid(tile)):
				tile.EN_DISablePeriodicHighlight(true)
			else:
				tile.EN_DISablePeriodicHighlight(false)

func changeHighlightColor(newColor: Color) -> void:
	for Row in BoardRows:
		for tile in Row:
			if(tile == null):
				continue
			
			tile.EN_DISablePeriodicHighlight(false, false)
			tile.Highlight.self_modulate = newColor

func HighlightMovingTileFinalPos(tile: TileContainer) -> void:
	#Vector2(95*index.y - 465, -ResourceContainer.BASE_RESOURCE_SIZE.y/2)
	var endPos: Vector2 = (tile.position + Vector2(ResourceContainer.BASE_RESOURCE_SIZE.x, ResourceContainer.BASE_RESOURCE_SIZE.y/2 - BOARD_HEIGHT*getTilePos(tile).x)).snapped(Vector2(95, 120)) - Vector2((ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES)/2, 0)
	var Y_BOUNDS: Vector2 = Vector2(-(BoardRows.size()-1)*BOARD_HEIGHT, 0)
	var X_BOUNDS: Vector2 = Vector2(-((BOARD_WIDTH-ResourceContainer.BASE_RESOURCE_SIZE.x)/2 - SPACE_BETWEEN_TILES), (BOARD_WIDTH-ResourceContainer.BASE_RESOURCE_SIZE.x)/2 - SPACE_BETWEEN_TILES)
	
	if(endPos.x > X_BOUNDS.y):
		endPos.x = X_BOUNDS.y
	
	if(endPos.x < X_BOUNDS.x):
		endPos.x = X_BOUNDS.x
	
	if(endPos.y > Y_BOUNDS.y):
		endPos.y = Y_BOUNDS.y
	
	if(endPos.y < Y_BOUNDS.x):
		endPos.y = Y_BOUNDS.x
	
	if(endPosHighlight == null):
		endPosHighlight = SparkleContainer.new(Vector2(85, 115), Vector2(10, 11), SparkleContainer.HoleShape.RECTANGLE, Vector2(75, 105))
		add_child(endPosHighlight)
		endPosHighlight.position = endPos
	elif(endPosHighlight.position != endPos):
		var tween: Tween = create_tween()
		tween.tween_property(endPosHighlight, "position", endPos, 0.1)

func endMovement(tile: TileContainer) -> void:
	assert(endPosHighlight != null)
	
	var rowIndex: int = round(abs(endPosHighlight.position.y/BOARD_HEIGHT))
	var colIndex: int = round(endPosHighlight.position.x + ((BOARD_WIDTH -ResourceContainer.BASE_RESOURCE_SIZE.x)/2 - SPACE_BETWEEN_TILES))/95
	
	var startCoord: Vector2i = getTilePos(tile)
	var endCoord: Vector2i = Vector2i(rowIndex, colIndex)
	
	var endPos: Vector2 = Vector2(-BOARD_WIDTH/2 + SPACE_BETWEEN_TILES + endCoord.y*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES), -ResourceContainer.BASE_RESOURCE_SIZE.y/2)#-BOARD_HEIGHT*endCoord.x 
	
	
	if(BoardRows[endCoord.x][endCoord.y] == null):
		BoardRows[startCoord.x][startCoord.y] = null
		BoardRows[endCoord.x][endCoord.y] = tile
	else:
		var otherTilePos: Vector2 = Vector2(-BOARD_WIDTH/2 + SPACE_BETWEEN_TILES + startCoord.y*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES), -ResourceContainer.BASE_RESOURCE_SIZE.y/2)#-BOARD_HEIGHT*startCoord.x 
		BoardRows[startCoord.x][startCoord.y] = BoardRows[endCoord.x][endCoord.y]
		BoardRows[endCoord.x][endCoord.y] = tile
		
		if(startCoord.x != endCoord.x):
			BoardRows[startCoord.x][startCoord.y].reparent(get_child(startCoord.x))
		
		BoardRows[startCoord.x][startCoord.y].moveTile(otherTilePos, null, Tween.TRANS_QUINT, Tween.EASE_IN)
	
	if(startCoord.x != endCoord.x):
		tile.reparent(get_child(endCoord.x))
	
	tile.moveTile(endPos, null, Tween.TRANS_QUINT, Tween.EASE_IN)
	endPosHighlight.queue_free()
