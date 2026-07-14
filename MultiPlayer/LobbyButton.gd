@warning_ignore("missing_tool")
extends GoodButton

class_name LobbyButton

const BUTTON_COLOR: Color = Color(0.1, 0.1, 0.1, 0.6)

var PassInput: TextEdit
var ErrorText: RichTextLabel
var joinButton: GoodButton

var MainMenu: Node
var isRevealed: bool = false
var revealTween: Tween
var lobbyName: String

func _init(lobbyName_param: String = "test", userNames: Array[String] = ["test1", "test2"], hasPass: bool = false) -> void:
	lobbyName = lobbyName_param
	var lobbyText: String = lobbyName + " - "
	for i in range(userNames.size()):
		lobbyText += userNames[i]
		if(i < userNames.size()-1):
			lobbyText += ", "
	
	super(lobbyText, BUTTON_COLOR, GoodButton.ButtonType.NONE, Vector2(0, 40))
	
	ErrorText = RichTextLabel.new()
	ErrorText.bbcode_enabled = true
	ErrorText.text = "[color=red]You must fill out the Username "
	
	if(hasPass):
		PassInput = TextEdit.new()
		PassInput.placeholder_text = "Enter Password"
		PassInput.size = custom_minimum_size
		PassInput.self_modulate.a = 0
		PassInput.visible = false
		PassInput.name = "PasswordInput"
		PassInput.editable = false
		add_child(PassInput)
		
		ErrorText.text += "and Password text areas![/color]"
	else:
		ErrorText.text += "text area![/color]"
	
	#var textSize: Vector2 = ErrorText.get_theme_font("font").get_string_size(ErrorText.text)
	
	ErrorText.size = ErrorText.get_theme_font("font").get_string_size(ErrorText.text)
	ErrorText.visible = false
	ErrorText.name = "ErrorText"
	add_child(ErrorText)
	
	joinButton = GoodButton.new("Join", BUTTON_COLOR, GoodButton.ButtonType.NONE, Vector2(0, 40), null, false)
	joinButton.visible = false
	joinButton.name = "joinButton"
	add_child(joinButton)
	
	joinButton.press.connect(func() -> void:
		if((MainMenu.Username_J.text as String).is_empty() || (hasPass && PassInput.text.is_empty())):
			ErrorText.visible = true
			return
		
		MainMenu.currThrobber = Throbber.new()
		MainMenu.add_child(MainMenu.currThrobber)
		MainMenu.currThrobber.global_position = get_viewport_rect().size/2
		
		MainMenu.chosenUserName = MainMenu.Username_J.text
		MainMenu.chosenLobbyName = lobbyName
		(MainMenu.Username_J as TextEdit).clear()
		var param: String = lobbyName + ":" + MainMenu.chosenUserName + ":"
		
		if(hasPass):
			param += PassInput.text
		else:
			param += "no_password"
		
		#MultiplayerHandler.receivedData.connect(func(source: String, command: String, params: PackedByteArray) -> void:
			#if(command == "get_lobby_members"):
				#pass
			#)
		MultiplayerHandler.receivedData.connect(MainMenu.confirm_join_lobby)
		MultiplayerHandler.send_data("join_lobby", param.to_utf8_buffer()))

func _ready() -> void:
	MainMenu = get_parent().get_parent().get_parent()

func finalPress() -> void:
	super()
	
	if(!enabled):
		return
	
	Reveal()

func lateFinalPress() -> void:
	super()
	
	if(!enabled):
		return
	
	Reveal()

func Reveal() -> void:
	isRevealed = !isRevealed
	
	if(isRevealed):
		if(PassInput != null):
			PassInput.visible = true
		
		joinButton.self_modulate.a = 0
		joinButton.visible = true
		
		if(revealTween != null && revealTween.is_running()):
			revealTween.kill()
			tweenFinished(true)
		
		revealTween = create_tween()
		revealTween.set_parallel()
		
		var finalPos: float = 50
		if(PassInput != null):
			revealTween.tween_property(PassInput, "self_modulate:a", 1, 0.2)
			revealTween.tween_property(PassInput, "position:y", finalPos, 0.2)
			finalPos += 50
		
		revealTween.tween_property(joinButton, "self_modulate:a", 1, 0.3)
		revealTween.tween_property(joinButton, "position:y", finalPos, 0.3)
		
		ErrorText.position = Vector2(joinButton.size.x+5, finalPos)
	else:
		if(PassInput != null):
			PassInput.editable = false
		
		#joinButton.DIS_ENable(false)
		joinButton.enabled = false
		
		if(revealTween != null && revealTween.is_running()):
			revealTween.kill()
			tweenFinished(true)
		
		revealTween = create_tween()
		revealTween.set_parallel()
		
		if(PassInput != null):
			revealTween.tween_property(PassInput, "self_modulate:a", 0, 0.15)
			revealTween.tween_property(PassInput, "position:y", 0, 0.15)
		
		revealTween.tween_property(joinButton, "self_modulate:a", 0, 0.15)
		revealTween.tween_property(joinButton, "position:y", 0, 0.15)
		
		revealTween.tween_property(ErrorText, "position:y", 0, 0.15)
		revealTween.tween_property(ErrorText, "self_modulate:a", 0, 0.15)
	
	revealTween.finished.connect(tweenFinished)

func tweenFinished(forcedKill: bool = false) -> void:
	var wasRevealing: bool = isRevealed == !forcedKill
	
	if(!forcedKill):
		if(wasRevealing):
			if(PassInput != null):
				PassInput.editable = true
			
			#joinButton.DIS_ENable(true)
			joinButton.enabled = true
		else:
			if(PassInput != null):
				PassInput.visible = false
			
			ErrorText.visible = false
			ErrorText.self_modulate.a = 1
			
			joinButton.self_modulate.a = joinButton.IconOrigColor.a
			joinButton.visible = false
