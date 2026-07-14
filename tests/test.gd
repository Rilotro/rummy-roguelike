extends Node2D

const DURATION: float = 1
const RADIUS: float = 200
const STEP: float = PI/2
var center: Vector2

func _ready() -> void:
	var windowSize: Vector2 = get_viewport_rect().size
	center = windowSize/2
	$Sprite2D.position = windowSize/2 + Vector2(0, RADIUS)
	
	rotateCube()

func rotateCube() -> void:
	#var newRot: float = $Sprite2D.rotation-STEP
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_method(func(newRot: float) -> void:
		$Sprite2D.rotation = newRot
		$Sprite2D.position = center + Vector2(RADIUS*sin(-newRot), RADIUS*cos(-newRot))
		, $Sprite2D.rotation, $Sprite2D.rotation-STEP, DURATION)
	#tween.tween_property($Sprite2D, "rotation", newRot, DURATION)
	#tween.tween_property($Sprite2D, "position:x", center.x + RADIUS*sin(-newRot), DURATION)
	#tween.tween_property($Sprite2D, "position:y", center.y + RADIUS*cos(-newRot), DURATION)
	tween.finished.connect(rotateCube)
