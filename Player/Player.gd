extends Node2D

class_name Player

const PLAYER_CONTAINER: ResourceContainer.ContainerType = ResourceContainer.ContainerType.PLAYER_TILE#----------------------------------------------------------------------
const BOARD_SPACE: TileContainer.PlayerSpace = TileContainer.PlayerSpace.BOARD
const SPREAD_SPACE: TileContainer.PlayerSpace = TileContainer.PlayerSpace.SPREAD
const RIVER_SPACE: TileContainer.PlayerSpace = TileContainer.PlayerSpace.RIVER

var GameBoard: Board
var PlayerDeck: Deck

static var selectedTiles: Array[TileContainer]

func _init() -> void:
	GameBoard = Board.new()
	GameBoard.name = "GameBoard"
	add_child(GameBoard)
	
	PlayerDeck = Deck.new()
	PlayerDeck.name = "PlayerDeck"
	PlayerDeck.position = Vector2((TileContainer.TILE_BASE_SIZE.x - Board.BOARD_WIDTH)/2, -(Board.BOARD_HEIGHT)*(GameBoard.BoardRows.size()-0.5) - TileContainer.TILE_BASE_SIZE.y/2 - 10)
	add_child(PlayerDeck)

func _ready() -> void:
	Draw(14)

func Draw(drawNumber: int = 1) -> void:
	if(drawNumber > PlayerDeck.DeckTiles.size()):
		drawNumber = PlayerDeck.DeckTiles.size()
	
	var newTile: TileContainer
	for i in range(drawNumber):
		##THE BACK IS NOT PlayerDeck.DeckTiles[0]!!!
		newTile = TileContainer.new(PlayerDeck.popTile(true), PLAYER_CONTAINER, -1, BOARD_SPACE)
		
		GameBoard.addTile(newTile)

func containerPressed(tileContainer: TileContainer) -> void:
	if(selectedTiles.has(tileContainer)):
		selectedTiles.erase(tileContainer)
	else:
		selectedTiles.append(tileContainer)
