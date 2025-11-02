extends Node2D

@export var size: Vector2 = Vector2(5, 5)
var Sparkle: PackedScene = preload("res://scenes/Sparkle.tscn")
var HB_density: int = 1
var LB_density: int = 10

func change_road(end_pos: Vector2, end_size: Vector2, duration: float, tween = get_tree().create_tween(), tween_trans = Tween.TRANS_LINEAR, tween_ease = Tween.EASE_IN_OUT, start_pos = global_position, start_size = size) -> void:
	global_position = start_pos
	size = start_size
	tween.tween_property(self, "size", end_size, duration).set_trans(tween_trans).set_ease(tween_ease)
	tween.parallel().tween_property(self, "global_position", end_pos, duration).set_trans(tween_trans).set_ease(tween_ease)

func _process(delta: float) -> void:
	var Sparkle_count: int = randi_range(LB_density, HB_density)
	if(Sparkle_count > 0):
		var new_Sparkle: Sprite2D
		var lowerBound: Vector2 = -size/2 + Vector2(5, 5)/2
		var upperBound: Vector2 = size/2 - Vector2(5, 5)/2
		for i in Sparkle_count:
			new_Sparkle = Sparkle.instantiate()
			add_child(new_Sparkle)
			new_Sparkle.global_position = global_position + Vector2(randf_range(lowerBound.x, upperBound.x), randf_range(lowerBound.y, upperBound.y))
