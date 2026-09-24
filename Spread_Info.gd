extends Resource

class_name Spread_Info

const SPREAD_SPACING: float = 15

var Tiles: Array[TileContainer]
var SpreadType: Type
var colors: Array[Color]
var duplicate_number: int = -1

enum SpreadCheck{
	ELIGIBLE, SHORT, VAGUE, NO_PATTERN, DUPLICATE_COLOR, TOO_MANY_COLORS, SEQUENCE_OOB
}

enum Type{
	SEQUENCE, DUPLICATES
}

signal tileActivated_postSpread(tileActivated: TileContainer)

func _init(newTiles: Array[TileContainer]) -> void:
	Tiles.append_array(newTiles.duplicate())
	
	var firstTile: Tile = null
	for tile in Tiles:
		if(tile.tile.jokerID == -1):
			if(firstTile == null):
				firstTile = tile.tile
			else:
				if(firstTile.number == tile.tile.number):
					SpreadType = Type.DUPLICATES
					duplicate_number = firstTile.number
				else:
					SpreadType = Type.SEQUENCE
				
			if(!tile.tile.effects.has(Tile.Effect.RAINBOW) && !colors.has(tile.tile.color)):
				colors.append(tile.tile.color)
	
	match SpreadType:
		Type.SEQUENCE:
			var jokers_atStart: Array[Tile]
			var currentNumber: int = -1
			for tile in Tiles:
				if(!colors.is_empty()):
					tile.tile.color = colors[0]
				
				if(tile.tile.jokerID >= 0):
					if(currentNumber == -1):
						jokers_atStart.append(tile.tile)
					else:
						tile.tile.number = currentNumber
						currentNumber += 1
				else:
					if(currentNumber == -1):
						currentNumber = tile.tile.number-jokers_atStart.size()
						for joker in jokers_atStart:
							joker.number = currentNumber
							currentNumber += 1
						
					currentNumber += 1

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
		tile_info = tile.tile
		
		if(hasWrapped):
			sequenceOutOfBounds = true
		
		if(curentNumber != -1):
			curentNumber += 1
			if(curentNumber == 14):
				curentNumber = 1
				hasWrapped = true
		
		if(tile_info.jokerID >= 0):
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
		
		if(colors.size() + anyColorCount > Tile.COLORS.size()):
			return SpreadCheck.TOO_MANY_COLORS
	
	if(isSequence):
		if(sequenceOutOfBounds || jokerOutOfBounds):
			return SpreadCheck.SEQUENCE_OOB
	
	return SpreadCheck.ELIGIBLE

func isAppendEligible(tile: TileContainer) -> bool:
	match SpreadType:
		Spread_Info.Type.SEQUENCE:
			var firstTile: Tile = Tiles[0].tile
			var lastTile: Tile = Tiles[Tiles.size()-1].tile
			if(tile.position.x <= 0):
				if(firstTile.number == 1):
					return false
				else:
					return (tile.tile.jokerID >= 0)||((colors.is_empty())||((tile.tile.color == firstTile.color) || (tile.tile.effects.has(Tile.Effect.RAINBOW)) || (firstTile.effects.has(Tile.Effect.RAINBOW))) && (tile.tile.number == firstTile.number-1))
			else:
				if(lastTile.number == 1):
					return false
				else:
					return (tile.tile.jokerID >= 0)||((colors.is_empty())||((tile.tile.color == lastTile.color) || (tile.tile.effects.has(Tile.Effect.RAINBOW)) || (lastTile.effects.has(Tile.Effect.RAINBOW))) && ((lastTile.number == 13 && tile.tile.number == 1)||(tile.tile.number == lastTile.number+1)))#----
		Spread_Info.Type.DUPLICATES:
			return (Tiles.size() < Tile.COLORS.size()) && (tile.tile.jokerID >= 0)||((tile.tile.number == duplicate_number) && ((tile.tile.effects.has(Tile.Effect.RAINBOW))||(!colors.has(tile.tile.color))))
	
	return false

func updateSpreadInfo(tile: Tile, is_first: bool) -> void:
	match SpreadType:
		Type.SEQUENCE:
			if(!colors.is_empty()):
				tile.color = colors[0]
			elif(tile.jokerID < 0 && !tile.effects.has(Tile.Effect.RAINBOW)):
				colors.append(tile.color)
			
			if(is_first):
				tile.number = Tiles[0].tile.number-1
			else:
				tile.number = Tiles[Tiles.size()-1].tile.number+1
				if(tile.number > 13):
					tile.number = 1
		Type.DUPLICATES:
			if(tile.jokerID < 0 && !tile.effects.has(Tile.Effect.RAINBOW)):
				colors.append(tile.color)
