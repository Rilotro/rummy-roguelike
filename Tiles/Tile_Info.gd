extends Resource

class_name Tile

var number: int
var color: Color
var joker_id: int = -1
var rarity: Rarity

var potential_colors: Array[int]
var potential_number: Array[int]

var points: int = 0

var effects: Array[Effect]
var myContainer: TileContainer

static var level: int = 0

static var TileColors: Array[Color] = [Color.BLACK, Color.RED, Color.GREEN, Color.BLUE]

static var accumulatedWingedDraw: int = 0

enum Rarity{
	PORCELAIN, BRONZE, SILVER, GOLD
}

enum Effect{
	RAINBOW, DUPLICATE, WINGED
}

#enum TileColor{
	#BLACK, 
#}

func _init(i_number: int = 0, i_color: Color = Color.BLACK, i_joker_id: int = -1, tile_rarity: Rarity = Rarity.PORCELAIN, new_effects: Array[Effect] = [], orig: Tile = null) -> void:
	if(orig != null):
		number = orig.number
		color = orig.color
		joker_id = orig.joker_id
		rarity = orig.rarity
		effects = orig.effects
	else:
		joker_id = i_joker_id
		if(joker_id < 0):
			assert(TileColors.find(i_color) >= 0, "this Color is NOT a valid Tile Color! (see Tile.TileColors for the valid Tile Colors)")
			
			number = i_number
			color = i_color
			joker_id = i_joker_id
			rarity = tile_rarity
			effects = new_effects
			
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
	if(effects.has(Tile.Effect.RAINBOW)):
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
	var keywords: String = StringsManager.EffectStrings["rarity"][Tile.Rarity.keys()[rarity]]
	
	for effect in effects:
		if(effect == Effect.RAINBOW):
			continue
		
		keywords += ", " + StringsManager.EffectStrings[Tile.Effect.keys()[effect]]["NAME"]
	
	keywords += " - " + str(points) + " points"
	
	return keywords

func getJokerImage() -> Texture:
	return null

func getName() -> String:
	return StringsManager.EffectStrings["tile"] + "(" + str(number) + ", " + getColorString() + ")"

func getDescription() -> String:
	var fullDescription: String = StringsManager.EffectStrings["ACTIVATE"]
	var firstText: bool = true
	
	for effect in effects:
		if(firstText):
			firstText = false
		else:
			fullDescription += "[br]"
		
		fullDescription += "[b]" + StringsManager.EffectStrings[Tile.Effect.keys()[effect]]["NAME"] + "[/b] - "
		fullDescription += StringsManager.EffectStrings[Tile.Effect.keys()[effect]]["DESCRIPTION"]
	
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

func getOnSpreadEffectsDuration(container: TileContainer) -> float:
	var onSpreadEffectsDuration: float = 0
	for effect in effects:
		match effect:
			Tile.Effect.DUPLICATE:
				onSpreadEffectsDuration += TileContainer.DUPLICATE_EFFECT_DURATION
	
	return onSpreadEffectsDuration

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

func activate(container: TileContainer, isPostSpread: bool = false) -> void:
	myContainer = container
	
	container.pointsGlitter(GameScene.MainPlayer.ExpBar.global_position)
	
	if(effects.has(Effect.DUPLICATE)):
		var duplicatedEffects: Array[Effect] = effects
		duplicatedEffects.erase(Effect.DUPLICATE)
		var duplicatedTile: Tile = Tile.new(number, color, -1, rarity, duplicatedEffects)
		var duplicatedContainer: TileContainer = TileContainer.new(duplicatedTile, ResourceContainer.ContainerType.PLAYER_TILE, -1, TileContainer.PlayerSpace.SPREAD)
		duplicatedContainer.scale = Vector2(0.1, 0.1)
		duplicatedContainer.modulate.a = 0
		duplicatedContainer.position = container.global_position - GameScene.MainPlayer.PlayerDeck.global_position
		GameScene.MainPlayer.PlayerDeck.addTile(duplicatedContainer, Deck.TileSource.DUPLICATE)
	
	if(isPostSpread):
		GameScene.MainPlayer.PlayerSpread.getSpreadRow(myContainer).tileActivated_postSpread.emit(myContainer)

func onRemovedFromBoard() -> void:
	if(effects.has(Effect.WINGED)):
		accumulatedWingedDraw += 1
		#GameScene.MainPlayer.Draw()

func onSpreadEffects(container: TileContainer) -> void:
	myContainer = container
	
	activate(container)
	
	await container.get_tree().create_timer(0.1).timeout
	
	#for effect in effects:
		#match effect:
			#Effect.WINGED:
				#GameScene.MainPlayer.Draw()
			#Effect.DUPLICATE:
				#var duplicatedEffects: Array[Effect] = effects
				#duplicatedEffects.erase(Effect.DUPLICATE)
				#var duplicatedTile: Tile = Tile.new(number, color, -1, rarity, duplicatedEffects)
				#var duplicatedContainer: TileContainer = TileContainer.new(duplicatedTile, ResourceContainer.ContainerType.PLAYER_TILE, -1, TileContainer.PlayerSpace.SPREAD)
				#duplicatedContainer.scale = Vector2(0.1, 0.1)
				#duplicatedContainer.modulate.a = 0
				#duplicatedContainer.position = container.global_position - GameScene.MainPlayer.PlayerDeck.global_position
				#GameScene.MainPlayer.PlayerDeck.addTile(duplicatedContainer, Deck.TileSource.DUPLICATE)

func getShopPrice() -> int:
	var cost: int = 0
	
	match rarity:
		Tile.Rarity.PORCELAIN:
			cost = randi_range(2, 12)
		Tile.Rarity.BRONZE:
			cost = randi_range(8, 17)
		Tile.Rarity.SILVER:
			cost = randi_range(12, 27)
		Tile.Rarity.GOLD:
			cost = randi_range(24, 31)
	
	if(effects.find(Tile.Effect.RAINBOW)):
		cost += randi_range(4, 13)
	
	if(effects.find(Tile.Effect.DUPLICATE)):
		cost += randi_range(6, 17)
	
	if(effects.find(Tile.Effect.WINGED)):
		cost += randi_range(5, 10)
	
	return cost

static func getRandomTile(effectsChance: int = -1) -> Tile:
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
	
	return Tile.new(newNumber, newColor, -1, newRarity, newEffects)

static func getRandomJoker() -> Tile:
	var JID: int = randi_range(0, 3)
	
	match JID:
		0:
			return Joker.new()
		1:
			return Partygoer.new()
		2:
			return Banker.new()
		3:
			return Architect.new()
		4:
			return Vampire.new()
	
	return null
