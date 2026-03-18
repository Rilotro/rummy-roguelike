extends Node2D

class_name Board

const STARTING_BOARD_ROWS: int = 2
const BOARD_COLOR: Color = Color(0.588, 0.431, 0.294, 1)#--------------------------------------------------------------------------------------------------------------------------------------
const ROW_TILE_SIZE: int = 10
const SPACE_BETWEEN_TILES: float = 20
const BOARD_HEIGHT: float = 120
const BOARD_WIDTH: float = ROW_TILE_SIZE*TileContainer.TILE_BASE_SIZE.x + (ROW_TILE_SIZE+1)*SPACE_BETWEEN_TILES
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
	DECK, RIVER, SELECTION
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
	get_child(index.x).add_child(newTile)
	
	var endPos: Vector2 = Vector2(95*index.y - 465, -TileContainer.TILE_BASE_SIZE.y/2)
	delayForAdditionalDraw += 0.1
	await get_tree().create_timer(delayForAdditionalDraw).timeout
	match tileOrigin:
		TileOrigin.DECK:
			newTile.modulate.a = 0
			newTile.scale = Vector2(0.1, 0.1)
			newTile.global_position = GameScene.Game.PB.PlayerDeck.global_position
			var displacement: Vector2 = Vector2(randf_range(0, 170), randf_range(-230, 0))
			while(displacement.length() < 150):
				displacement = Vector2(randf_range(-170, 0), randf_range(-230, 0))
			
			var tween: Tween = create_tween()
			tween.set_parallel()
			tween.tween_property(newTile, "modulate:a", 1, TileContainer.MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(newTile, "scale", Vector2(1, 1), TileContainer.MOVE_TILE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			
			await newTile.moveTile(newTile.position+displacement, tween, Tween.TRANS_QUINT, Tween.EASE_OUT)
			await newTile.moveTile(endPos, null, Tween.TRANS_QUINT, Tween.EASE_IN)
	
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

func getActualBoardSpace(index: int) -> int:
	var space: int = 0
	for tile in BoardRows[index]:
		if(tile == null):
			space += 1
	
	return space
