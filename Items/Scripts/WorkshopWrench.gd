extends Item

class_name WorkshopWrench

static var ADDITIONAL_USES: int = 0

func _init() -> void:
	passive = true
	
	super(2)

func getImage() -> Texture:
	return load("res://Items/Sprites/Workshop Wrench.png")

func getIDName() -> String:
	return "Workshop Wrench"

func getShopPrice() -> int:
	return randi_range(45, 70)

func effectOnGet() -> void:
	ADDITIONAL_USES += 1
	Item.singularItems.append(2)
	
	for item in GameScene.GameShop.ItemSelections:
		if(item.resource.consumable):
			item.resource.uses += 1
	
	#Game.addShopUses()
