extends Item

class_name MonkeysPaw

func _init() -> void:
	target = ItemTarget.VIABLE_BOARD_TILE
	
	super(6)

func getImage() -> Texture:
	return load("res://Items/Sprites/Monkey's Paw.png")

func getIDName() -> String:
	return "Monkey's Paw"

func getShopPrice() -> int:
	return randi_range(60, 85)

func effectOnGet() -> void:
	Item.singularItems.append(6)

func use() -> bool:
	if(!GameScene.myTurn):
		return false
	
	#Game.currentItemTarget = GameScene.ItemTarget.VIABLE_TILE
	GameScene.PlayerTurnButton.disabled = true
	
	return true

func isTileViable(tile: TileContainer) -> bool:
	if(!tile.is_on_Board() || tile.resource.rarity == Tile.Rarity.PORCELAIN):
		return false
	
	return true

func useOnTile(tile: TileContainer) -> void:
	return
