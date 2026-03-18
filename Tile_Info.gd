extends Resource

class_name Tile_Info

var number: int
var color: Color
var joker_id: int
var rarity: Rarity

var potential_colors: Array[int]
var potential_number: Array[int]

var points: int = 0

var effects: Array[Effect]

static var level: int = 0
var joker_name: String
var joker_image: Texture

static var TileColors: Array[Color] = [Color.BLACK, Color.RED, Color.GREEN, Color.BLUE]

enum Rarity{
	PORCELAIN, BRONZE, SILVER, GOLD
}

enum Effect{
	RAINBOW, DUPLICATE, WINGED
}

#enum TileColor{
	#BLACK, 
#}

func _init(i_number: int = 0, i_color: Color = Color.BLACK, i_joker_id: int = -1, tile_rarity: Rarity = Rarity.PORCELAIN, new_effects: Array[Effect] = [], orig: Tile_Info = null) -> void:
	if(orig != null):
		number = orig.number
		color = orig.color
		joker_id = orig.joker_id
		rarity = orig.rarity
		effects = orig.effects
	else:
		assert(TileColors.find(i_color) >= 0, "this Color is NOT a valid Tile Color! (see Tile_Info.TileColors for the valid Tile Colors)")
		
		number = i_number
		color = i_color
		joker_id = i_joker_id
		rarity = tile_rarity
		effects = new_effects
	
	if(joker_id >= 0):
		match joker_id:
			0:
				joker_name = "The Joker"
				#joker_description = "[b]Joker[/b] - Counts as any [i]number[/i] and any [i]color[/i]"
				points = 50
			1:
				joker_name = "The Partygoer"
				#joker_description = "[b]Joker[/b] - Counts as any [i]number[/i] and any [i]color[/i].[br][b]On Spread[/b] - I have [b]+10 Points[/b] for each [i]other[/i] [b]Tile[/b] in the [b]Row[/b]"
				points = 10
			2:
				joker_name = "The Banker"
				#joker_description = "[b]Joker[/b] - Counts as any [i]number[/i] and any [i]color[/i].[br][b]On Spread[/b] - The next [b]Item[/b] or [b]Tile[/b] you buy in the [b]Shop[/b] is [b]Free[/b]"
				points = 5
			3:
				joker_name = "The Architect"
				#joker_description = "[b]Joker[/b] - Counts as any [i]number[/i] and any [i]color[/i].[br][b]On Spread[/b] - All your [b]Consumable Items[/b] gain [b]+1 Uses[/b].[br][b]While Spread[/b] - When you [b]Use[/b] a [b]Consumable[/b], [b]Gain +5 Points[/b]"
				points = 10
			4:
				joker_name = "The Vampire"
				#joker_description = "[b]Joker[/b] - Counts as any [i]number[/i] and any [i]color[/i].[br][b]On Spread[/b] - If I am a [b]Leech[/b], I [b]Gain Points[/b] equal to the ammount of [b]Spread Points[/b] in the [b]Row[/b] I'm [b]Leeching[/b]"
				points = 0
	
	match rarity:
		Rarity.PORCELAIN:
			points = 5
		Rarity.BRONZE:
			points = 10
		Rarity.SILVER:
			points = 25
		Rarity.GOLD:
			points = 50

func getColorString() -> String:
	if(effects.has(Tile_Info.Effect.RAINBOW)):
		return StringsManager.EffectStrings["RAINBOW"]["NAME"]
	
	match color:
		Color.BLACK:
			return StringsManager.EffectStrings["color"]["black"]
		Color.RED:
			return StringsManager.EffectStrings["color"]["red"]
		Color.GREEN:
			return StringsManager.EffectStrings["color"]["green"]
		Color.BLUE:
			return StringsManager.EffectStrings["color"]["blue"]
	
	return ""

func getKeywords() -> String:
	if(joker_id >= 0):
		return (StringsManager.JokerStrings["joker"]) + " - " + str(points) + " points"
	
	var keywords: String = StringsManager.EffectStrings["rarity"][Tile_Info.Rarity.keys()[rarity]]
	
	for effect in effects:
		if(effect == Effect.RAINBOW):
			continue
		
		keywords += ", " + StringsManager.EffectStrings[Tile_Info.Effect.keys()[effect]]["NAME"]
	
	keywords += " - " + str(points) + " points"
	
	return keywords

func getDescription() -> String:
	if(joker_id >= 0):
		return StringsManager.JokerStrings[joker_name]["DESCRIPTION"]
	
	var fullDescription: String = ""
	var firstText: bool = true
	
	for effect in effects:
		if(firstText):
			firstText = false
		else:
			fullDescription += "[br]"
		
		fullDescription += "[b]" + StringsManager.EffectStrings[Tile_Info.Effect.keys()[effect]]["NAME"] + "[/b] - "
		fullDescription += StringsManager.EffectStrings[Tile_Info.Effect.keys()[effect]]["DESCRIPTION"]
	
	return fullDescription

func getEffectContainer(effect: Effect) -> Control:
	var container: Control = Control.new()
	var effectIcon: Sprite2D = Sprite2D.new()
	
	container.custom_minimum_size = Vector2(32, 32)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.name = (Effect.keys()[effect]).to_lower() + "Container"
	
	effectIcon.position = Vector2(16, 16)
	effectIcon.scale = Vector2(0.5, 0.5)
	effectIcon.name = (Effect.keys()[effect]).to_lower() + "Icon"
	container.add_child(effectIcon)
	
	match effect:
		Effect.DUPLICATE:
			effectIcon.texture = load("res://Items/Sprites/Duplicate.png")
			effectIcon.self_modulate = color
		Effect.WINGED:
			effectIcon.texture = load("res://Items/Sprites/Winged.png")
			if(color == Color.BLACK):
				effectIcon.self_modulate = Color(0.15, 0.15, 0.15, 1)
			else:
				effectIcon.self_modulate = color
	
	return container

func setRarity(set_rarity: Rarity = Rarity.PORCELAIN) -> void:
	if(joker_id >= 0):
		return
	
	match set_rarity:
		Rarity.PORCELAIN:
			rarity = Rarity.PORCELAIN
			points = 5
		Rarity.BRONZE:
			rarity = Rarity.BRONZE
			points = 10
		Rarity.SILVER:
			rarity = Rarity.SILVER
			points = 25
		Rarity.GOLD:
			rarity = Rarity.GOLD
			points = 50

func Rarify(direction: bool = true) -> void:
	if(joker_id >= 0):
		return
	
	match rarity:
		Rarity.PORCELAIN:
			if(direction):
				rarity = Rarity.BRONZE
				points = 10
		Rarity.BRONZE:
			if(direction):
				rarity = Rarity.SILVER
				points = 25
			else:
				rarity = Rarity.PORCELAIN
				points = 5
		Rarity.SILVER:
			if(direction):
				rarity = Rarity.GOLD
				points = 50
			else:
				rarity = Rarity.BRONZE
				points = 10
		Rarity.GOLD:
			if(!direction):
				rarity = Rarity.SILVER
				points = 25

static func getShopCost(tile: Tile_Info) -> int:
	var cost: int = 0
	
	if(tile.joker_id >= 0):
		match tile.joker_id:
				0:
					cost = randi_range(30, 50)
				1:
					cost = randi_range(15, 35)
				2:
					cost = randi_range(60, 85)
				3:
					cost = randi_range(35, 70)
				4:
					cost = randi_range(45, 75)
	else:
		match tile.rarity:
			Tile_Info.Rarity.PORCELAIN:
				cost = randi_range(2, 12)
			Tile_Info.Rarity.BRONZE:
				cost = randi_range(8, 17)
			Tile_Info.Rarity.SILVER:
				cost = randi_range(12, 27)
			Tile_Info.Rarity.GOLD:
				cost = randi_range(24, 31)
		
		if(tile.effects.find(Tile_Info.Effect.RAINBOW)):
			cost += randi_range(4, 13)
		
		if(tile.effects.find(Tile_Info.Effect.DUPLICATE)):
			cost += randi_range(6, 17)
		
		if(tile.effects.find(Tile_Info.Effect.WINGED)):
			cost += randi_range(5, 10)
	
	return cost

static func getRandomTile(effectsChance: int = -1) -> Tile_Info:
	var newNumber: int = randi_range(1, 13)
	var newColor: Color = TileColors.pick_random()
	var newRarity: Rarity = Rarity.values().pick_random()
	var newEffects: Array[Effect] = []
	
	if(effectsChance > -1):
		var effectIndex: int = randi_range(0, Effect.size()+effectsChance)
		var newEffect: Effect# = Effect.values()[effectIndex]
		while(effectIndex < Effect.size() && !newEffects.has(Effect.values()[effectIndex])):
			newEffect = Effect.values()[effectIndex]
			newEffects.append(newEffect)
			effectIndex = randi_range(0, Effect.size()+effectsChance)
	
	return Tile_Info.new(newNumber, newColor, -1, newRarity, newEffects)
