extends Sprite2D

class_name Sparkle

const SPARKLE_SIZE: Vector2 = Vector2(5, 5)

var is_tweening: bool = false

func _init() -> void:
	texture = CanvasTexture.new()
	region_enabled = true
	region_rect = Rect2(0, 0, 5, 5)
	material = ShaderMaterial.new()
	material.shader = load("res://shaders/Sparkle.gdshader")

func _ready() -> void:
	modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1-modulate.a, randf_range(0.05, 0.15))
	tween.tween_property(self, "modulate:a", 1-modulate.a, randf_range(0.05, 0.15))
	await tween.finished
	queue_free()
