extends Node2D

class_name Board

const STARTING_BOARD_ROWS: int = 2
const BOARD_COLOR: Color = Color(0.588, 0.431, 0.294, 1)#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
const ROW_TILE_SIZE: int = 10
const SPACE_BETWEEN_TILES: float = 20
const BOARD_HEIGHT: float = 120
const BOARD_WIDTH: float = ROW_TILE_SIZE*ResourceContainer.BASE_RESOURCE_SIZE.x + (ROW_TILE_SIZE+1)*SPACE_BETWEEN_TILES
const MAX_BOARD_ROWS: int = 5
const MOVE_TILE_DURATION: float = 0.35

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
	DECK, DECK_BURNING_SHOES, RIVER, SELECTION, SHOP, OTHER_PLAYER, ATUU
}

var delayForAdditionalDraw: float = 0

func addTile(newTile: TileContainer, tileOrigin: TileOrigin = TileOrigin.DECK, overridePos: Vector2i = Vector2i(-1, -1), playerOrigin: Player = GameScene.MainPlayer) -> Vector2i:
	var boardSpace: bool
	var index: Vector2i = overridePos
	for i in range(BoardRows.size()):
		if(getActualBoardSpace(i) > 0):
			#index.x = i
			boardSpace = true
			break
	
	if(!boardSpace):
		addBoard()
		index.x = BoardRows.size()-1
	else:
		#index.x = randi_range(0, BoardRows.size()-1)
		while(index.x == -1 || getActualBoardSpace(index.x) <= 0):
			index.x = randi_range(0, BoardRows.size()-1)
	
	#index.y = randi_range(0, ROW_TILE_SIZE-1)
	while(index.y == -1 || BoardRows[index.x][index.y] != null):
		index.y = randi_range(0, ROW_TILE_SIZE-1)
	
	BoardRows[index.x][index.y] = newTile
	
	newTile.name = "BoardTile" + str(index.y+1)
	
	var endPos: Vector2 = Vector2(95*index.y - 465, -ResourceContainer.BASE_RESOURCE_SIZE.y/2)
	#if():
		#get_child(index.x).add_child(newTile)
		#newTile.position = endPos
		
		#return index
	
	if(tileOrigin == TileOrigin.DECK || tileOrigin == TileOrigin.DECK_BURNING_SHOES || tileOrigin == TileOrigin.OTHER_PLAYER):
		get_child(index.x).add_child(newTile)
	else:
		newTile.reparent(get_child(index.x))
	
	handleTileMovement(newTile, endPos, tileOrigin, playerOrigin)
	
	return index

func handleTileMovement(newTile: TileContainer, endPos: Vector2, tileOrigin: TileOrigin = TileOrigin.DECK, playerOrigin: Player = GameScene.MainPlayer) -> void:
	delayForAdditionalDraw += 0.1
	match tileOrigin:
		TileOrigin.OTHER_PLAYER:
			newTile.modulate.a = 0
			newTile.scale = Vector2(0.1, 0.1)
			newTile.global_position = playerOrigin.otherPlayerDeck.global_position
			
			await get_tree().create_timer(delayForAdditionalDraw).timeout
			
			var displacement: Vector2 = Vector2(randf_range(0, 170), randf_range(-230, 0))
			while(displacement.length() < 150):
				displacement = Vector2(randf_range(-170, 0), randf_range(-230, 0))
			
			var tween: Tween = create_tween()
			tween.set_parallel()
			tween.tween_property(newTile, "modulate:a", 1, MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(newTile, "scale", Vector2(1, 1), MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(newTile, "position", newTile.position+displacement, MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			
			await tween.finished
			
			tween = create_tween()
			
			tween.tween_property(newTile, "position", endPos, MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
			
			await tween.finished
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
			tween.tween_property(newTile, "modulate:a", 1, MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(newTile, "scale", Vector2(1, 1), MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(newTile, "position", newTile.position+displacement, MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			
			await tween.finished
			
			tween = create_tween()
			
			tween.tween_property(newTile, "position", endPos, MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
			
			await tween.finished
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
			
			tween = create_tween()
			
			tween.tween_property(newTile, "position", endPos, MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
			
			await tween.finished
		TileOrigin.RIVER, TileOrigin.SELECTION:
			await get_tree().create_timer(delayForAdditionalDraw).timeout
			newTile.Highlight.visible = false
			newTile.Highlight.self_modulate = TileContainer.HIGHLIGHT_BASE_COLOR
			var tween: Tween = create_tween()
			
			tween.tween_property(newTile, "position", endPos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			
			await tween.finished
		TileOrigin.ATUU:
			await get_tree().create_timer(delayForAdditionalDraw).timeout
			var tween: Tween = create_tween()
			tween.tween_property(newTile, "position", endPos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			
			await tween.finished
			
			newTile.enabled = true
			newTile.z_index = 0
	
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
				return

func removeTiles(tiles: Array[TileContainer]) -> void:
	for Row in BoardRows:
		for i in range(Row.size()):
			if(Row[i] != null && tiles.has(Row[i])):
				Row[i].tile.onRemovedFromBoard()
				Row[i] = null
	
	#GameScene.MainPlayer.Draw(Tile.accumulatedWingedDraw)
	#Tile.accumulatedWingedDraw = 0

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

func getTiles_fromMessage(message: String) -> Array[TileContainer]:
	var tiles: Array[TileContainer]
	var tileCount: int = int(message.get_slice("::", 0))
	var tempStringPos: String
	
	for i in range(tileCount):
		tempStringPos = message.get_slice("::", i+1)
		tiles.append(BoardRows[int(tempStringPos.get_slice(":", 0))][int(tempStringPos.get_slice(":", 1))])
	
	return tiles

var endPosHighlight: SparkleContainer

func SpreadHelper(selectedTiles: Array[TileContainer]) -> void:
	var rainbowEffect: Tile.Effect = Tile.Effect.RAINBOW
	
	var tile_info: Tile
	var other_tile_info: Tile = null
	var tempArray: Array[TileContainer]
	var Outcome:Spread_Info.SpreadCheck
	
	for Row in BoardRows:
		for tile: TileContainer in Row:
			if(tile == null):
				continue
			
			tile.flash(false)
			tile.show_count(-1)
			
			if(selectedTiles.has(tile)):
				tile.show_count(selectedTiles.find(tile)+1)
				continue
			
			tile_info = tile.tile
			
			if(selectedTiles.size() <= 0):
				continue
			
			if(selectedTiles.size() == 1):
				if(other_tile_info == null):
					other_tile_info = selectedTiles[0].tile
				
				if(other_tile_info.jokerID >= 0 || tile_info.jokerID >= 0):
					tile.flash(true)
					continue
				
				if(tile_info.number == other_tile_info.number+1):
					if(tile_info.effects.has(rainbowEffect) || other_tile_info.effects.has(rainbowEffect) || tile_info.color == other_tile_info.color):
						tile.flash(true)
				
				if(tile_info.number == other_tile_info.number):
					if(tile_info.effects.has(rainbowEffect) || other_tile_info.effects.has(rainbowEffect) || tile_info.color != other_tile_info.color):
						tile.flash(true)
			
			if(selectedTiles.size() >= 2):
				tempArray.clear()
				tempArray.append_array(selectedTiles)
				tempArray.append(tile)
				Outcome = Spread_Info.getSpreadEligibility(tempArray)
				
				if(Outcome == Spread_Info.SpreadCheck.ELIGIBLE || Outcome == Spread_Info.SpreadCheck.VAGUE):
					tile.flash(true)

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
				tile.flash(true)
			else:
				tile.flash(false)

func changeHighlightColor(newColor: Color) -> void:
	for Row in BoardRows:
		for tile in Row:
			if(tile == null):
				continue
			
			tile.flash(false)
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
	
	var tileTween: Tween = create_tween()
	tileTween.set_parallel().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	if(BoardRows[endCoord.x][endCoord.y] == null):
		BoardRows[startCoord.x][startCoord.y] = null
		BoardRows[endCoord.x][endCoord.y] = tile
	else:
		var otherTilePos: Vector2 = Vector2(-BOARD_WIDTH/2 + SPACE_BETWEEN_TILES + startCoord.y*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES), -ResourceContainer.BASE_RESOURCE_SIZE.y/2)#-BOARD_HEIGHT*startCoord.x 
		BoardRows[startCoord.x][startCoord.y] = BoardRows[endCoord.x][endCoord.y]
		BoardRows[endCoord.x][endCoord.y] = tile
		
		if(startCoord.x != endCoord.x):
			BoardRows[startCoord.x][startCoord.y].reparent(get_child(startCoord.x))
		
		tileTween.tween_property(BoardRows[startCoord.x][startCoord.y], "position", otherTilePos, 0.35)
	
	if(startCoord.x != endCoord.x):
		tile.reparent(get_child(endCoord.x))
	
	tileTween.tween_property(tile, "position", endPos, 0.35)
	endPosHighlight.queue_free()
	
	MultiplayerHandler.send_data("tile_moved", (str(startCoord.x) + ":" + str(startCoord.y) + "::" + str(endCoord.x) + ":" + str(endCoord.y)).to_utf8_buffer())

func otherPlayer_movedTile(coordinates: String) -> void:
	var coord_str: String = coordinates.get_slice("::", 0)
	var startCoord: Vector2i = Vector2i(int(coord_str.get_slice(":", 0)), int(coord_str.get_slice(":", 1)))
	
	coord_str = coordinates.get_slice("::", 1)
	var endCoord: Vector2i = Vector2i(int(coord_str.get_slice(":", 0)), int(coord_str.get_slice(":", 1)))
	
	var tileAux: TileContainer = BoardRows[startCoord.x][startCoord.y]
	BoardRows[startCoord.x][startCoord.y] = BoardRows[endCoord.x][endCoord.y]
	BoardRows[endCoord.x][endCoord.y] = tileAux
	
	var newTilePos: Vector2
	if(BoardRows[startCoord.x][startCoord.y] != null):
		newTilePos = Vector2(-BOARD_WIDTH/2 + SPACE_BETWEEN_TILES + startCoord.y*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES), -ResourceContainer.BASE_RESOURCE_SIZE.y/2)
		if(startCoord.x != endCoord.x):
			BoardRows[startCoord.x][startCoord.y].reparent(get_child(startCoord.x))
		
		BoardRows[startCoord.x][startCoord.y].moveTile(newTilePos, null, Tween.TRANS_QUINT, Tween.EASE_IN)
	
	if(BoardRows[endCoord.x][endCoord.y] != null):
		newTilePos = Vector2(-BOARD_WIDTH/2 + SPACE_BETWEEN_TILES + endCoord.y*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES), -ResourceContainer.BASE_RESOURCE_SIZE.y/2)
		if(startCoord.x != endCoord.x):
			BoardRows[endCoord.x][endCoord.y].reparent(get_child(endCoord.x))
		
		BoardRows[endCoord.x][endCoord.y].moveTile(newTilePos, null, Tween.TRANS_QUINT, Tween.EASE_IN)
