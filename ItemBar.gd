extends Node2D

class_name GameBar

var items: Array[Item]

signal item_used

const MAX_ITEM_SLOTS: int = 10
const STARTING_SLOTS: int = 3

var ItemSlots: Array[ItemContainer]
var ModifierConatiners: Array[ModifierContainer]

func _ready() -> void:
	for i in range(STARTING_SLOTS):
		var newItemSlot: ItemContainer = ItemContainer.new(null, ResourceContainer.ContainerType.GAMEBAR)
		$Slots.add_child(newItemSlot)
		ItemSlots.append(newItemSlot)
	
	get_parent().StartOfTurn.connect(ModifierCountdown)

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("Left_Click")):
		if(inside_IB_S):
			still_inside_IB_S = true
	
	if(Input.is_action_just_released("Left_Click")):
		if(inside_IB_S && still_inside_IB_S && ItemSlots.size() < MAX_ITEM_SLOTS):
			still_inside_IB_S = false
			if(GameScene.Game.usingItem != null && GameScene.Game.usingItem.resource.target == Item.ItemTarget.ANY_HIGHLIGHT):
				GameScene.Game.usingItem.resource.useOnHighlight($Slots, Vector2(0, 35))
				await get_tree().create_timer(1.8).timeout
				add_ItemSlot()
				#get_parent().HammerTime(false, $Slots, Vector2(0, 35))

func add_item(new_item: Item):
	var end_point: int = ItemSlots.size()
	
	if(new_item.uses != 0):
		for i in range(end_point):
			if(ItemSlots[end_point - i - 1].resource == null):
				ItemSlots[end_point - i - 1].REgenerateResource(new_item)
				break
				#if(!new_item.passive):
					#ItemSlots[end_point - i - 1].Outline(true)
				#else:
					#ItemSlots[end_point - i - 1].Outline(false)
				#break
	
	new_item.effectOnGet()

func addItemBarUses() -> void:
	for item in ItemSlots:
		if(item.resource != null && item.resource.uses >=  1):
			item.resource.uses += 1

func getItems() -> Array[Item]:
	var Items: Array[Item]
	for item in ItemSlots:
		if(item.resource != null):
			Items.append(item.resource)
	
	return Items

func get_Slots() -> HBoxContainer:
	return $Slots

func containerPressed(ItemSlot: ItemContainer) -> void:
	var Game: GameScene = get_parent()
	
	if(Game.usingItem != null):
		if(Game.usingItem == ItemSlot.resource):
			ItemSlot.resource.endItemUse(true)
			ItemSlot.OutlineColor(Color(1, 1, 1, 1))
			#Game.endItemUse()
		
		return
	
	if(ItemSlot.resource != null):
		var was_used: bool = ItemSlot.resource.use()
		
		if(was_used && ItemSlot.resource.instant):
			ItemSlot.resource.usedThisRound += 1
			if(ItemSlot.resource.consumable):
				ItemSlot.resource.uses -= 1
			
			item_used.emit(multiplayer.get_unique_id())
			
			if(ItemSlot.resource.uses <= 0 && ItemSlot.resource.consumable):
				ItemSlot.remove_item()
			
		elif(was_used):
			ItemSlot.OutlineColor(Color(1, 0, 0, 1))
			Game.startIteamUse(ItemSlot)

func endItemUse(item: ItemContainer) -> void:
	item.resource.usedThisRound += 1
	if(item.resource.consumable):
		item.resource.uses -= 1
	
	item_used.emit(multiplayer.get_unique_id())
	
	if(item.resource.uses <= 0 && item.resource.consumable):
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
	$ItemBar_Sensor.visible = toggle
	if(toggle):
		$BarBody.self_modulate.a = 100.0/255.0
		if($Slots.get_child_count() >= MAX_ITEM_SLOTS):
			$ItemBar_Highlight.self_modulate = Color(1, 0, 0, 1)
		else:
			$ItemBar_Highlight.self_modulate = Color(0, 74.0/255.0, 221.0/255.0, 1)
	else:
		$BarBody.self_modulate.a = 1

func add_ItemSlot() -> void:
	var new_ItemSlot: ItemContainer = ItemContainer.new(null, ResourceContainer.ContainerType.GAMEBAR)
	$Slots.add_child(new_ItemSlot)
	$Slots.move_child(new_ItemSlot, 0)
	ItemSlots.append(new_ItemSlot)

func addModifier(newModifier: Modifier) -> void:
	var newModifierContainer: ModifierContainer = ModifierContainer.new(newModifier, ResourceContainer.ContainerType.GAMEBAR)
	ModifierConatiners.append(newModifierContainer)
	$ModifierSlots.add_child(newModifierContainer)
	newModifier.effectOnGet()

func removeModifier(ModifierToRemove: Modifier) -> void:
	for modifier in ModifierConatiners:
		if(modifier.resource == ModifierToRemove):
			#modifier.removeModifier()
			modifier.queue_free()
			break

func ModifierCountdown() -> void:
	for modifier in ModifierConatiners:
		modifier.resource.effectOnStartOfTurn()
		if(modifier.resource.rounds <= 0):
			#modifier.removeModifier()
			modifier.queue_free()

func getItemSlot(item: Item) -> ItemContainer:
	for Slot in ItemSlots:
		if(Slot.resource == item):
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
