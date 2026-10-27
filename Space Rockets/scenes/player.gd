extends CharacterBody2D

signal health_changed(new_health)
signal died

const SPEED = 300.0
const FIRE_RATE = 0.25
const MAX_HEALTH = 3
const INVINCIBLE_SECONDS = 1.0
const SHIP_BOTTOM_LIMIT = 525.0
const BULLET = preload("res://Space Rockets/scenes/bullet.tscn")

var health = MAX_HEALTH
var invincible_time = 0.0
var cooldown = 0.0
var ship
var laser_texture: Texture2D = null

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var hitbox = $CollisionShape2D


func _ready():
	add_to_group("player")
	collision_layer = 1
	collision_mask = 0

	ship = GameState.current_ship()
	sprite.texture = load(ship.sprite)
	sprite.scale = Vector2.ONE * ship.scale
	laser_texture = load(ship.laser)
	GameState.fit_hitbox(sprite, hitbox)

 
	var ship_bottom = hitbox.position.y + hitbox.shape.size.y * 0.625
	var lift = maxf(0.0, ship_bottom - SHIP_BOTTOM_LIMIT)
	sprite.position.y -= lift
	hitbox.position.y -= lift

	muzzle.position = Vector2(hitbox.position.x, hitbox.position.y - hitbox.shape.size.y * 0.6)


func _physics_process(delta):
	velocity.x = Input.get_axis("left", "right") * SPEED
	move_and_slide()
	position.x = clamp(position.x, -500, 550)

	cooldown -= delta
	if Input.is_action_pressed("shoot") and cooldown <= 0:
		shoot()
		cooldown = FIRE_RATE

 
	invincible_time = maxf(0.0, invincible_time - delta)
	sprite.modulate.a = 0.4 if invincible_time > 0 else 1.0


func center_position() -> Vector2:
	return hitbox.global_position


func shoot():
	for x in ship.guns:
		var bullet = BULLET.instantiate()
		
		bullet.texture = laser_texture
		bullet.texture_scale = ship.laser_scale
		bullet.speed = ship.laser_speed
		get_parent().add_child(bullet)
		bullet.global_position = muzzle.global_position + Vector2(x, 0)


func take_damage(amount: int) -> void:
	if invincible_time > 0 or health <= 0:
		return

	health = maxi(0, health - amount)
	invincible_time = INVINCIBLE_SECONDS
	health_changed.emit(health)

	if health <= 0:
		died.emit()
		queue_free()
