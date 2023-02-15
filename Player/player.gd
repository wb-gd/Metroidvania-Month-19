extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

var _lastJumpPressed : float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	GetInput(delta)
	
	velocity.y += _gravity * delta
	move_and_slide()
	
func GetInput(delta):
	velocity.x = 0
	
	# Store the last time the Jump button was pressed
	if Input.is_action_just_pressed("Jump"):
		_lastJumpPressed = Time.get_ticks_msec()
		velocity.y += JUMP_VELOCITY
	
	# Horizontal movement
	if Input.is_action_pressed("Left"):
		velocity.x -= SPEED
	if Input.is_action_pressed("Right"):
		velocity.x += SPEED
