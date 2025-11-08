extends Resource

class_name Spread_Info

var Tiles: Array[Tile]
var same_color: bool
var same_number: bool
var the_number: int = -1
var the_color: int = -1
var colors: Array[int]

var prefixedLeeches: Array[Tile]
var suffixedLeeches: Array[Tile]

func _init(new_row: Array[Tile]) -> void:
	Tiles = new_row.duplicate()
	
	var temp_color: int = -1
	var temp_number: int = -1
	var is_color: bool = true
	var is_number: bool = true
	var joker: Tile = null
	
	for tile in new_row:
		if(tile.getTileData().joker_id >= 0):
			joker = tile
		else:
			if(temp_color == -1):
				temp_color = tile.getTileData().color
				colors.append(tile.getTileData().color)
			elif(!tile.getTileData().effects["rainbow"] && tile.getTileData().color != temp_color):
				is_color = false
				colors.append(tile.getTileData().color)
			
			
			if(temp_number == -1):
				temp_number = tile.getTileData().number
			elif(tile.getTileData().number != temp_number):
				is_number = false
	
	if(is_color):
		same_color = true
		same_number = false
		the_color = temp_color
		if(joker != null):
			var jIndex: int = new_row.find(joker)
			joker.getTileData().potential_colors = [temp_color]
			if(jIndex == 0):
				joker.getTileData().potential_number = [new_row[jIndex+1].getTileData().number-1]
			else:
				joker.getTileData().potential_number = [new_row[jIndex-1].getTileData().number+1]
	elif(is_number):
		same_number = true
		same_color = false
		the_number = temp_number
		if(joker != null):
			joker.getTileData().potential_number.append(temp_number)
			var jColors: Array[int]
			for i in range(1, 5):
				if(colors.find(i) < 0):
					jColors.append(i)
			joker.getTileData().potential_colors = jColors

func is_postSpread_Eligible(tile: Tile, is_HomeSpread: bool = true):
	#-------------------------------------------------------------------------------------------------------------------------------------------------------------------
	var parentRot: float = tile.Player.rotation
	
	var firstTile: Tile = Tiles[0]
	var lastTile: Tile = Tiles[Tiles.size()-1]
	if(prefixedLeeches.size() >= 1):
		firstTile = prefixedLeeches[0]
	if(suffixedLeeches.size() >= 1):
		lastTile = suffixedLeeches[suffixedLeeches.size()-1]
	
	if(tile.getTileData().joker_id >= 0):
		var S: Vector2 = Tiles[0].parentEffector.global_position
		var D: float = cos(PI/2-parentRot)*(S.y-tile.global_position.y) + sin(PI/2-parentRot)*(S.x-tile.global_position.x)
		if(D >= 0):
			if(prefixedLeeches.size() >= 1 && is_HomeSpread):
				return false
		else:
			if(suffixedLeeches.size() >= 1 && is_HomeSpread):
				return false
		
		return true
	
	if(same_color):
		if(tile.getTileData().effects["rainbow"] || tile.getTileData().color == the_color):
			if(tile.getTileData().number == firstTile.getTileData().number-1 && prefixedLeeches.size() == 0):
				return true
			elif(tile.getTileData().number == firstTile.getTileData().number-1 && !is_HomeSpread):
				return true
			
			if(tile.getTileData().number == lastTile.getTileData().number+1 && suffixedLeeches.size() == 0):
				return true
			elif(tile.getTileData().number == lastTile.getTileData().number+1 && !is_HomeSpread):
				return true
	
	if(same_number):
		if(tile.getTileData().number == the_number):
			if(tile.getTileData().effects["rainbow"] || colors.find(tile.getTileData().color) < 0):
				if(suffixedLeeches.size() >= 1 && prefixedLeeches.size() >= 1):
					if(!is_HomeSpread):
						return true
				else:
					return true
	
	return false

func append_postSpread(new_Tile: Tile) -> Vector2:
	var parentRot: float = new_Tile.Player.rotation
	var final_pos: Vector2
	
	var firstTile: Tile = Tiles[0]
	var lastTile: Tile = Tiles[Tiles.size()-1]
	if(prefixedLeeches.size() >= 1):
		firstTile = prefixedLeeches[0]
	if(suffixedLeeches.size() >= 1):
		lastTile = suffixedLeeches[suffixedLeeches.size()-1]
	
	if(new_Tile.getTileData().joker_id >= 0):
		var S: Vector2 = Tiles[0].parentEffector.global_position
		var D: float = cos(PI/2-parentRot)*(S.y-new_Tile.global_position.y) + sin(PI/2-parentRot)*(S.x-new_Tile.global_position.x)
		if(D >= 0):
			if(new_Tile.rotation == 0 && prefixedLeeches.size() == 0):
				Tiles.insert(0, new_Tile)
				final_pos = Vector2(-30*cos(parentRot), -30*sin(parentRot)) + Vector2(10*sin(parentRot), -10*cos(parentRot))
			elif(new_Tile.rotation != 0):
				prefixedLeeches.insert(0, new_Tile)
				final_pos = Vector2(-30*cos(parentRot), 30*sin(parentRot))
		else:
			if(new_Tile.rotation == 0 && suffixedLeeches.size() == 0):
				Tiles.append(new_Tile)
				final_pos = Vector2(30*cos(parentRot), 30*sin(parentRot)) + Vector2(10*sin(parentRot), -10*cos(parentRot))
			elif(new_Tile.rotation != 0):
				suffixedLeeches.append(new_Tile)
				final_pos = Vector2(-30*cos(parentRot), 30*sin(parentRot))
	else:
		if(same_color):#prefixedLeeches
			if(new_Tile.getTileData().number == firstTile.getTileData().number-1):
				if(new_Tile.rotation == 0):
					Tiles.insert(0, new_Tile)
					final_pos = Vector2(-30*cos(parentRot), -30*sin(parentRot)) + Vector2(10*sin(parentRot), -10*cos(parentRot))
				else:
					prefixedLeeches.insert(0, new_Tile)
					final_pos = Vector2(-30*cos(parentRot), 30*sin(parentRot))
			if(new_Tile.getTileData().number == lastTile.getTileData().number+1):
				if(new_Tile.rotation == 0):
					Tiles.append(new_Tile)
					final_pos = Vector2(30*cos(parentRot), 30*sin(parentRot)) + Vector2(10*sin(parentRot), -10*cos(parentRot))
				else:
					suffixedLeeches.append(new_Tile)
					final_pos = Vector2(-30*cos(parentRot), 30*sin(parentRot))
		
		if(same_number):
			if(new_Tile.rotation == 0):
				Tiles.append(new_Tile)
				final_pos = Vector2(30*cos(parentRot), 30*sin(parentRot)) + Vector2(10*sin(parentRot), -10*cos(parentRot))
			else:
				suffixedLeeches.append(new_Tile)
				final_pos = Vector2(-30*cos(parentRot), 30*sin(parentRot))
	
	return final_pos

func get_SpreadSize(SpreadNode: Node2D) -> Vector2:
	#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	var parentRot: float = SpreadNode.get_parent().rotation
	
	var SuffixSize: Vector2 = Vector2(35*suffixedLeeches.size()*cos(parentRot), 35*suffixedLeeches.size()*sin(parentRot))
	var TileSize: Vector2 = Vector2((25 + 30*(Tiles.size()-1))*cos(parentRot), (25 + 30*(Tiles.size()-1))*sin(parentRot))
	var PrefixSize: Vector2 = Vector2(35*prefixedLeeches.size()*cos(parentRot), 35*prefixedLeeches.size()*sin(parentRot))
	
	return SuffixSize + TileSize + PrefixSize

static func check_spread_legality(selected_tiles: Array[Tile], highlight: bool = false) -> String:
	if(selected_tiles.size() < 3 && !highlight):
		return "too few!"
	
	var same_number: bool = true
	var same_color: bool = true
	var all_diff_color: bool = true
	var temp_color: int = -1
	var temp_number: int = -1
	var last_number: int = -1
	var is_ordered: bool = true
	var colors: Array[int]
	
	for tile in selected_tiles:
		if(tile.getTileData().joker_id >= 0):
			colors.append(-1)
			if(last_number != -1):
				last_number += 1
				if(last_number >= 14):
					last_number = 1
		else:
			if(temp_color == -1):
				temp_color = tile.getTileData().color
				colors.append(tile.getTileData().color)
			else:
				if(tile.getTileData().effects["rainbow"]):
					colors.append(0)
				elif(tile.getTileData().color != temp_color):
					same_color = false
					if(colors.find(tile.getTileData().color) >= 0):
						all_diff_color = false
					else:
						colors.append(tile.getTileData().color)
			
			
			if(temp_number == -1):
				temp_number = tile.getTileData().number
				last_number = temp_number
			else:
				if(tile.getTileData().number - last_number != 1):
					if(!(last_number == 13 && tile.getTileData().number == 1)):
						is_ordered = false
				if(tile.getTileData().number != temp_number):
					same_number = false
				
				last_number = tile.getTileData().number
	
	if(!same_color && !same_number):
		return "no pattern!"
	
	if(same_color && !is_ordered):
		return "not sequenced!"
	
	if(same_number && !all_diff_color):
		return "duplicates are illegal!"
	
	if(same_number && !all_diff_color):
		return "duplicates are illegal!"
	
	if(highlight && selected_tiles.size() > 1):
		if(same_number):
			return "number:" + str(temp_number)
		elif(same_color):
			return "color:" + str(temp_color)
	return "Spread!"
