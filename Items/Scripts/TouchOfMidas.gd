extends Item

class_name TouchOfMidas

var MidasSparkle: Node2D

func _init() -> void:
	uses = 3
	
	consumable = true
	target = ItemTarget.VIABLE_BOARD_TILE
	
	super(3)

func getImage() -> Texture:
	return load("res://Items/Sprites/Touch of Midas.png")

func getIDName() -> String:
	return "Touch of Midas"

func getShopPrice() -> int:
	return randi_range(70, 100)

func endItemUse(canceled: bool) -> void:
	MidasSparkle.queue_free()
	GameScene.PlayerTurnButton.DIS_ENable(true)

func use() -> bool:
	if(!GameScene.myTurn):
		return false
	
	MidasSparkle = SparkleContainer.new(Vector2(10, 10), Vector2i(20, 20), SparkleContainer.HoleShape.NULL, Vector2(-1, -1), true)# = load("res://scenes/sparkle_road.tscn").instantiate()#---------------------------
	GameScene.Game.add_child(MidasSparkle)
	#MidasSparkle.change_road(Game.get_global_mouse_position(), Vector2(20, 20), 0.0)
	#MidasSparkle.is_TopLevel = true
	
	GameScene.PlayerTurnButton.DIS_ENable(false)
	
	#Game.TurnButton.disabled = true
	#Game.currentItemTarget = GameScene.ItemTarget.VIABLE_TILE
	return true

func updateWhileUsing(delta: float) -> void:
	if(MidasSparkle != null):
		MidasSparkle.global_position = GameScene.Game.get_global_mouse_position()

func isTileValid(tile: TileContainer) -> bool:
	if(tile.container_type != ResourceContainer.ContainerType.PLAYER_TILE || tile.playerSpace != TileContainer.PlayerSpace.BOARD):
		return false
	
	if(tile.resource.joker_id >= 0 || tile.resource.rarity == Tile.Rarity.GOLD):
		return false
	
	return true

func useOnTile(tile: TileContainer) -> void:
	var tileInfo: Tile = tile.resource
	
	if(!isTileValid(tile)):
		return
	
	endItemUse(false)
	
	tileInfo.setRarity(Tile.Rarity.GOLD)
	tileInfo.effects = []
	tile.REgenerateResource(tileInfo)
	
	GameScene.PlayerBar.endItemUse(GameScene.PlayerBar.getItemSlot(self))
