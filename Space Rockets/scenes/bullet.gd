extends Area2D

@export var speed = 600.0
@export var from_player = true
@export var damage = 1
# The way the sprite and collision shape point inside the scene.
@export var base_direction = Vector2.UP

var direction = Vector2.ZERO
var texture: Texture2D = null
var texture_scale = 0.0
var hit = false


func _ready():
	
	collision_layer = 4 if from_player else 8
	collision_mask = 2 if from_player else 1
	
	if direction == Vector2.ZERO:
		direction = base_direction
	rotation = direction.angle() - base_direction.angle()
	
	if texture !=null:
		$Sprite2D.texture = texture
	if texture_scale > 0.0:
		$Sprite2D.scale = Vector2.ONE * texture_scale
		
	if from_player:
		area_entered.connect(_on_hit)
	else:
		body_entered.connect(_on_hit)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)		

func _physics_process(delta):
	position += direction * speed * delta


func _on_hit(other: Node) -> void:
	if hit:
		return

	var target_group = "enemies" if from_player else "player"
	if not other.is_in_group(target_group):
		return
	if not other.has_method("take_damage"):
		return

	hit = true
	other.take_damage(damage)
	queue_free()
