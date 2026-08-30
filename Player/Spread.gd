extends Node2D

class_name Spread

const MAX_VISIBLE_ROW_SIZE: int = 5
const TILE_SPACING: Vector2 = Vector2(20, 15)
const ROW_WIDTH: float = ResourceContainer.BASE_RESOURCE_SIZE.x*MAX_VISIBLE_ROW_SIZE + TILE_SPACING.x*(MAX_VISIBLE_ROW_SIZE-1)
const ROW_HEIGHT: float = ResourceContainer.BASE_RESOURCE_SIZE.y + TILE_SPACING.y

var SpreadRows: Array[Spread_Info]
var SpreadingFirstTile: bool = false
#var SpreadingCurrTiles: Array[TileContainer]
var currSpreadingRow: Control

func _init() -> void:
	pass

func _process(_delta: float) -> void:
	if(SpreadingFirstTile):
		SpreadingFirstTile = false
		var windowSize: Vector2 = get_viewport_rect().size
		var tween: Tween = create_tween()
		tween.tween_property(GameScene.MainPlayer.Camera, "position", Vector2(GameScene.MainPlayer.PlayerSpread.position.x, Board.BOARD_HEIGHT/2 - windowSize.y/2), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	#handleMovingSpreadTiles()
	#if(SpreadingLastTile != null)

#var spreadTween: Array[Tween]

func SpreadTiles(newRow: Array[TileContainer]) -> void:
	#var parent: Player = get_parent()
	#currSpreadingRow = Control.new()
	#currSpreadingRow.custom_minimum_size = Vector2(ROW_WIDTH, ROW_HEIGHT)
	#currSpreadingRow.position = -Vector2(ROW_WIDTH/2, ROW_HEIGHT*(SpreadRows.size()+0.5))
	#currSpreadingRow.clip_contents = true
	#currSpreadingRow.name = "currSpreadingRow" + str(SpreadRows.size()+1)
	#add_child(currSpreadingRow)
	#
	##var newSpreadRow: Spread_Info = Spread_Info.new(newRow.duplicate())
	#SpreadRows.append(Spread_Info.new(newRow.duplicate()))
	#
	#var rowWidth: float = ROW_WIDTH
	#if(newRow.size() < MAX_VISIBLE_ROW_SIZE):
		#rowWidth = ResourceContainer.BASE_RESOURCE_SIZE.x*newRow.size() + SPACE_BETWEEN_TILES*(newRow.size()-1)
	#
	#var endPos: Vector2 = Vector2(-rowWidth/2, -ROW_HEIGHT*(SpreadRows.size()-0.5))#-----------------------------------------------------------
	#var tileIndex: int = 0
	#var tileStep: float = ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES
	#
	#SpreadingFirstTile = true
	#var waitTime: float = 0
	#var tileTween: Tween
	#
	#for tile in newRow:
		#tileIndex += 1
		#
		#tile.Highlight.visible = false
		#tile.reparent(self)
		##tile.playerSpace = Player.SPREAD_SPACE
		#
		#var reposDelay: float = 0
		#
		#if(tileIndex > MAX_VISIBLE_ROW_SIZE):
			#await get_tree().create_timer(0.5).timeout
			#var reposTween: Tween = create_tween()
			#reposTween.set_parallel().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)#.set_delay(0.2)
			#for tile_toBeMoved in currSpreadingRow.get_children():
				#if(tile_toBeMoved != tile):
					#reposTween.tween_property(tile_toBeMoved, "position", tile_toBeMoved.position - Vector2(tileStep, 0), 0.4)
			#
			#reposDelay = 0.3
		#
		#tileTween = create_tween()
		#tileTween.finished.connect(func() -> void: 
			#tile.reparent(currSpreadingRow)
			#tile.z_index = 0
			#tile.handleQueuedSpread())
		#
		#
		#tile.z_index = 1
		#
		#tileTween.tween_property(tile, "position", endPos, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(reposDelay)
		#
		##tile.moveTile(endPos, tileTween, Tween.TRANS_BACK, Tween.EASE_IN, 0.45)
		#
		#waitTime = 0.4
		#if(tileIndex < MAX_VISIBLE_ROW_SIZE):
			#endPos.x += tileStep
			#tile.onSpreadQueueEffects()
		#else:
			#waitTime += tile.onSpreadQueueEffects()
		#
		#await get_tree().create_timer(waitTime).timeout
	
	#SpreadingLastTile = newRow[newRow.size()-1]
	
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
