extends Button

class_name Item_Selection

var item_cost: int = 5
var item_info: Item = null

var cost: bool = true

var mouse_inside: bool = false
var tip_timer: float = 0
var tip_openned: bool = false
var tip_UI: Control

#@export var id: int = 0

func _process(delta: float) -> void:
	if(mouse_inside):
		tip_timer += delta
		if(tip_timer >= 1 && !tip_openned):
			tip_openned = true
			tip_UI = preload("res://UI_Tip.tscn").instantiate()
			tip_UI.initialise_tip(self)
			get_tree().root.get_child(0).add_child(tip_UI)
			tip_UI.z_index = 3

func _on_pressed() -> void:
	get_parent().get_parent().item_select(self, item_info, item_cost)
	if(cost):
		$SOLD.visible = true
		disabled = true

func acc_size() -> Vector2:
	return size*scale

func no_cost() -> void:
	cost = false
	$Cost_Text.visible = false

func check_access(currentCurrency: int) -> void:
	if(free):
		disabled = false
		$Cost_Text.text = "0"
		$Cost_Text.modulate = Color(1, 1, 0, 1)
	else:
		$Cost_Text.text = str(item_cost)
		if(currentCurrency < item_cost):
			disabled = true
			$Cost_Text.modulate = Color(1, 0, 0, 1)
		else:
			disabled = false
			$Cost_Text.modulate = Color(1, 1, 1, 1)

func add_uses(additionalUses: int) -> void:
	if(item_info.uses >= 0):
		item_info.uses += additionalUses

var free: bool = false

func freebie(is_free: bool, currency: int) -> void:
	free = is_free
	check_access(currency)

func remove_item():
	item_info = null
	$ItemSprite.texture = null

func REgenerate_selection(new_item: Item = null) -> int:
	$SOLD.visible = false
	disabled = false
	
	var id: int
	
	if(new_item == null):
		id = randi_range(0, 4)
		if(Item.flags["Beaver Teeth"]):
			while(id == 4 && cost):
				id = randi_range(0, 4)
		item_info = Item.new(id)
	else:
		id = new_item.id
		item_info = new_item
	
	$ItemSprite.texture = item_info.item_image
	
	if(cost):
		match id:
			0:
				item_cost = randi_range(40, 65)
			1:
				item_cost = randi_range(20, 50)
			2:
				item_cost = randi_range(60, 85)
			3:
				item_cost = randi_range(70, 100)
		$Cost_Text.text = str(item_cost)
	
	return item_info.id


func _on_mouse_entered() -> void:
	mouse_inside = true


func _on_mouse_exited() -> void:
	mouse_inside = false
	tip_timer = 0
	if(tip_openned):
		tip_openned = false
		tip_UI.queue_free()
