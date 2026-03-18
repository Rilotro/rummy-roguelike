extends Item

class_name BottledNostalgia

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Bottled Nostalgia.png")
	
	uses = 1
	
	passive = true
	consumable = true
	
	super(7, "Bottled Nostalgia", newGame)
	
	GameScene.Game.EndOfRound.connect(effectOnRoundEnd)#-----------------------------------

func getDescription() -> String:
	if(uses == 1):
		return super()
	else:
		return extendedDescription[0] + str(uses) + extendedDescription[1]

func getShopPrice() -> int:
	return randi_range(20, 45)

#func effectOnGet() -> void:
	#Item.flags["Bottled Nostalgia"] += uses

func effectOnRoundEnd() -> void:
	if(Game.ItemBar.getItemSlot(self) == null):
		return
	
	for tile in Game.PB.selected_tiles:
		await Game.PB.add_tile_to_deck(tile.resource, -1, tile)
	
	Game.PB.selected_tiles.clear()
	Game.ItemBar.usedPassiveItem(self)
