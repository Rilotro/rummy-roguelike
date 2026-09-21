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
		var closestRow: Control = null
		#print("HERE0 - " + str(tile.position))
		
		for index in range(SpreadRows.size()):
			#if(index == get_child_count()-1):
				#continue
			
			if(closestRow == null || abs(tile.position.y - GoodButton.BASE_RESOURCE_SIZE.y/2 - get_children()[index].position.y + ROW_HEIGHT/2) < minDis):
				closestRow = get_children()[index]
				minDis = abs(tile.position.y - closestRow.position.y + ROW_HEIGHT/2)
		
		var finalPos: Vector2 = closestRow.position + Vector2(closestRow.size.x, GoodButton.BASE_RESOURCE_SIZE.y)/2
		if(Player.GameBoard.endPosHighlight.position != finalPos):
			create_tween().tween_property(Player.GameBoard.endPosHighlight, "position", finalPos, 0.1)
	else:
		Player.GameBoard.endPosHighlight.visible = false

func SpreadTiles(newRow: Array[TileContainer]) -> void:
	currSpreadingRow = Control.new()
	currSpreadingRow.custom_minimum_size = Vector2(ROW_WIDTH, ROW_HEIGHT)
	currSpreadingRow.position = -Vector2(ROW_WIDTH/2, ROW_HEIGHT*(SpreadRows.size()+0.5))
	currSpreadingRow.clip_contents = true
	currSpreadingRow.name = "SpreadingRow" + str(SpreadRows.size()+1)
	add_child(currSpreadingRow)
	
	SpreadRows.append(Spread_Info.new(newRow))
	
	var rowLength: float = newRow.size()*TileContainer.BASE_RESOURCE_SIZE.x + (newRow.size()-1)*TILE_SPACING.x
	var endPos: Vector2 = Vector2(position.x - rowLength/2, -ROW_HEIGHT*(SpreadRows.size()-0.5))
	var spreadTween: Tween = create_tween()
	var tweenDelay: float = 0
	var colCount: int = 0
	
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


#var currTween: Tween = null
#
#func handleSpreadingTiles() -> void:
	#while(!spreadTween.is_empty() && (spreadTween[0] == null || !spreadTween[0].is_running())):
		#spreadTween.remove_at(0)
		#if(currTween != null):
			#currTween = null
	#
	#if(spreadTween.is_empty()):
		#return
	#
	#if(currTween == null && currSpreadingRow.get_child_count() >= 5 && spreadTween[0].get_total_elapsed_time() >= 0.05):
		#currTween = spreadTween[0]
		#
		#var repositionTween: Tween = create_tween()
		#repositionTween.set_parallel()
		#repositionTween.set_trans(Tween.TRANS_QUINT)
		#repositionTween.set_ease(Tween.EASE_OUT)
		##repositionTween.finished.connect(func() -> void: hasMovedForTile = false)
		#
		#var tileStep: float = ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES
		#for tile in currSpreadingRow.get_children():
			#if(!tile.isBeingMoved):
				#repositionTween.tween_property(tile, "position", tile.position - Vector2(tileStep, 0), 0.3).set_delay(0.2)

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
