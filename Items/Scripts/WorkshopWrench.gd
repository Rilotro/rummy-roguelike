extends Item

class_name WorkshopWrench

static var ADDITIONAL_USES: int = 0

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Workshop Wrench.png")
	
	passive = true
	
	super(2, "Workshop Wrench", newGame)

func getShopPrice() -> int:
	return randi_range(45, 70)

func effectOnGet() -> void:
	ADDITIONAL_USES += 1
	Item.singularItems.append(2)
	
	Game.addShopUses()
