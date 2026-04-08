extends Tile

class_name Banker

func _init() -> void:
	super(-1, Color.WHITE, 2)#-------------------------------------------------------------------------------------------------------
	points = 0

func getJokerImage() -> Texture:
	return load("res://Tiles/jokers/Sprites/Banker.png")

func getKeywords() -> String:
	return (StringsManager.JokerStrings["joker"]) + " - " + str(points) + " " + StringsManager.EffectStrings["points"]

func getName() -> String:
	return StringsManager.JokerStrings["The Banker"]["NAME"]

func getDescription() -> String:
	return StringsManager.JokerStrings["The Banker"]["ACTIVATE"] + StringsManager.JokerStrings["The Banker"]["DESCRIPTION"]

func getShopPrice() -> int:
	return randi_range(60, 85)

func getOnSpreadEffectsDuration(container: TileContainer) -> float:
	return 0

func activate(container: TileContainer, isPostSpread: bool = false) -> void:
	super(container, isPostSpread)
	
	GameScene.GameShop.freebies += 1
	GameScene.GameShop.checkButtons()

func onSpreadEffects(container: TileContainer) -> void:
	myContainer = container
	activate(container)
