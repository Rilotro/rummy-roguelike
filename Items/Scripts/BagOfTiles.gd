extends Item

class_name BagOfTiles

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Bag of Tiles.png")
	uses = 3
	
	instant = true
	consumable = true
	
	super(0, "Bag of Tiles", newGame)

func getDescription() -> String:
	var fullDescription: String = description#-------------------------------------------------------------
	
	fullDescription += extendedDescription[0]
	
	if(usedThisRound >= 1):
		fullDescription += "[color=red]"
	
	fullDescription += "(" + str(usedThisRound) + "/1)"
	
	if(usedThisRound >= 1):
		fullDescription += "[/color]"
	
	fullDescription += extendedDescription[1]
	
	return fullDescription

func getShopPrice() -> int:
	return randi_range(30, 50)

func use() -> bool:
	if(!Game.getTurn()):
		return false
	
	if(usedThisRound == 0):
		var DeckIndex: int = 0
		var DeckSize: int = Game.PB.Tile_Deck.size()
		if(DeckSize >= 5):
			DeckIndex = randi_range(0, 4)
		elif(DeckSize > 0):
			DeckIndex = randi_range(0,DeckSize-1)
		
		Game.select_tiles(SelectScreen.SelectOption.DECK_ADD_TILE, 3, {"DeckPosition": DeckIndex, "CanHaveEffects": true})
	else:
		return false
	
	return true
