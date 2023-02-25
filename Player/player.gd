extends CharacterBody2D

@export var walkSpeed : float
@export var maxFallSpeed : float
@export var jumpSpeed : float
@export var jumpBufferMSec : int
@export var coyoteBufferMSec : int
@export var maxAirJumps : int

var lastJumpPressed : int
var lastTimeonGround : int
var availableAirJumps := 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	GetInput(delta)
	
	# Gravity and cap fall speedw
	velocity.y += gravity * delta
	if velocity.y > maxFallSpeed:
		velocity.y = maxFallSpeed
	
	move_and_slide()
	
func GetInput(delta):
	velocity.x = 0
	
	# Reset Jumps when on floor
	if is_on_floor():
		lastTimeonGround = Time.get_ticks_msec()
		availableAirJumps = maxAirJumps
		
	# Store the last time the Jump button was pressed
	if Input.is_action_just_pressed("Jump"):
		lastJumpPressed = Time.get_ticks_msec()
	
	# Jump on ground if pressed within buffer and or coyote buffer
	if Time.get_ticks_msec() - lastJumpPressed <= jumpBufferMSec:
		if Time.get_ticks_msec() - lastTimeonGround <= coyoteBufferMSec:
			velocity.y = jumpSpeed
			lastJumpPressed = 0
			lastTimeonGround = 0
		elif availableAirJumps > 0:
			velocity.y = jumpSpeed
			availableAirJumps -= 1
			lastJumpPressed = 0
	
	# Slow acceleration if jump is released
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y /= 3
	
	# Horizontal movement
	if Input.is_action_pressed("Left"):
		velocity.x -= walkSpeed
	if Input.is_action_pressed("Right"):
		velocity.x += walkSpeed
