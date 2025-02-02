extends Area2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
var velocity = Vector2.ZERO
var gravity_enabled = true  # Whether gravity is applied
@export var speed: float = 100.0  # Movement speed
var direction: int = 1
@onready var tilemaplayer: TileMapLayer = get_parent().get_node("TileMapLayer")
@export var left = 120
@export var right = 340
var hp = 30
const BOMB = preload("res://scenes/bomb.tscn")
@onready var bomb_timer: Timer = $BombTimer
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gravity_enabled:
		# Apply gravity to velocity in the Y-axis
		velocity.y += gravity * delta
	
	# Check for ground collision using RayCast2D
	var is_on_floor = ray_cast_2d.is_colliding()
	
	# Stop downward velocity when on the ground
	if is_on_floor and velocity.y > 0:
		velocity.y = 0  # Prevent falling through the ground
		
	
	position.x += speed * direction * delta
	
	# Reverse direction at boundaries
	if position.x >= right:
		$AnimatedSprite2D.play("walking")
		position.x = right  # Prevent overshooting
		direction = -1  # Move left
		$AnimatedSprite2D.flip_h = true
	elif position.x <= left:
		$AnimatedSprite2D.play("walking")
		position.x = left  # Prevent overshooting
		direction = 1  # Move right
		$AnimatedSprite2D.flip_h = false

	# Apply velocity for vertical movement
	position += Vector2(0, velocity.y * delta)

func take_damage(damage):
	hp -= 10
	if hp == 0:
		direction = 0
		$AnimatedSprite2D.play("dead")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body 
		if bomb_timer.is_stopped():
			bomb_timer.start()


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "dead":  # Ensure only triggers for "dead" animation
		print("freeing")
		queue_free()  # Remove enemy from the scene
		

func throw_bomb(target_position):
	var bomb = BOMB.instantiate()
	var anim_sprite = bomb.get_node("AnimatedSprite2D")  
	if anim_sprite:
		anim_sprite.play("BombOn")
	get_parent().add_child(bomb)

	bomb.global_position = global_position  

	var direction = (target_position - global_position).normalized()
	if bomb.has_method("set_direction"):
		bomb.set_direction(direction)
		

func _on_bomb_timer_timeout() -> void:
	if player:
		throw_bomb(player.global_position)  # Throw at player's last known position
	else:
		bomb_timer.stop()  # Stop throwing if player is gone
