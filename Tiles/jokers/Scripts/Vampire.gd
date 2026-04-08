extends Tile

class_name Vampire

func _init() -> void:
	super(-1, Color.WHITE, 4)#-------------------------------------------------------------------------------------------------------
	points = 0

func getJokerImage() -> Texture:
	return load("res://Tiles/jokers/Sprites/Vampire.png")

func getKeywords() -> String:
	return (StringsManager.JokerStrings["Vampire"]) + " - " + str(points) + " " + StringsManager.EffectStrings["points"]

func getName() -> String:
	return StringsManager.JokerStrings["The Vampire"]["NAME"]

func getDescription() -> String:
	return StringsManager.JokerStrings["The Vampire"]["DESCRIPTION"]

func getShopPrice() -> int:
	return randi_range(45, 75)
