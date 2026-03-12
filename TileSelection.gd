extends Button

class_name Tile_Selection

@export var joker_tile: bool = false
var tile_cost: int = 5

var cost: bool = true

var parentEffector: Node

func _on_pressed() -> void:
	parentEffector.tile_select(self, $Body.Tile_Data, tile_cost)
	if(cost && !parentEffector.get_parent().getTurn()):
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
			tile_cost = Tile_Info.getShopCost(setTile)
			$Cost_Text.text = str(tile_cost)
		
		$Body.change_info(setTile)
		return setTile.joker_id
	elif(joker_tile):
		var joker_id: int = randi_range(0, 4)
		while(HighLevelNetworkHandler.is_singleplayer && joker_id == 4):
			joker_id = randi_range(0, 4)
		
		var newTile: Tile_Info = Tile_Info.new(0, Color.BLACK, joker_id)
		
		if(cost):
			tile_cost = Tile_Info.getShopCost(newTile)
			$Cost_Text.text = str(tile_cost)
		
		$Body.change_info(newTile)
		return joker_id
	else:
		var newTile: Tile_Info = Tile_Info.getRandomTile(Tile_Info.Effect.size())
		tile_cost = Tile_Info.getShopCost(newTile)
		
		if(cost):
			$Cost_Text.text = str(tile_cost)
		#-------------------------------------------------------------------------------------------------------------------------------------------
		$Body.change_info(newTile)
		return -1

func _on_control_mouse_entered() -> bool:
	return !disabled

func _on_control_mouse_exited() -> bool:
	return !disabled
