extends Resource

class_name Item #Paint size: 130x200

var id: int
var item_image: Texture
var uses: int
var passive: bool
var instant: bool
var consumable: bool
var name: String
var description: String#written for BBCode text
var usedThisRound: int = 0
static var flags = {"Wrench": 0, "Midas Touch": 0, "Burning Shoes": 0}
static var singularItems: Array[int]

static var is_HammerTime: bool = false

func _init(new_id: int = 0) -> void:
	id = new_id
	match new_id:
		0:
			item_image = load("res://Items/Untitled.png")
			uses = 3
			passive = false
			instant = false
			consumable = true
			name = "Bag of Tiles"
			description = "[b]Choose one of three Tiles[/b] to add in the [i]Top 5 Positions[/i] of your [b]Deck[/b][br][font_size=10][color=gray]Can only be [b]Used [i]Once[/i][/b] per [b]Round[/b][/color][/font_size]"
		1:
			item_image = load("res://Items/Slot_Hammer.png")
			uses = 2
			passive = false
			instant = false
			consumable = true
			name = "Architect's Hammer"
			description = "Add one [b]Slot[/b] in the [b]Shop[/b] or in the [b]Item Bar[/b]. [color=Gray](You can only have up to 10 item slots)[/color]"
		2: 
			item_image = load("res://Items/Workshop_Wrench.png")
			uses = -1
			passive = true
			instant = true
			consumable = false
			name = "Workshop Wrench"
			description = "All [b]Consumable Items[/b] have an extra [b]Use[/b]"
		3:
			item_image = load("res://Items/Midas_Touch.png")
			uses = 2
			passive = true
			instant = false
			consumable = true
			name = "Touch of Midas"
			description = "[b]Rarify[/b] the next [b]non-Gold Tile[/b] you [b]Draw[/b] up to [b]Gold[/b]"
		4:
			item_image = load("res://Items/Beaver_Teeth.png")
			uses = -1
			passive = true
			instant = true
			consumable = false
			name = "Beaver Teeth"
			description = "[b]Draining the River[/b] requires [b]40%[/b] less [b]Tiles[/b] to [b]Discard[/b]"
		5:
			item_image = load("res://Items/Burning_Shoes.png")
			uses = -1
			passive = true
			instant = false
			consumable = false
			name = "Burning Shoes"
			description = "Whenever you [b]Draw Tiles[/b], [b]Draw[/b] [i]an additional[/i] [b]Tile[/b]"
		6:
			item_image = load("res://Items/Monkey's Paw.png")
			uses = 3
			passive = false
			instant = false
			consumable = true#"On Use - [font_size=12]Select a [b]Tile[/b] from your [b]Board[/b] that has [b]Bronze-or-Higher Rarity[/b] to [b]De-Rarify[/b], then [b]Choose one of three Tiles[/b] with the [i]same [b]Rarity[/b] and [b]Effects[/b][/i] to [b]Replace[/b] the [b]Selected Tile[/b] with[/font_size].[br][font_size=12][color=gray]Can only be [b]Used[/b] 3 times per [b]Round[/b][/color][/font_size]"
			name = "Monkey's Paw"#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			description = "On Use - Select a [b]Tile[/b] to [b]de-Rarify[/b], then [b]Choose one of three Tiles[/b], with [i]the same [b]Rarity[/b] and [b]Effects[/b][/i] as the [b]Selected Tile[/b], to [b]Replace the Selected Tile[/b].[br][font_size=10][color=gray]Can only be [b]Used[/b] 3 times per [b]Round[/b][/color][/font_size]"
	if(uses > 0):
		uses += flags["Wrench"]

func useItem(Game: Node2D) -> bool:
	if(!Game.getTurn() && !instant):
		return false
	match id:
		0:
			if(usedThisRound == 0):
				var DeckIndex: int = 0
				var DeckSize: int = Game.PB.Tile_Deck.size()
				if(DeckSize >= 5):
					DeckIndex = randi_range(0, 4)
				elif(DeckSize > 0):
					DeckIndex = randi_range(0,DeckSize-1)
				
				Game.select_tiles(3, DeckIndex)
				uses -= 1
			else:
				return false
		1:
			#for i in range(uses):
				#Game.add_ItemSlot()
			is_HammerTime = !is_HammerTime
			Game.HammerTime(is_HammerTime)
		2:
			Game.addShopUses()
		3:
			pass
		4:
			Game.PB.Beaver()
		6:
			if(Game.PB.discarding):
				return false
			
			if(usedThisRound < 3):
				Tile.MonkeyPaw = !Tile.MonkeyPaw
				Game.PB.show_possible_selections(Tile.MonkeyPaw)
				if(!Tile.MonkeyPaw):
					return false
				else:
					usedThisRound -= 1
			else:
				return false
	
	usedThisRound += 1
	return true

func resetUTR() -> void:
	usedThisRound = 0
