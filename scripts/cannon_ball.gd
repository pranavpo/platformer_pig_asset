extends RigidBody2D

@export var speed: float = 400.0  # Adjust speed
@export var gravity: float = 0.02  # Simulate real gravity

var direction: Vector2 = Vector2.ZERO

func _ready():
	freeze = false  # Ensure physics is active

func _physics_process(delta):
	# Apply gravity manually
	linear_velocity.y += gravity * delta

func set_direction(dir: Vector2):
	direction = dir
	linear_velocity = direction * speed  # Apply velocity
