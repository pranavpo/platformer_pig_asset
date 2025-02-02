extends RigidBody2D

@export var speed: float = 200.0  # Adjust speed
@export var gravity: float = 0.02  # Simulate real gravity

var direction: Vector2 = Vector2.ZERO

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bomb_timer: Timer = $BombOffTimer  # Ensure there's a Timer node
@export var explosion_time: float = 1.0  # Time before explosion
var is_exploding = false  # Flag to check if the bomb is in the explosion state

func _ready():
	freeze = false  # Ensure physics is active

func _physics_process(delta):
	# Apply gravity manually
	linear_velocity.y += gravity * delta

func set_direction(dir: Vector2):
	direction = dir
	linear_velocity = direction * speed  # Apply velocity

	# Start the timer for explosion
	bomb_timer.start(explosion_time)

func _on_bomb_off_timer_timeout() -> void:
	if anim_sprite and not is_exploding:
		is_exploding = true
		linear_velocity = Vector2(0,0);
		anim_sprite.play("Boom")  # Play explosion animation
		# Set the animation to stop after it finishes (ensure it is set to not loop in the editor)

func _on_animated_sprite_2d_animation_finished() -> void:
	print("reached bomb queue free")
	if anim_sprite.animation == "Boom" and is_exploding:  # Ensure correct animation before freeing
		anim_sprite.stop()  # Stop animation
		queue_free()  # Remove bomb from scene
		is_exploding = false  # Reset explosion flag
