extends Item

class_name ArchitectsChisel

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Architect's Chisel.png")
	
	uses = 5
	
	passive = true
	consumable = true
	
	super(8, "Architect's Chisel", newGame)
	
	#GameScene.Game.PB.DeckAddTile.connect(EffectOnDeckAddTile)#-------------------------------------

func getDescription() -> String:
	if(uses == 1):
		return super()
	else:
		return extendedDescription[0] + str(uses) + extendedDescription[1]

func getShopPrice() -> int:
	return randi_range(1, 2)

func EffectOnDeckAddTile(tile: Tile):
	if(Game.ItemBar.getItemSlot(self) == null || tile == null):
		return
	
	#while(tile.is_being_moved):
		#await Game.get_tree().create_timer(0.001).timeout
	
	tile.is_being_moved = true
	tile.getTileData().Rarify(true)
	Game.ItemBar.usedPassiveItem(self)
	var EW: Sprite2D = ExplosionWave.new()
	tile.add_child(EW)
	#move_child(EW, 0)
	tile.change_info()
	await Game.get_tree().create_timer(1.0).timeout
	tile.is_being_moved = false
