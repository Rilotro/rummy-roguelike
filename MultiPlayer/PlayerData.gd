extends Resource

class_name PlayerData

var ID: int
var name: String
var order: int
var playerSpace: Player

func _init(i_ID: int) -> void:#, i_name = "", i_order = -1
	ID = i_ID
	#name = i_name
	#order = i_order
