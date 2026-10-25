extends Node2D

enum Phase { SPAWNING, CLEARING, BOSS, DONE }

const ENEMY = preload("res://Space Rockets/scenes/enemy.tscn")
const MENU_SCENE = "res://Space Rockets/scenes/Main Scene.tscn"
const BOSS_SPAWN_POSITION = Vector2(27, -260)

var data
var phase = Phase.SPAWNING
var regular_alive = 0
var boss_alive = false
var start_score = 0
var finished = false

@onready var score_label = $Score
@onready var wave_label = $Wave
@onready var size_label = $Size
@onready var player = $SpaceShipBody2D
@onready var hearts = $Hearts
@onready var message = $Overlay/Message
@onready var menu_button = $Overlay/MenuButton


func _ready():
	data = GameState.current_wave()
	start_score = GameState.score

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


func load_background():
	var path = data.background

	if ResourceLoader.exists(path):
		$Background.set_background(load(path))
	else:
		push_warning("Missing background: " + path)


func run_wave():
	phase = Phase.SPAWNING

	await get_tree().create_timer(1.0).timeout

	if finished:
		return

	for group in data.groups:
		for i in range(group.count):
			if finished:
				return

			spawn_enemy(group.type)

			if data.one_at_a_time:
				await await_unit_regular_dead()

				if finished:
					return

				await get_tree().create_timer(0.8).timeout
			else:
				await get_tree().create_timer(group.gap).timeout

				if finished:
					return

		if group.pause > 0.0:
			await get_tree().create_timer(group.pause).timeout

			if finished:
				return

	phase = Phase.CLEARING

	await wait_until_regular_dead()

	if finished:
		return

	if data.boss != "":
		phase = Phase.BOSS

		var spawned = spawn_boss(data.boss)

		if spawned:
			while boss_alive and not finished:
				await get_tree().create_timer(0.2).timeout

			if finished:
				return

	wave_cleared()


func await_unit_regular_dead():
	while regular_alive > 0 and not finished:
		await get_tree().create_timer(0.2).timeout


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

	var boss_scene = load(path)

	if boss_scene == null:
		push_error("Failed to load boss scene: " + path)
		return false

	var boss = boss_scene.instantiate()
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
