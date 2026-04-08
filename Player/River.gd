extends Node2D

class_name River

const MAX_TILES_PER_ROW: int = 12
const SPACE_BETWEEN_TILES: Vector2 = Vector2(20, 15)
const ROW_WIDTH: float = MAX_TILES_PER_ROW*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_TILES.x) - SPACE_BETWEEN_TILES.x#-----------------

#static var 

static var river: Array[TileContainer]
static var bait: int = 0

#func addTile(newTile) -> void:
	#var oldSize: int = river.size()
	#
	#river.append(newTile)

func DiscardTiles(newTiles: Array[TileContainer]) -> void:
	bait += newTiles.size()
	
	GameScene.BaitButton.changeVisuals(StringsManager.UIStrings["BAIT"]["TEXT"][0]+str(bait))
	
	var oldSize: int = river.size()
	
	for tile in newTiles:
		tile.reparent(self)
		tile.playerSpace = Player.RIVER_SPACE
		tile.DIS_ENable(false)
		tile.Highlight.visible = false
		tile.Highlight.self_modulate = TileContainer.HIGHLIGHT_RIVER_COLOR
	
	river.append_array(newTiles)
	
	REpositionTiles()
	
	#var startPos_X: float = ResourceContainer.BASE_RESOURCE_SIZE.x/2
	#var rowNumber: int = ceili(river.size()/float(MAX_TILES_PER_ROW))
	#var oldRowNumber: int = ceili(oldSize/float(MAX_TILES_PER_ROW))
	#var currPos: Vector2 = Vector2(startPos_X, -(rowNumber*(ResourceContainer.BASE_RESOURCE_SIZE.y+SPACE_BETWEEN_TILES.y) - SPACE_BETWEEN_TILES.y)/2)
	#var posStep: Vector2 = ResourceContainer.BASE_RESOURCE_SIZE + SPACE_BETWEEN_TILES
	#var rowIndex: int = 0
	#
	#if(rowNumber > oldRowNumber):#-----------------------------------------------------------------------------------------------------------------------------------------------
		#for tile in river:
			#tile.moveTile(currPos, null, Tween.TRANS_BACK, Tween.EASE_IN, 0.45)
			#await get_tree().create_timer(0.4).timeout
			#
			#rowIndex += 1
			#if(rowIndex >= MAX_TILES_PER_ROW):
				#rowIndex = 0
				#currPos.y += posStep.y
				#currPos.x = startPos_X
			#else:
				#currPos.x += posStep.x
	#else:
		#rowIndex = oldSize - MAX_TILES_PER_ROW*(rowNumber-1)
		#currPos.x += rowIndex*posStep.x
		#for tile in newTiles:
			#tile.moveTile(currPos, null, Tween.TRANS_BACK, Tween.EASE_IN, 0.45)
			#await get_tree().create_timer(0.4).timeout
			#
			#currPos.x += posStep.x

func Draw(ammount: int = 0, startingTile: TileContainer = null) -> void:
	if(ammount <= 0):
		return
	
	print("HERE1")
	
	var startingIndex: int = river.find(startingTile)
	if(startingIndex < 0):
		startingIndex = river.size()-1
	
	while(ammount > 0 && startingIndex >= 0 && !river.is_empty()):
		GameScene.MainPlayer.GameBoard.addTile(river.pop_at(startingIndex), Board.TileOrigin.RIVER)
		startingIndex -= 1
		ammount -= 1
	
	REpositionTiles()

func REpositionTiles() -> void:
	var startPos_X: float = ResourceContainer.BASE_RESOURCE_SIZE.x/2
	var rowNumber: int = ceili(river.size()/float(MAX_TILES_PER_ROW))
	var currPos: Vector2 = Vector2(startPos_X, -(rowNumber*(ResourceContainer.BASE_RESOURCE_SIZE.y+SPACE_BETWEEN_TILES.y) - SPACE_BETWEEN_TILES.y)/2)
	var posStep: Vector2 = ResourceContainer.BASE_RESOURCE_SIZE + SPACE_BETWEEN_TILES
	var rowIndex: int = 0
	
	for tile in river:
		if(tile.position == currPos):
			continue
		
		tile.moveTile(currPos, null, Tween.TRANS_BACK, Tween.EASE_IN, 0.45)
		await get_tree().create_timer(0.4).timeout
		
		rowIndex += 1
		if(rowIndex >= MAX_TILES_PER_ROW):
			rowIndex = 0
			currPos.y += posStep.y
			currPos.x = startPos_X
		else:
			currPos.x += posStep.x
#func DrainRiver(spreadTile: TileContainer) -> void:
	#var updatedRiver: Array[TileContainer]
	#for tile in river:
		#if(tile == spreadTile):
			#break
		#
		#updatedRiver.append(tile)
	#
	#for i in range(updatedRiver.size()+1, river.size()):
		#GameScene.MainPlayer.GameBoard.addTile(river[i], Board.TileOrigin.RIVER)
	#
	#river = updatedRiver
