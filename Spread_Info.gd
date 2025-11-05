extends Resource

class_name Spread_Info

var Tiles: Array[Tile]
var same_color: bool
var same_number: bool
var the_number: int = -1
var the_color: int = -1
var colors: Array[int]

static var MIDDLE_POS: float = 840.0

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

func is_postSpread_Eligible(tile: Tile):
	#-------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if(tile.getTileData().joker_id >= 0):
		return true
	if(same_color):
		if(tile.getTileData().effects["rainbow"] || tile.getTileData().color == the_color):
			if(tile.getTileData().number == Tiles[0].getTileData().number-1 || tile.getTileData().number == Tiles[Tiles.size()-1].getTileData().number+1):
				return true
	
	if(same_number):
		if(tile.getTileData().number == the_number):
			if(tile.getTileData().effects["rainbow"] || colors.find(tile.getTileData().color) < 0):
				return true
	
	return false

func append_postSpread(new_Tile: Tile) -> Vector2:
	var final_pos: Vector2
	if(same_color):
		if(new_Tile.getTileData().joker_id >= 0):
			if(new_Tile.global_position.x <= MIDDLE_POS):
				Tiles.insert(0, new_Tile)
				final_pos = Vector2(-30, -10)
			else:
				Tiles.append(new_Tile)
				final_pos = Vector2(30, -10)
		if(new_Tile.getTileData().number == Tiles[0].getTileData().number-1):
			Tiles.insert(0, new_Tile)
			final_pos = Vector2(-30, -10)
		if(new_Tile.getTileData().number == Tiles[Tiles.size()-1].getTileData().number+1):
			Tiles.append(new_Tile)
			final_pos = Vector2(30, -10)
	
	if(same_number):
		Tiles.append(new_Tile)
		final_pos = Vector2(30, -10)
	
	return final_pos

func get_tile_pos(pos: int) -> float:
	if(pos >= 0 && pos <= Tiles.size()-1):
		var start_pos: float = MIDDLE_POS - (25 + 30*(Tiles.size()-1))/2.0
		return start_pos + 12.5 + 30*pos
	
	return 0

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
