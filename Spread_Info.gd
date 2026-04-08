extends Resource

class_name Spread_Info

var Tiles: Array[TileContainer]

enum SpreadCheck{
	ELIGIBLE, SHORT, VAGUE, NO_PATTERN, DUPLICATE_COLOR, TOO_MANY_COLORS, SEQUENCE_OOB
}

signal tileActivated_postSpread(tileActivated: TileContainer)

func _init(newTiles: Array[TileContainer]) -> void:
	Tiles.append_array(newTiles.duplicate())

static func getSpreadEligibility(SpreadTiles: Array[TileContainer]) -> SpreadCheck:#---------------------------------------------
	if(SpreadTiles.size() < 3):
		return SpreadCheck.SHORT
	
	var jokerCount: int = 0
	
	var isColor: bool = true
	var singleNumber: int = -1
	var anyColorCount: int = 0
	var colors: Array[Color]
	var hasColorDuplicate: bool = false
	
	var isSequence: bool = true
	var curentNumber: int = -1
	var hasWrapped: bool = false
	var sequenceOutOfBounds: bool = false
	var jokerOutOfBounds: bool = false
	
	var tile_info: Tile
	for tile in SpreadTiles:
		tile_info = tile.resource
		
		if(hasWrapped):
			sequenceOutOfBounds = true
		
		if(curentNumber != -1):
			curentNumber += 1
			if(curentNumber == 14):
				curentNumber = 1
				hasWrapped = true
		
		if(tile_info.joker_id >= 0):
			jokerCount += 1
			anyColorCount += 1
			continue
		
		if(!tile_info.effects.has(Tile.Effect.RAINBOW)):
			if(colors.has(tile_info.color)):
				hasColorDuplicate = true
			else:
				colors.append(tile_info.color)
			
		else:
			anyColorCount += 1
		
		if(singleNumber == -1):
			singleNumber = tile_info.number
		elif(singleNumber != tile_info.number):
			isColor = false
		
		if(curentNumber == -1):
			curentNumber = tile_info.number
			if(jokerCount >= curentNumber):
				jokerOutOfBounds = true
		elif(curentNumber != tile_info.number):
			isSequence = false
	
	if(jokerCount >= SpreadTiles.size()-1):
		return SpreadCheck.VAGUE
	
	if(isSequence):
		isSequence = colors.size() <= 1
	
	if(!isColor && !isSequence):
		return SpreadCheck.NO_PATTERN
	
	if(isColor):
		if(hasColorDuplicate):
			return SpreadCheck.DUPLICATE_COLOR
		
		if(colors.size() + anyColorCount > Tile.TileColors.size()):
			return SpreadCheck.TOO_MANY_COLORS
	
	if(isSequence):
		if(sequenceOutOfBounds || jokerOutOfBounds):
			return SpreadCheck.SEQUENCE_OOB
	
	return SpreadCheck.ELIGIBLE
