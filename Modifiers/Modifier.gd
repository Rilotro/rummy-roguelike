extends Resource

class_name Modifier

var rounds: int
var type: Type

enum Type{
	BOON, CURSE, OTHER
}

func _init(newRounds: int, newType: Type) -> void:
	rounds = newRounds
	type = newType
