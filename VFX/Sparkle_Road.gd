extends Node2D

class_name SparkleContainer

@export var size: Vector2 = Vector2(5, 5)
#var Sparkle: PackedScene = preload("res://scenes/Sparkle.tscn")
var LowerBound_density: int = 1
var UpperBound_density: int = 10
var rect_offset: Vector2 = Vector2(0, 0)
var checkPolarity_atReady: bool = true

var isTopLevel: bool = false
var HoleSize: Vector2
var Shape: HoleShape

enum HoleShape{
	NULL, ELIPSE, RECTANGLE
}

func _init(newSize: Vector2, density: Vector2i = Vector2i(1, 10), holeShape: HoleShape = HoleShape.NULL, holeSize: Vector2 = Vector2(0, 0), topLevel: bool = false) -> void:
	assert(newSize.x >= holeSize.x || newSize.y >= holeSize.y, "sizes: " + str(newSize) + " - " + str(holeSize))
	
	size = newSize
	LowerBound_density = density.x
	UpperBound_density = density.y
	Shape = holeShape
	HoleSize = holeSize
	isTopLevel = topLevel

func _process(delta: float) -> void:
	var Sparkle_count: int = randi_range(LowerBound_density, UpperBound_density)
	if(Sparkle_count > 0):
		var new_Sparkle: Sparkle
		var lowerBound: Vector2 = (Sparkle.SPARKLE_SIZE - size)/2
		var upperBound: Vector2 = (size - Sparkle.SPARKLE_SIZE)/2
		for i in Sparkle_count:
			var sparklePos: Vector2 = Vector2(randf_range(lowerBound.x, upperBound.x), randf_range(lowerBound.y, upperBound.y))
			
			match Shape:
				HoleShape.RECTANGLE:
					while((sparklePos.x > -HoleSize.x/2 && sparklePos.x < HoleSize.x/2) && (sparklePos.y > -HoleSize.y/2 && sparklePos.y < HoleSize.y/2)):
						sparklePos = Vector2(randf_range(lowerBound.x, upperBound.x), randf_range(lowerBound.y, upperBound.y))
			
			new_Sparkle = Sparkle.new()
			add_child(new_Sparkle)
			new_Sparkle.top_level = isTopLevel
			if(isTopLevel):
				new_Sparkle.position = global_position + sparklePos
			else:
				new_Sparkle.position = sparklePos
