extends Modifier

class_name Riches

const STARTING_CURRENCY: int = 17
var currency: int 

func _init() -> void:
	rounds = 5
	type = Type.BOON
	
	image = load("res://Modifiers/Sprites/Riches.png")
	
	super()
	
	currency = STARTING_CURRENCY
	#Game.EndOfRound.connect(testFunction)
	#Game.StartOfTurn.connect(effectOnStartOfTurn)

func getIDName() -> String:
	return "Riches"

func getDescription() -> String:
	return StringsManager.ModifierStrings[getIDName()]["DESCRIPTION"][0] + str(currency) + StringsManager.ModifierStrings[getIDName()]["DESCRIPTION"][1]#------------

func effectOnStartOfTurn() -> void:
	GameScene.GameShop.update_currency(currency)
	#Game.Shop.update_currency(currency)
	
	currency *= 2
	
	super()
