extends Node2D

class_name GameBar

var items: Array[Item]
var ItemSlot_base: PackedScene = preload("res://ItemSelection.tscn")

signal item_used

const MAX_ITEM_SLOTS: int = 10
const STARTING_SLOTS: int = 3

var ItemSlots: Array[Item_Selection]

func _ready() -> void:
	for i in range(STARTING_SLOTS):
		var new_ItemSlot: Item_Selection = ItemSlot_base.instantiate()
		new_ItemSlot.no_cost()
		$Slots.add_child(new_ItemSlot)
		new_ItemSlot.parentEffector = self
		ItemSlots.append(new_ItemSlot)

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("Left_Click")):
		if(inside_IB_S):
			still_inside_IB_S = true
	
	if(Input.is_action_just_released("Left_Click")):
		if(inside_IB_S && still_inside_IB_S && $Slots.get_child_count() < MAX_ITEM_SLOTS):
			var Game: GameScene = get_parent()
			still_inside_IB_S = false
			if(Game.usingItem != null && Game.usingItem.item_info.target == Item.ItemTarget.ANY_HIGHLIGHT):
				Game.usingItem.item_info.useOnHighlight($Slots, Vector2(0, 35))
				await get_tree().create_timer(1.8).timeout
				add_ItemSlot()
				#get_parent().HammerTime(false, $Slots, Vector2(0, 35))

func add_item(new_item: Item):
	var end_point: int = $Slots.get_children().size()
	
	new_item.effectOnGet()
	
	if(new_item.uses != 0):
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
		if("item_info" in item && item.item_info != null && item.item_info.uses >=  1):
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
	var Game: GameScene = get_parent()
	
	if(Game.usingItem != null):
		if(Game.usingItem == item):
			item.endItemUse(true)
			Item_Slot.OutlineColor(Color(1, 1, 1, 1))
			#Game.endItemUse()
		
		return
	
	if(item != null):
		var was_used: bool = item.use()
		
		if(was_used && item.instant):
			item.usedThisRound += 1
			if(item.consumable):
				item.uses -= 1
			
			item_used.emit(multiplayer.get_unique_id())
			
			if(item.uses <= 0 && item.consumable):
				Item_Slot.remove_item()
			
		elif(was_used):
			Item_Slot.OutlineColor(Color(1, 0, 0, 1))
			Game.startIteamUse(Item_Slot)

func endItemUse(item: Item_Selection) -> void:
	item.item_info.usedThisRound += 1
	if(item.item_info.consumable):
		item.item_info.uses -= 1
	
	item_used.emit(multiplayer.get_unique_id())
	
	if(item.item_info.uses <= 0 && item.item_info.consumable):
		item.remove_item()
	else:
		item.OutlineColor(Color(1, 1, 1, 1))
	
	#item.item_info.endItemUse(true)

func usedPassiveItem(item: Item):
	#if((!isSlot_id && item.item_info.id == item_id) || (isSlot_id && item.get_index() == item_id)):
	
	if(item.consumable):
		item.uses -= 1
		item_used.emit(multiplayer.get_unique_id())
		if(item.uses <= 0):
			getItemSlot(item).remove_item()

func ToggleHighlight(toggle: bool = false) -> void:
	#if(Target == $Slots):
		#add_ItemSlot()
	
	#, Target: Node = null
	
	$ItemBar_Sensor.visible = toggle
	if(toggle):
		$BarBody.self_modulate.a = 100.0/255.0
		if($Slots.get_child_count() >= MAX_ITEM_SLOTS):
			$ItemBar_Highlight.self_modulate = Color(1, 0, 0, 1)
		else:
			$ItemBar_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	else:
		$BarBody.self_modulate.a = 1
	

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

#func activeItemUses(item: Item_Selection):
	#item.item_info.usedThisRound += 1
	#
	#match(item.item_info.id):
		#3:
			#MidasSparkle.queue_free()
		#6:
			#item.change_Sprite(load("res://Items/MonkeyPawUses/Monkey's Paw" + str(item.item_info.usedThisRound) + ".png"))
			#item.OutlineColor(Color(1, 1, 1, 1))
			#if(item.item_info.usedThisRound == 3):
				#item.item_info.description = "I hope you got what you wished for..."
	#
	#if(item.item_info.consumable):
		#item.item_info.uses -= 1
	#
	#item_used.emit(multiplayer.get_unique_id())
	#
	#if(item.item_info.consumable):
		#if(item.item_info.uses <= 0):
			#item.remove_item()
		#else:
			#item.OutlineColor(Color(1, 1, 1, 1))

#func StartTurn() -> void:
	#for item in $Slots.get_children():
		#if("item_info" in item && item.item_info != null):
			#item.item_info.resetUTR()
			#if(item.item_info.id == 6):
				#item.change_Sprite(load("res://Items/Sprites/Monkey's Paw.png"))#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				#item.item_info.description = "On Use - Select a [b]Tile[/b] to [b]de-Rarify[/b], then [b]Choose one of three Tiles[/b], with [i]the same [b]Rarity[/b] and [b]Effects[/b][/i] as the [b]Selected Tile[/b], to [b]Replace the Selected Tile[/b].[br][font_size=10][color=gray]Can only be [b]Used[/b] 3 times per [b]Round[/b][/color][/font_size]"

func add_ItemSlot() -> void:
	var new_ItemSlot: Item_Selection = ItemSlot_base.instantiate()
	new_ItemSlot.no_cost()
	$Slots.add_child(new_ItemSlot)
	$Slots.move_child(new_ItemSlot, 0)
	new_ItemSlot.parentEffector = self
	ItemSlots.append(new_ItemSlot)

func getItemSlot(item: Item) -> Item_Selection:
	for Slot in $Slots.get_children():
		if("item_info" in Slot && Slot.item_info != null && Slot.item_info == item):
			return Slot
	
	return null

var inside_IB_S: bool = false
var still_inside_IB_S: bool = false

func _on_ItemBar_Sensor_mouse_entered() -> void:
	inside_IB_S = true
	$ItemBar_Highlight.visible = true

func _on_ItemBar_Sensor_mouse_exited() -> void:
	still_inside_IB_S = false
	inside_IB_S = false
	$ItemBar_Highlight.visible = false
