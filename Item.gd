extends Resource

class_name Item

var id: int
var item_image: Texture
var uses: int
var passive: bool
var instant: bool
var name: String
var description: String#written for BBCode text
static var flags = {"Wrench": 0, "Midas Touch": 0, "Beaver Teeth": false}

func _init(new_id: int = 0) -> void:
	id = new_id
	match new_id:
		0:
			item_image = load("res://Items/Untitled.png")
			uses = 3
			passive = false
			instant = false
			name = "Bag of Tiles"
			description = "Choose one of three [b]Tiles[/b] to add to your [b]Deck[/b]"
		1:
			item_image = load("res://Items/Slot_Hammer.png")
			uses = 1
			passive = false
			instant = true
			name = "Slot Hammer"
			description = "Add one [b]Item Slot[/b]. [color=Gray](You can only have up to 10 item slots)[/color]"
		2: 
			item_image = load("res://Items/Workshop_Wrench.png")
			uses = -1
			passive = true
			instant = false
			name = "Workshop Wrench"
			description = "All [b]Consumable Items[/b] have an extra [b]Use[/b]"
		3:
			item_image = load("res://Items/Midas_Touch.png")
			uses = 2
			passive = true
			instant = false
			name = "Touch of Midas"
			description = "[b]Rarify[/b] the next [b]non-Gold Tile[/b] you [b]Draw[/b] up to [b]Gold[/b]"
		4:
			item_image = load("res://Items/Beaver_Teeth.png")
			uses = -1
			passive = true
			instant = true
			name = "Beaver Teeth"
			description = "[b]Draining the River[/b] requires [b]40%[/b] less [b]Tiles[/b] to [b]Discard[/b]"
	if(uses > 0):
		uses += flags["Wrench"]

func useItem(Game: Node2D) -> bool:
	if(!Game.my_turn && !instant):
		return false
	match id:
		0:
			Game.select_tiles(3)
		1:
			Game.add_ItemSlot()
		3:
			pass
		4:
			pass
	return true
