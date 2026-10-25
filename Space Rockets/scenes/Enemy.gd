extends Area2D

signal died

const BULLET = preload("res://Space Rockets/scenes/bullet.tscn")

var speed = 100
var can_shoot = true
var hp = 1
var sway = 0.0
var start_x = 0.0
var time = 0.0
var shoot_timer = 2.0
@onready var sprite = $Sprite2D
@onready var hitbox = $CollisionShape2D

func _ready():
	add_to_group("enemies")
	collision_layer = 2
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	shoot_timer = randf_range(1.0, 3.0)
	

func setup(data):
	speed = data.speed
	hp = data.hp
	sway = data.sway
	can_shoot = data.shoot
	start_x = clamp(position.x, -400, 450)
	scale = Vector2.ONE * data.scale 
	
	$Sprite2D.position = Vector2.ZERO
	$Sprite2D.scale = Vector2.ONE
	hitbox.scale = Vector2.ONE
	$Sprite2D.texture = load(data.sprite)
	sprite.flip_v = true
	GameState.fit_hitbox(sprite, hitbox)

func _physics_process(delta):
	time += delta
	position.x = start_x + sin(time * 2.0) * sway
	position.y += speed * delta
	
	if position.y > 560:
		position.y = -130
		
	if can_shoot:
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot()
			shoot_timer = randf_range(1.5, 3.0)
		

func shoot():
	var bullet = BULLET.instantiate()
	bullet.from_player = false
	bullet.direction = Vector2.DOWN
	bullet.speed = 300
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	
	
func take_damage(amount):
	if hp <= 0:
		return
	hp -= amount
	if hp <= 0:
		died.emit()
		queue_free()
	else:
		$Sprite2D.modulate = Color.RED
		create_tween().tween_property($Sprite2D, "modulate", Color.WHITE, 0.15)
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1)
