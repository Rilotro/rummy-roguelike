extends Resource

class_name Tile

const COLORS: Array[Color] = [Color.RED, Color.GREEN, Color.BLUE,Color.BLACK]

var number: int
var color: Color
var rarity: Rarity
var points: int = 0
var effects: Array[Effect]

var jokerID: int = -1

enum Rarity{
	PORCELAIN, BRONZE, SILVER, GOLD
}

enum Effect{
	RAINBOW, DUPLICATE, WINGED
}

func _init(n: int, c: Color, r: Rarity = Rarity.PORCELAIN, bP: int = 0, e: Array[Effect] = []) -> void:
	assert(COLORS.has(c), "Unsopported Color!")
	
	number = n
	color = c
	rarity = r
	points = getRarityBasePoints(r) + bP
	effects = e.duplicate()

static func getRarityBasePoints(r: Rarity) -> int:
	match r:
		Rarity.GOLD:
			return 50
		Rarity.SILVER:
			return 25
		Rarity.BRONZE:
			return 10
		_:
			return 5

static func getRarityColor(r: Rarity) -> Color:
	match r:
		Rarity.PORCELAIN:
			return Color.WHITE
		Rarity.BRONZE:
			return Color(0.804, 0.498, 0.196, 1)
		Rarity.SILVER:
			return Color.SILVER
		Rarity.GOLD:
			return Color.GOLD
	
	return Color.BLACK

static func getEffectContainer(effect: Effect, containerColor: Color) -> Control:
	if(effect == Effect.RAINBOW):
		return null
	
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
			effectIcon.self_modulate = containerColor
		Effect.WINGED:
			effectIcon.texture = load("res://Items/Sprites/Winged.png")
			if(containerColor == Color.BLACK):
				effectIcon.self_modulate = Color(0.15, 0.15, 0.15, 1)
			else:
				effectIcon.self_modulate = containerColor
	
	return container


static func getRandomTile() -> Tile:
	return Tile.new(randi_range(1, 14), Tile.COLORS[randi_range(0, Tile.COLORS.size()-1)], randi_range(0, Tile.Rarity.size()-1))

func _to_string() -> String:
	var returnVal: String = str(number) + ":" + str(COLORS.find(color)) + ":" + str(rarity) + ":" + str(effects.size())
	for effect in effects:
		returnVal += ":" + str(effect)
	
	return returnVal

static func _from_str(string: String, hasBoardPos: bool = false) -> Array:
	var tileN: int = int(string.get_slice(":", 0))
	
	var tileC: Color = COLORS[int(string.get_slice(":", 1))]
	
	var tileR: Rarity = int(string.get_slice(":", 2)) as Rarity
	
	var effectsSize: int = int(string.get_slice(":", 3))
	
	var tileE: Array[Effect]
	for i in range(effectsSize):
		tileE.append(int(string.get_slice(":", 4+i)))
	
	var tilePos: Vector2i = Vector2i(-1, -1)
	if(hasBoardPos):
		tilePos.x = int(string.get_slice(":", 4+effectsSize))
		tilePos.y = int(string.get_slice(":", 5+effectsSize))
	
	return [Tile.new(tileN, tileC, tileR, 0, tileE), tilePos]

static func _from_bytes(bytes: PackedByteArray, hasBoardPos: bool = false) -> Array:
	return _from_str(bytes.get_string_from_utf8(), hasBoardPos)
