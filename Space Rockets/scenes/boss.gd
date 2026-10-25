extends "res://Space Rockets/scenes/Enemy.gd"

@export var max_health = 30
@export var points = 300
@export var hover_y = 40.0
@export var enter_speed =100.0
@export var sway_width = 250.0   
@export var sway_speed = 0.8
@export var fire_interval = 1.6   
@export var laser_texture_file: Texture2D
@export var laser_size = 0.55
@export var boss_laser_speed = 320.0
 
@export var aimed_attack_every = 0
 
@export var enrage_below = 0.5
@export var enrage_speed_up = 0.7
 
@export var bar_width = 220.0
@export var bar_y = -120.0

var entered = false
var attack_count = 0
var attack_timer = 1.5

@onready var nozzles = $Nozzles


func _ready():
	super()
	hp = max_health
	start_x = position.x
	laser_texture = laser_texture_file
	laser_scale = laser_size
	laser_speed = boss_laser_speed


func _physics_process(delta):
	if not entered:
		position.y += enter_speed * delta
		if position.y >= hover_y:
			position.y = hover_y
			entered = true
		return

	time += delta
	position.x = start_x + sin(time * sway_speed) * sway_width

	attack_timer -= delta
	if attack_timer <= 0:
		attack()
		attack_timer = current_fire_interval()

	check_contact_damage()


func current_fire_interval() -> float:
	if float(hp) / max_health <= enrage_below:
		return fire_interval * enrage_speed_up
	return fire_interval


# One attack = one laser from every nozzle at the same moment.
func attack():
	attack_count += 1
	var aimed = aimed_attack_every > 0 and attack_count % aimed_attack_every == 0

	for nozzle in nozzles.get_children():
		if not nozzle is Marker2D:
			continue
		var from_position = nozzle.global_position
		var direction = Vector2.DOWN
		if aimed:
			direction = (target_position() - from_position).normalized()
		fire_laser(from_position, direction)


func target_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return global_position + Vector2.DOWN * 500.0
	return player.center_position()


func take_damage(amount):
	super(amount)
	queue_redraw()


func _draw():
	var ratio = clampf(float(hp) / max_health, 0.0, 1.0)
	var back = Rect2(-bar_width / 2.0, bar_y, bar_width, 12)
	draw_rect(back, Color(0.15, 0.0, 0.0, 0.9))
	draw_rect(Rect2(back.position, Vector2(bar_width * ratio, back.size.y)), Color(0.9, 0.15, 0.15))
	draw_rect(back, Color.WHITE, false, 2.0)
