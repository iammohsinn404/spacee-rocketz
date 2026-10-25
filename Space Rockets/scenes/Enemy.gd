extends Area2D

signal died

const BULLET = preload("res://Space Rockets/scenes/bullet.tscn")

@export var speed = 100
@export var can_shoot = true
var hp = 1
var sway = 0.0
var start_x = 0.0
var time = 0.0
var shoot_timer = 2.0

func _ready():
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)
	shoot_timer = randf_range(1.0, 3.0)
	

func setup(data):
	speed = data.speed
	hp = data.hp
	can_shoot = data.shoot
	sway = data.shoot
	start_x = clamp(position.x, -400, 450)
	scale = Vector2.ONE * data.scale 
	
	var tex = load(data.sprite)
	$Sprite2D.texture = tex
	var shape = CircleShape2D.new()
	shape.radius = tex.get_width() * 0.3
	$CollisionShape2D.shape = shape

func _physics_process(delta):
	time += delta
	position.x = start_x + start_x + sin(time * 2.0) * sway
	position.y += -speed * delta
	
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
	
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(1)
		take_damage(1)
