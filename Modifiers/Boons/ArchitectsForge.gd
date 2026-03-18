extends Modifier

class_name ArchitectsForge

const CHOSEN_ITEM_USES_ADD: int = 2
const OTHER_ITEMS_USES_ADD: int = 1

func _init(newGame: GameScene) -> void:
	rounds = 3
	type = Type.BOON
	
	image = load("res://Modifiers/Sprites/ArchitectsForge.png")
	
	super(newGame)

var ItemSlots: Array[ItemContainer]

func effectOnGet() -> void:#--------------------------------------------------------------------------------------------
	Game.select_tiles(SelectScreen.SelectOption.GAIN_ITEM, Vector3i(3, 1, 1), {"ConsumablesOnly": true})
	
	while(SelectScreen.finalSelections.is_empty()):
		await Game.get_tree().create_timer(0.001).timeout
	
	for Slot in SelectScreen.finalSelections:
		ItemSlots.append(Game.ItemBar.getItemSlot(Slot.item_info))
	#ItemSlot = Game.ItemBar.getItemSlot()

func effectOnStartOfTurn() -> void:
	for Slot in ItemSlots:
		if(Slot.item_info != null):
			Slot.item_info.uses += CHOSEN_ITEM_USES_ADD
		else:
			Game.ItemBar.addItemBarUses()
	
	super()
