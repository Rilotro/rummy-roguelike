extends Node

const baseFilePath: String =  "res://LanguageStrings/english/"

var ItemStrings: Dictionary
var JokerStrings: Dictionary
var EffectStrings: Dictionary

func _init() -> void:
	var file: FileAccess
	var content: Dictionary
	
	if(FileAccess.file_exists(baseFilePath + "Items.json")):
		file = FileAccess.open(baseFilePath + "Items.json", FileAccess.READ)
		content = JSON.parse_string(file.get_as_text())
		
		ItemStrings = content
		
		print(ItemStrings["Bag of Tiles"]["NAME"])
		
		file.close()
	else:
		print("Error: Item Strings File not found")
	
	if(FileAccess.file_exists(baseFilePath + "Jokers.json")):
		file = FileAccess.open(baseFilePath + "Jokers.json", FileAccess.READ)
		content = JSON.parse_string(file.get_as_text())
		
		JokerStrings = content
		
		file.close()
	else:
		print("Error: Joker Strings File not found")
	
	if(FileAccess.file_exists(baseFilePath + "Effects.json")):
		file = FileAccess.open(baseFilePath + "Effects.json", FileAccess.READ)
		content = JSON.parse_string(file.get_as_text())
		
		EffectStrings = content
		
		file.close()
	else:
		print("Error: Effect Strings File not found")
