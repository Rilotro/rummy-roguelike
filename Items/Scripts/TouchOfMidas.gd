extends Item

class_name TouchOfMidas

var MidasSparkle: Node2D

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Touch of Midas.png")
	uses = 3
	
	consumable = true
	target = ItemTarget.VIABLE_BOARD_TILE
	
	super(3, "Touch of Midas", newGame)

func getShopPrice() -> int:
	return randi_range(70, 100)

func endItemUse(canceled: bool) -> void:
	MidasSparkle.queue_free()

func use() -> bool:
	if(!Game.getTurn()):
		return false
	
	MidasSparkle = load("res://scenes/sparkle_road.tscn").instantiate()#---------------------------
	Game.add_child(MidasSparkle)
	MidasSparkle.change_road(Game.get_global_mouse_position(), Vector2(20, 20), 0.0)
	MidasSparkle.is_TopLevel = true
	
	Game.TurnButton.disabled = true
	#Game.currentItemTarget = GameScene.ItemTarget.VIABLE_TILE
	return true

func updateWhileUsing(delta: float) -> void:
	if(MidasSparkle != null):
		MidasSparkle.global_position = Game.get_global_mouse_position()

func isTileValid(tile: Tile) -> bool:
	if(!tile.is_on_Board() || tile.getTileData().joker_id >= 0 || tile.getTileData().rarity == Tile_Info.Rarity.GOLD):
		return false
	
	return true

func useOnTile(tile: Tile) -> void:
	var tileInfo: Tile_Info = tile.getTileData()
	
	if(!isTileValid(tile)):
		return
	
	endItemUse(false)
	
	tileInfo.setRarity(Tile_Info.Rarity.GOLD)
	tileInfo.effects = []
	tile.change_info()
	
	Game.endItemUse()
