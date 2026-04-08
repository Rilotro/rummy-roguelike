extends Node2D

class_name GameBar

var items: Array[Item]

signal item_used

const MAX_ITEM_SLOTS_ROW: int = 7
const MAX_MODIFIER_SLOTS_ROW: int = 3
const STARTING_SLOTS: int = 3
const SPACE_BETWEEN_ITEM_SLOTS: float = 5
const SPACE_BETWEEN_MODIFIER_SLOTS: Vector2 = Vector2(15, 15)
const SLOT_SIZE: Vector2 = Vector2(75, 105)
const SLOT_BAR_SIZE: Vector2 = Vector2(MAX_ITEM_SLOTS_ROW*(SLOT_SIZE.x + SPACE_BETWEEN_ITEM_SLOTS)-SPACE_BETWEEN_ITEM_SLOTS, SLOT_SIZE.y)
const BODY_COLOR: Color = Color(0, 0.29, 0.86, 1)
const MODIFIER_TAB_WIDTH: float = MAX_MODIFIER_SLOTS_ROW*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_MODIFIER_SLOTS.x) + 20

var Body: Sprite2D
var Highlight: Sprite2D
var ItemSlotsContainer: HBoxContainer
var ItemSlots_Sensor: GoodButton
var ModifiersTab: Sprite2D
var ModifierSlots_Box: HFlowContainer ## CHANGE TO HFLOWCONTAINER!!
var hideModifiersTab: GoodButton
var expandModifiersTab: GoodButton

static var ItemSlots: Array[ItemContainer]
static var ModifierSlots: Array[ModifierContainer]

func _init() -> void:
	Body = Sprite2D.new()
	Body.texture = CanvasTexture.new()
	Body.region_enabled = true
	Body.self_modulate = BODY_COLOR
	Body.name = "Body"
	add_child(Body)
	
	Highlight = Sprite2D.new()
	Highlight.texture = CanvasTexture.new()
	Highlight.region_enabled = true
	Highlight.region_rect = Rect2(Vector2(0, 0), SLOT_BAR_SIZE)
	Highlight.position = Vector2(SLOT_BAR_SIZE.x/2, 0)
	Highlight.visible = false
	Highlight.self_modulate = BODY_COLOR
	Highlight.name = "Highlight"
	add_child(Highlight)
	
	var currInventorySize: float = STARTING_SLOTS*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_ITEM_SLOTS) + 4*SPACE_BETWEEN_ITEM_SLOTS
	ItemSlots_Sensor = GoodButton.new("", Color(BODY_COLOR, 0), GoodButton.ButtonType.SENSOR_ITEMBAR, Vector2(currInventorySize, SLOT_BAR_SIZE.y+5))
	ItemSlots_Sensor.IconHighlightColor = BODY_COLOR
	ItemSlots_Sensor.visible = false
	ItemSlots_Sensor.name = "ItemSlots_Sensor"
	add_child(ItemSlots_Sensor)
	
	ItemSlotsContainer = HBoxContainer.new()
	ItemSlotsContainer.alignment = BoxContainer.ALIGNMENT_END
	ItemSlotsContainer.custom_minimum_size = SLOT_BAR_SIZE
	ItemSlotsContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ItemSlotsContainer.add_theme_constant_override("separation", SPACE_BETWEEN_ITEM_SLOTS)
	ItemSlotsContainer.name = "ItemSlots"
	add_child(ItemSlotsContainer)
	
	var newItemSlot: ItemContainer
	for i in STARTING_SLOTS:
		newItemSlot = ItemContainer.new(null, ResourceContainer.ContainerType.GAMEBAR)#-----------------------------------------------------------------------------------------------------------------------------------
		newItemSlot.name = "ItemSlot" + str(i+1)
		ItemSlots.append(newItemSlot)
		ItemSlotsContainer.add_child(newItemSlot)
	
	ItemSlots_Sensor.press.connect(func() -> void:
		if(GameScene.usingItem == null):
			return
		
		await GameScene.usingItem.resource.useOnHighlight(ItemSlots_Sensor)
		add_ItemSlot())
	
	ModifiersTab = Sprite2D.new()
	ModifiersTab.texture = CanvasTexture.new()
	ModifiersTab.region_enabled = true
	ModifiersTab.self_modulate = BODY_COLOR
	ModifiersTab.z_index = -1
	ModifiersTab.name = "ModifiersTab"
	add_child(ModifiersTab)
	
	hideModifiersTab = GoodButton.new("", Color.WHITE, GoodButton.ButtonType.HIDE_MODIFIERS, Vector2(-1, -1), load("res://UI/TrabsitionArraows.png"))
	hideModifiersTab.rotation = -PI/2
	
	ModifierSlots_Box = HFlowContainer.new()
	ModifierSlots_Box.custom_minimum_size.x = MODIFIER_TAB_WIDTH - 2*SPACE_BETWEEN_MODIFIER_SLOTS.x
	ModifierSlots_Box.add_theme_constant_override("h_separation", int(SPACE_BETWEEN_MODIFIER_SLOTS.x))
	ModifierSlots_Box.add_theme_constant_override("v_separation", int(SPACE_BETWEEN_MODIFIER_SLOTS.y))
	ModifierSlots_Box.name = "ModifierSlots_Box"
	ModifiersTab.add_child(ModifierSlots_Box)
	
	hideModifiersTab.scale = Vector2(0.5, 0.5)
	hideModifiersTab.name = "hideModifiersTab"
	ModifiersTab.add_child(hideModifiersTab)
	
	expandModifiersTab = GoodButton.new("", Color.WHITE, GoodButton.ButtonType.REVEAL_MODIFIERS, Vector2(-1, -1), load("res://UI/TrabsitionArraows.png"))
	expandModifiersTab.rotation = PI/2
	expandModifiersTab.scale = Vector2(0.5, 0.5)
	expandModifiersTab.visible = false
	expandModifiersTab.name = "expandModifiersTab"
	add_child(expandModifiersTab)
	
	expandModifiersTab.press.connect(func() -> void:
		var expandTween: Tween = create_tween()
		var finalPos_Y: float = (GameBar.SLOT_SIZE.y+5)/2 + ModifiersTab.region_rect.size.y/2
		expandTween.tween_property(ModifiersTab, "position:y", finalPos_Y, 1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT))
	
	hideModifiersTab.press.connect(func() -> void:
		var hideTween: Tween = create_tween()
		var finalPos_Y: float = -ModifiersTab.region_rect.size.y/2
		hideTween.tween_property(ModifiersTab, "position:y", finalPos_Y, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT))
	
	GameScene.Game.StartOfRound.connect(ModifierCountdown)

func _ready() -> void:
	var windowSize: Vector2 = get_viewport_rect().size
	
	Body.region_rect = Rect2(0, 0, windowSize.x, SLOT_SIZE.y+5)
	
	ItemSlotsContainer.position = Vector2(windowSize.x/2 - SLOT_BAR_SIZE.x - 5, -SLOT_BAR_SIZE.y/2)
	
	var sensorPos_Y: float = ItemSlotsContainer.size.x - ItemSlots_Sensor.size.x + SPACE_BETWEEN_ITEM_SLOTS
	ItemSlots_Sensor.position = Vector2(ItemSlotsContainer.position.x+sensorPos_Y, ItemSlotsContainer.position.y - 2.5)
	
	expandModifiersTab.position = Vector2(expandModifiersTab.size.y, -expandModifiersTab.size.x)/4
	expandModifiersTab.position.y += (GameBar.SLOT_SIZE.y+5)/2 - expandModifiersTab.size.x/4

func add_item(new_item: Item) -> void:
	var end_point: int = ItemSlots.size()
	if(new_item.uses != 0):
		for i in range(end_point):
			if(ItemSlots[end_point - i - 1].resource == null):
				ItemSlots[end_point - i - 1].REgenerateResource(new_item)
				break
	
	new_item.effectOnGet()

func containerPressed(ItemSlot: ItemContainer) -> void:
	if(GameScene.usingItem != null):
		if(GameScene.usingItem == ItemSlot):
			ItemSlot.resource.endItemUse(true)
			GameScene.endItemUse()
		
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
			ItemSlot.DIS_ENable(true)
			GameScene.startItemUse(ItemSlot)

func endItemUse(item: ItemContainer) -> void:
	GameScene.endItemUse()
	item.resource.usedThisRound += 1
	if(item.resource.consumable):
		item.resource.uses -= 1
	
	item_used.emit(multiplayer.get_unique_id())
	
	if(item.resource.uses <= 0 && item.resource.consumable):
		item.REgenerateResource(null, true)
	else:
		item.DIS_ENable(true)

func usedPassiveItem(item: ItemContainer):
	if(item.resource.consumable):
		item.resource.uses -= 1
		item_used.emit(multiplayer.get_unique_id())
		if(item.resource.uses <= 0):
			item.REgenerateResource(null, true)

func ToggleHighlight(toggle: bool = false) -> void:
	ItemSlots_Sensor.visible = toggle
	if(toggle):
		#print("HERE0 - " + str())
		Body.self_modulate *= 0.5
		
		#Body.self_modulate.a = 100.0/255.0
		Body.self_modulate.a = 1
	else:
		Body.self_modulate = BODY_COLOR
	
	for item in ItemSlots:
		if(toggle):
			item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			item.mouse_filter = Control.MOUSE_FILTER_STOP
	
	for item in ItemSlots:
		item.DIS_ENable(!toggle)

func add_ItemSlot() -> void:
	var new_ItemSlot: ItemContainer = ItemContainer.new(null, ResourceContainer.ContainerType.GAMEBAR)
	ItemSlotsContainer.add_child(new_ItemSlot)
	ItemSlotsContainer.move_child(new_ItemSlot, 0)
	ItemSlots.append(new_ItemSlot)
	
	var currInventorySize: float = ItemSlots.size()*(ResourceContainer.BASE_RESOURCE_SIZE.x + SPACE_BETWEEN_ITEM_SLOTS) + 4*SPACE_BETWEEN_ITEM_SLOTS
	ItemSlots_Sensor.changeVisuals(ItemSlots_Sensor.ButtonText.text, ItemSlots_Sensor.IconOrigColor, Vector2(currInventorySize, ItemSlots_Sensor.size.y))# = GoodButton.new("", Color(BODY_COLOR, 0), GoodButton.ButtonType.SENSOR_ITEMBAR, Vector2(currInventorySize, SLOT_BAR_SIZE.y+5))
	ItemSlots_Sensor.IconHighlightColor = BODY_COLOR
	
	var sensorPos_Y: float = ItemSlotsContainer.size.x - ItemSlots_Sensor.size.x + SPACE_BETWEEN_ITEM_SLOTS
	ItemSlots_Sensor.position = Vector2(ItemSlotsContainer.position.x+sensorPos_Y, ItemSlotsContainer.position.y - 2.5)

func addModifier(newModifier: Modifier) -> void:
	expandModifiersTab.visible = true
	
	var oldRowCount: int = ceili(ModifierSlots.size()/float(MAX_MODIFIER_SLOTS_ROW))
	var newModifierContainer: ModifierContainer = ModifierContainer.new(newModifier, ResourceContainer.ContainerType.GAMEBAR)
	
	ModifierSlots_Box.add_child(newModifierContainer)
	ModifierSlots.append(newModifierContainer)
	
	var newRowCount: int = ceili(ModifierSlots.size()/float(MAX_MODIFIER_SLOTS_ROW))
	if(oldRowCount != newRowCount):
		resizeModifiersTab()
	
	newModifier.effectOnGet()

func resizeModifiersTab() -> void:
	var newRowCount: int = ceili(ModifierSlots.size()/float(MAX_MODIFIER_SLOTS_ROW))
	var ModifierTabHeigth: float = hideModifiersTab.custom_minimum_size.x/2 + newRowCount*(ResourceContainer.BASE_RESOURCE_SIZE.y + SPACE_BETWEEN_MODIFIER_SLOTS.y) + SPACE_BETWEEN_MODIFIER_SLOTS.y
	ModifiersTab.region_rect = Rect2(0, 0, MODIFIER_TAB_WIDTH, ModifierTabHeigth)
	ModifiersTab.position.y = -ModifiersTab.region_rect.size.y/2
	
	var newPredictedSize_Y: float = newRowCount*(SPACE_BETWEEN_MODIFIER_SLOTS.y + ResourceContainer.BASE_RESOURCE_SIZE.y)-SPACE_BETWEEN_MODIFIER_SLOTS.y
	ModifierSlots_Box.position = -ModifierSlots_Box.size/2
	ModifierSlots_Box.position.y = - newPredictedSize_Y/2 - SPACE_BETWEEN_MODIFIER_SLOTS.y
	
	hideModifiersTab.position = Vector2(-hideModifiersTab.custom_minimum_size.y/4, ModifiersTab.region_rect.size.y/2)

var queuedRemoval: bool = false

func removeModifier(ModifierToRemove: ModifierContainer) -> void:
	var oldRowCount: int = ceili(ModifierSlots.size()/float(MAX_MODIFIER_SLOTS_ROW))
	
	ModifierSlots.erase(ModifierToRemove)
	ModifierToRemove.queue_free()
	
	var newRowCount: int = ceili(ModifierSlots.size()/float(MAX_MODIFIER_SLOTS_ROW))
	if(oldRowCount != newRowCount):
		resizeModifiersTab()
	
	if(ModifierSlots.is_empty()):
		expandModifiersTab.visible = false

func ModifierCountdown() -> void:
	var modifiers_toRemove: Array[ModifierContainer]
	for modifier in ModifierSlots:
		modifier.resource.effectOnStartOfTurn()
		if(modifier.resource.rounds <= 0):
			modifiers_toRemove.append(modifier)
	
	for modifier in modifiers_toRemove:
		removeModifier(modifier)

func getItemSlot(item: Item) -> ItemContainer:
	for Slot in ItemSlots:
		if(Slot.resource == item):
			return Slot
	
	return null
