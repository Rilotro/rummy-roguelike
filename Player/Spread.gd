extends Node2D

class_name Spread

const MAX_VISIBLE_ROW_SIZE: int = 5
const SPACE_BETWEEN_TILES: float = 20
const ROW_WIDTH: float = ResourceContainer.BASE_RESOURCE_SIZE.x*MAX_VISIBLE_ROW_SIZE + SPACE_BETWEEN_TILES*(MAX_VISIBLE_ROW_SIZE-1)
const ROW_HEIGHT: float = ResourceContainer.BASE_RESOURCE_SIZE.y + 15

var SpreadRows: Array[Spread_Info]
var SpreadingFirstTile: bool = false
#var SpreadingCurrTiles: Array[TileContainer]
var currSpreadingRow: Control

func _init() -> void:
	pass

func _process(delta: float) -> void:
	if(SpreadingFirstTile && !SpreadRows[SpreadRows.size()-1].Tiles[0].isBeingMoved):
		SpreadingFirstTile = false
		GameScene.MainPlayer.moveCamera(Player.CameraPosition.SPREAD)
		GameScene.MainPlayer.SpreadCameraTransition.ButtonIcon.flip_h = true
		GameScene.MainPlayer.SpreadCameraTransition.position = GameScene.MainPlayer.SpreadCameraTransition_positionSpread
	
	if(!spreadTween.is_empty()):
		handleSpreadingTiles()
	#handleMovingSpreadTiles()
	#if(SpreadingLastTile != null)

var spreadTween: Array[Tween]

func SpreadTiles(newRow: Array[TileContainer]) -> void:
	currSpreadingRow = Control.new()
	currSpreadingRow.custom_minimum_size = Vector2(ROW_WIDTH, ROW_HEIGHT)
	currSpreadingRow.position = -Vector2(ROW_WIDTH/2, ROW_HEIGHT*(SpreadRows.size()+0.5))
	currSpreadingRow.clip_contents = true
	currSpreadingRow.name = "currSpreadingRow" + str(SpreadRows.size()+1)
	add_child(currSpreadingRow)
	
	#var newSpreadRow: Spread_Info = Spread_Info.new(newRow.duplicate())
	SpreadRows.append(Spread_Info.new(newRow.duplicate()))
	
	var rowWidth: float = ROW_WIDTH
	if(newRow.size() < MAX_VISIBLE_ROW_SIZE):
		rowWidth = ResourceContainer.BASE_RESOURCE_SIZE.x*newRow.size() + SPACE_BETWEEN_TILES*(newRow.size()-1)
	
	var endPos: Vector2 = Vector2(-rowWidth/2, -ROW_HEIGHT*(SpreadRows.size()-0.5))#-----------------------------------------------------------
	var tileIndex: int = 0
	var tileStep: float = ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES
	
	SpreadingFirstTile = true
	var waitTime: float = 0
	var tileTween: Tween
	
	for tile in newRow:
		tileIndex += 1
		
		tile.Highlight.visible = false
		tile.reparent(self)
		tile.playerSpace = Player.SPREAD_SPACE
		
		tileTween = create_tween()
		tileTween.finished.connect(func() -> void: tile.reparent(currSpreadingRow))
		spreadTween.append(tileTween)
		tile.moveTile(endPos, tileTween, Tween.TRANS_BACK, Tween.EASE_IN, 0.45)
		
		waitTime = 0.4
		if(tileIndex < MAX_VISIBLE_ROW_SIZE):
			endPos.x += tileStep
			tile.onSpreadQueueEffects()
		else:
			waitTime += tile.onSpreadQueueEffects()
		
		await get_tree().create_timer(waitTime).timeout
	
	#SpreadingLastTile = newRow[newRow.size()-1]

var currTween: Tween = null

func handleSpreadingTiles() -> void:
	while(!spreadTween.is_empty() && (spreadTween[0] == null || !spreadTween[0].is_running())):
		spreadTween.remove_at(0)
		if(currTween != null):
			currTween = null
	
	if(spreadTween.is_empty()):
		return
	
	if(currTween == null && currSpreadingRow.get_child_count() >= 5 && spreadTween[0].get_total_elapsed_time() >= 0.05):
		currTween = spreadTween[0]
		
		var repositionTween: Tween = create_tween()
		repositionTween.set_parallel()
		repositionTween.set_trans(Tween.TRANS_QUINT)
		repositionTween.set_ease(Tween.EASE_OUT)
		#repositionTween.finished.connect(func() -> void: hasMovedForTile = false)
		
		var tileStep: float = ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES
		for tile in currSpreadingRow.get_children():
			if(!tile.isBeingMoved):
				repositionTween.tween_property(tile, "position", tile.position - Vector2(tileStep, 0), 0.3).set_delay(0.2)

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
