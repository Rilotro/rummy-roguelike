extends Node2D

class_name SparkleContainer

@export var size: Vector2 = Vector2(5, 5)
#var Sparkle: PackedScene = preload("res://scenes/Sparkle.tscn")
var LowerBound_density: int = 1
var UpperBound_density: int = 10
var rect_offset: Vector2 = Vector2(0, 0)
var checkPolarity_atReady: bool = true

var isTopLevel: bool = false
var hole: Hole = null

enum Shape{
	RECTANGLE, ELIPSE
}

func _init(newSize: Vector2, density: Vector2i = Vector2i(1, 10), h: Hole = null, topLevel: bool = false) -> void:
	if(h != null):
		assert(newSize.x >= h.size.x || newSize.y >= h.size.y, "sizes: " + str(newSize) + " - " + str(h.size))
	
	size = newSize
	LowerBound_density = density.x
	UpperBound_density = density.y
	hole = h
	isTopLevel = topLevel

func _process(_delta: float) -> void:
	if(!checkForAvailableArea()):
		return
	
	var Sparkle_count: int = randi_range(LowerBound_density, UpperBound_density)
	if(Sparkle_count > 0):
		var new_Sparkle: Sparkle
		var lowerBound: Vector2 = (Sparkle.SPARKLE_SIZE - size)/2
		var upperBound: Vector2 = (size - Sparkle.SPARKLE_SIZE)/2
		for i in Sparkle_count:
			var sparklePos: Vector2 = Vector2(randf_range(lowerBound.x, upperBound.x), randf_range(lowerBound.y, upperBound.y))
			
			if(hole != null):
				match hole.shape:
					Shape.RECTANGLE:
						var XBounds: Vector2 = hole.get_XBounds()
						var YBounds: Vector2 = hole.get_YBounds()
						
						
						while((sparklePos.x > XBounds.x && sparklePos.x < XBounds.y) && (sparklePos.y > YBounds.x && sparklePos.y < YBounds.y)):
							sparklePos = Vector2(randf_range(lowerBound.x, upperBound.x), randf_range(lowerBound.y, upperBound.y))
			
			new_Sparkle = Sparkle.new()
			new_Sparkle.z_index = z_index
			add_child(new_Sparkle)
			new_Sparkle.top_level = isTopLevel
			if(isTopLevel):
				new_Sparkle.position = global_position + sparklePos
			else:
				new_Sparkle.position = sparklePos

func checkForAvailableArea() -> bool:
	if(hole == null):
		return true
	
	#var notablePoints: Array[Vector2]
	
	#notablePoints.append(-size/2)
	#notablePoints.append(Vector2(size.x, -size.y)/2)
	#notablePoints.append(size/2)
	#notablePoints.append(Vector2(-size.x, size.y)/2)points
	
	var outOfBounds_count: int = 0
	for point in hole.points:
		if(abs(point.x) >= size.x/2 && abs(point.y) >= size.y/2):
			outOfBounds_count += 1
	
	if(outOfBounds_count >= 4):
		return false
	
	return true

class Hole:
	var size: Vector2
	var position: Vector2
	var shape: Shape
	var points: Array[Vector2]
	
	func _init(s: Vector2, p: Vector2, sh: Shape):
		size = s
		position = p
		shape = sh
		
		points.append(position - size/2)
		points.append(position + Vector2(size.x, -size.y)/2)
		points.append(position + size/2)
		points.append(position + Vector2(-size.x, size.y)/2)
	
	func get_XBounds() -> Vector2:
		var bounds: Vector2
		
		bounds.x = position.x - size.x/2
		bounds.y = position.x + size.x/2
		
		return bounds
	
	func get_YBounds() -> Vector2:
		var bounds: Vector2
		
		bounds.x = position.y - size.y/2
		bounds.y = position.y + size.y/2
		
		return bounds
