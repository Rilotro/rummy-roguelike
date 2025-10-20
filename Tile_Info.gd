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
