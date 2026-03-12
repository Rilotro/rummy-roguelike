extends Node2D

class_name SelectScreen

@onready var Tile_Selection_Base: PackedScene = preload("res://TileSelection.tscn")
var is_starting: bool = false
var separation: float = -50

var currentFlags: Dictionary
var currentOption: SelectOption
var DeckAdd_position: int = -1

enum SelectOption{
	DECK_ADD_TILE, WISHES
}

#var selectFlags: Dictionary = {"BoardAdd": false, "Position": -1, "Replacement": null}

func start_select(option: SelectOption, selection_nr: int, select_flags: Dictionary) -> void:
	currentOption = option
	currentFlags = select_flags
	var final_sep: float = ($HBoxContainer.size.x - 50*selection_nr)/(selection_nr+1)
	
	match option:
		SelectOption.DECK_ADD_TILE:
			#currentFlags.#-------------------------------------------------------------------------------------------------
			assert(currentFlags.has("DeckPosition") && type_string(typeof(currentFlags.DeckPosition)) == "int")
			assert(currentFlags.has("CanHaveEffects") && type_string(typeof(currentFlags.CanHaveEffects)) == "bool")
			
			var new_selection: Tile_Selection
			for i in range(selection_nr):
				new_selection = Tile_Selection_Base.instantiate()
				new_selection.no_cost()
				new_selection.joker_tile = false
				new_selection.parentEffector = self
				new_selection.REgenerate_selection()
				$HBoxContainer.add_child(new_selection)
	
	visible = true
	var tween = get_tree().create_tween()
	is_starting = true
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25)
	tween.parallel().tween_property(self, "separation", final_sep, 0.25)
	await tween.finished
	is_starting = false

func _process(_delta: float) -> void:
	if(is_starting):
		$HBoxContainer.add_theme_constant_override("separation", separation)
	
	if(Input.is_action_just_pressed("Debug_Draw")):
		for TS in $HBoxContainer.get_children():
			TS.REgenerate_selection()

func tile_select(_selection: Tile_Selection, selection_info: Tile_Info, _c: int):
	match currentOption:
		SelectOption.DECK_ADD_TILE:
			get_parent().PB.add_tile_to_deck(selection_info)
	
	#if(selectFlags["BoardAdd"]):
		#var newTile: Tile = preload("res://Tile.tscn").instantiate()
		#newTile.change_info(selection_info)
		#get_parent().PB.add_BoardTile(newTile)
		#get_parent().PB.updateTilePos(0.1)
	#elif(selectFlags["Replacement"] != null):
		##get_parent().PB
		#selectFlags["Replacement"].change_info(selection_info)
	#else:
		#get_parent().PB.add_tile_to_deck(selection_info, selectFlags["Position"])
	
	for button in $HBoxContainer.get_children():
		button.disabled = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.25)
	await tween.finished
	visible = false
	$HBoxContainer.add_theme_constant_override("separation", -50)
	separation = -50
	
	for button in $HBoxContainer.get_children():
		button.queue_free()
