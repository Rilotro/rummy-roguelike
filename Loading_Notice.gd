extends Node2D

func _ready() -> void:
	var new_disk: Sprite2D
	var disk_count: int = 8
	for i in range(disk_count):
		new_disk = Sprite2D.new()
		new_disk.texture = CanvasTexture.new()
		new_disk.region_enabled = true
		new_disk.region_rect = Rect2(Vector2(0, 0), Vector2(20, 20))
		new_disk.material = ShaderMaterial.new()
		new_disk.material.shader = load("res://MultiPlayer/Loading_Disk.gdshader")
		new_disk.set_instance_shader_parameter("delay", 0.8*i)
		$Body.add_child(new_disk)
		new_disk.position = Vector2(36*sin(2*i*PI/disk_count), -36*cos(2*i*PI/disk_count))
