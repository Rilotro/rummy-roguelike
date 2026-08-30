extends Node2D

#class_name ButtonCallables

var Callables: Dictionary[String, Dictionary] = {
	"SPREAD": {
		"NAME": func(_TipRef: UITip) -> String: return StringsManager.UIStrings["SPREAD"]["NAME"],#-----------------
		"KEYWORDS": func(_TipRef: UITip) -> String:
			var selectionSize: int = Player.selectedTiles.size()
			var keywords: String = str(selectionSize)
			
			if(selectionSize == 1):
				keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][0]
			else:
				keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][1]
			
			keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][2]
			
			var imageScale: float = (UITip.KEYWORD_SIZE_Y-10)/ResourceContainer.BASE_RESOURCE_SIZE.y
			
			var extraBBCodeWidth: float = _TipRef.Keyword_Text.get_theme_font("font").get_string_size(StringsManager.UIStrings["SPREAD"]["KEYWORDS"][6], _TipRef.Keyword_Text.horizontal_alignment, -1, _TipRef.Keyword_Text.get_theme_font_size("normal_font_size")).x
			var origImagePos_X: float = _TipRef.Keyword_Text.get_theme_font("font").get_string_size(keywords, _TipRef.Keyword_Text.horizontal_alignment, -1, _TipRef.Keyword_Text.get_theme_font_size("normal_font_size")).x - extraBBCodeWidth + 10
			var imagePos_X: float = origImagePos_X
			var newSequenceImage: TileImage
			for tile in Player.selectedTiles:
				#(PlayerTurnButton.size.y - BaitButton.size.y)/2)
				newSequenceImage = TileImage.new(tile.tile)
				newSequenceImage.scale = Vector2(imageScale, imageScale)
				newSequenceImage.position = Vector2(imagePos_X, _TipRef.Keyword_Text.position.y)
				newSequenceImage.position.y += (UITip.KEYWORD_SIZE_Y - (ResourceContainer.BASE_RESOURCE_SIZE.y*imageScale))/2
				imagePos_X += ResourceContainer.BASE_RESOURCE_SIZE.y*imageScale + 1
				_TipRef.add_child(newSequenceImage)
			
			var emptySpace: String = ""
			while(_TipRef.Keyword_Text.get_theme_font("font").get_string_size(emptySpace, _TipRef.Keyword_Text.horizontal_alignment, -1, _TipRef.Keyword_Text.get_theme_font_size("normal_font_size")).x < imagePos_X-origImagePos_X):
				emptySpace += " "
			
			keywords += emptySpace + StringsManager.UIStrings["SPREAD"]["KEYWORDS"][3]
			
			if(GameScene.MainPlayer.SpreadButton.enabled):
				keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][4]
			else:
				keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][5]
			
			return keywords,
		"DESCRIPTION": func(_TipRef: UITip) -> String:
			var strings: Array = StringsManager.UIStrings["SPREAD"]["DESCRIPTION"]
			var selectionSize: int = Player.selectedTiles.size() 
			var description: String = strings[0] + str(selectionSize)
			
			if(selectionSize == 1):
				description += strings[1]
			else:
				description += strings[2]
			
			description += strings[3]
			
			match Player.currentSpreadEligibility:
				Spread_Info.SpreadCheck.ELIGIBLE:
					description += strings[4]
					return description
				Spread_Info.SpreadCheck.SHORT:
					description += strings[5] + str(3) + strings[6]
				Spread_Info.SpreadCheck.VAGUE:
					description += strings[7]
				Spread_Info.SpreadCheck.NO_PATTERN:
					description += strings[8]
				Spread_Info.SpreadCheck.DUPLICATE_COLOR:
					description += strings[9]
				Spread_Info.SpreadCheck.TOO_MANY_COLORS:
					description += strings[10]
				Spread_Info.SpreadCheck.SEQUENCE_OOB:
					description += strings[11]
			
			description += strings[12]
			
			return description
			},
	
	"DISCARD":{
		"NAME": func(_TipRef: UITip) -> String:return StringsManager.UIStrings["DISCARD"]["NAME"],
		"KEYWORDS": func(_TipRef: UITip) -> String:
			var selectionSize: int = Player.selectedTiles.size()
			var keywords: String = str(selectionSize) + "/[color=dark_red]" + str(Player.minMAXTilesToDiscard.x) + "[/color]([color=light_green]" + str(Player.minMAXTilesToDiscard.y) + "[/color]) "
			return keywords + StringsManager.UIStrings["DISCARD"]["KEYWORDS"],
		"DESCRIPTION": func(_TipRef: UITip) -> String:
			var selectionSize: int = Player.selectedTiles.size()
			var strings: Array = StringsManager.UIStrings["DISCARD"]["DESCRIPTION"]
			var description: String = strings[0]
			
			if(selectionSize == 0):
				description += strings[1]
			elif(selectionSize == 1):
				description += str(selectionSize) + strings[2]
			else:
				description += str(selectionSize) + strings[3]
			
			description += strings[4] + str(Player.minMAXTilesToDiscard.x)
			
			if(Player.minMAXTilesToDiscard.x == 1):
				description += strings[2]
			else:
				description += strings[1]
			
			description += strings[5] + str(Player.minMAXTilesToDiscard.y)
			
			if(Player.minMAXTilesToDiscard.y == 1):
				description += strings[2]
			else:
				description += strings[3]
			
			description += strings[6]
			
			if(selectionSize < Player.minMAXTilesToDiscard.x):
				description += strings[7]
			elif(BottledNostalgia.NostalgiaUses > 0):
				description += StringsManager.ItemStrings["Bottled Nostalgia"]["MISCELLANEOUS"][0]
			else:
				description += strings[8] + str(selectionSize) + strings[9] + str(1) + strings[10]
			
			return description
			},
	
	"BAIT":{
		"NAME": func(_TipRef: UITip) -> String: return StringsManager.UIStrings["BAIT"]["NAME"],
		"KEYWORDS": func(_TipRef: UITip) -> String: return StringsManager.UIStrings["BAIT"]["KEYWORDS"][0] + str(River.bait) + StringsManager.UIStrings["BAIT"]["KEYWORDS"][1],
		"DESCRIPTION": func(_TipRef: UITip) -> String: 
			var strings: Array = StringsManager.UIStrings["BAIT"]["DESCRIPTION"]
			var beaverStrings: Array = StringsManager.ItemStrings["Beaver Teeth"]["MISCELLANEOUS"]
			var description: String = strings[0]
			
			if(River.bait == 0):
				description += strings[1]
				return description
			else:
				description += str(River.bait) + strings[2]
			
			if(River.bait == 1):
				if(BeaverTeeth.Beaver_Teeth_Activated):
					description += beaverStrings[0]
				else:
					description += strings[3] + strings[4]
			else:
				if(BeaverTeeth.Beaver_Teeth_Activated):
					description += beaverStrings[1]
				
				description += strings[3] + str(River.bait) + strings[5]
				
				if(BeaverTeeth.Beaver_Teeth_Activated):
					description += beaverStrings[2]
				else:
					description += strings[6]
				
				description += strings[7]
			
			description += strings[9]
			
			description += strings[7]
			
			description += strings[10]
			
			return description
			}
}
