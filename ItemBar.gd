extends Node2D

var items: Array[Item]
var ItemSlot_base: PackedScene = preload("res://ItemSelection.tscn")

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
	if(new_item.instant):
		for i in range(new_item.uses):
			new_item.useItem(get_parent())
	else:
		for i in range(end_point):
			if($Slots.get_child(end_point - i - 1).item_info == null):
				#items[i] = new_item
				$Slots.get_child(end_point - i - 1).REgenerate_selection(new_item)
				break

func item_select(Item_Slot: Item_Selection, item: Item, _cost: int) -> void:
	#index = items.size()-1 - index
	if(item != null && !item.passive):
		var was_used: bool = item.useItem(get_parent())
		if(was_used):
			item.uses -= 1
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
					break

func add_ItemSlot() -> void:
	var new_ItemSlot: Item_Selection = ItemSlot_base.instantiate()
	new_ItemSlot.no_cost()
	$Slots.add_child(new_ItemSlot)
	$Slots.move_child(new_ItemSlot, 0)
