@abstract
extends Resource

class_name Item #Paint size: 130x200

var id: int
var uses: int = -1
var passive: bool = false
var instant: bool = false
var consumable: bool = false
var usedThisRound: int = 0

var target: ItemTarget = ItemTarget.NO_TARGET

#var ChildCLasses: Array = [ArchitectsChisel, ArchitectsHammer]

#static var flags = {"Wrench": 0, "Midas Touch": 0, "Burning Shoes": 0, "Bottled Nostalgia": 0}
#static var hasSpecialHighlight: Array[int] = [3, 6];
static var singularItems: Array[int]
static var consumbaleItems: Array[int] = [0, 1, 3, 6, 7, 8]

static var ITEM_ID_FINAL: int = 8 #NOT SUPPOSED TO CHANGE WHILE RUNNING!!!

enum ItemTarget{
	NO_TARGET, VIABLE_BOARD_TILE, ANY_HIGHLIGHT
}

func _init(new_id: int) -> void:
	id = new_id
	
	if(consumable && uses > 0):
		uses += WorkshopWrench.ADDITIONAL_USES
	
	GameScene.Game.StartOfRound.connect(effectOnStartOfRound)

@abstract
func getIDName() -> String

func getName() -> String:
	return StringsManager.ItemStrings[getIDName()]["NAME"]

func getKeywords() -> String:
	var keywords: String
	
	if(passive):
		keywords = StringsManager.ItemStrings["passive"]
	else:
		keywords = StringsManager.ItemStrings["active"]
	
	if(consumable):
		keywords += ", [color=green]" + StringsManager.ItemStrings["uses"] + " - " + str(uses) + "[/color]"
	
	return keywords

@abstract
func getImage() -> Texture

func getDescription() -> String:
	return StringsManager.ItemStrings[getIDName()]["DESCRIPTION"]

#func isItemBarItem() -> bool:
	#for item in Game.ItemBar.get_Slots().get_children():
		#if("item_info" in item && item.item_info != null && item.item_info == self):
			#return true
	#
	#return false

@abstract
func getShopPrice() -> int

func effectOnGet() -> void:
	return

func effectOnStartOfRound() -> void:
	usedThisRound = 0
	return

func endItemUse(canceled: bool) -> void:
	return

func use() -> bool:
	return false

func updateWhileUsing(delta: float) -> void:
	pass

func isTileValid(tile: TileContainer) -> bool:
	return false

func useOnTile(tile: TileContainer) -> void:
	return

func useOnHighlight(Highlight: GoodButton, displacement: Vector2 = Vector2(0, 0)) -> void:
	return 

static func getRandomItem(newGame: GameScene, forShop: bool = false, consumablesOnly = false) -> Item:
	var newID: int
	if(consumablesOnly):
		newID = consumbaleItems.pick_random()
	else:
		newID = randi_range(0, 2)#ITEM_ID_FINAL
		
		if(forShop):
			while(singularItems.find(newID) >= 0):
				newID = randi_range(0, ITEM_ID_FINAL)
	
	match newID:
		0:
			return BagOfTiles.new()
		1:
			return ArchitectsHammer.new()
		2:
			return WorkshopWrench.new()
		3:
			return TouchOfMidas.new()
		4:
			return BeaverTeeth.new()
		5:
			return BurningShoes.new()
		6:
			#return MonkeysPaw.new()
			return TouchOfMidas.new()
		7:
			return BottledNostalgia.new()
		8:
			return ArchitectsChisel.new()
	
	return null
