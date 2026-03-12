extends Item

class_name MonkeysPaw

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Monkey's Paw.png")
	
	target = ItemTarget.VIABLE_BOARD_TILE
	
	super(6, "Monkey's Paw", newGame)

func getShopPrice() -> int:
	return randi_range(60, 85)

func effectOnGet() -> void:
	Item.singularItems.append(6)

func use() -> bool:
	if(!Game.getTurn()):
		return false
	
	#Game.currentItemTarget = GameScene.ItemTarget.VIABLE_TILE
	Game.TurnButton.disabled = true
	
	return true

func isTileViable(tile: Tile) -> bool:
	if(!tile.is_on_Board() || tile.getTileData().rarity == Tile_Info.Rarity.PORCELAIN):
		return false
	
	return true

func useOnTile(tile: Tile) -> void:
	return
