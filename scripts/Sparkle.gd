extends Sprite2D

var is_tweening: bool = false

func _ready() -> void:
	modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1-modulate.a, randf_range(0.05, 0.15))
	tween.tween_property(self, "modulate:a", 1-modulate.a, randf_range(0.05, 0.15))
	await tween.finished
	queue_free()
