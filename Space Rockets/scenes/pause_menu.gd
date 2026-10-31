extends CanvasLayer

const MENU_SCENE = "res://Space Rockets/scenes/Main Scene.tscn"
const FONT = preload("res://Resources/FONTS AND STYLES/Trade_Winds/TradeWinds-Regular.ttf")

var restart_score = 0
var can_pause = true

var pause_button: Button
var dimmer: ColorRect
var resume_button: Button

func _ready():
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	build_pause_button()
	build_pause_screen()
	
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		player.died.connect(_on_player_died)
		
func build_pause_button():
	pause_button = Button.new()
	pause_button.text = "Menu"
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.add_theme_font_override("font", FONT)
	pause_button.add_theme_font_size_override("font_size", 24)
	pause_button.anchor_left = 0.5
	pause_button.anchor_right = 0.5
	pause_button.offset_left = -50
	pause_button.offset_right = 50
	pause_button.offset_top = 10
	pause_button.offset_bottom = 54
	pause_button.pressed.connect(open)
	add_child(pause_button)
	
func build_pause_screen():
	dimmer = ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.65)
	dimmer.hide()
	add_child(dimmer)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var box = VBoxContainer.new()
	dimmer.add_child(box)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)

	var title = Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", 56)
	box.add_child(title)

	resume_button = make_button("Resume", box, close)
	make_button("Restart", box, _on_restart)
	make_button("Main Menu", box, _on_main_menu)
	
func make_button(text: String, parent: Node, action: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(220, 60)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_override("font", FONT)
	button.add_theme_font_size_override("font_size", 56)
	button.pressed.connect(action)
	parent.add_child(button)
	return button
	
func _unhandled_input(event):
	if event.is_action_pressed("menu"):
		if get_tree().paused:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
		
func open():
	if not can_pause or get_tree().paused:
		return
		
	get_tree().paused = true
	pause_button.hide()
	dimmer.show()
	resume_button.grab_focus()
	
func close():
	get_tree().paused = false
	dimmer.hide()
	pause_button.visible = can_pause
	
func _on_player_died():
	can_pause = false
	pause_button.hide()
	
func _on_restart():
	await stop_game()
	
	if GameState.endless:
		GameState.reset(true)
	else:
		GameState.score = restart_score
		
	get_tree().reload_current_scene()
	
func _on_main_menu():
	await stop_game()
	
	GameState.reset()
	get_tree().change_scene_to_file(MENU_SCENE)
	
func stop_game():
	can_pause = false
	pause_button.hide()
	dimmer.hide()
	
	get_parent().set("finished", true)
	if GameState.endless:
		GameState.submit_high_score(GameState.score)
		
	get_tree().paused = false
	await get_tree().create_timer(0.3).timeout
