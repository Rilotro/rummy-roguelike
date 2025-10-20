extends Resource

class_name Spread_Info

var Tiles: Array[Tile]
var same_color: bool
var same_number: bool
var the_number: int = -1
var the_color: int = -1

func _init(new_row: Array[Tile]) -> void:
	Tiles = new_row.duplicate()
	
	var temp_color: int = -1
	var temp_number: int = -1
	var is_color: bool = true
	var is_number: bool = true
	var colors: Array[int]
	var joker: Tile = null
	
	for tile in new_row:
		if(tile.getTileData().joker):
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
