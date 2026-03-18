extends Resource

class_name Modifier

var rounds: int
var type: Type
var image: Texture
var Game: GameScene

enum Type{
	BOON, CURSE, OTHER
}

func _init(newGame: GameScene) -> void:
	#rounds = newRounds
	#type = newType
	Game = newGame
	
	#Game.StartOfTurn.connect(effectOnStartOfTurn)

func effectOnGet() -> void:
	return

func effectOnStartOfTurn() -> void:
	rounds -= 1
	#if(rounds <= 0):
	#	Game.ItemBar.removeModifier

static func getRandomModifier(anyType: bool = true, ModType: Type = Type.OTHER) -> Modifier:
	var viableChoices: Array[String]
	if(anyType):
		viableChoices = ["ArchitectsForge", "BagOfTiles", "Riches"]#----------------------
	else:
		match ModType:
			Type.BOON:
				viableChoices = ["ArchitectsForge", "BagOfTiles", "Riches"]
	
	match viableChoices.pick_random():
		"ArchitectsForge":
			return ArchitectsForge.new(GameScene.Game)
		"BagOfTiles":
			return BagOfTiles.new(GameScene.Game)
		"Riches":
			return Riches.new(GameScene.Game)
	
	return null
