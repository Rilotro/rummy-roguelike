extends Sprite2D

var is_tweening: bool = false

func _ready() -> void:
	modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1-modulate.a, randf_range(0.05, 0.15))
	tween.tween_property(self, "modulate:a", 1-modulate.a, randf_range(0.05, 0.15))
	await tween.finished
	queue_free()


#func _process(delta: float) -> void:
	#if(!is_tweening):
		#is_tweening = true
		#var tween = get_tree().create_tween()
		#if(randi_range(0, 1)):
			#tween.tween_property(self, "modulate:a", 1-modulate.a, randf_range(0.05, 0.15))
		#else:
			#tween.tween_property(self, "modulate:a", modulate.a, randf_range(0.05, 0.15))
		#await tween.finished
		#is_tweening = false
	
