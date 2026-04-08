extends Node2D

class_name SelectScreen

#@onready var Tile_Selection_Base: PackedScene = preload("res://TileSelection.tscn")
var is_starting: bool = false
var separation: float = -50
var extendedSeparation: float = -50
var rowSeparation: float = -50
var extendedSep_startingIndex: int = 0

var currentFlags: Dictionary
var currentOption: SelectOption
var DeckAdd_position: int = -1

static var Selections: Array[ResourceContainer]
static var finalSelections: Array[ResourceContainer]
var minMAXOptions: Vector2i#X is the minimum ammount of choices, default should be 1
						   #Y is the MAXimum ammount of choices, default is -1, meaning any ammount of choices

signal selectionEnded

var separationTween: Tween
var selection_nr: int

var DestroySelfInstantly_AfterSelectionEnd: bool = true

const MAX_ROW_SIZE: int = 5
const CONTAINER_SIZE_X: float = 115

enum SelectOption{
	TILE, WISHES, ITEM
}

@export var TileSelect_BG: Sprite2D
@export var Obfuscator: Control
@export var RowContainer: VBoxContainer
@export var SelectionContainers: Array[HBoxContainer]
@export var Proceed: Button

func _init(option: SelectOption, selectionOptions: Vector3i, select_flags: Dictionary) -> void:
	selection_nr = selectionOptions.x
	minMAXOptions = Vector2(selectionOptions.y, selectionOptions.z)
	
	Selections.clear()
	finalSelections.clear()
	currentFlags = select_flags
	currentOption = option
	
	TileSelect_BG = Sprite2D.new()
	TileSelect_BG.texture = CanvasTexture.new()
	TileSelect_BG.region_enabled = true
	TileSelect_BG.region_rect = Rect2(0, 0, 1152, 648)
	TileSelect_BG.self_modulate = Color(0, 0, 0, 0.39)
	TileSelect_BG.name = "TileSelect_Background"
	add_child(TileSelect_BG)
	
	Obfuscator = Control.new()
	Obfuscator.custom_minimum_size = Vector2(1152, 648)
	Obfuscator.size = Vector2(1152, 648)
	Obfuscator.position = Vector2(-576, -324)
	Obfuscator.name = "Obfuscator"
	add_child(Obfuscator)
	
	RowContainer = VBoxContainer.new()
	RowContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	RowContainer.custom_minimum_size = Vector2(1152, 648)
	RowContainer.set_anchors_preset(Control.PRESET_CENTER)
	RowContainer.size = Vector2(1152, 648)
	RowContainer.position = Vector2(-576, -324)
	RowContainer.add_theme_constant_override("separation", -50)
	RowContainer.name = "RowContainer"
	add_child(RowContainer)
	
	var rowNumber: int = 1
	var SelectionContainer: HBoxContainer
	rowNumber = ceili(selection_nr/5.0)
	
	for i in rowNumber:
		SelectionContainer = HBoxContainer.new()
		SelectionContainer.alignment = BoxContainer.ALIGNMENT_CENTER
		SelectionContainer.custom_minimum_size = Vector2(1152, 0)
		SelectionContainer.name = "SelectionContainer" + str(i+1)
		SelectionContainers.append(SelectionContainer)
		RowContainer.add_child(SelectionContainer)
	
	Proceed = Button.new()
	Proceed.text = "Proceed"
	Proceed.position = Vector2(450, -21)
	Proceed.add_theme_font_size_override("font_size", 24)
	Proceed.visible = false
	Proceed.pressed.connect(end_select)
	Proceed.name = "Proceed"
	add_child(Proceed)

func _ready() -> void:
	var rowNumber: int = RowContainer.get_children().size()
	var colNumber: int = floori(selection_nr/float(rowNumber))
	var leftover: int = selection_nr - colNumber*rowNumber
	extendedSep_startingIndex = rowNumber - leftover
	
	var RowSelectionsizes: Array[int]
	RowSelectionsizes.resize(rowNumber)
	RowSelectionsizes.fill(colNumber)
	
	for i in leftover:
		RowSelectionsizes[RowSelectionsizes.size()-1-i] += 1
	
	match currentOption:
		SelectOption.TILE:
			#assert(currentFlags.has("DeckPosition") && type_string(typeof(currentFlags.DeckPosition)) == "int")
			assert(currentFlags.has("EffectsChance") && type_string(typeof(currentFlags.EffectsChance)) == "int")
			
			var new_selection: TileContainer
			var nameIndex: int = 0
			for i in range(rowNumber):
				for j in range(RowSelectionsizes[i]):
					new_selection = TileContainer.new(null, ResourceContainer.ContainerType.SELECTION, currentFlags.EffectsChance)
					new_selection.name = "Tile_Selection" + str(nameIndex*i + j)
					SelectionContainers[i].add_child(new_selection)
					Selections.append(new_selection)
				
				nameIndex += RowSelectionsizes[i]
		
		SelectOption.ITEM:
			assert(currentFlags.has("ConsumablesOnly") && type_string(typeof(currentFlags.ConsumablesOnly)) == "bool")

			var new_selection: ItemContainer
			var nameIndex: int = 0
			for i in range(rowNumber):
				for j in range(RowSelectionsizes[i]):#-------------------------------------------------------------------------------------------------------------------
					new_selection = ItemContainer.new(Item.getRandomItem(get_parent(), false, currentFlags.ConsumablesOnly), ResourceContainer.ContainerType.SELECTION)
					new_selection.name = "Item_Selection" + str(nameIndex*i + j)
					SelectionContainers[i].add_child(new_selection)
					Selections.append(new_selection)
				
				nameIndex += RowSelectionsizes[i]
	
	var final_sep: float = (RowContainer.size.x - 85*colNumber)/(colNumber+1)
	var extended_final_sep: float = (RowContainer.size.x - 85*(colNumber+1))/(colNumber+2)
	var final_row_sep: float = CONTAINER_SIZE_X*1.5
	
	separationTween = create_tween()
	is_starting = true
	separationTween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25)
	separationTween.parallel().tween_property(self, "separation", final_sep, 0.25)
	separationTween.parallel().tween_property(self, "extendedSeparation", extended_final_sep, 0.25)
	separationTween.parallel().tween_property(self, "rowSeparation", final_row_sep, 0.25)

func _process(_delta: float) -> void:
	if(separationTween == null || !separationTween.is_running()):
		is_starting = false
	
	if(is_starting):
		RowContainer.add_theme_constant_override("separation", floori(rowSeparation))
		for i in range(SelectionContainers.size()):
			if(i >= extendedSep_startingIndex):
				SelectionContainers[i].add_theme_constant_override("separation", floori(extendedSeparation))
			else:
				SelectionContainers[i].add_theme_constant_override("separation", floori(separation))
	
	if(Input.is_action_just_pressed("Debug_Draw") && currentOption == SelectOption.TILE):
		for SC in SelectionContainers:
			for TS in SC.get_children():
				TS.REgenerateResource(null)

func containerPressed(selection: ResourceContainer) -> void:
	if(finalSelections.has(selection)):
		finalSelections.erase(selection)
		
		if(finalSelections.size() < minMAXOptions.x):
			Proceed.visible = false
	else:
		if(finalSelections.size() >= minMAXOptions.y):
			return
		
		finalSelections.append(selection)
		
		if(finalSelections.size() == minMAXOptions.x):
			if(minMAXOptions.x == minMAXOptions.y && minMAXOptions.x == 1):
				end_select()
			else:
				Proceed.visible = true
	

func end_select() -> void:
	selectionEnded.emit()
	
	if(DestroySelfInstantly_AfterSelectionEnd):
		queue_free()

static func getSelectionString(selectionOptions: Vector3i = Vector3i(1, 1, 3)) -> String:
	var selectionString: String = StringsManager.UIStrings["SELECT"][0]
	
	if(selectionOptions.x == selectionOptions.y):
		selectionString += str(selectionOptions.x)
	else:
		if(selectionOptions.x > 1):
			selectionString += StringsManager.UIStrings["SELECT"][2] + str(selectionOptions.x)
		
		if(selectionOptions.y > 1):
			if(selectionOptions.x > 1):
				selectionString += ", "
			
			selectionString += StringsManager.UIStrings["SELECT"][3] + str(selectionOptions.y)
		
	
	selectionString += StringsManager.UIStrings["SELECT"][1] + str(selectionOptions.z)
	
	return selectionString
