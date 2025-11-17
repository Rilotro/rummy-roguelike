extends Control

func initialise_tip(body) -> void:
	global_position = body.global_position + body.acc_size()/2 - Vector2(-30, size.y/2)
	if(global_position.y > DisplayServer.window_get_size().y - 200):
		global_position.y = DisplayServer.window_get_size().y - 200
	elif(global_position.y < 0):
		global_position.y = 0
	
	if(global_position.x > DisplayServer.window_get_size().x - 250):
		global_position.x = body.global_position.x - body.acc_size().x/2 - 280
	elif(global_position.x < 0):
		global_position.x = 0
	
	if("Tile_Data" in body):
		if(body.Tile_Data.joker_id >= 0):
			$Banner_Text.text = body.Tile_Data.joker_name
			$Keyword_Text.text = "Joker - [b]" + str(body.Tile_Data.points) + " Points[/b]"
			$Effects_Text.text = Descriprions.joker_descriptions[body.Tile_Data.joker_id]
		else:
			$Banner_Text.text = "Tile"
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
			
			if(body.Tile_Data.effects["winged"]):
				$Keyword_Text.text += ", winged"
			
			$Keyword_Text.text += " - [b]" + str(body.Tile_Data.points) + " Points[/b]"
			
			$Effects_Text.text = ""
			if(body.Tile_Data.effects["rainbow"]):
				$Effects_Text.text += "[b]rainbow[/b] - Counts as any [b]Color[/b].[br]"#--------------------------------------------------------------------------------------------
			if(body.Tile_Data.effects["duplicate"]):
				$Effects_Text.text += "[b]duplicate[/b] - [b]On Spread[/b] - create a copy of this [b]Tile[/b] in your [b]Deck[/b], [i]without this [b]Effect[/b][/i].[br]"
			if(body.Tile_Data.effects["winged"]):
				$Effects_Text.text += "[b]winged[/b] - [b]On Spread[/b] - [b]Draw[/b] one.[br]"
			
	elif("item_info" in body):
		if(body.item_info != null):
			$Banner_Text.text = body.item_info.name
			$Keyword_Text.text = "item"
			if(body.item_info.passive):
				$Keyword_Text.text += ", passive"
			else:
				$Keyword_Text.text += ", active"
			if(body.item_info.instant):
				$Keyword_Text.text += ", instant"
			if(body.item_info.consumable):
				$Keyword_Text.text += ", consumable - "  + str(body.item_info.uses) + " uses"
			
			$Effects_Text.text = body.item_info.description
			match body.item_info.id:
				0:
					$Effects_Text.text += "[font_size=10][color=Gray] - ([b]"
					if(body.item_info.usedThisRound >= 1):
						$Effects_Text.text += "[color=red]" + str(body.item_info.usedThisRound) + "/1[/color][/b])[/color][/font_size]"
					else:
						$Effects_Text.text += str(body.item_info.usedThisRound) + "/1[/b])[/color][/font_size]"
				1:
					var Game: Node2D = body.parentEffector.get_parent()
					var IB_count: int = Game.get_ItemBar().get_Slots().get_child_count()
					var TS_count: int = Game.get_Shop().get_TileSelections().get_child_count()-1 #get_child_count()
					var JS_count: int = Game.get_Shop().get_JokerSelecions().get_child_count()-1
					var IS_count: int = Game.get_Shop().get_ItemSelections().get_child_count()-1
					$Effects_Text.text += "[font_size=10][color=Gray] - ([b]"
					if(TS_count >= 10):
						$Effects_Text.text += "[color=red]" + str(TS_count) + "/10[/color][/b]); ([b]"
					else:
						$Effects_Text.text += str(TS_count) + "/10[/b]); ([b]"
					if(JS_count >= 3):
						$Effects_Text.text += "[color=red]" + str(JS_count) + "/3[/color][/b]); ([b]"
					else:
						$Effects_Text.text += str(JS_count) + "/3[/b]); ([b]"
					if(IS_count >= 8):
						$Effects_Text.text += "[color=red]" + str(IS_count) + "/8[/color][/b]); ([b]"
					else:
						$Effects_Text.text += str(IS_count) + "/8[/b]); ([b]"
					if(IB_count >= 12):
						$Effects_Text.text += "[color=red]" + str(IB_count) + "/12[/color][/b])[/color][/font_size]"
					else:
						$Effects_Text.text += str(IB_count) + "/12[/b])[/color][/font_size]"
				6:
					$Effects_Text.text += "[font_size=10][color=Gray] - ([b]"
					if(body.item_info.usedThisRound >= 3):
						$Effects_Text.text += "[color=red]" + str(body.item_info.usedThisRound) + "/3[/color][/b])[/color][/font_size]"
					else:
						$Effects_Text.text += str(body.item_info.usedThisRound) + "/3[/b])[/color][/font_size]"
		else:
			$Banner_Text.text = "Empty Item Slot"
			$Keyword_Text.text = ""
			$Effects_Text.text = "Buy [b]Items[/b] to add them here"
	
	await get_tree().create_timer(0.001).timeout
	while($Effects_Text.size.y > 122.5):
		$Effects_Text.custom_minimum_size.x += 1.0
		$Effects_Text.size.x += 1
		
		$Body.region_rect.size.x += 1
		$Separator.region_rect.size.x += 1
		$Banner.region_rect.size.x += 1
		
		$Body.global_position.x += 0.5
		$Separator.global_position.x += 0.5
		$Banner.global_position.x += 0.5
		
		$Effects_Text.size.y = 122.5
