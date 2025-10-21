extends Resource

class_name Tile_Info

var number: int
var color: int
var joker_id: int
var rarity: String

var potential_colors: Array[int]
var potential_number: Array[int]

var points: int = 0

var effects: Dictionary

static var level: int = 0
var joker_name: String
var joker_description: String

func _init(i_number: int = 0, i_color: int = 0, i_joker_id: int = -1, tile_rarity: String = "porcelain", orig: Tile_Info = null, new_effects: Dictionary = {"rainbow": false, "duplicate": false}) -> void:
	if(orig != null):
		number = orig.number
		color = orig.color
		joker_id = orig.joker_id
		rarity = orig.rarity
		effects = orig.effects
	else:
		number = i_number
		color = i_color
		joker_id = i_joker_id
		rarity = tile_rarity
		effects = new_effects
	
	if(joker_id >= 0):
		match joker_id:
			0:
				joker_name = "The Joker"
				joker_description = "Counts as any [i]number[/i] and any [i]color[/i]"
				points = 50
			1:
				joker_name = "The Partygoer"
				joker_description = "[b]On Spread[/b] - I have [b]+10 Points[/b] for each [i]other[/i] [b]Tile[/b] in the [b]Row[/b]"
				points = 10
			2:
				joker_name = "The Banker"
				joker_description = "[b]On Spread[/b] - The next [b]Item[/b] or [b]Tile[/b] you buy in the [b]Shop[/b] is [b]Free[/b]"
				points = 5
	elif(tile_rarity == "gold"):
		points = 50
	elif(tile_rarity == "silver"):
		points = 25
	elif(tile_rarity == "bronze"):
		points = 10
	else:
		points = 5

func Rarify(set_rarity: String = "") -> bool:
	if(joker_id >= 0):
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
