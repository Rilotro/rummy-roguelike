extends Sprite2D

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
var FireSprites: Array[Texture] = [preload("res://Items/Deck_Fire1.png"), preload("res://Items/Deck_Fire2.png"), preload("res://Items/Deck_Fire3.png"), preload("res://Items/Deck_Fire4.png")]
var fire_timer: float = 0
var lastIndex: int = -1
var fireCheck: Array[bool] = [false, false, false, false]
var triggerTime: float = 0.05

func _ready() -> void:
	var fireIndex: int = randi_range(0, 3)
	texture = FireSprites[fireIndex]
	fireCheck[fireIndex] = true
	lastIndex = fireIndex

func _process(delta: float) -> void:
	fire_timer += delta
	if(fire_timer >= triggerTime):
		fire_timer = 0
		triggerTime = randf_range(0.06, 0.08)
		var fireIndex: int = randi_range(0, 3)
		while(fireCheck[fireIndex] == true && fireIndex == lastIndex):
			fireIndex = randi_range(0, 3)
		
		texture = FireSprites[fireIndex]
		lastIndex = fireIndex
		fireCheck[fireIndex] = true
		for check in fireCheck:
			if(check == false):
				return
		
		fireCheck.fill(false)
