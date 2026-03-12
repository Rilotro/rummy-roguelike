extends Item

class_name WorkshopWrench

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Workshop Wrench.png")
	
	passive = true
	
	super(2, "Workshop Wrench", newGame)

func getShopPrice() -> int:
	return randi_range(45, 70)

func effectOnGet() -> void:
	Item.flags["Wrench"] += 1
	Item.singularItems.append(2)
	
	Game.addShopUses()
