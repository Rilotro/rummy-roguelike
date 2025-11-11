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
	
	#multiplayer.peer_connected.connect(player_joined)
	Tiles[0].Player.get_parent().get_ItemBar().item_used.connect(Architect_Check)
	
	var temp_color: int = -1
	var temp_number: int = -1
	var is_color: bool = true
	var is_number: bool = true
	var joker: Tile = null
	
	for tile in new_row:
		if(tile.getTileData().joker_id >= 0):
			colors.append(-1)
		else:
			if(temp_color == -1):
				if(!tile.getTileData().effects["rainbow"]):
					temp_color = tile.getTileData().color
					colors.append(tile.getTileData().color)
				#else:
					#colors.append(-1)
			elif(!tile.getTileData().effects["rainbow"] && tile.getTileData().color != temp_color):
				is_color = false
				colors.append(tile.getTileData().color)
			
			if(tile.getTileData().effects["rainbow"]):
				colors.append(-1)
			
			if(temp_number == -1):
				temp_number = tile.getTileData().number
			elif(tile.getTileData().number != temp_number):
				is_number = false
	
	if(is_color):
		same_color = true
		same_number = false
		the_color = temp_color
		#if(joker != null):
			#var jIndex: int = new_row.find(joker)
			#joker.getTileData().potential_colors = [temp_color]
			#if(jIndex == 0):
				#joker.getTileData().potential_number = [new_row[jIndex+1].getTileData().number-1]
			#else:
				#joker.getTileData().potential_number = [new_row[jIndex-1].getTileData().number+1]
	elif(is_number):
		same_number = true
		same_color = false
		the_number = temp_number
		#if(joker != null):
			#joker.getTileData().potential_number.append(temp_number)
			#var jColors: Array[int]
			#for i in range(1, 5):
				#if(colors.find(i) < 0):
					#jColors.append(i)
			#joker.getTileData().potential_colors = jColors

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
			if(same_color && firstTile.getTileData().number == 1):
				return false
		else:
			if(suffixedLeeches.size() >= 1 && is_HomeSpread):
				return false
			if(same_color && lastTile.getTileData().number == 1):
				return false
		
		if(same_number && colors.size() >= 4):
			return false
		
		return true
	
	if(same_color):
		var firstNumber: int = firstTile.getTileData().number
		if(firstTile.getTileData().joker_id >= 0):
			firstNumber = -1
			for i in range(prefixedLeeches.size()):
				if(prefixedLeeches[i] != firstTile && prefixedLeeches[i].getTileData().joker_id < 0):
					firstNumber = prefixedLeeches[i].getTileData().number-i
			
			if(firstNumber == -1):
				for i in range(Tiles.size()):
					if(Tiles[i] != firstTile && Tiles[i].getTileData().joker_id < 0):
						firstNumber = Tiles[i].getTileData().number - prefixedLeeches.size()-i
		
		var lastNumber: int = lastTile.getTileData().number
		if(lastTile.getTileData().joker_id >= 0):
			lastNumber = -1
			var SLSize: int = suffixedLeeches.size()
			for i in range(SLSize):
				if(suffixedLeeches[SLSize-i-1] != lastTile && suffixedLeeches[SLSize-i-1].getTileData().joker_id < 0):
					lastNumber = suffixedLeeches[i].getTileData().number + i
			
			var TSize: int = Tiles.size()
			if(lastNumber == -1):
				for i in range(TSize):
					if(Tiles[TSize-i-1] != lastTile && Tiles[TSize-i-1].getTileData().joker_id < 0):
						lastNumber = Tiles[TSize-i-1].getTileData().number + suffixedLeeches.size() + i
		
		if(tile.getTileData().effects["rainbow"] || tile.getTileData().color == the_color):
			if(tile.getTileData().number == firstNumber-1):
				if(prefixedLeeches.size() == 0 || !is_HomeSpread):
					return true
			
			if(tile.getTileData().number == lastNumber+1 && lastNumber != 1):
				if(suffixedLeeches.size() == 0 || !is_HomeSpread):
					return true
			elif(tile.getTileData().number == 1 && lastNumber == 13):
				if(suffixedLeeches.size() == 0 || !is_HomeSpread):
					return true
	
	if(same_number):
		if(tile.getTileData().number == the_number && colors.size() < 4):
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
		colors.append(-1)
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
		if(same_color):
			var firstNumber: int = firstTile.getTileData().number
			if(firstTile.getTileData().joker_id >= 0):
				firstNumber = -1
				for i in range(prefixedLeeches.size()):
					if(prefixedLeeches[i] != firstTile && prefixedLeeches[i].getTileData().joker_id < 0):
						firstNumber = prefixedLeeches[i].getTileData().number-i
				
				if(firstNumber == -1):
					for i in range(Tiles.size()):
						if(Tiles[i] != firstTile && Tiles[i].getTileData().joker_id < 0):
							firstNumber = Tiles[i].getTileData().number - prefixedLeeches.size()-i
			
			var lastNumber: int = lastTile.getTileData().number
			if(lastTile.getTileData().joker_id >= 0):
				lastNumber = -1
				var SLSize: int = suffixedLeeches.size()
				for i in range(SLSize):
					if(suffixedLeeches[SLSize-i-1] != lastTile && suffixedLeeches[SLSize-i-1].getTileData().joker_id < 0):
						lastNumber = suffixedLeeches[i].getTileData().number + i
				
				var TSize: int = Tiles.size()
				if(lastNumber == -1):
					for i in range(TSize):
						if(Tiles[TSize-i-1] != lastTile && Tiles[TSize-i-1].getTileData().joker_id < 0):
							lastNumber = Tiles[TSize-i-1].getTileData().number + suffixedLeeches.size() + i
			
			if(new_Tile.getTileData().number == firstNumber-1):
				if(new_Tile.rotation == 0):
					Tiles.insert(0, new_Tile)
					final_pos = Vector2(-30*cos(parentRot), -30*sin(parentRot)) + Vector2(10*sin(parentRot), -10*cos(parentRot))
				else:
					prefixedLeeches.insert(0, new_Tile)
					final_pos = Vector2(-30*cos(parentRot), 30*sin(parentRot))
			if(new_Tile.getTileData().number == lastNumber+1 || (new_Tile.getTileData().number == 1 && lastNumber == 13)):
				if(new_Tile.rotation == 0):
					Tiles.append(new_Tile)
					final_pos = Vector2(30*cos(parentRot), 30*sin(parentRot)) + Vector2(10*sin(parentRot), -10*cos(parentRot))
				else:
					suffixedLeeches.append(new_Tile)
					final_pos = Vector2(-30*cos(parentRot), 30*sin(parentRot))
		
		if(same_number):
			if(new_Tile.getTileData().effects["rainbow"]):
				colors.append(-1)
			else:
				colors.append(new_Tile.getTileData().color)
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

func Architect_Check() -> void:
	for tile in Tiles:
		if(tile.getTileData().joker_id == 3):
			var extraPoints: int = tile.on_spread(Vector2(0, 0), self, {"Architect": true})
			await tile.get_tree().create_timer(0.8).timeout
		
			var TMP_RTL: RichTextLabel = RichTextLabel.new()
			tile.Player.add_child(TMP_RTL)
			TMP_RTL.text = "0"
			TMP_RTL.visible = false
			TMP_RTL.global_position = tile.Player.get_ProgressBar().global_position
			await tile.UI_add_score(TMP_RTL, 0, 0)
			TMP_RTL.queue_free()
			
			tile.Player.addPoints(extraPoints)

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
	#var out_of_bounds: bool = false
	var sequence: Array[int]
	var joker_count: int = 0
	var tile: Tile
	
	for i in range(selected_tiles.size()):
		tile = selected_tiles[i]
		if(tile.getTileData().joker_id >= 0):
			joker_count += 1
			colors.append(-1)
			if(last_number == -1):
				for j in range(selected_tiles.size()-i-1):
					if(selected_tiles[i+j+1].getTileData().joker_id < 0):
						if(selected_tiles[i+j+1].getTileData().number == 1):
							sequence.append(13-j)
							break
						else:
							sequence.append(selected_tiles[i+j+1].getTileData().number-j-1)
							break
			else:
				last_number += 1
				if(last_number >= 14):
					last_number = 1
				
				sequence.append(last_number)
		else:
			if(temp_color == -1):
				temp_color = tile.getTileData().color
				colors.append(tile.getTileData().color)
			else:
				if(tile.getTileData().effects["rainbow"]):
					colors.append(-1)
				elif(tile.getTileData().color != temp_color):
					same_color = false
					if(colors.find(tile.getTileData().color) >= 0):
						all_diff_color = false
					else:
						colors.append(tile.getTileData().color)
			
			sequence.append(tile.getTileData().number)
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
	
	if(selected_tiles.size() - joker_count <= 1):
		return "too ambiguous"
	
	if(!same_color && !same_number):
		return "no pattern!"
	
	if(same_color):
		if(!is_ordered):
			return "not sequenced!"
		else:
			last_number = -1
			var endPassed: bool = false
			for entry in sequence:
				if(entry < 1):
					return "out of bounds!"
				if(last_number != -1):
					if(entry - last_number != 1):
						if(!(last_number == 13 && entry == 1)):
							return "not sequenced!" 
				
				if(entry > 1 && endPassed):
					return "out of bounds!"
				
				last_number = entry
				if(entry == 13):
					endPassed = true
	
	
	if(same_number):
		if(!all_diff_color):
			return "duplicates are illegal!"
		elif(colors.size() > 4):
			return "too many colors!"
	
	if(highlight && selected_tiles.size() > 1):
		if(same_number):
			return "number:" + str(temp_number)
		elif(same_color):
			return "color:" + str(temp_color)
	return "Spread!"
