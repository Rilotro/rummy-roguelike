extends Control

#func _process(delta: float) -> void:
	#global_position = get_global_mouse_position() + body_to_follow.acc_size()/2 - Vector2(0, size.y/2)

func initialise_tip(body) -> void:
	global_position = body.global_position + body.acc_size()/2 - Vector2(-30, size.y/2)
	if(global_position.y > DisplayServer.window_get_size().y - 200):
		global_position.y = DisplayServer.window_get_size().y - 200
	elif(global_position.y < 0):
		global_position.y = 0
	
	if(global_position.x > DisplayServer.window_get_size().x - 250):
		#global_position.x > DisplayServer.window_get_size().x - 250
		global_position.x = body.global_position.x - body.acc_size().x/2 - 280
	elif(global_position.x < 0):
		global_position.x = 0
	
	if("Tile_Data" in body):
		$Banner_Text.text = "Tile"
		if(body.Tile_Data.joker):
			$Keyword_Text.text = "Joker"
			$Effects_Text.text = "Can be used as any [b]Tile[/b]"
		else:
			var color: String
			match body.Tile_Data.color:
				1:
					color = "black"
				2:
					color = "blue"
				3:
					color = "green"
				4:
					color = "red"
			if(body.Tile_Data.effects["rainbow"]):
				color = "rainbow"
			
			$Keyword_Text.text = body.Tile_Data.rarity + ", " + str(body.Tile_Data.number) + ", " + color
			if(body.Tile_Data.effects["duplicate"]):
				$Keyword_Text.text += ", duplicate"
			$Keyword_Text.text += " - " + str(body.Tile_Data.points) + " points"
			
			$Effects_Text.text = "[font_size=12]"
			if(body.Tile_Data.effects["rainbow"]):
				$Effects_Text.text += "[b]rainbow[/b] - Counts as any [b]Color[/b][br]"
			if(body.Tile_Data.effects["duplicate"]):
				$Effects_Text.text += "[b]duplicate[/b] - When [b]Spread[/b], create a copy of this [b]Tile[/b] in your [b]Deck[/b], [i]without this [b]Effect[/b][/i]"
			$Effects_Text.text += "[/font_size]"
	elif("item_info" in body):
		if(body.item_info != null):
			$Banner_Text.text = body.item_info.name
			$Keyword_Text.text = "item"
			if(body.item_info.passive):
				$Keyword_Text.text += ", passive"
			if(body.item_info.instant):
				$Keyword_Text.text += ", instant"
			if(body.item_info.uses > 0):
				$Keyword_Text.text += ", consumable - "  + str(body.item_info.uses) + " uses"
			
			$Effects_Text.text = body.item_info.description
		else:
			$Banner_Text.text = "Empty Item Slot"
			$Keyword_Text.text = ""
			$Effects_Text.text = "Buy [b]Items[/b] to add them here"
