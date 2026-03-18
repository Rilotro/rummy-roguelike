extends Modifier

class_name Riches

const STARTING_CURRENCY: int = 17
var currency: int 

func _init(newGame: GameScene) -> void:
	rounds = 5
	type = Type.BOON
	
	image = load("res://Modifiers/Sprites/Riches.png")
	
	super(newGame)
	
	currency = STARTING_CURRENCY
	#Game.EndOfRound.connect(testFunction)
	#Game.StartOfTurn.connect(effectOnStartOfTurn)

func effectOnStartOfTurn() -> void:
	Game.Shop.update_currency(currency)
	
	currency *= 2
	
	super()
