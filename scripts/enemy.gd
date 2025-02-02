extends Area2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
var velocity = Vector2.ZERO
var gravity_enabled = true  # Whether gravity is applied
@export var speed: float = 100.0  # Movement speed
var direction: int = 1
@onready var tilemaplayer: TileMapLayer = get_parent().get_node("TileMapLayer")
@export var left = 120
@export var right = 340

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
	elif position.x <= left:
		$AnimatedSprite2D.play("walking")
		position.x = left  # Prevent overshooting
		direction = 1  # Move right

	# Apply velocity for vertical movement
	position += Vector2(0, velocity.y * delta)

func take_damage(damage):
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
