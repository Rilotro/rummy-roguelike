extends Node2D

var items: Array[Item]
var ItemSlot_base: PackedScene = preload("res://ItemSelection.tscn")

signal item_used

func _ready() -> void:
	for i in range(3):
		var new_ItemSlot: Item_Selection = ItemSlot_base.instantiate()
		new_ItemSlot.no_cost()
		$Slots.add_child(new_ItemSlot)

func add_item(new_item: Item):
	var end_point: int = $Slots.get_children().size()
	match new_item.id:
		2:
			Item.flags["Wrench"] += 1
		3:
			Item.flags["Midas Touch"] += new_item.uses
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
					break
	else:
		for i in range(end_point):
			if($Slots.get_child(end_point - i - 1).item_info == null):
				$Slots.get_child(end_point - i - 1).REgenerate_selection(new_item)
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

func item_select(Item_Slot: Item_Selection, item: Item, _cost: int) -> void:
	if(item != null && !item.passive):
		var was_used: bool = item.useItem(get_parent())
		if(was_used):
			if(item.consumable):
				item_used.emit()
				if(item.uses <= 0):
					Item_Slot.remove_item()

func used_PassiveItem(item_id: int):
	for item in $Slots.get_children():
		if(item.item_info != null && item.item_info.id == item_id):
			match item_id:
				3:
					item.item_info.uses -= 1
					if(item.item_info.uses <= 0):
						item.remove_item()
					Item.flags["Midas Touch"] -= 1
					item_used.emit()
					break

func MonkeyPawUsed() -> void:
	for Slot in $Slots.get_children():#-------------------------------------------------------------------------------------------------
		if("item_info" in Slot && Slot.item_info != null && Slot.item_info.id == 6):
			Slot.item_info.usedThisRound += 1
			Slot.change_Sprite(load("res://Items/MonkeyPawUses/Monkey's Paw" + str(Slot.item_info.usedThisRound) + ".png"))
			break

func StartTurn() -> void:
	for item in $Slots.get_children():
		if("item_info" in item && item.item_info != null):
			item.item_info.resetUTR()
			if(item.item_info.id == 6):
				item.change_Sprite(load("res://Items/Monkey's Paw.png"))

func add_ItemSlot() -> void:
	var new_ItemSlot: Item_Selection = ItemSlot_base.instantiate()
	new_ItemSlot.no_cost()
	$Slots.add_child(new_ItemSlot)
	$Slots.move_child(new_ItemSlot, 0)
