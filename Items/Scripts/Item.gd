@abstract
extends Resource

class_name Item #Paint size: 130x200

var id: int
var itemID: String
var item_image: Texture
var uses: int = -1
var passive: bool = false
var instant: bool = false
var consumable: bool = false
var name: String
var description: String#written for BBCode text
var usedThisRound: int = 0

var extendedDescription: Array

var target: ItemTarget = ItemTarget.NO_TARGET

#var ChildCLasses: Array = [ArchitectsChisel, ArchitectsHammer]

var Game: GameScene

#static var flags = {"Wrench": 0, "Midas Touch": 0, "Burning Shoes": 0, "Bottled Nostalgia": 0}
#static var hasSpecialHighlight: Array[int] = [3, 6];
static var singularItems: Array[int]
static var consumbaleItems: Array[int] = [0, 1, 3, 6, 7, 8]

static var ITEM_ID_FINAL: int = 8 #NOT SUPPOSED TO CHANGE WHILE RUNNING!!!

enum ItemTarget{
	NO_TARGET, VIABLE_BOARD_TILE, ANY_HIGHLIGHT
}

func _init(new_id: int, nameID: String, newGame: GameScene) -> void:
	Game = newGame
	id = new_id
	itemID = nameID
	var Strings: Dictionary = StringsManager.ItemStrings[nameID]
	
	name = Strings["NAME"]
	description = Strings["DESCRIPTION"]
	if(Strings.has("EXTENDED_DESCRIPTION")):
		extendedDescription = Strings["EXTENDED_DESCRIPTION"]
	
	
	if(uses > 0):
		uses += WorkshopWrench.ADDITIONAL_USES
	
	GameScene.Game.StartOfTurn.connect(effectOnStartOfTurn)

func getKeywords() -> String:
	var keywords: String
	
	if(passive):
		keywords = StringsManager.ItemStrings["passive"]
	else:
		keywords = StringsManager.ItemStrings["active"]
	
	if(consumable):
		keywords += ", " + StringsManager.ItemStrings["uses"] + " - " + str(uses)
	
	return keywords

func getDescription() -> String:
	return description

func isItemBarItem() -> bool:
	for item in Game.ItemBar.get_Slots().get_children():
		if("item_info" in item && item.item_info != null && item.item_info == self):
			return true
	
	return false

@abstract
func getShopPrice() -> int

func effectOnGet() -> void:
	return

func effectOnStartOfTurn() -> void:
	usedThisRound = 0
	return

func endItemUse(canceled: bool) -> void:
	return

func use() -> bool:
	return false

func updateWhileUsing(delta: float) -> void:
	pass

func isTileValid(tile: Tile) -> bool:
	return false

func useOnTile(tile: Tile) -> void:
	return

func useOnHighlight(Highlight: Control, displacement: Vector2 = Vector2(0, 0)) -> void:
	return 

static func getRandomItem(newGame: GameScene, forShop: bool = false, consumablesOnly = false) -> Item:
	var newID: int
	if(consumablesOnly):
		newID = consumbaleItems.pick_random()
	else:
		newID = randi_range(6, 8)#ITEM_ID_FINAL
		
		if(forShop):
			while(singularItems.find(newID) >= 0):
				newID = randi_range(0, ITEM_ID_FINAL)
	
	match newID:
		#0:
			#return BagOfTiles.new(newGame)
		1:
			return ArchitectsHammer.new(newGame)
		2:
			return WorkshopWrench.new(newGame)
		3:
			return TouchOfMidas.new(newGame)
		4:
			return BeaverTeeth.new(newGame)
		5:
			return BurningShoes.new(newGame)
		6:
			#return MonkeysPaw.new(newGame)
			return TouchOfMidas.new(newGame)
		7:
			return BottledNostalgia.new(newGame)
		8:
			return ArchitectsChisel.new(newGame)
	
	return null
