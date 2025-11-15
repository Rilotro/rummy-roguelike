extends Button

class_name Tile_Selection

@export var joker_tile: bool = false
var tile_cost: int = 5

var cost: bool = true

var parentEffector: Node

func _on_pressed() -> void:
	parentEffector.tile_select(self, $Body.Tile_Data, tile_cost)
	if(cost):
		$SOLD.visible = true
	$Body._on_control_mouse_exited()
	disabled = true

func get_TileData() -> Tile_Info:
	return $Body.Tile_Data

func no_cost() -> void:
	cost = false
	$Cost_Text.modulate = Color(1, 1, 1, 0)

func check_access(currentCurrency: int) -> void:
	if(free):
		disabled = false
		#$Cost_Text.text = "0"
		$Cost_Text.modulate = Color(1, 1, 0, 1)
	else:
		$Cost_Text.text = str(tile_cost)
		if(currentCurrency < tile_cost):
			disabled = true
			$Cost_Text.modulate = Color(1, 0, 0, 1)
		else:
			disabled = false
			$Cost_Text.modulate = Color(1, 1, 1, 1)

var free: bool = false

func freebie(is_free: bool, currency: int) -> void:
	free = is_free
	check_access(currency)

func REgenerate_selection(setTile: Tile_Info = null) -> int:
	$SOLD.visible = false
	disabled = false
	if(setTile != null):
		if(cost):
			if(setTile.joker_id >= 0):
				match setTile.joker_id:
					0:
						tile_cost = randi_range(30, 50)
					1:
						tile_cost = randi_range(15, 35)
					2:
						tile_cost = randi_range(75, 105)
					3:
						tile_cost = randi_range(35, 70)
					4:
						tile_cost = randi_range(45, 75)
				$Cost_Text.text = str(tile_cost)
			else:
				match setTile.rarity:
					"porcelain":
						tile_cost = randi_range(2, 12)
					"bronze":
						tile_cost = randi_range(8, 17)
					"silver":
						tile_cost = randi_range(12, 27)
					"gold":
						tile_cost = randi_range(24, 31)
				
				if(setTile.effects["rainbow"]):
					tile_cost += randi_range(4, 13)
				
				if(setTile.effects["duplicate"]):
					tile_cost += randi_range(6, 17)
				
				if(setTile.effects["winged"]):
					tile_cost += randi_range(5, 10)
				
				$Cost_Text.text = str(tile_cost)
		
		$Body.change_info(setTile)
		return setTile.joker_id
	elif(joker_tile):
		var joker_id: int = randi_range(0, 4)
		while(HighLevelNetworkHandler.is_singleplayer && joker_id == 4):
			joker_id = randi_range(0, 4)
		
		if(cost):
			match joker_id:
				0:
					tile_cost = randi_range(30, 50)
				1:
					tile_cost = randi_range(15, 35)
				2:
					tile_cost = randi_range(60, 85)
				3:
					tile_cost = randi_range(35, 70)
				4:
					tile_cost = randi_range(45, 75)
			$Cost_Text.text = str(tile_cost)
		$Body.change_info(Tile_Info.new(0, 0, joker_id))
		return joker_id
	else:
		var tile_rarity: String
		var is_rainbow: bool = false
		var is_duplicate: bool = false
		var is_winged: bool = false
		var rainbow_rng: int = randi_range(1, 100)
		var duplicate_rng: int = randi_range(1, 100)
		var winged_rng: int = randi_range(1, 100)
		var rarity: int = randi_range(1, 100)
		var rarity_counter: int = 0
		
		if(rarity <= 50 - 10*Tile_Info.level):
			tile_rarity = "porcelain"
			tile_cost = randi_range(2, 12)
		elif(rarity <= 75 - 7*Tile_Info.level):
			tile_rarity = "bronze"
			rarity_counter = 1
			tile_cost = randi_range(8, 17)
		elif(rarity <= 90 - 4*Tile_Info.level):
			tile_rarity = "silver"
			rarity_counter = 2
			tile_cost = randi_range(12, 27)
		else:
			tile_rarity = "gold"
			rarity_counter = 3
			tile_cost = randi_range(24, 31)
		
		if(rainbow_rng <= 15 + 7*Tile_Info.level - 2*rarity_counter):
			is_rainbow = true
			tile_cost += randi_range(4, 13)
		
		if(duplicate_rng <= 10 + 6*Tile_Info.level - 3*rarity_counter):
			is_duplicate = true
			tile_cost += randi_range(6, 17)
		
		if(winged_rng <= 12 + 7*Tile_Info.level - rarity_counter):
			is_winged = true
			tile_cost += randi_range(5, 10)
		
		if(cost):
			$Cost_Text.text = str(tile_cost)
		var rand_num: int = randi_range(1, 13)
		var rand_col: int = randi_range(1, 4)
		if(is_rainbow):
			rand_col = -1
		#-------------------------------------------------------------------------------------------------------------------------------------------
		$Body.change_info(Tile_Info.new(rand_num, rand_col, -1, tile_rarity, null, {"rainbow": is_rainbow, "duplicate": is_duplicate, "winged": is_winged}))
		return -1

func _on_control_mouse_entered() -> bool:
	return !disabled

func _on_control_mouse_exited() -> bool:
	return !disabled
