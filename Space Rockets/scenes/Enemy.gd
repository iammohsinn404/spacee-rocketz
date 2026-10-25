extends Area2D

signal died

const LASER = preload("res://Space Rockets/scenes/bullet.tscn")
const BOTTOM_EDGE = 560.0
const RESPAWN_Y = -130.0
const FIRST_VISIBLE_Y = -90.0

var speed = 100.0
var hp = 1
var sway = 0.0
var can_shoot = true
var aims_at_player = false
var start_x = 0.0
var time = 0.0
var shoot_timer = 2.0
var fire_min = 2.0
var fire_max = 3.5
var fire_rate = 1.0
var laser_texture: Texture2D = null
var laser_scale = 0.45
var laser_speed = 300.0

@onready var sprite = $Sprite2D
@onready var hitbox = $CollisionShape2D


func _ready():
	add_to_group("enemies")
	collision_layer = 2
	collision_mask = 1
	shoot_timer = randf_range(1.0, 3.0)


func setup(data):
	speed = data.speed
	hp = data.hp
	sway = data.sway
	can_shoot = data.get("shoot", true)
	aims_at_player = data.aim
	fire_min = data.fire_min
	fire_max = data.fire_max
	fire_rate = data.fire_rate
	laser_scale = data.laser_scale
	laser_speed = data.laser_speed
	laser_texture = load(data.laser)

	start_x = clamp(position.x, -400, 450)
	scale = Vector2.ONE * data.scale

	sprite.position = Vector2.ZERO
	sprite.scale = Vector2.ONE
	sprite.flip_v = data.flip_v
	hitbox.scale = Vector2.ONE
	sprite.texture = load(data.sprite)
	GameState.fit_hitbox(sprite, hitbox)


func _physics_process(delta):
	time += delta
	position.x = start_x + sin(time * 2.0) * sway
	position.y += speed * delta

	if position.y > BOTTOM_EDGE:
		position.y = RESPAWN_Y

	if can_shoot and position.y > FIRST_VISIBLE_Y:
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot()
			shoot_timer = randf_range(fire_min, fire_max) / fire_rate

	check_contact_damage()


func check_contact_damage():
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(1)


func muzzle_point() -> Vector2:
	return hitbox.position + Vector2(0, hitbox.shape.size.y / 2.0)


func aim_direction(from_position: Vector2) -> Vector2:
	if not aims_at_player:
		return Vector2.DOWN
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return Vector2.DOWN
	var dir = (player.center_position() - from_position).normalized()
	# Never shoot sideways or backwards.
	if dir.y < 0.5:
		return Vector2.DOWN
	return dir


func shoot():
	var from_position = to_global(muzzle_point())
	fire_laser(from_position, aim_direction(from_position))


func fire_laser(from_position: Vector2, direction: Vector2):
	var laser = LASER.instantiate()
 
	laser.from_player = false
	laser.direction = direction
	laser.speed = laser_speed
	laser.texture = laser_texture
	laser.texture_scale = laser_scale
	get_parent().add_child(laser)
	laser.global_position = from_position


func take_damage(amount):
	if hp <= 0:
		return
	hp -= amount
	if hp <= 0:
		died.emit()
		queue_free()
	else:
		$Sprite2D.modulate = Color.RED
		create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.15)
