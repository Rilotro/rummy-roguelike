extends GoodButton

class_name TurnButton

var currButtonAction: ButtonAction

enum ButtonAction{
	END_TURN, SHOP
}

func _init(initButtonAction: ButtonAction) -> void:
	currButtonAction = initButtonAction
	match(initButtonAction):
		ButtonAction.END_TURN:
			super(StringsManager.UIStrings["TURN"]["TEXT"][0], Color.BLACK)
		ButtonAction.SHOP:
			super(StringsManager.UIStrings["SHOP"][0], Color.GOLD)

func getName(Tip: UITip) -> String:
	match currButtonAction:
		ButtonAction.SHOP:
			return StringsManager.UIStrings["SHOP"][0]
		ButtonAction.END_TURN:
			if(!Player.isDiscarding):
				return StringsManager.UIStrings["TURN"]["NAME"][0]
			else:
				return StringsManager.UIStrings["TURN"]["NAME"][1]
	
	return ""

func getKeywords(Tip: UITip) -> String:
	match currButtonAction:
		ButtonAction.SHOP:
			return StringsManager.UIStrings["SHOP"][3]
		ButtonAction.END_TURN:
			if(!Player.isDiscarding):
				return StringsManager.UIStrings["TURN"]["KEYWORDS"][0]
			else:
				return StringsManager.UIStrings["TURN"]["KEYWORDS"][1]
	
	return ""

func getDescription(Tip: UITip) -> String:
	var descriptionStrings: Array = StringsManager.UIStrings["TURN"]["DESCRIPTION"]
	var description: String = ""
	
	match currButtonAction:
		ButtonAction.SHOP:
			description += descriptionStrings[0]
		ButtonAction.END_TURN:
			if(!Player.isDiscarding):
				description += descriptionStrings[1]
			else:
				description += descriptionStrings[2]
	
	description += descriptionStrings[3] + str(Shop.currency) + descriptionStrings[4]
	
	return description

func changeButtonAction(newButtonAction: ButtonAction) -> void:
	currButtonAction = newButtonAction
	match(currButtonAction):
		ButtonAction.END_TURN:
			changeVisuals(StringsManager.UIStrings["TURN"]["TEXT"][0], Color.BLACK)
		ButtonAction.SHOP:
			changeVisuals(StringsManager.UIStrings["SHOP"][0], Color.GOLD)

func finalPress() -> void:
	if(!isEnabled):
		return
	
	match(currButtonAction):
		ButtonAction.END_TURN:
			GameScene.MainPlayer.EN_DISableDiscarding()
			
			if(Player.isDiscarding):
				changeVisuals(StringsManager.UIStrings["TURN"]["TEXT"][1], Color.RED)
			else:
				changeVisuals(StringsManager.UIStrings["TURN"]["TEXT"][0], Color.BLACK)
		ButtonAction.SHOP:
			GameScene.GameShop.visible = true
	
	press.emit()
