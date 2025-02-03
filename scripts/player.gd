extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const DOUBLE_JUMP = -200
var is_hitting = false
var hammer_offset = 25     # Right offset
var left_hammer_offset = 30     # Left offset (20 + 20)
@onready var double_jump: Timer = $DoubleJump

var jumped_once = false  # Track if the first jump has occurred

func _ready() -> void:
	$AnimatedSprite2D.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	$Hammer.area_entered.connect(_on_hammer_area_entered)  # Connect hammer collision signal
	$Hammer.monitoring = true
	$Hammer.get_node("CollisionShape2D").disabled = true  # Disable collision shape initially

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if not is_hitting:
		# First jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			jumped_once = true
			double_jump.start()  # Start the double jump timer

		# Second jump (double jump)
		if Input.is_action_just_pressed("jump") and jumped_once and not is_on_floor():
			jumped_once = false
			velocity.y = DOUBLE_JUMP
			double_jump.stop()  # Stop the double jump timer since it was used

	# Handle movement and animation
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		if not is_hitting:
			$AnimatedSprite2D.play("Run")

		# Flip the sprite when moving left
		$AnimatedSprite2D.flip_h = direction < 0  

		# Stick Hammer (Area2D) to the correct side
		if $AnimatedSprite2D.flip_h:
			$Hammer.position.x = -left_hammer_offset
		else:
			$Hammer.position.x = hammer_offset
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle hit action
	if Input.is_action_just_pressed("hit_enemy") and not is_hitting:
		is_hitting = true
		$AnimatedSprite2D.play("Hit")
		# Enable the hammer's collision shape during the "Hit" animation
		$Hammer.get_node("CollisionShape2D").disabled = false

	# Handle idle animation
	if is_on_floor() and velocity.x == 0 and not is_hitting:
		$AnimatedSprite2D.play("Idle")

	move_and_slide()

# Reset is_hitting when animation finishes
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "Hit":
		is_hitting = false
		print("Hit animation finished, is_hitting set to false.")
		# Disable the hammer's collision shape after the "Hit" animation ends
		$Hammer.get_node("CollisionShape2D").disabled = true

# Hammer collision handling
func _on_hammer_area_entered(body: Area2D) -> void:
	var animation = $AnimatedSprite2D.animation
	if animation == "Hit" and $AnimatedSprite2D.is_playing():
		print("Hammer hit in 'Run' animation")
		# Check if the body is an enemy (you can adjust the condition as needed)
		if body.is_in_group("enemies"):  # Ensure the enemy is in the "enemies" group
			# Call the take_damage method on the enemy (assuming it exists)
			if body.has_method("take_damage"):
				body.take_damage(10)  # Adjust damage as necessary
		else:
			print("Hit something else")
		
