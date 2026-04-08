extends Item

class_name BagOfTiles

const BASE_SELECTION_OPTIONS: Vector3i = Vector3i(1, 2, 5)
const DESCRIPTION_BASE_COLOR: String = "gray"
const DESCRIPTION_USED_COLOR: String = "dark_red"

func _init() -> void:
	uses = 3
	
	#instant = true
	consumable = true
	
	super(0)

func getImage() -> Texture:
	return load("res://Items/Sprites/Bag of Tiles.png")

func getIDName() -> String:
	return "Bag of Tiles"

func getDescription() -> String:#String
	#var extendedDescription: Array = StringsManager.ItemStrings[getIDName()]["EXTENDED_DESCRIPTION"]
	#var fullDescription: String = StringsManager.ItemStrings[getIDName()]["DESCRIPTION"]#-------------------------------------------------------------
	var strings: Array = StringsManager.ItemStrings[getIDName()]["DESCRIPTION"]
	var desciption: String = SelectScreen.getSelectionString(BASE_SELECTION_OPTIONS) + strings[0]
	
	if(usedThisRound < 1):
		desciption += DESCRIPTION_BASE_COLOR
	else:
		desciption += DESCRIPTION_USED_COLOR
	
	desciption +=  strings[1] + str(usedThisRound) + strings[2]
	
	return desciption

func getShopPrice() -> int:
	return randi_range(30, 50)

func use() -> bool:
	if(!GameScene.myTurn):# .getTurn()):
		return false
	
	if(usedThisRound >= 1):
		return false
	
	#var DeckIndex: int = 0
	#var DeckSize: int = Game.PB.Tile_Deck.size()
	#if(DeckSize >= 5):
		#DeckIndex = randi_range(0, 4)
	#elif(DeckSize > 0):
		#DeckIndex = randi_range(0,DeckSize-1)
	
	GameScene.Game.createSelectionScreen(SelectScreen.SelectOption.TILE, Vector3i(5, 1, 2), {"EffectsChance": Tile.Effect.size()})
	GameScene.currSelectScreen.DestroySelfInstantly_AfterSelectionEnd = false
	waitForSelectionEnd()
	return true

func waitForSelectionEnd() -> void:
	await GameScene.currSelectScreen.selectionEnded
	
	for tile in SelectScreen.Selections:
		if(SelectScreen.finalSelections.has(tile)):
			GameScene.MainPlayer.GameBoard.addTile(tile, Board.TileOrigin.SELECTION)
		else:
			GameScene.MainPlayer.PlayerDeck.addTile(tile, Deck.TileSource.SELECTION)
		
		await GameScene.Game.get_tree().create_timer(0.1).timeout
	
	GameScene.currSelectScreen.queue_free()
	GameScene.PlayerBar.endItemUse(GameScene.PlayerBar.getItemSlot(self))
