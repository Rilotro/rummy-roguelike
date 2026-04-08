extends Tile

class_name Architect

func _init() -> void:
	super(-1, Color.WHITE, 3)#-------------------------------------------------------------------------------------------------------
	points = 10

func getJokerImage() -> Texture:
	return load("res://Tiles/jokers/Sprites/Architect.png")

func getKeywords() -> String:
	return (StringsManager.JokerStrings["joker"]) + " - " + str(points) + " " + StringsManager.EffectStrings["points"]

func getName() -> String:
	return StringsManager.JokerStrings["The Architect"]["NAME"]

func getDescription() -> String:
	return StringsManager.JokerStrings["The Architect"]["ACTIVATE"] + StringsManager.JokerStrings["The Architect"]["DESCRIPTION"]

func getShopPrice() -> int:
	return randi_range(35, 70)

func activate(container: TileContainer, isPostSpread: bool = false) -> void:
	super(container, isPostSpread)
	

func onSpreadEffects(container: TileContainer) -> void:
	activate(container)
	myContainer = container
	GameScene.PlayerBar.item_used.connect(func(_playerID: int) -> void:
		activate(myContainer, true))
