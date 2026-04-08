@abstract
extends Resource

class_name Modifier

var rounds: int
var type: Type
var image: Texture

enum Type{
	BOON, CURSE, OTHER
}

func _init() -> void:
	#rounds = newRounds
	#type = newType
	pass
	
	#Game.StartOfTurn.connect(effectOnStartOfTurn)

@abstract
func getIDName() -> String

func getName() -> String:
	return StringsManager.ModifierStrings[getIDName()]["NAME"]

func getKeywords() -> String:
	var keywords: String = StringsManager.ModifierStrings["modifier"]
	
	keywords += StringsManager.ModifierStrings[Type.keys()[type]]
	
	keywords += " - " + str(rounds) + " "
	if(rounds == 1):
		keywords += StringsManager.ModifierStrings["round"]
	else:
		keywords += StringsManager.ModifierStrings["rounds"]
	
	return keywords

func getDescription() -> String:
	return StringsManager.ModifierStrings[getIDName()]["DESCRIPTION"][0]

func effectOnGet() -> void:
	return

func effectOnStartOfTurn() -> void:
	rounds -= 1
	#if(rounds <= 0):
	#	Game.ItemBar.removeModifier

static func getRandomModifier(anyType: bool = true, ModType: Type = Type.OTHER) -> Modifier:
	var viableChoices: Array[String]
	if(anyType):
		viableChoices = ["ArchitectsForge", "Riches"]#----------------------
	else:
		match ModType:
			Type.BOON:
				viableChoices = ["ArchitectsForge", "Riches"]
	
	match viableChoices.pick_random():
		"ArchitectsForge":
			return ArchitectsForge.new()
		#"BagOfTiles":
			#return BagOfTiles.new(GameScene.Game)
		"Riches":
			return Riches.new()
	
	return null
