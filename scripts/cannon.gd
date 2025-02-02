extends Area2D

const CANNON_BALL = preload("res://scenes/cannon_ball.tscn")

@onready var area_hit: Area2D = $AreaHit
@onready var timer: Timer = $Timer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: CharacterBody2D = null

func _ready() -> void:
	timer.wait_time = 3.0  # Fire every 3 seconds
	timer.autostart = false  # Start only when player is nearby
	timer.one_shot = false  # Ensure it loops

	# Ensure the timeout signal is connected
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

	timer.start()  # Ensure timer starts

func _on_area_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		if timer.is_stopped():
			timer.start()  # Ensure the timer starts when player enters

func shoot_cannonball(target_position: Vector2) -> void:
	sprite.play("Shooting")

	var cannonball = CANNON_BALL.instantiate()
	get_parent().add_child(cannonball)

	cannonball.global_position = global_position  

	var direction = (target_position - global_position).normalized()
	if cannonball.has_method("set_direction"):
		cannonball.set_direction(direction)

func _on_timer_timeout() -> void:
	print("Timer timeout triggered")  # Debugging
	if player:
		shoot_cannonball(player.global_position)  # Shoot at player's latest position
	else:
		timer.stop()  # Stop firing if player is gone
