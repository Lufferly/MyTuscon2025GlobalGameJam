class_name Player extends CharacterBody2D

# This player uses a finite state machine
# The possible states the player can be
enum States {IDLE, WALKING, RUNNING, DASHING}
# Represents the player states in strings, for debugging
var STATES_STRING_REPRESENTATION : Array = ["IDLE", "WALKING", "RUNNING", "DASHING"]
# The players current state
var state : States = States.IDLE

@export var ACCELERATION : float = 500.0
@export var DECELERATION : float = 600.0
@export var MAX_WALK_SPEED : float = 255.0
@export var MAX_RUN_SPEED : float = 500.0
@export var BASE_TURN_RADIUS: float = PI * 2.5# Turn radius per second

# When we dash, we move quickly but lose a lot of turn radius
# How long we dash for
@export var DASH_DURATION : float = 0.5 # Seconds
# Our Dash speed
@export var DASH_SPEED : float = 750.0
# Our turn radius while dashing
@export var DASH_TURN_RADIUS: float = PI # Turn radius per second

# Whether or not the player is walking
var b_player_pressing_move : bool = false
# The position the player is moving to, only relevant if the player is pressing a move key
var point_to_move_to : Vector2 = Vector2.ZERO
# our current speed, should always be positive or zero
var current_speed : float = 0.0
# our current direction
var current_direction : Vector2 = Vector2(0, 1)

# How many bubbles (ammo) we can have stored
@export var max_bubbles_stored : int = 2
# How many bubbles (ammo) we currently have stored
var bubbles_stored : int = 0
# The projectile we fire using bubbles
@export var bubble_projectile = load("res://scenes/bubble_projectile.tscn")
# The cooldown between the players attacks (in seconds)
@export var attack_cooldown : float = 2 # Seconds


func _ready():
	scale = Vector2(0.7, 0.7)
	
	# Set up our attack timer
	$AttackTimer.one_shot = true # Stay stopped after finished, we will manually restart it
	# Set up our Dash Timer
	$DashTimer.one_shot = true
	$DashTimer.timeout.connect(on_dash_timer_timeout)
	

# Calculate our speed
func calculate_speed(current_speed: float, delta: float, b_player_pressing_move: bool, 
	point_to_move_to: Vector2) -> float:
	var new_speed : float
	
	# First check if we are approaching the point we want to move to
	#	dont stop if we are DASHING
	if position.distance_to(point_to_move_to) <= 10 and (state != States.DASHING):
		new_speed = 0	# Dont move
	# If the player is walking
	elif state == States.WALKING:
		# If we are over our MAX_WALK_SPEED, decelerate down to our MAX_WALK_SPEED
		if current_speed > MAX_WALK_SPEED:
			new_speed = current_speed - (DECELERATION * delta)
			# Clamp so we dont decelerate too much
			new_speed = clamp(new_speed, MAX_WALK_SPEED, new_speed)
		# Otherwise accelerate up to our max walk speed
		else:
			new_speed = current_speed + (ACCELERATION * delta)
			new_speed = clamp(new_speed, 0, MAX_WALK_SPEED)
	# If the player is running
	elif state == States.RUNNING:
		if current_speed > MAX_RUN_SPEED:
			# decelerate down to our MAX_RUN_SPEED
			new_speed = current_speed - (DECELERATION * delta)
			new_speed = clamp(new_speed, MAX_RUN_SPEED, new_speed)
		else:
			new_speed = current_speed + (ACCELERATION * delta)
			new_speed = clamp(new_speed, 0, MAX_RUN_SPEED)
	# If the player is dashing
	elif state == States.DASHING:
		new_speed = DASH_SPEED
	else:	# If we are idle, decelerate
		new_speed = current_speed - (DECELERATION * delta)
		new_speed = clamp(new_speed, 0, current_speed)
	
	
	return new_speed
	

# Calculate our direction
func calculate_direction(current_direction: Vector2, current_position: Vector2,
	target_position: Vector2, delta: float) -> Vector2:
	
	
	var current_turn_radius : float
	# If we are dashing, we use a lower turn radius
	if state == States.DASHING:
		current_turn_radius = DASH_TURN_RADIUS
	# otherwise we use our regular turn radius
	else:
		current_turn_radius = BASE_TURN_RADIUS
	
	# Otherwise calculate our direction
	# The direction that we want to go towards
	var target_direction: Vector2 = current_position.direction_to(target_position)
	# The new direction that we will have
	var new_direction: Vector2
	# The max turn radius this process (tick?)
	var max_BASE_TURN_RADIUS: float = current_turn_radius * delta
	# Apply the turn radius, so that we do not snap to our target direction
	if current_direction.angle_to(target_direction) > max_BASE_TURN_RADIUS:
		new_direction = current_direction.rotated(max_BASE_TURN_RADIUS)
	elif current_direction.angle_to(target_direction) < -max_BASE_TURN_RADIUS:
		new_direction = current_direction.rotated(-max_BASE_TURN_RADIUS)
	else:
		new_direction = target_direction

	return new_direction


# Calculate our velocity
func calculate_velocity(current_pos: Vector2, current_direction: Vector2, current_speed: float, 
	current_velocity: Vector2, target_position: Vector2) -> Vector2:
	
	# We dont need to handle delta here because move_and_slide will handle it for us
	var new_velocity = (current_direction * current_speed)
	
	return new_velocity

# Handle everything that has to do with the players movement, including input
func handle_movement(delta):
	# Handle movement input
	if state == States.DASHING: # If we are currently dashing, block other movement input
		pass
	elif Input.is_action_pressed("dash") and bubbles_stored > 0: # If we are dashing from not dashing and we have enough bubbles
		# While dashing, we move very quickly but lose a lot of turn radius
		# Change the state to dashing
		state = States.DASHING
		$DashTimer.start(DASH_DURATION) # How long we will dash for, when this timesout we get set back to idle
		# Use bubble ammo, use 1 bubble
		modify_bubble_count(-1) 
	elif Input.is_action_pressed("run"):
		# Change the state
		state = States.RUNNING
	elif Input.is_action_pressed("walk"):
		# Change the state
		state = States.WALKING
	else:
		state = States.IDLE
		
	# Find our target position (the mouse)
	if state == States.WALKING or state == States.RUNNING or state == States.DASHING:
		point_to_move_to = get_global_mouse_position()
		
	# Move to our target position if we can move right now
	current_direction = calculate_direction(current_direction, position, point_to_move_to, delta)
	current_speed = calculate_speed(current_speed, delta, b_player_pressing_move, point_to_move_to)
	velocity = calculate_velocity(position, current_direction, current_speed, velocity, point_to_move_to)
	
	# Change our visual and actual rotation
	rotation = current_direction.angle()

		
	move_and_slide()

# When the DashTimer finishes, we stop dashing and subtract some speed
func on_dash_timer_timeout():
	state = States.IDLE
	current_speed = MAX_RUN_SPEED

func fire_bullet():
	var this_bullet = bubble_projectile.instantiate()
	this_bullet.position = position
	this_bullet.rotation = rotation # Make it follow our rotation
	get_parent().add_child(this_bullet)
	# Start the attack cooldown again
	$AttackTimer.start(attack_cooldown)

func handle_attacking(delta):
	if Input.is_action_pressed("fire_bubble"):
		# If our attack is not on cooldown and we have enough ammo
		if $AttackTimer.is_stopped() and bubbles_stored > 0:
			fire_bullet()
			modify_bubble_count(-1) # Remove a bubble

func _physics_process(delta):

	# Handle movement, including its input
	handle_movement(delta)
	
	# Handle attacking
	handle_attacking(delta)

# Modify how many bubbles we have, adding or removing
# 	Change is how many bubbles we add (it will subtract if its negative)
func modify_bubble_count(change : int):
	bubbles_stored = clamp(bubbles_stored + change, 0, max_bubbles_stored)

# What happens when something (that we care about fuck you masks)
#	enters our bubble collision detection (probably a bubble)
func _on_bubble_area_area_entered(area):
	# Store a bubble if we touch a bubble
	if area.get_parent() is Bubble:
		modify_bubble_count(1) # Add a bubble
