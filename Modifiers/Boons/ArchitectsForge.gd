extends Modifier

class_name ArchitectsForge

const CHOSEN_ITEM_USES_ADD: int = 2
const OTHER_ITEMS_USES_ADD: int = 1
#const BASE_SELECTION_OPTIONS: Vector3i = Vector3i(1, 1, 3)

func _init() -> void:
	rounds = 3
	type = Type.BOON
	
	image = load("res://Modifiers/Sprites/ArchitectsForge.png")
	
	super()

func getIDName() -> String:
	return "Architect's Forge"

func getDescription() -> String:#String
	var descriptionStrings: Array = StringsManager.ModifierStrings[getIDName()]["DESCRIPTION"]
	var fullDescription: String = descriptionStrings[0]
	
	fullDescription += SelectScreen.getSelectionString()
	
	fullDescription += descriptionStrings[1]
	
	fullDescription += descriptionStrings[2]
	
	fullDescription += str(CHOSEN_ITEM_USES_ADD) + descriptionStrings[4]
	if(CHOSEN_ITEM_USES_ADD == 1):
		fullDescription += descriptionStrings[5]
	else:
		fullDescription += descriptionStrings[6]
	
	fullDescription += descriptionStrings[7] + str(OTHER_ITEMS_USES_ADD) + descriptionStrings[4]
	
	if(OTHER_ITEMS_USES_ADD == 1):
		fullDescription += descriptionStrings[5]
	else:
		fullDescription += descriptionStrings[6]
	
	return fullDescription

var ItemSlots: Array[ItemContainer]

func effectOnGet() -> void:#--------------------------------------------------------------------------------------------
	GameScene.Game.createSelectionScreen(SelectScreen.SelectOption.ITEM, Vector3i(3, 1, 1), {"ConsumablesOnly": true})
	
	#while(SelectScreen.finalSelections.is_empty()):
		#await Game.get_tree().create_timer(0.001).timeout
	
	await GameScene.currSelectScreen.selectionEnded
	
	for Slot in SelectScreen.finalSelections:
		GameScene.PlayerBar.add_item(Slot.resource)
		ItemSlots.append(GameScene.PlayerBar.getItemSlot(Slot.resource))
	#ItemSlot = Game.ItemBar.getItemSlot()

func effectOnStartOfTurn() -> void:
	for Slot in ItemSlots:
		if(Slot.isEmpty):
			for otherSlot in GameScene.PlayerBar.ItemSlots:
				if(!otherSlot.isEmpty):
					otherSlot.resource.uses += OTHER_ITEMS_USES_ADD
		else:
			Slot.resource.uses += CHOSEN_ITEM_USES_ADD
	
	super()
