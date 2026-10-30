extends Node2D

enum Phase { PLAYING, CLEARING, WARNING, BOSS, CELEBRATING, OVER }

const MENU_SCENE = "res://Space Rockets/scenes/Main Scene.tscn"
const ENEMY = preload("res://Space Rockets/scenes/enemy.tscn")
const PICKUP = preload("res://Space Rockets/scenes/pickup.tscn")
const POPUP_FONT = preload("res://Resources/FONTS AND STYLES/Trade_Winds/TradeWinds-Regular.ttf")
const BOSS_SPAWN_POSITION = Vector2(27, -260)

const BOSS_EVERY = 5
const MAX_ALIVE = 8
const HEART_DROP_CHANCE = 0.08
const OVERDRIVE_DROP_CHANCE = 0.06

const GOLD = Color(1.0, 0.84, 0.3)
const RED = Color(1.0, 0.25, 0.25)
const CYAN = Color(0.45, 0.95, 1.0)
const PINK = Color(1.0, 0.45, 0.55)

var phase = Phase.PLAYING
var stage = 1
var boss_count = 0
var regular_alive = 0
var boss_alive = false
var background_index = -1

var message: Label
var best_label: Label
var retry_button: Button
var menu_button: Button

@onready var score_label = $Score
@onready var stage_label = $Wave
@onready var size_label = $Size
@onready var player = $SpaceShipBody2D
@onready var hearts = $Hearts

func _ready():
	GameState.score = 0

	build_overlay()
	build_best_label()

	retry_button.pressed.connect(_retry)
	menu_button.pressed.connect(_return_to_menu)

	hearts.set_health(player.health)
	player.health_changed.connect(hearts.set_health)
	player.died.connect(_on_player_died)

	update_score()
	update_stage()
	update_size()

	run_endless()
	
func bulid_overlay():
	var layer = CanvasLayer.new()
	add_child(layer)
	
	var box = VBoxContainer.new()
	layer.add_child(box)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	message = Label.new()
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_override("font", POPUP_FONT)
	message.add_theme_font_size_override("font_size", 48)
	message.add_theme_color_override("font_outline_color", Color.BLACK)
	message.add_theme_constant_override("outlink_size", 8)
	box.add_child(message)
	
	retry_button = make_button("PLAY AGAIN", box)
	menu_button = make_button("Main Menu", box)
	
func make_button(text: String, parent: Node) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_maximum_size = Vector2(200, 60)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.hide()
	parent.add_child(button)
	return button
	
func build_best_label():
	best_label = Label.new()
	best_label.position = Vector2(-536, -18)
	best_label.add_theme_font_override("font", POPUP_FONT)
	best_label.add_theme_font_size_override("font_size", 26)
	best_label.add_theme_color_override("font_color", GOLD)
	add_child(best_label)
	
func update_score():
	score_label.text = "Score = &d" % GameState.score
	best_label.text = "Best = %d" % maxi(GameStage.high_score, GameStage.score)
	
func update_stage():
	stage_label.text = "Stage = %d" % stage
	
func update_size():
	size_label.text = "Size =  " + player.ship.name
	
func show_message(text: String, color: Color = Color.WHITE) -> void:
	message.text = text
	message.add_theme_color_override("font_color", color)
	
func load_background():
	var index = floori((stage - 1) / float(BOSS_EVERY)) % GameStage.waves.size()
	if index == background_index:
		return
				
	background_index = index	
	
	
