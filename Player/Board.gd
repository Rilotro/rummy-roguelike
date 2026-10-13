extends Control

class_name Board

const STARTING_BOARD_ROWS: int = 2
const BOARD_COLOR: Color = Color(0.588, 0.431, 0.294, 1)#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
const ROW_TILE_SIZE: int = 10
const SPACE_BETWEEN_TILES: float = 20
const BOARD_HEIGHT: float = 120
const BOARD_WIDTH: float = ROW_TILE_SIZE*ResourceContainer.BASE_RESOURCE_SIZE.x + (ROW_TILE_SIZE+1)*SPACE_BETWEEN_TILES
const MAX_BOARD_ROWS: int = 5
const MOVE_TILE_DURATION: float = 0.35

static var player_pos: PlayerData = null

var BoardRows: Array[Array]
var curr_lowerBorad: int = 0

func _init() -> void:
	clip_contents = true
	
	size = Vector2(BOARD_WIDTH, 2*BOARD_HEIGHT)
	
	var newBoard: Sprite2D
	var RowArray: Array[TileContainer]
	for i in range(STARTING_BOARD_ROWS):
		newBoard = Sprite2D.new()
		newBoard.texture = CanvasTexture.new()
		newBoard.region_enabled = true
		newBoard.region_rect = Rect2(0, 0, BOARD_WIDTH, BOARD_HEIGHT)
		newBoard.position = Vector2(BOARD_WIDTH/2, (1.5-i)*BOARD_HEIGHT)
		newBoard.self_modulate = BOARD_COLOR - i*BOARD_COLOR/MAX_BOARD_ROWS
		newBoard.name = "BoardRow" + str(i+1)
		RowArray = []
		RowArray.resize(ROW_TILE_SIZE)
		RowArray.fill(null)
		BoardRows.append(RowArray)
		add_child(newBoard)

func moveBoard(nextPlayer: PlayerData) -> void:
	Board.player_pos = nextPlayer
	for Row: Array[TileContainer] in BoardRows:
		for tile in Row:
			if(tile == null):
				continue
			
			tile.player_owner = nextPlayer
	
	var tween: Tween = create_tween()
	tween.tween_method(func(newRot: float) -> void:
		rotation = newRot
		global_position =  Vector2(GameScene.BoardRadius*sin(-newRot), GameScene.BoardRadius*cos(-newRot))
	, rotation, rotation-GameScene.interPlayer_rotationStep, 1)

func addBoard() -> void:
	var newBoard: Sprite2D = Sprite2D.new()
	newBoard.texture = CanvasTexture.new()
	newBoard.region_enabled = true
	newBoard.region_rect = Rect2(0, 0, BOARD_WIDTH, BOARD_HEIGHT)
	#curr_lowerBorad
	newBoard.position = Vector2(BOARD_WIDTH/2, (1.5 - BoardRows.size() + curr_lowerBorad)*BOARD_HEIGHT)
	newBoard.self_modulate = BOARD_COLOR - BoardRows.size()*BOARD_COLOR/MAX_BOARD_ROWS
	newBoard.name = "BoardRow" + str(BoardRows.size())
	var RowArray: Array[TileContainer]
	RowArray.resize(ROW_TILE_SIZE)
	RowArray.fill(null)
	BoardRows.append(RowArray)
	add_child(newBoard)
	
	GameScene.MainPlayer.boardRows_moveUp.visible = true

enum TileOrigin{#DECK, DECK_BURNING_SHOES, RIVER, SELECTION, SHOP, 
	OTHER_PLAYER, ATUU
}

func addTile(newTile: TileContainer, tileOrigin: TileOrigin = TileOrigin.ATUU, overridePos: Vector2i = Vector2i(-1, -1), playerOrigin: Player = GameScene.MainPlayer) -> Vector2i:
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
	
	while(index.x != curr_lowerBorad && index.x != curr_lowerBorad+1):
		await moveRows(index.x < curr_lowerBorad)
	
	var endPos: Vector2 = Vector2(95*index.y - 465, -ResourceContainer.BASE_RESOURCE_SIZE.y/2)
	endPos += (get_child(index.x) as Sprite2D).position + position# + Vector2(0, BOARD_HEIGHT)
	#if():
		#get_child(index.x).add_child(newTile)
		#newTile.position = endPos
		
		#return index
	#ileOrigin == TileOrigin.DECK || tileOrigin == TileOrigin.DECK_BURNING_SHOES || 
	#if(tileOrigin == TileOrigin.OTHER_PLAYER):
		#get_child(index.x).add_child(newTile)
	#else:
		#newTile.reparent(get_child(index.x))
	
	await get_tree().create_timer(0.1).timeout
	
	handleTileMovement(newTile, endPos, index.x, tileOrigin, playerOrigin)
	
	return index

var tileQueue: int = 0

func handleTileMovement(newTile: TileContainer, endPos: Vector2, parentIndex: int, tileOrigin: TileOrigin = TileOrigin.ATUU, playerOrigin: Player = GameScene.MainPlayer) -> void:
	tileQueue += 1
	
	#if(moveBoardsTween != null && moveBoardsTween.is_running()):
		#await moveBoardsTween.finished
	
	match tileOrigin:
		TileOrigin.OTHER_PLAYER:
			newTile.modulate.a = 0
			newTile.scale = Vector2(0.1, 0.1)
			newTile.global_position = playerOrigin.otherPlayerDeck.global_position
			
			#await get_tree().create_timer(delayForAdditionalDraw).timeout
			
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
		TileOrigin.ATUU:
			#await get_tree().create_timer(delayForAdditionalDraw).timeout
			var tween: Tween = create_tween()
			tween.tween_property(newTile, "position", endPos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			
			await tween.finished
			
			newTile.enabled = true
			newTile.z_index = 0
	
	if(tileOrigin == TileOrigin.OTHER_PLAYER):
		get_child(parentIndex).add_child(newTile)
	else:
		newTile.reparent(get_child(parentIndex))
	
	tileQueue -= 1

func moveRows(up: bool) -> void:
	if(BoardRows.size() <= 2):
		return
	
	var direction: int = -1 if(up) else 1
	
	curr_lowerBorad += direction
	
	GameScene.MainPlayer.boardRows_moveUp.enabled = false
	GameScene.MainPlayer.boardRows_moveDown.enabled = false
	
	while(tileQueue > 0):
		await get_tree().create_timer(0.001).timeout
	
	var moveBoardsTween: Tween = create_tween().set_parallel()
	for i in range(BoardRows.size()):
		moveBoardsTween.tween_property(get_child(i), "position:y", get_child(i).position.y + BOARD_HEIGHT*direction, 0.5)
	
	await moveBoardsTween.finished
	
	GameScene.MainPlayer.boardRows_moveUp.enabled = true
	GameScene.MainPlayer.boardRows_moveDown.enabled = true
	
	var upVisibility: bool = curr_lowerBorad != 0
	var downVisibility: bool = curr_lowerBorad != BoardRows.size()-2
	
	if(TileContainer.MovingTile != null):
		if(GameScene.MainPlayer.boardRows_moveUp.visible != upVisibility):
			if(upVisibility):
				if(downVisibility):
					Player.boardRows_UpHighlight = SparkleContainer.new(GameScene.MainPlayer.boardRows_moveUp.size+Player.HIGHLIGHT_THICKNESS, Vector2(10, 11), SparkleContainer.Hole.new(GameScene.MainPlayer.boardRows_moveUp.size, Vector2(), SparkleContainer.Shape.RECTANGLE))
					Player.boardRows_UpHighlight.position = Player.boardRows_DownHighlight.position
					GameScene.MainPlayer.add_child(Player.boardRows_UpHighlight)
				else:
					Player.boardRows_UpHighlight = Player.boardRows_DownHighlight
					Player.boardRows_DownHighlight = null
			
				create_tween().tween_property(Player.boardRows_UpHighlight, "position", GameScene.MainPlayer.boardRows_moveUp.position + GameScene.MainPlayer.boardRows_moveUp.size/2, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
			elif(GameScene.MainPlayer.boardRows_moveDown.visible):
				Player.boardRows_UpHighlight.queue_free()
		if(GameScene.MainPlayer.boardRows_moveDown.visible != downVisibility):
			if(downVisibility):
				if(upVisibility):
					Player.boardRows_DownHighlight = SparkleContainer.new(GameScene.MainPlayer.boardRows_moveDown.size+Player.HIGHLIGHT_THICKNESS, Vector2(10, 11), SparkleContainer.Hole.new(GameScene.MainPlayer.boardRows_moveDown.size, Vector2(), SparkleContainer.Shape.RECTANGLE))
					Player.boardRows_DownHighlight.position = Player.boardRows_UpHighlight.position
					GameScene.MainPlayer.add_child(Player.boardRows_DownHighlight)
				else:
					Player.boardRows_DownHighlight = Player.boardRows_UpHighlight
					Player.boardRows_UpHighlight = null
				
				create_tween().tween_property(Player.boardRows_DownHighlight, "position", GameScene.MainPlayer.boardRows_moveDown.position + GameScene.MainPlayer.boardRows_moveDown.size/2, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
			elif(GameScene.MainPlayer.boardRows_moveUp.visible):
				Player.boardRows_DownHighlight.queue_free()
	
	GameScene.MainPlayer.boardRows_moveUp.visible = upVisibility
	GameScene.MainPlayer.boardRows_moveDown.visible = downVisibility

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
				#Row[i].tile.onRemovedFromBoard()
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

#var endPosHighlight: SparkleContainer

func startMovingTile(tile: TileContainer) -> void:
	pass

func handleMovingTile(tile: TileContainer) -> void:
	#Vector2(95*index.y - 465, -ResourceContainer.BASE_RESOURCE_SIZE.y/2)
	#print("HERE0 - " + str(tile.position) + " - " + str(tile.global_position - GameScene.MainPlayer.position + Vector2(0, BOARD_HEIGHT*getTilePos(tile).x)))
	#var tileRelPos: Vector2 = tile.position - Vector2(0, get_child(getTilePos(tile).x).position.y)
	#var endPos: Vector2 = (tileRelPos + Vector2(ResourceContainer.BASE_RESOURCE_SIZE.x, ResourceContainer.BASE_RESOURCE_SIZE.y/2 - BOARD_HEIGHT*getTilePos(tile).x)).snapped(Vector2(95, 120)) - Vector2((ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES)/2, 0)
	
	var endPos: Vector2 = get_global_mouse_position() - GameScene.MainPlayer.position - position
	
	if(endPos.y < -50):
		pass
	else:
		pass
	
	endPos = (endPos - Vector2(95, 120)/2).snapped(Vector2(95, 120)) + GoodButton.BASE_RESOURCE_SIZE/2# - Vector2(GoodButton.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES/2, 0)#ResourceContainer.BASE_RESOURCE_SIZE.x + 
	endPos += Vector2(SPACE_BETWEEN_TILES, (BOARD_HEIGHT-GoodButton.BASE_RESOURCE_SIZE.y)/2)
	
	#if(GameScene.MainPlayer.boardRows_moveUp.visible && boardRows_UpHighlight == null):
		#
	#elif(!GameScene.MainPlayer.boardRows_moveUp.visible && boardRows_UpHighlight != null):
		#boardRows_UpHighlight.queue_free()
	
	#if(GameScene.MainPlayer.boardRows_moveDown.visible && boardRows_DownHighlight == null):
		#boardRows_DownHighlight = SparkleContainer.new(GameScene.MainPlayer.boardRows_moveDown.size + HIGHLIGHT_THICKNESS, Vector2(10, 11), SparkleContainer.Hole.new(GameScene.MainPlayer.boardRows_moveDown.size, Vector2(), SparkleContainer.Shape.RECTANGLE))
		#boardRows_DownHighlight.position = GameScene.MainPlayer.boardRows_moveDown.position + GameScene.MainPlayer.boardRows_moveDown.size/2
		#GameScene.MainPlayer.add_child(boardRows_DownHighlight)
	#elif(!GameScene.MainPlayer.boardRows_moveDown.visible && boardRows_DownHighlight != null):
		#boardRows_DownHighlight.queue_free()
	
	# + GoodButton.BASE_RESOURCE_SIZE/2
	var Y_BOUNDS: Vector2 = Vector2(BOARD_HEIGHT/2, (BoardRows.size()-0.5)*BOARD_HEIGHT)
	var X_BOUNDS: Vector2 = Vector2(SPACE_BETWEEN_TILES+GoodButton.BASE_RESOURCE_SIZE.x/2, BOARD_WIDTH-SPACE_BETWEEN_TILES-GoodButton.BASE_RESOURCE_SIZE.x/2)
	
	if(endPos.x > X_BOUNDS.y):
		endPos.x = X_BOUNDS.y
	
	if(endPos.x < X_BOUNDS.x):
		endPos.x = X_BOUNDS.x
	
	if(endPos.y > Y_BOUNDS.y):
		endPos.y = Y_BOUNDS.y
	
	if(endPos.y < Y_BOUNDS.x):
		endPos.y = Y_BOUNDS.x
	
	#endPos -= position
	
	#(1.5-i)*BOARD_HEIGHT
	#SPACE_BETWEEN_TILES + (GoodButton.BASE_RESOURCE_SIZE.x+SPACE_BETWEEN_TILES)*i
	
	if(Player.SparkleHighlight.position != endPos):
		var tween: Tween = create_tween()
		tween.tween_property(Player.SparkleHighlight, "position", endPos, 0.1)
		if(Player.SparkleHighlight.size != GoodButton.BASE_RESOURCE_SIZE+Player.HIGHLIGHT_THICKNESS):
			tween.tween_property(Player.SparkleHighlight.hole, "size", GoodButton.BASE_RESOURCE_SIZE, 0.1)
			tween.tween_property(Player.SparkleHighlight, "size", GoodButton.BASE_RESOURCE_SIZE+Player.HIGHLIGHT_THICKNESS, 0.1)
			tween.tween_property(Player.SparkleHighlight, "LowerBound_density", 10, 0.1)
			tween.tween_property(Player.SparkleHighlight, "UpperBound_density", 11, 0.1)

func endMovement(tile: TileContainer) -> void:
	assert(Player.SparkleHighlight != null)
	
	var rowIndex: int = roundi(1.5 - Player.SparkleHighlight.position.y/BOARD_HEIGHT) + curr_lowerBorad
	var colIndex: int = roundi((Player.SparkleHighlight.position.x - SPACE_BETWEEN_TILES - GoodButton.BASE_RESOURCE_SIZE.x/2)/(GoodButton.BASE_RESOURCE_SIZE.x+SPACE_BETWEEN_TILES))
	
	var startCoord: Vector2i = getTilePos(tile)
	var endCoord: Vector2i = Vector2i(rowIndex, colIndex)
	
	if(Player.SparkleHighlight.get_parent() != self):
		endCoord = startCoord
	
	var endPos: Vector2 = Vector2(-BOARD_WIDTH/2 + SPACE_BETWEEN_TILES + endCoord.y*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES), -ResourceContainer.BASE_RESOURCE_SIZE.y/2)#-BOARD_HEIGHT*endCoord.x 
	
	var tileTween: Tween = create_tween()
	tileTween.set_parallel().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	if(endCoord != startCoord):
		if(BoardRows[endCoord.x][endCoord.y] == null):
			BoardRows[startCoord.x][startCoord.y] = null
			BoardRows[endCoord.x][endCoord.y] = tile
		else:
			var otherTilePos: Vector2 = Vector2(-BOARD_WIDTH/2 + SPACE_BETWEEN_TILES + startCoord.y*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES), -ResourceContainer.BASE_RESOURCE_SIZE.y/2)#-BOARD_HEIGHT*startCoord.x 
			BoardRows[startCoord.x][startCoord.y] = BoardRows[endCoord.x][endCoord.y]
			BoardRows[endCoord.x][endCoord.y] = tile
			
			if(startCoord.x != endCoord.x):
				BoardRows[startCoord.x][startCoord.y].reparent(get_child(startCoord.x))
			
			BoardRows[startCoord.x][startCoord.y].z_index = 1
			tileTween.tween_property(BoardRows[startCoord.x][startCoord.y], "position", otherTilePos, 0.35)
	
	#if(startCoord.x != endCoord.x):
	tile.reparent(get_child(endCoord.x))
	
	tileTween.tween_property(tile, "position", get_child(endCoord.x).global_position + endPos, 0.35)
	tileTween.finished.connect(func() -> void:
		var posAux: Vector2 = tile.global_position
		tile.top_level = false
		tile.global_position = posAux
		if(BoardRows[startCoord.x][startCoord.y] != null):
			BoardRows[startCoord.x][startCoord.y].z_index = 0)
	
	Player.SparkleHighlight.queue_free()
	
	MultiplayerHandler.send_data("tile_moved", (str(startCoord.x) + ":" + str(startCoord.y) + "::" + str(endCoord.x) + ":" + str(endCoord.y)).to_utf8_buffer())

func otherPlayer_movedTile(coordinates: String) -> void:
	var coord_str: String = coordinates.get_slice("::", 0)
	var startCoord: Vector2i = Vector2i(int(coord_str.get_slice(":", 0)), int(coord_str.get_slice(":", 1)))
	
	coord_str = coordinates.get_slice("::", 1)
	var endCoord: Vector2i = Vector2i(int(coord_str.get_slice(":", 0)), int(coord_str.get_slice(":", 1)))
	
	var tileAux: TileContainer = BoardRows[startCoord.x][startCoord.y]
	BoardRows[startCoord.x][startCoord.y] = BoardRows[endCoord.x][endCoord.y]
	BoardRows[endCoord.x][endCoord.y] = tileAux
	
	var tileTween: Tween = create_tween()
	tileTween.set_parallel().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	var newTilePos: Vector2
	tileAux = BoardRows[startCoord.x][startCoord.y]
	if(tileAux != null):
		newTilePos = Vector2(-BOARD_WIDTH/2 + SPACE_BETWEEN_TILES + startCoord.y*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES), -ResourceContainer.BASE_RESOURCE_SIZE.y/2)
		if(startCoord.x != endCoord.x):
			tileAux.reparent(get_child(startCoord.x))
		
		tileTween.tween_property(tileAux, "position", newTilePos, 0.35)
		#BoardRows[startCoord.x][startCoord.y].moveTile(newTilePos, null, Tween.TRANS_QUINT, Tween.EASE_IN)
	
	tileAux = BoardRows[endCoord.x][endCoord.y]
	if(tileAux != null):
		newTilePos = Vector2(-BOARD_WIDTH/2 + SPACE_BETWEEN_TILES + endCoord.y*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES), -ResourceContainer.BASE_RESOURCE_SIZE.y/2)
		if(startCoord.x != endCoord.x):
			tileAux.reparent(get_child(endCoord.x))
		
		tileTween.tween_property(tileAux, "position", newTilePos, 0.35)
		#BoardRows[endCoord.x][endCoord.y].moveTile(newTilePos, null, Tween.TRANS_QUINT, Tween.EASE_IN)
