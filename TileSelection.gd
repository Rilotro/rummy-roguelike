extends Button

class_name Tile_Selection

@export var joker_tile: bool = false
var tile_cost: int = 5

var cost: bool = true

var parentEffector: Node

var CostText: RichTextLabel
var Body: TileBody
var SOLD: RichTextLabel

func _init(tile_info: Tile_Info = null, isShopSelection: bool = false, EffectsChance: int = -1) -> void:
	if(tile_info == null):
		tile_info = Tile_Info.getRandomTile(EffectsChance)
	
	pressed.connect(_on_pressed)
	
	custom_minimum_size = Vector2(50, 70)
	set_anchors_preset(Control.PRESET_CENTER)
	size = Vector2(50, 70)
	#add_theme_font_size_override("font_size", 16)
	self_modulate = Color.TRANSPARENT
	
	CostText = RichTextLabel.new()
	CostText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CostText.custom_minimum_size = Vector2(50, 23)
	CostText.size = Vector2(50, 23)
	CostText.position.y = 70
	CostText.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if(isShopSelection):
		cost = Tile_Info.getShopCost(tile_info)
		CostText.text = str(cost)
	
	CostText.name = "CostText"
	add_child(CostText)
	
	Body = TileBody.new(tile_info)
	Body.name = "Body"
	add_child(Body)
	
	SOLD = RichTextLabel.new()
	SOLD.fit_content = true
	SOLD.scroll_active = false
	SOLD.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	SOLD.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	SOLD.custom_minimum_size = Vector2(105.58, 42)
	SOLD.size = Vector2(105.58, 42)
	SOLD.position = Vector2(-20, 65)
	SOLD.rotation = -45
	SOLD.mouse_filter = Control.MOUSE_FILTER_IGNORE
	SOLD.add_theme_color_override("default_color", Color.RED)
	SOLD.add_theme_font_size_override("normal_font_size", 30)
	var Style: StyleBoxTexture = StyleBoxTexture.new()
	Style.texture = CanvasTexture.new()
	Style.modulate_color = Color.BLACK
	SOLD.add_theme_stylebox_override("normal", Style)
	SOLD.visible = false
	SOLD.self_modulate = Color(1, 1, 1, 0.78)
	SOLD.name = "SOLD"
	add_child(SOLD)

func _on_pressed() -> void:
	parentEffector.tile_select(self, $Body.Tile_Data, tile_cost)
	if(cost && !parentEffector.get_parent().getTurn()):
		SOLD.visible = true
	
	Body._on_control_mouse_exited()
	disabled = true

func get_TileData() -> Tile_Info:
	return $Body.Tile_Data

func no_cost() -> void:
	cost = false
	CostText.modulate = Color(1, 1, 1, 0)

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

func REgenerate_selection(setTile: Tile_Info = null, EffectsChance: int = -1) -> int:
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
		
		Body.change_info(newTile)
		return joker_id
	else:
		var newTile: Tile_Info = Tile_Info.getRandomTile(EffectsChance)
		tile_cost = Tile_Info.getShopCost(newTile)
		
		if(cost):
			$Cost_Text.text = str(tile_cost)
		#-------------------------------------------------------------------------------------------------------------------------------------------
		Body.change_info(newTile)
		#Body.change_info(newTile)
		return -1

func _on_control_mouse_entered() -> bool:
	return !disabled

func _on_control_mouse_exited() -> bool:
	return !disabled
