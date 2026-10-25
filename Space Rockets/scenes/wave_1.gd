extends Node2D

enum Phase { SPAWNING, CLEARING, BOSS, DONE }

const ENEMY = preload("res://Space Rockets/scenes/enemy.tscn")
const MENU_SCENE = "res://Space Rockets/scenes/Main Scene.tscn"
const MESSAGE_FONT = "res://Resources/FONTS AND STYLES/Trade_Winds/TradeWinds-Regular.ttf"
const BOSS_SPAWN_POSITION = Vector2(27, -260)

var data
var phase = Phase.SPAWNING
var regular_alive = 0
var boss_alive = false
var start_score = 0
var finished = false

# FIX: Wave 1.tscn has no "Overlay" node, so the old @onready lines
# ($Overlay/Message and $Overlay/MenuButton) were null and crashed _ready().
# These two are now built in code (see build_overlay below).
var message: Label
var menu_button: Button

@onready var score_label = $Score
@onready var wave_label = $Wave
@onready var size_label = $Size
@onready var player = $SpaceShipBody2D
@onready var hearts = $Hearts


func _ready():
	data = GameState.current_wave()
	start_score = GameState.score

	build_overlay()

	wave_label.text = "Wave = %d" % (GameState.wave + 1)
	score_label.text = "Score = %d" % GameState.score
	size_label.text = "Size = " + player.ship.name

	message.text = ""
	menu_button.hide()
	menu_button.pressed.connect(_return_to_menu)

	load_background()

	hearts.set_health(player.health)
	player.health_changed.connect(hearts.set_health)
	player.died.connect(_on_player_died)

	run_wave()


# Big centered text (Game Over / Wave Cleared / Victory) and the menu button.
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
	message.add_theme_font_size_override("font_size", 48)
	if ResourceLoader.exists(MESSAGE_FONT):
		message.add_theme_font_override("font", load(MESSAGE_FONT))
	box.add_child(message)

	menu_button = Button.new()
	menu_button.text = "Main Menu"
	menu_button.custom_minimum_size = Vector2(200, 60)
	menu_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(menu_button)


func load_background():
	var path = data.background

	if ResourceLoader.exists(path):
		$Background.set_background(load(path))
	else:
		push_warning("Missing background: " + path)


func run_wave():
	phase = Phase.SPAWNING

	await wait(1.0)
	if finished:
		return

	for group in data.groups:
		for i in range(group.count):
			spawn_enemy(group.type)

			if data.one_at_a_time:
				await wait_until_regular_dead()
				await wait(0.8)
			else:
				await wait(group.gap)

			if finished:
				return

		await wait(group.pause)
		if finished:
			return

	phase = Phase.CLEARING
	await wait_until_regular_dead()
	if finished:
		return

	if data.boss != "":
		phase = Phase.BOSS

		if spawn_boss(data.boss):
			while boss_alive and not finished:
				await get_tree().create_timer(0.2).timeout

			if finished:
				return

	wave_cleared()


# A timer that stops early once the wave is over. That way nothing is still
# waiting when the scene reloads (that caused "class instance is gone" errors).
func wait(seconds):
	var left = seconds
	while left > 0.0 and not finished:
		await get_tree().create_timer(0.1).timeout
		left -= 0.1


# FIX: there were two identical functions for this (await_unit_regular_dead and
# wait_until_regular_dead). Kept one.
func wait_until_regular_dead():
	while regular_alive > 0 and not finished:
		await get_tree().create_timer(0.2).timeout


func spawn_enemy(type_name):
	if finished:
		return

	if not GameState.enemy_types.has(type_name):
		push_error("Unknown enemy type: " + str(type_name))
		return

	var enemy_data = GameState.enemy_types[type_name].duplicate()
	enemy_data.hp += data.hp_bonus
	enemy_data.speed += data.speed_bonus
	enemy_data.fire_rate = data.fire_rate

	var enemy = ENEMY.instantiate()
	enemy.position = Vector2(randf_range(-500, 550), -130)
	enemy.died.connect(_on_enemy_died.bind(enemy_data.points))

	add_child(enemy)
	enemy.setup(enemy_data)

	regular_alive += 1


func spawn_boss(boss_name) -> bool:
	if not GameState.bosses.has(boss_name):
		push_error("Unknown boss: " + str(boss_name))
		return false

	var path = GameState.bosses[boss_name]

	if not ResourceLoader.exists(path):
		push_error("Missing boss scene: " + path)
		return false

	var boss = load(path).instantiate()
	boss.position = BOSS_SPAWN_POSITION
	boss.died.connect(_on_boss_died.bind(boss.points))

	add_child(boss)
	boss_alive = true

	return true


func add_score(points):
	GameState.score += points
	score_label.text = "Score = %d" % GameState.score


func _on_enemy_died(points):
	regular_alive = maxi(0, regular_alive - 1)
	add_score(points)


func _on_boss_died(points):
	boss_alive = false
	add_score(points)


func wave_cleared():
	if finished:
		return

	finished = true
	phase = Phase.DONE

	if GameState.wave + 1 >= GameState.waves.size():
		show_victory()
	else:
		wave_label.text = "Wave %d Cleared!" % (GameState.wave + 1)
		message.text = "Wave %d Cleared!" % (GameState.wave + 1)

		await get_tree().create_timer(2.0).timeout

		GameState.wave += 1
		get_tree().reload_current_scene()


func show_victory():
	wave_label.text = "YOU WIN!"
	message.text = "VICTORY!\nThe final boss is down.\nFinal score: %d" % GameState.score

	menu_button.show()
	menu_button.grab_focus()


func _return_to_menu():
	GameState.reset()
	get_tree().change_scene_to_file(MENU_SCENE)


# If all the hearts are gone: Game Over, then the same wave starts again.
func _on_player_died():
	if finished:
		return

	finished = true

	wave_label.text = "Game Over"
	message.text = "GAME OVER"

	await get_tree().create_timer(2.0).timeout

	GameState.score = start_score
	get_tree().reload_current_scene()
