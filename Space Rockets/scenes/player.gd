extends CharacterBody2D

signal health_changed(new_health)
signal died

const SPEED = 300.0
const FIRE_RATE = 0.25
const OVERDRIVE_FIRE_BOOST = 2.0
const OVERDRIVE_TINT = Color(0.6, 1.0, 1.0)
const MAX_HEALTH = 3
const INVINCIBLE_SECONDS = 1.0
const SHIP_BOTTOM_LIMIT = 525.0
const BULLET = preload("res://Space Rockets/scenes/bullet.tscn")

var health = MAX_HEALTH
var invincible_time = 0.0
var overdrive_time = 0.0
var cooldown = 0.0
var ship
var laser_texture: Texture2D = null
var sprite_start_position = Vector2.ZERO

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var hitbox = $CollisionShape2D


func _ready():
	add_to_group("player")
	collision_layer = 1
	collision_mask = 0
	
	sprite_start_position = sprite.position
	
	set_ship(GameState.current_ship())
	
func set_ship(new_ship) -> void:
	ship = new_ship
	sprite.texture = load(ship.sprite)
	sprite.scale = Vector2.ONE * ship.scale
	sprite.position = sprite_start_position
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
		cooldown = FIRE_RATE / current_fire_boost()

	invincible_time = maxf(0.0, invincible_time - delta)
	overdrive_time = maxf(0.0, overdrive_time - delta)
	update_look()


func update_look() -> void:
	var color = OVERDRIVE_TINT if overdrive_time > 0.0 else Color.WHITE
	color.a = 0.4 if invincible_time > 0 else 1.0
	sprite.modulate = color
	
func current_fire_boost() -> float:
	return OVERDRIVE_FIRE_BOOST if overdrive_time > 0.0 else 1.0
	

	
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

func heal(amount: int) -> void:
	if health <= 0:
		return
		
	health = mini(MAX_HEALTH, health + amount)
	health_changed.emit(health)
	
func start_overdrive(seconds: float) -> void:
	overdrive_time = maxf(overdrive_time, seconds)		
