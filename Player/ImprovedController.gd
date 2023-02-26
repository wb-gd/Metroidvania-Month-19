extends KinematicBody2D

var _velocity : Vector2
var _rawMovement : Vector2
var _lastPosition : Vector2
var _input : InputThisFrame
var _lastJumpPressed : int
var _currentHorizontalSpeed : float
var _currentVerticalSpeed : float
var _isJumping : bool
var _isLanding : bool
var _isGrounded : bool

class InputThisFrame:
	var X : float
	var JumpDown : bool
	var JumpUp : bool

func _physics_process(delta):
	_velocity = (position - _lastPosition) / delta
	_lastPosition = position
	
	GetInput()

# Get the Input for the current frame
func GetInput():
	_input = InputThisFrame.new()
	_input.X = Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left")
	_input.JumpDown = Input.is_action_just_pressed("ui_up")
	_input.jumpUp = Input.is_action_just_released("ui_up")
	
	if (_input.JumpDown):
		_lastJumpPressed = Time.get_ticks_msec()
