extends Node2D

@onready var Tile_Selection_Base: PackedScene = preload("res://TileSelection.tscn")
var is_starting: bool = false
var separation: float = -50

var add_toBoard: bool = false

func start_select(selection_nr: int, atB: bool = false) -> void:
	add_toBoard = atB
	var final_sep: float = ($HBoxContainer.size.x - 50*selection_nr)/(selection_nr+1)
	for i in range(selection_nr):
		var new_selection: Tile_Selection = Tile_Selection_Base.instantiate()
		new_selection.no_cost()
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
	if(!add_toBoard):
		get_parent().PB.add_tile_to_deck(selection_info)
	else:
		var newTile: Tile = preload("res://Tile.tscn").instantiate()
		newTile.change_info(selection_info)
		get_parent().PB.add_BoardTile(newTile)
		get_parent().PB.updateTilePos(0.1)
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
