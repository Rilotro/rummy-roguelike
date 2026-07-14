extends Node2D

class_name Throbber

const DISK_COUNT: int = 8

var Background: Sprite2D
var BG_Obfuscator: Control
var Body: Sprite2D

func _init() -> void:
	Background = Sprite2D.new()
	Background.texture = CanvasTexture.new()
	Background.region_enabled = true
	Background.self_modulate = Color(Color.BLACK, 0.5)
	Background.name = "Background"
	add_child(Background)
	
	BG_Obfuscator = Control.new()
	BG_Obfuscator.name = "BG_Obfuscator"
	BG_Obfuscator.mouse_filter = Control.MOUSE_FILTER_STOP
	BG_Obfuscator.z_index = 1
	add_child(BG_Obfuscator)
	
	Body = Sprite2D.new()
	Body.texture = CanvasTexture.new()
	Body.region_enabled = true
	Body.region_rect = Rect2(0, 0, 100, 100)
	Body.self_modulate = Color.BLACK
	Body.name = "Body"
	add_child(Body)

func _ready() -> void:
	var windowSize: Vector2 = get_viewport_rect().size
	
	Background.region_rect = Rect2(Vector2(0, 0), windowSize)
	BG_Obfuscator.size = windowSize
	BG_Obfuscator.position = -windowSize/2
	
	var new_disk: Sprite2D
	for i in range(DISK_COUNT):
		new_disk = Sprite2D.new()
		new_disk.texture = CanvasTexture.new()
		new_disk.region_enabled = true
		new_disk.region_rect = Rect2(Vector2(0, 0), Vector2(20, 20))
		new_disk.material = ShaderMaterial.new()
		new_disk.material.shader = load("res://MultiPlayer/Loading_Disk.gdshader")
		new_disk.set_instance_shader_parameter("delay", 0.8*i)
		Body.add_child(new_disk)
		new_disk.position = Vector2(36*sin(2*i*PI/DISK_COUNT), -36*cos(2*i*PI/DISK_COUNT))
