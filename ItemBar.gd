extends Node2D

var items: Array[Item]
var ItemSlot_base: PackedScene = preload("res://ItemSelection.tscn")

signal item_used

const MAX_ITEM_SLOTS = 12

var MidasSparkle: Node2D

func _ready() -> void:
	for i in range(3):
		var new_ItemSlot: Item_Selection = ItemSlot_base.instantiate()
		new_ItemSlot.no_cost()
		$Slots.add_child(new_ItemSlot)
		new_ItemSlot.parentEffector = self

func _process(delta: float) -> void:
	if(MidasSparkle != null):
		MidasSparkle.global_position = get_global_mouse_position()
	if(Input.is_action_just_pressed("Left_Click")):
		if(inside_IB_S):
			still_inside_IB_S = true
	
	if(Input.is_action_just_released("Left_Click")):
		if(inside_IB_S && still_inside_IB_S && $Slots.get_child_count() < MAX_ITEM_SLOTS):
			still_inside_IB_S = false
			Item.is_HammerTime = false
			get_parent().HammerTime(false, $Slots, Vector2(0, 35))

func add_item(new_item: Item):
	var end_point: int = $Slots.get_children().size()
	match new_item.id:
		2:
			Item.flags["Wrench"] += 1
		4:
			Item.flags["Beaver Teeth"] = true
		5:
			Item.flags["Burning Shoes"] += 1
	if(new_item.instant):
		#if(new_item.uses >= 0):
			#for i in range(new_item.uses):
		new_item.useItem(get_parent())
		if(new_item.uses < 0):
			for i in range(end_point):
				if($Slots.get_child(end_point - i - 1).item_info == null):
					$Slots.get_child(end_point - i - 1).REgenerate_selection(new_item)
					if(!new_item.passive):
						$Slots.get_child(end_point - i - 1).Outline(true)
					else:
						$Slots.get_child(end_point - i - 1).Outline(false)
					break
	else:
		for i in range(end_point):
			if($Slots.get_child(end_point - i - 1).item_info == null):
				$Slots.get_child(end_point - i - 1).REgenerate_selection(new_item)
				if(!new_item.passive):
					$Slots.get_child(end_point - i - 1).Outline(true)
				else:
					$Slots.get_child(end_point - i - 1).Outline(false)
				break
	

func addItemBarUses() -> void:
	for item in $Slots.get_children():
		if("item_info" in item && item.item_info != null && item.item_info.uses >  1):
			item.item_info.uses += 1

func getItems() -> Array[Item]:
	var Items: Array[Item]
	for item in $Slots.get_children():
		if("item_info" in item && item.item_info != null):
			Items.append(item.item_info)
	
	return Items

func get_Slots() -> HBoxContainer:
	return $Slots

func item_select(Item_Slot: Item_Selection, item: Item, _cost: int) -> void:
	if(item != null && !item.passive):
		var was_used: bool = item.useItem(get_parent())
		if(was_used):
			#if(item.consumable):
			match item.id:
				0:
					item_used.emit(multiplayer.get_unique_id())
				1:
					Item_Slot.OutlineColor(Color(1, 0, 0, 1))
				3:
					Item_Slot.OutlineColor(Color(1, 0, 0, 1))
					MidasSparkle = load("res://scenes/sparkle_road.tscn").instantiate()
					get_parent().add_child(MidasSparkle)
					MidasSparkle.change_road(get_global_mouse_position(), Vector2(20, 20), 0.0)
					MidasSparkle.is_TopLevel = true
				6:
					Item_Slot.OutlineColor(Color(1, 0, 0, 1))
				
			if(item.uses <= 0 && item.consumable):
				Item_Slot.remove_item()
		else:
			match item.id:
				1:
					Item_Slot.OutlineColor(Color(1, 1, 1, 1))
				3:
					Item_Slot.OutlineColor(Color(1, 1, 1, 1))
					MidasSparkle.queue_free()
				6:
					Item_Slot.OutlineColor(Color(1, 1, 1, 1))

func used_PassiveItem(item_id: int):
	for item in $Slots.get_children():
		if(item.item_info != null && item.item_info.id == item_id):
			match item_id:
				3:
					item.item_info.uses -= 1
					if(item.item_info.uses <= 0):
						item.remove_item()
					Item.flags["Midas Touch"] -= 1
					item_used.emit(multiplayer.get_unique_id())
					break

func HammerTime(is_HammerTime: bool = false, Target: Node = null) -> void:
	if(Target == $Slots):
		add_ItemSlot()
	
	$ItemBar_Sensor.visible = is_HammerTime
	if(is_HammerTime):
		$BarBody.self_modulate.a = 100.0/255.0
		if($Slots.get_child_count() >= MAX_ITEM_SLOTS):
			$ItemBar_Highlight.self_modulate = Color(1, 0, 0, 1)
		else:
			$ItemBar_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	else:
		$BarBody.self_modulate.a = 1
		

func HammerUsed() -> void:
	for Slot in $Slots.get_children():
		if("item_info" in Slot && Slot.item_info != null && Slot.item_info.id == 1):
			Slot.item_info.uses -= 1
			item_used.emit(multiplayer.get_unique_id())
			if(Slot.item_info.uses <= 0):
				Slot.remove_item()
			else:
				Slot.OutlineColor(Color(1, 1, 1, 1))
			break

func MidasTouchUsed() -> void:
	for Slot in $Slots.get_children():
		if("item_info" in Slot && Slot.item_info != null && Slot.item_info.id == 3):
			Slot.item_info.uses -= 1
			item_used.emit(multiplayer.get_unique_id())
			if(Slot.item_info.uses <= 0):
				Slot.remove_item()
			else:
				Slot.OutlineColor(Color(1, 1, 1, 1))
			break
	
	MidasSparkle.queue_free()

func MonkeyPawUsed() -> void:
	for Slot in $Slots.get_children():#-------------------------------------------------------------------------------------------------
		if("item_info" in Slot && Slot.item_info != null && Slot.item_info.id == 6):
			Slot.item_info.usedThisRound += 1
			item_used.emit(multiplayer.get_unique_id())
			Slot.change_Sprite(load("res://Items/MonkeyPawUses/Monkey's Paw" + str(Slot.item_info.usedThisRound) + ".png"))
			Slot.OutlineColor(Color(1, 1, 1, 1))
			if(Slot.item_info.usedThisRound == 3):
				Slot.item_info.description = "I hope you got what you wished for..."
			break

func StartTurn() -> void:
	for item in $Slots.get_children():
		if("item_info" in item && item.item_info != null):
			item.item_info.resetUTR()
			if(item.item_info.id == 6):
				item.change_Sprite(load("res://Items/Monkey's Paw.png"))#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				item.item_info.description = "On Use - Select a [b]Tile[/b] to [b]de-Rarify[/b], then [b]Choose one of three Tiles[/b], with [i]the same [b]Rarity[/b] and [b]Effects[/b][/i] as the [b]Selected Tile[/b], to [b]Replace the Selected Tile[/b].[br][font_size=10][color=gray]Can only be [b]Used[/b] 3 times per [b]Round[/b][/color][/font_size]"

func add_ItemSlot() -> void:
	var new_ItemSlot: Item_Selection = ItemSlot_base.instantiate()
	new_ItemSlot.no_cost()
	$Slots.add_child(new_ItemSlot)
	$Slots.move_child(new_ItemSlot, 0)
	new_ItemSlot.parentEffector = self

var inside_IB_S: bool = false
var still_inside_IB_S: bool = false

func _on_ItemBar_Sensor_mouse_entered() -> void:
	inside_IB_S = true
	$ItemBar_Highlight.visible = true

func _on_ItemBar_Sensor_mouse_exited() -> void:
	still_inside_IB_S = false
	inside_IB_S = false
	$ItemBar_Highlight.visible = false
