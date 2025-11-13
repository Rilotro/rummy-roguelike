extends Node2D

@onready var Tile_Selection_Base: PackedScene = preload("res://TileSelection.tscn")
var is_starting: bool = false
var separation: float = -50

var selectFlags: Dictionary = {"BoardAdd": false, "Position": -1, "Replacement": null}

func start_select(selection_nr: int, flags: Dictionary = {"BoardAdd": false, "Position": -1, "Replacement": null}) -> void:
	selectFlags = flags
	var final_sep: float = ($HBoxContainer.size.x - 50*selection_nr)/(selection_nr+1)
	for i in range(selection_nr):
		var new_selection: Tile_Selection = Tile_Selection_Base.instantiate()
		new_selection.no_cost()
		var setTile: Tile_Info = null
		if(flags["Replacement"] != null):
			var number: int = 0
			var color: int = 0
			if(flags["Replacement"].getTileData().joker_id < 0):
				number = randi_range(1, 13)
				if(!flags["Replacement"].getTileData().effects["rainbow"]):
					color = randi_range(1, 4)
				else:
					color = -1
			#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			setTile = Tile_Info.new(number, color, flags["Replacement"].getTileData().joker_id, flags["Replacement"].getTileData().rarity, null, flags["Replacement"].getTileData().effects)
		new_selection.parentEffector = self
		new_selection.REgenerate_selection(setTile)
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
	#, "Replacement": Replacement
	if(selectFlags["BoardAdd"]):
		var newTile: Tile = preload("res://Tile.tscn").instantiate()
		newTile.change_info(selection_info)
		get_parent().PB.add_BoardTile(newTile)
		get_parent().PB.updateTilePos(0.1)
	elif(selectFlags["Replacement"] != null):
		#get_parent().PB
		selectFlags["Replacement"].change_info(selection_info)
	else:
		get_parent().PB.add_tile_to_deck(selection_info, selectFlags["Position"])
	
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
