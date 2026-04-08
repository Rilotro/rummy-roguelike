extends Tile

class_name Joker

func _init() -> void:
	super(-1, Color.WHITE, 0)#-------------------------------------------------------------------------------------------------------
	points = 50

func getJokerImage() -> Texture:
	return load("res://Tiles/jokers/Sprites/Joker.png")

func getKeywords() -> String:
	return (StringsManager.JokerStrings["joker"]) + " - " + str(points) + " " + StringsManager.EffectStrings["points"]

func getName() -> String:
	return StringsManager.JokerStrings["The Joker"]["NAME"]

func getDescription() -> String:
	return StringsManager.JokerStrings["The Joker"]["ACTIVATE"] + StringsManager.JokerStrings["The Joker"]["DESCRIPTION"]

func getShopPrice() -> int:
	return randi_range(30, 50)
	#match tile.joker_id:
				#0:
					#cost = randi_range(30, 50)
				#1:
					#cost = randi_range(15, 35)
				#2:
					#cost = randi_range(60, 85)
				#3:
					#cost = randi_range(35, 70)
				#4:
					#cost = randi_range(45, 75)
