extends Resource

class_name Tile_Info

var number: int
var color: int
var joker: bool
var rarity: String

var potential_colors: Array[int]
var potential_number: Array[int]

var points: int = 0

var effects: Dictionary

static var level: int = 0

func _init(i_number: int = 0, i_color: int = 0, is_joker: bool = false, tile_rarity: String = "porcelain", orig: Tile_Info = null, new_effects: Dictionary = {"rainbow": false, "duplicate": false}) -> void:
	if(orig != null):
		number = orig.number
		color = orig.color
		joker = orig.joker
		rarity = orig.rarity
		effects = orig.effects
	else:
		number = i_number
		color = i_color
		joker = is_joker
		rarity = tile_rarity
		effects = new_effects
	
	if(joker):
		points = 50
	elif(tile_rarity == "gold"):
		points = 50
	elif(tile_rarity == "silver"):
		points = 25
	elif(tile_rarity == "bronze"):
		points = 10
	else:
		points = 5

func Rarify(set_rarity: String = "") -> bool:
	if(joker):
		return false
	
	match set_rarity:
		"":
			match rarity:
				"porcelain":
					rarity = "bronze"
					points = 10
				"bronze":
					rarity = "silver"
					points = 25
				"silver":
					rarity = "gold"
					points = 50
				"gold":
					return false
		"porcelain":
			if(rarity == "porcelain"):
				return false
			rarity = "porcelain"
			points = 5
		"bronze":
			if(rarity == "bronze"):
				return false
			rarity = "bronze"
			points = 10
		"silver":
			if(rarity == "silver"):
				return false
			rarity = "silver"
			points = 25
		"gold":
			if(rarity == "gold"):
				return false
			rarity = "gold"
			points = 50
	
	return true
