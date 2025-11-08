extends Sprite2D

func _ready() -> void:
	var tween1 = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween1.tween_property(self, "global_position", Vector2(300, 300), 2)
	while(tween1.is_running()):
		print("HERE0")
		tween2.tween_property(self, "rotation", deg_to_rad(360), 0.5)
		await tween2.finished
		rotation = 0
		if(tween1.is_running()):
			tween2 = get_tree().create_tween()
