extends GoodButton

class_name SpreadTransition

#const IMAGE_SIZE: Vector2 = Vector2(75, 300)

var LoadingSprite: Sprite2D

func _init() -> void:
	var arrowImage: Texture = load("res://UI/TrabsitionArraows.png")
	
	LoadingSprite = Sprite2D.new()
	LoadingSprite.texture = CanvasTexture.new()
	LoadingSprite.region_enabled = true
	LoadingSprite.region_rect = Rect2(0, 0, 85, 310)
	LoadingSprite.position = arrowImage.get_size()/2
	LoadingSprite.self_modulate = Color.YELLOW
	LoadingSprite.self_modulate.a = 0
	LoadingSprite.material = ShaderMaterial.new()
	LoadingSprite.material.shader = load("res://shaders/LoadingOutline.gdshader")
	LoadingSprite.name = "LoadingSprite"
	add_child(LoadingSprite)
	
	super("", Color.WHITE, GoodButton.ButtonType.TRANSITION_SPREAD, Vector2(-1, -1), arrowImage)

func _process(delta: float) -> void:
	super(delta)
	
	LoadingSprite.material.set_shader_parameter("loadingTime", hoverTimer)#Time.get_ticks_msec()/1000.0-0.8

func _mouse_entered() -> void:
	super()
	
	LoadingSprite.self_modulate.a = 1
	ButtonIcon.self_modulate.a = 1

func _mouse_exited() -> void:
	super()
	
	LoadingSprite.self_modulate.a = 0
