extends Item

class_name BottledNostalgia

static var NostalgiaUses: int = 0

func _init() -> void:
	uses = 1
	
	passive = true
	consumable = true
	
	super(7)
	
	GameScene.Game.EndOfRound.connect(effectOnRoundEnd)#----------------------------------------------------------------------

func getImage() -> Texture:
	return load("res://Items/Sprites/Bottled Nostalgia.png")

func getIDName() -> String:
	return "Bottled Nostalgia"

func getDescription() -> String:
	var strings: Array = StringsManager.ItemStrings[getIDName()]["DESCRIPTION"]
	var description: String = strings[0]
	if(uses == 1):
		description += strings[1] + strings[2]
	else:
		description += str(uses) + " " + strings[1] + strings[3]
	
	description += strings[4]
	
	return description

func getShopPrice() -> int:
	return randi_range(20, 45)

func effectOnGet() -> void:
	NostalgiaUses += uses

func effectOnRoundEnd() -> void:
	if(GameScene.PlayerBar.getItemSlot(self) == null):
		return
	
	if(Player.selectedTiles.is_empty()):
		return
	
	for tile in GameScene.MainPlayer.selectedTiles:
		GameScene.MainPlayer.PlayerDeck.addTile(tile, Deck.TileSource.BOARD)
		#await GameScene.MainPlayer.add_tile_to_deck(tile.resource, -1, tile)
	
	NostalgiaUses -= 1
	GameScene.MainPlayer.selectedTiles.clear()
	GameScene.PlayerBar.usedPassiveItem(GameScene.PlayerBar.getItemSlot(self))
