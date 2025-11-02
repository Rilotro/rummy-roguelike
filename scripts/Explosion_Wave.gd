extends Sprite2D

func _ready() -> void:
	modulate = Color(1, 1, 1, 1)
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_value, 0.0, 15.0, 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 0, 1), 0.4)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()

func set_shader_value(value: float):
	material.set_shader_parameter("range", value)
