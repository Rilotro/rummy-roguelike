extends Sprite2D

class_name Deck

var DeckTiles: Array[Tile_Info]
var DeckLabel: Label

func _init() -> void:
	texture = CanvasTexture.new()
	region_enabled = true
	region_rect = Rect2(Vector2(0, 0), TileContainer.TILE_BASE_SIZE)#-------------------------------------------------------------
	
	DeckLabel = Label.new()
	var newLabelSettings: LabelSettings = LabelSettings.new()
	newLabelSettings.font_color = Color.BLACK
	DeckLabel.label_settings = newLabelSettings
	DeckLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	DeckLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	DeckLabel.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	DeckLabel.custom_minimum_size = TileContainer.TILE_BASE_SIZE
	DeckLabel.position = -TileContainer.TILE_BASE_SIZE/2.0
	DeckLabel.name = "DeckLabel"
	add_child(DeckLabel)
	
	for i in range(13):
		for color in Tile_Info.TileColors:
			DeckTiles.append(Tile_Info.new(i+1, color))
	
	DeckTiles.shuffle()
	
	DeckLabel.text = StringsManager.UIStrings["DECK"]["DECK_SIZE"] + str(DeckTiles.size())

func popTile(fromBack: bool = true, position: int = -1) -> Tile_Info:
	DeckLabel.text = StringsManager.UIStrings["DECK"]["DECK_SIZE"] + str(DeckTiles.size()-1)
	if(position >= 0 && position < DeckTiles.size()-1):
		return DeckTiles.pop_at(position)
	elif(fromBack):
		return DeckTiles.pop_back()
	else:
		return DeckTiles.pop_front()
