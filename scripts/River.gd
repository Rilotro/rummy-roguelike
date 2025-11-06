extends Node2D

var Discard_River: Array[Tile]
var DT_multiplier: int = 5
var times_drained: int = 0
var tiles_discarded: int = 0

func isDrainEligible() -> bool:
	return tiles_discarded >= DT_multiplier*(1+times_drained)

func updateTilePos(duration: float = 0.3) -> void:
	var curr_pos: Vector2
	for k in range(Discard_River.size()):
		var river_row: int = snapped(k/10, 1)
		curr_pos = Vector2(400 + 30*(k - 10*river_row), 324 + 40*river_row)
		if(Discard_River[k].global_position != curr_pos && !Discard_River[k].is_being_moved):
			Discard_River[k].moveTile(curr_pos)
			await get_tree().create_timer(duration).timeout

func Drain_River(Drain_Start: int, OPD: bool = false) -> void:
	if(Drain_Start >= 0):
		var drain_threshold: int = DT_multiplier*(1+times_drained)
		tiles_discarded -= drain_threshold
		times_drained += 1
		drain_threshold += DT_multiplier
		
		if(!OPD):
			for i in range(Drain_Start, Discard_River.size()):
				get_parent().add_BoardTile(Discard_River[i])
		
		var new_River: Array[Tile]
		for i in range(Drain_Start):
			new_River.append(Discard_River[i])
		
		if(OPD):
			for i in range(Drain_Start, Discard_River.size()):
				await Discard_River[i].moveTile(Vector2(50, 320), 0.3)
				Discard_River[i].queue_free()
		
		Discard_River = new_River

func peer_Drained() -> void:
	var drain_threshold: int = DT_multiplier*(1+times_drained)
	tiles_discarded -= drain_threshold
	times_drained += 1
	drain_threshold += DT_multiplier

func get_current_DrainThreshold() -> int:
	return DT_multiplier*(1+times_drained)

func add_RiverTile(tile: Tile, discarded: bool = true) -> void:
	Discard_River.append(tile)
	tile.reparent(self)
	tile.REparent(get_parent(), self)
	if(discarded):
		tiles_discarded += 1

func get_RiverTile_index(tile: Tile) -> int:
	return Discard_River.find(tile)

func remove_RiverTile(tile: Tile) -> void:
	Discard_River.erase(tile)
