extends Node2D

@export var size: Vector2 = Vector2(5, 5)
var Sparkle: PackedScene = preload("res://scenes/Sparkle.tscn")
var HB_density: int = 1
var LB_density: int = 10
var rect_offset: Vector2 = Vector2(0, 0)
var checkPolarity_atReady: bool = true

var is_TopLevel: bool = false

#func _ready() -> void:
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "global_position", Vector2(500, 500), 5)

func change_road(end_pos: Vector2, end_size: Vector2, duration: float, tween = get_tree().create_tween(), tween_trans = Tween.TRANS_LINEAR, tween_ease = Tween.EASE_IN_OUT) -> void:
	if(duration == 0):
		global_position = end_pos
		size = end_size
	else:
		tween.tween_property(self, "size", end_size, duration).set_trans(tween_trans).set_ease(tween_ease)
		tween.parallel().tween_property(self, "global_position", end_pos, duration).set_trans(tween_trans).set_ease(tween_ease)

func _process(delta: float) -> void:
	var Sparkle_count: int = randi_range(LB_density, HB_density)
	if(Sparkle_count > 0):
		var new_Sparkle: Sprite2D
		var lowerBound: Vector2 = -size/2 + Vector2(5, 5)/2
		var upperBound: Vector2 = size/2 - Vector2(5, 5)/2
		for i in Sparkle_count:
			var loc_pos: Vector2 = Vector2(randf_range(lowerBound.x, upperBound.x), randf_range(lowerBound.y, upperBound.y))
			if(upperBound.x > rect_offset.x && upperBound.y > rect_offset.y):
				while(abs(loc_pos.x) <= rect_offset.x && abs(loc_pos.y) <= rect_offset.y):
					loc_pos = Vector2(randf_range(lowerBound.x, upperBound.x), randf_range(lowerBound.y, upperBound.y))
			
			new_Sparkle = Sparkle.instantiate()
			add_child(new_Sparkle)
			new_Sparkle.top_level = is_TopLevel
			if(checkPolarity_atReady):
				checkPolarity_atReady = false
				if(!new_Sparkle.material.get_shader_parameter("is_positive")):
					new_Sparkle.material.set_shader_parameter("is_positive", true)
			
			if(queue_change):
				new_Sparkle.material.set_shader_parameter("is_positive", polarity)
				queue_change = false
			#move_child(new_Sparkle, 0)
			new_Sparkle.global_position = global_position + loc_pos

var polarity: bool = true
var queue_change: bool = false

func change_polarity(new_polarity: bool):
	if(polarity != new_polarity):
		polarity = new_polarity
		if(get_child_count() > 0):
			get_child(0).material.set_shader_parameter("is_positive", new_polarity)
		else:
			queue_change = true
