extends  Control

class_name Shop

const MAIN_BACKGROUND_COLOR: Color = Color(0, 0.31, 0.53, 1)
const TILE_IMAGE_SCALE_REDUCTOR: float = 1.5
const SELECTION_SEPARATION: Vector2 = Vector2(20, 0)
const NEXT_DRAW_SEPARATION: Vector2 = Vector2(10, 0)

var Background: Sprite2D
var MainShopBackground: Sprite2D
var SelectionBackground: Sprite2D
var SelectionView: Control
var NextDrawBackground: Sprite2D
var NextDrawView: Control
var ExitShop: GoodButton

func _init() -> void:
	Background = Sprite2D.new()
	Background.texture = CanvasTexture.new()
	Background.region_enabled = true
	Background.self_modulate = Color.BLACK
	Background.self_modulate.a = 100.0/255
	Background.name = "Background"
	add_child(Background)
	
	MainShopBackground = Sprite2D.new()
	MainShopBackground.texture = CanvasTexture.new()
	MainShopBackground.region_enabled = true
	MainShopBackground.self_modulate = MAIN_BACKGROUND_COLOR
	MainShopBackground.name = "MainShopBackground"
	add_child(MainShopBackground)
	
	SelectionBackground = Sprite2D.new()
	SelectionBackground.texture = CanvasTexture.new()
	SelectionBackground.region_enabled = true
	SelectionBackground.self_modulate = MAIN_BACKGROUND_COLOR - 0.1*Color.WHITE
	SelectionBackground.self_modulate.a = 1
	SelectionBackground.name = "SelectionBackground"
	add_child(SelectionBackground)
	
	SelectionView = Control.new()
	SelectionView.name = "SelectionView"
	add_child(SelectionView)
	
	NextDrawBackground = Sprite2D.new()
	NextDrawBackground.texture = CanvasTexture.new()
	NextDrawBackground.region_enabled = true
	NextDrawBackground.self_modulate = MAIN_BACKGROUND_COLOR - 0.1*Color.WHITE
	NextDrawBackground.self_modulate.a = 1
	NextDrawBackground.name = "NextDrawBackground"
	add_child(NextDrawBackground)
	
	NextDrawView = Control.new()
	NextDrawView.name = "NextDrawView"
	add_child(NextDrawView)
	
	ExitShop = GoodButton.new("", Color.WHITE, Vector2(-1, -1), load("res://UI/Exit.png"))#, GoodButton.ButtonType.EXIT_SHOP
	ExitShop.scale = Vector2(0.5, 0.5)
	ExitShop.name = "ExitShop"
	add_child(ExitShop)
	
	ExitShop.press.connect(func() -> void:
		visible = false
		GameScene.MainPlayer.ExpBar.z_index = 0)

func _ready() -> void:
	var windowSize: Vector2 = get_viewport_rect().size
	
	size = windowSize
	
	Background.region_rect = Rect2(Vector2(0, 0), windowSize)
	Background.position = windowSize/2
	
	MainShopBackground.region_rect = Rect2(Vector2(0, 0), windowSize*0.9)
	MainShopBackground.position = windowSize/2
	
	SelectionView.size.x = 3*TileContainer.BASE_RESOURCE_SIZE.x/TILE_IMAGE_SCALE_REDUCTOR + 4*SELECTION_SEPARATION.x
	SelectionView.size.y = 1.2*TileContainer.BASE_RESOURCE_SIZE.y/TILE_IMAGE_SCALE_REDUCTOR
	SelectionView.position.x = windowSize.x/2 - SelectionView.size.x/2
	SelectionView.position.y = windowSize.y*0.3
	
	NextDrawView.size.x = windowSize.x*0.8
	NextDrawView.size.y = SelectionView.size.y
	NextDrawView.position.x = windowSize.x*0.1
	NextDrawView.position.y = windowSize.y*0.6
	
	reloadShop()
	
	ExitShop.position = Vector2(windowSize.x*0.95 - ExitShop.size.x/2, windowSize.y*0.05)

func reloadShop() -> void:
	for child in SelectionView.get_children():
		child.queue_free()
	
	for child in NextDrawView.get_children():
		child.queue_free()
	
	SelectionBackground.region_rect.size = SelectionView.size
	SelectionBackground.position = SelectionView.position + SelectionBackground.region_rect.size/2
	
	NextDrawBackground.region_rect.size = NextDrawView.size
	NextDrawBackground.position = NextDrawView.position + NextDrawBackground.region_rect.size/2
	
	var tilePos: Vector2 = Vector2(SELECTION_SEPARATION.x, 0.1*TileContainer.BASE_RESOURCE_SIZE.y/TILE_IMAGE_SCALE_REDUCTOR)
	var tempTile: TileContainer
	
	for i in range(3):
		tempTile = TileContainer.new(Tile.new(1, Tile.BASE_COLOR, randi_range(0, Tile.Rarity.size()-1), randi_range(0, 20)), TileContainer.Type.SELECTION)
		tempTile.scale /= TILE_IMAGE_SCALE_REDUCTOR
		tempTile.position = tilePos
		SelectionView.add_child(tempTile)
		
		tilePos.x += TileContainer.BASE_RESOURCE_SIZE.x/TILE_IMAGE_SCALE_REDUCTOR + SELECTION_SEPARATION.x
	
	tilePos = Vector2(NEXT_DRAW_SEPARATION.x, 0.1*TileContainer.BASE_RESOURCE_SIZE.y/TILE_IMAGE_SCALE_REDUCTOR)
	
	var RowSize: float = 13*TileContainer.BASE_RESOURCE_SIZE.x/TILE_IMAGE_SCALE_REDUCTOR + 12*NEXT_DRAW_SEPARATION.x
	if(RowSize < NextDrawView.size.x):
		tilePos.x = (NextDrawView.size.x - RowSize)/2
		NextDrawBackground.region_rect.size.x = RowSize + NEXT_DRAW_SEPARATION.x * 2
	
	var deckCount: int = GameScene.MainPlayer.PlayerDeck.DeckTiles.size()-1
	for i in range(13):
		tempTile = TileContainer.new(GameScene.MainPlayer.PlayerDeck.DeckTiles[deckCount-i], TileContainer.Type.NEXT_DRAW)
		tempTile.scale /= TILE_IMAGE_SCALE_REDUCTOR
		tempTile.position = tilePos
		NextDrawView.add_child(tempTile)
		
		tilePos.x += TileContainer.BASE_RESOURCE_SIZE.x/TILE_IMAGE_SCALE_REDUCTOR + NEXT_DRAW_SEPARATION.x
