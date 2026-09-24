extends Node2D

class_name Spread

const MAX_VISIBLE_ROW_SIZE: int = 5
const TILE_SPACING: Vector2 = Vector2(20, 15)
const ROW_WIDTH: float = GoodButton.BASE_RESOURCE_SIZE.x*MAX_VISIBLE_ROW_SIZE + TILE_SPACING.x*(MAX_VISIBLE_ROW_SIZE-1)
const ROW_HEIGHT: float = GoodButton.BASE_RESOURCE_SIZE.y + TILE_SPACING.y

var SpreadRows: Array[Spread_Info]
var SpreadingFirstTile: bool = false
#var SpreadingCurrTiles: Array[TileContainer]
var currSpreadingRow: Control

#func _init() -> void:
	#pass

#var spreadTween: Array[Tween]

func handleMovingTile(tile: TileContainer) -> void:
	if(!SpreadRows.is_empty()):
		#var tileRelPos: Vector2 = tile.global_position - (get_parent() as Player).position - position
		var minDis: float
		var closestRow_index: int = -1
		
		for index in range(SpreadRows.size()):
			#if(index == get_child_count()-1):
				#continue
			
			if(closestRow_index == -1 || abs(tile.position.y - GoodButton.BASE_RESOURCE_SIZE.y/2 - get_children()[index].position.y + ROW_HEIGHT/2) < minDis):
				closestRow_index = index#get_children()[index]
				minDis = abs(tile.position.y - get_children()[index].position.y + ROW_HEIGHT/2)
		
		var finalPos: Vector2 = get_children()[closestRow_index].position + Vector2(get_children()[closestRow_index].size.x, GoodButton.BASE_RESOURCE_SIZE.y)/2
		if(Player.SparkleHighlight.position != finalPos):
			Player.SparkleHighlight.is_positive = SpreadRows[closestRow_index].isAppendEligible(tile)
			
			var finalSize_x: float = (GoodButton.BASE_RESOURCE_SIZE.x + TILE_SPACING.x)*(SpreadRows[closestRow_index].Tiles.size()-1) + GoodButton.BASE_RESOURCE_SIZE.x
			if(finalSize_x > GameScene.window_size.x):
				finalSize_x = GameScene.window_size.x
			
			var finalSize: Vector2 = Vector2(finalSize_x, GoodButton.BASE_RESOURCE_SIZE.y)
			var highlightTween: Tween = create_tween().set_parallel()
			highlightTween.tween_property(Player.SparkleHighlight, "position", finalPos, 0.1)
			highlightTween.tween_property(Player.SparkleHighlight, "size", finalSize + Board.HIGHLIGHT_THICKNESS, 0.1)
			highlightTween.tween_property(Player.SparkleHighlight.hole, "size", finalSize, 0.1)
			highlightTween.tween_property(Player.SparkleHighlight, "LowerBound_density", 10 + 3*(SpreadRows[closestRow_index].Tiles.size()-1), 0.1)
			highlightTween.tween_property(Player.SparkleHighlight, "UpperBound_density", 11 + 3*(SpreadRows[closestRow_index].Tiles.size()-1), 0.1)
			
	else:
		Player.SparkleHighlight.visible = false

func endMovement(tile: TileContainer) -> void:
	if(!SpreadRows.is_empty()):
		var minDis: float
		var closestRow_index: int = -1
		
		for index in range(SpreadRows.size()):
			#if(index == get_child_count()-1):
				#continue
			
			if(closestRow_index == -1 || abs(tile.position.y - GoodButton.BASE_RESOURCE_SIZE.y/2 - get_children()[index].position.y + ROW_HEIGHT/2) < minDis):
				closestRow_index = index#get_children()[index]
				minDis = abs(tile.position.y - get_children()[index].position.y + ROW_HEIGHT/2)
		
		if(SpreadRows[closestRow_index].isAppendEligible(tile)):
			var msg_params: String = ""
			if(MultiplayerHandler.currPlayer != null):
				var tilePos: Vector2i = Player.GameBoard.getTilePos(tile)
				msg_params = str(MultiplayerHandler.currPlayer.ID) + "::" + str(closestRow_index) + "::" + str(tilePos.x) + ":" + str(tilePos.y) + "::"
			
			tile.enabled = false
			SpreadRows[closestRow_index].updateSpreadInfo(tile.tile, tile.position.x <= 0)
			if(tile.position.x <= 0):
				msg_params += str(1)
				SpreadRows[closestRow_index].Tiles.insert(0, tile)
			else:
				msg_params += str(0)
				SpreadRows[closestRow_index].Tiles.append(tile)
			
			MultiplayerHandler.send_data("spread_row_append", msg_params.to_utf8_buffer())
			
			Player.GameBoard.removeTile(tile)
			
			var rowLength: float = SpreadRows[closestRow_index].Tiles.size()*GoodButton.BASE_RESOURCE_SIZE.x + (SpreadRows[closestRow_index].Tiles.size()-1)*TILE_SPACING.x
			var endPos: Vector2 = Vector2(GameScene.window_size.x/2 - rowLength/2, SpreadRows[closestRow_index].Tiles[1].position.y)
			var spreadTween: Tween = create_tween()
			spreadTween.set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			
			for tilee in SpreadRows[closestRow_index].Tiles:
				if(tilee == tile):
					spreadTween.tween_property(tile, "position", endPos + get_children()[closestRow_index].position, 0.5)
				else:
					spreadTween.tween_property(tilee, "position", endPos, 0.5)
				
				endPos.x += TileContainer.BASE_RESOURCE_SIZE.x + TILE_SPACING.x
			
			spreadTween.finished.connect(func() -> void:
				tile.reparent(get_children()[closestRow_index])
				if(tile.position.x <= 0):
					get_children()[closestRow_index].move_child(tile, 0)
				
				tile.activate(false))
			
			Player.SparkleHighlight.queue_free()
		else:
			Player.GameBoard.endMovement(tile)
	else:
		Player.GameBoard.endMovement(tile)

func MultiplayerAppend(params: String, source: int) -> void:
	#var msg_params: String = str(MultiplayerHandler.currPlayer.ID) + "::" + str(closestRow_index) + "::" + str(tilePos.x) + ":" + str(tilePos.y) + "::"
	var rowIndex: int = int(params.get_slice("::", 1))
	var boardPos_String: String = params.get_slice("::", 2)
	var tile: TileContainer = Player.GameBoard.BoardRows[int(boardPos_String.get_slice(":", 0))][int(boardPos_String.get_slice(":", 1))]
	var isFirst: bool = bool(int(params.get_slice("::", 3)))
	
	GameScene.MainPlayer.getPlayerButton(int(source)).SpreadAppend_View(SpreadRows[rowIndex].Tiles.duplicate(), tile, isFirst)
	
	tile.reparent(self)
	SpreadRows[rowIndex].updateSpreadInfo(tile.tile, isFirst)
	if(isFirst):
		SpreadRows[rowIndex].Tiles.insert(0, tile)
	else:
		SpreadRows[rowIndex].Tiles.append(tile)
	
	Player.GameBoard.removeTile(tile)
	
	var rowLength: float = SpreadRows[rowIndex].Tiles.size()*GoodButton.BASE_RESOURCE_SIZE.x + (SpreadRows[rowIndex].Tiles.size()-1)*TILE_SPACING.x
	var endPos: Vector2 = Vector2(GameScene.window_size.x/2 - rowLength/2, SpreadRows[rowIndex].Tiles[1].position.y)
	var spreadTween: Tween = create_tween()
	spreadTween.set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	for tilee in SpreadRows[rowIndex].Tiles:
		if(tilee == tile):
			spreadTween.tween_property(tile, "position", endPos + get_children()[rowIndex].position, 0.5)
		else:
			spreadTween.tween_property(tilee, "position", endPos, 0.5)
		
		endPos.x += TileContainer.BASE_RESOURCE_SIZE.x + TILE_SPACING.x
	
	spreadTween.finished.connect(func() -> void:
		tile.reparent(get_children()[rowIndex])
		if(isFirst):
			get_children()[rowIndex].move_child(tile, 0)
		
		tile.activate(false))

func SpreadTiles(newRow: Array[TileContainer]) -> void:
	currSpreadingRow = Control.new()
	currSpreadingRow.size = Vector2(GameScene.window_size.x, ROW_HEIGHT)
	currSpreadingRow.position = -Vector2(currSpreadingRow.size.x/2, ROW_HEIGHT*(SpreadRows.size()+0.5))
	currSpreadingRow.clip_contents = true
	currSpreadingRow.name = "SpreadingRow" + str(SpreadRows.size()+1)
	add_child(currSpreadingRow)
	
	SpreadRows.append(Spread_Info.new(newRow))
	
	var rowLength: float = newRow.size()*TileContainer.BASE_RESOURCE_SIZE.x + (newRow.size()-1)*TILE_SPACING.x
	var endPos: Vector2 = Vector2(position.x - rowLength/2, -ROW_HEIGHT*(SpreadRows.size()-0.5))
	var spreadTween: Tween = create_tween()
	var tweenDelay: float = 0
	var colCount: int = 0
	
	if(rowLength > GameScene.window_size.x):
		endPos.x = position.x - GameScene.window_size.x/2
	
	spreadTween.set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	for tile in newRow:
		spreadTween.tween_property(tile, "position", endPos, 0.5).set_delay(tweenDelay)
		tweenDelay += 0.1
		endPos.x += TileContainer.BASE_RESOURCE_SIZE.x + TILE_SPACING.x
	
	await spreadTween.finished
	
	for tile in newRow:
		colCount += 1
		tile.reparent(currSpreadingRow)
		tile.z_index = 0
		tile.name = "SpreadTile" + str(SpreadRows.size()) + "_" + str(colCount)

func getTile(tileInfo: Tile) -> TileContainer:
	for Row in SpreadRows:
		for tile in Row.Tiles:
			if(tile.resource == tileInfo):
				return tile
	
	return null

func getSpreadRow(tile: TileContainer) -> Spread_Info:
	for Row in SpreadRows:
		if(Row.Tiles.has(tile)):
			return Row
	
	return null

#func handleMovingSpreadTiles() -> void:
	#for tile in SpreadingCurrTiles:
		#if(!tile.isBeingMoved):
			#tile.reparent(currSpreadingRow)
		#else:
			#break
	#
	#var tileRemoved: bool = false
	#while(!SpreadingCurrTiles.is_empty() && SpreadingCurrTiles[0] != null && !SpreadingCurrTiles[0].isBeingMoved && !SpreadingCurrTiles[0].spreadQueued && !SpreadingCurrTiles[0].isActingOnSpreadEffects):
		#SpreadingCurrTiles.remove_at(0)
		#tileRemoved = true
	#
	#if(tileRemoved && currSpreadingRow != null && currSpreadingRow.get_child_count() >= MAX_VISIBLE_ROW_SIZE && !SpreadingCurrTiles.is_empty()):#--------------------------------------------------
		##moveTiles = true
		#var tileStep: float = ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES
		#for tile in currSpreadingRow.get_children():
			#if(!tile.isBeingMoved):
				#tile.moveTile(tile.position - Vector2(tileStep, 0), null, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.4)
	
	#if(SpreadingCurrTiles.is_empty()):
		#currSpreadingRow = null
