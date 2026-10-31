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
var finished = false
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
	
func build_overlay():
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
	message.add_theme_constant_override("outline_size", 8)
	box.add_child(message)
	
	retry_button = make_button("PLAY AGAIN", box)
	menu_button = make_button("Main Menu", box)
	
func make_button(text: String, parent: Node) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(200, 60)
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
	score_label.text = "Score = %d" % GameState.score
	best_label.text = "Best = %d" % maxi(GameState.high_score, GameState.score)
	
func update_stage():
	stage_label.text = "Stage = %d" % stage
	
func update_size():
	size_label.text = "Size =  " + player.ship.name
	
func show_message(text: String, color: Color = Color.WHITE) -> void:
	message.text = text
	message.add_theme_color_override("font_color", color)
	
func load_background():
	var index = floori((stage - 1) / float(BOSS_EVERY)) % GameState.waves.size()
	if index == background_index:
		return
				
	background_index = index
	var path = GameState.waves[index].background	
	
	if ResourceLoader.exists(path):
		$Background.set_background(load(path))
		
func run_endless():
	await wait(1.0)

	while not finished:
		update_stage()
		load_background()

		show_message("STAGE %d" % stage, CYAN)
		await wait(1.5)
		show_message("")
		if finished:
			return

		if stage % BOSS_EVERY == 0:
			await boss_stage()
		else:
			await enemy_stage()
		if finished:
			return

		stage += 1
			
func enemy_stage():
	phase = Phase.PLAYING

	var count = mini(4 + stage * 2, 30)
	var second_chance = clampf(0.15 + stage * 0.05, 0.0, 0.7)
	var gap = maxf(0.35, 1.2 - stage * 0.04)

	for _i in range(count):
		while regular_alive >= MAX_ALIVE and not finished:
			await get_tree().create_timer(0.2).timeout
		if finished:
			return

		var type_name = "second" if randf() < second_chance else "basic"
		spawn_enemy(type_name)
		await wait(gap)
		if finished:
			return

	phase = Phase.CLEARING
	await wait_until_regular_dead()
	
func boss_stage():
	phase = Phase.WARNING
	show_message("WARNING!\nBOSS INCOMING", RED)
	await wait(2.5)
	show_message("")
	if finished:
		return

	phase = Phase.BOSS
	var boss_name = "boss%d" % (boss_count % 3 + 1)
	if not spawn_boss(boss_name):
		return

	while boss_alive and not finished:
		await get_tree().create_timer(0.2).timeout
	if finished:
		return

	phase = Phase.CELEBRATING
	boss_count += 1
	upgrade_ship()
	show_message("BOSS DOWN!", GOLD)
	await wait(2.0)
	show_message("")
		
func upgrade_ship():
	GameState.endless_ship = mini(boss_count, GameState.ships.size() - 1)
	player.set_ship(GameState.current_ship())
	update_size()
		
func wait(seconds):
	var left = seconds
	while left > 0.0 and not finished:
		await get_tree().create_timer(0.1).timeout
		left -= 0.1
		
func wait_until_regular_dead():
	while regular_alive > 0 and not finished:
		await get_tree().create_timer(0.2).timeout
		
func spawn_enemy(type_name):
	var enemy_data = GameState.enemy_types[type_name].duplicate()
	enemy_data.hp += floori(stage / 6.0)
	enemy_data.speed += mini(stage * 3, 90)
	enemy_data.fire_rate = minf(1.0 + stage * 0.05, 2.5)

	var enemy = ENEMY.instantiate()
	enemy.position = Vector2(randf_range(-500, 550), -130)
	enemy.died.connect(_on_enemy_died.bind(enemy, enemy_data.points))

	add_child(enemy)
	enemy.setup(enemy_data)

	regular_alive += 1
	
func spawn_boss(boss_name) -> bool:
	var path = GameState.bosses[boss_name]
	
	if not ResourceLoader.exists(path):
		push_error("Missing Boss Scene" + path)
		return false
	
	var boss = load(path).instantiate()
	boss.position = BOSS_SPAWN_POSITION
	boss.max_health += boss_count * 10
	boss.died.connect(_on_boss_died.bind(boss))
	
	add_child(boss)
	boss_alive = true
	
	return true
	
func add_score(points):
	GameState.score += points
	update_score()
	
func _on_enemy_died(enemy, points):
	regular_alive = maxi(0, regular_alive - 1)
	add_score(points)
	popup_at(enemy.global_position, "+%d" % points, GOLD)
	roll_for_drop(enemy.global_position)
	
func _on_boss_died(boss):
	boss_alive = false
	add_score(boss.points)
	popup_at(boss.global_position, "+%d" % boss.points, GOLD)
	drop_pickup("heart", boss.global_position)
	
func roll_for_drop(at: Vector2) -> void:
	var roll = randf()
	if roll < HEART_DROP_CHANCE:
		drop_pickup("heart", at)
	elif roll < HEART_DROP_CHANCE + OVERDRIVE_DROP_CHANCE:
		drop_pickup("overdrive", at)
		
func drop_pickup(kind: String, at: Vector2) -> void:
	var pickup = PICKUP.instantiate()
	pickup.kind = kind
	pickup.position = at
	pickup.collected.connect(_on_pickup_collected)
	add_child.call_deferred(pickup)
	
func _on_pickup_collected(kind, at):
	if kind == "heart":
		popup_at(at, "+1 HEART", PINK)
	else:
		popup_at(at, "OVERDRIVE:", CYAN)
			
func popup_at(at: Vector2, text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.z_index = 20
	label.position = at + Vector2(-40, -30)
	label.add_theme_font_override("font", POPUP_FONT)
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	add_child(label)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60.0, 0.9)
	tween.tween_property(label, "modulate:a", 0.0, 0.9)
	tween.finished.connect(label.queue_free)
	
func _on_player_died():
	if finished:
		return
		
	finished = true
	phase = Phase.OVER
	
	var is_new_best = GameState.submit_high_score(GameState.score)
	best_label.text = "Best = %d" % GameState.high_score
	
	if is_new_best:
		show_message("GAME OVER\nNEW BEST: %d!" % GameState.score)
	else:
		show_message("GAME OVER\nScore: %d\nBest: %d" % [GameState.score, GameState.high_score], RED)
		
	get_tree().call_group("enemies", "queue_free")
	
	retry_button.show()
	menu_button.show()
	retry_button.grab_focus()
	
func _retry():
	GameState.reset(true)
	get_tree().reload_current_scene()


func _return_to_menu():
	GameState.reset()
	get_tree().change_scene_to_file(MENU_SCENE)
