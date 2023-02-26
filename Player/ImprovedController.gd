extends KinematicBody2D

export(float) var _acceleration
export(float) var _maxMoveSpeed
export(float) var _decceleration
export(float) var _apexBonus
export(float) var _fallClamp
export(float) var _minFallSpeed
export(float) var _maxFallSpeed
export(float) var _jumpHeight
export(float) var _jumpApexThreshold
export(float) var _earlyEndModifier
export(int) var _coyoteBuffer
export(int) var _jumpBuffer

var _velocity : Vector2
var _lastPosition : Vector2
var _input : InputThisFrame
var _lastJumpPressed : int
var _lastTimeGrounded : int
var _currentHorizontalSpeed : float
var _currentVerticalSpeed : float
var _apexPoint : float
var _fallSpeed : float
var _jumpingThisFrame : bool
var _isGrounded : bool
var _coyoteUsable : bool
var _endedJumpEarly := true

class InputThisFrame:
	var X : float
	var JumpDown : bool
	var JumpUp : bool

func _physics_process(delta):
	_currentHorizontalSpeed = _velocity.x
	_currentVerticalSpeed = _velocity.y
	
	GetInput()
	GroundCollisions()
	Walk(delta)
	Gravity(delta)
	JumpApex()
	Jump()
	
	_velocity = Vector2(_currentHorizontalSpeed, _currentVerticalSpeed)
	_velocity = move_and_slide(_velocity, Vector2.UP)

# Get the Input for the current frame
func GetInput():
	_input = InputThisFrame.new()
	_input.X = Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left")
	_input.JumpDown = Input.is_action_just_pressed("ui_up")
	_input.JumpUp = Input.is_action_just_released("ui_up")
	
	if (_input.JumpDown):
		_lastJumpPressed = Time.get_ticks_msec()

# Calculate Ground Collisions
func GroundCollisions():
	# Just left floor this frame
	if _isGrounded and !is_on_floor():
		_lastTimeGrounded = Time.get_ticks_msec()
		
	if !_isGrounded and is_on_floor():
		_coyoteUsable = true;
	
	_isGrounded = is_on_floor()

# Calculate Horizontal Movement
func Walk(delta):
	if _input.X != 0:
		# Set and clamp speed
		_currentHorizontalSpeed += _input.X * _acceleration * delta
		_currentHorizontalSpeed = clamp(_currentHorizontalSpeed, -_maxMoveSpeed, _maxMoveSpeed)
		
		# Apply apex bonus
		var bonus = sign(_input.X) * _apexBonus * _apexPoint
		_currentHorizontalSpeed += bonus * delta
	else:
		# Slow character
		_currentHorizontalSpeed = move_toward(_currentHorizontalSpeed, 0, _decceleration * delta)

# Calculate Gravity
func Gravity(delta):
	if _isGrounded:
		if _currentVerticalSpeed > 0:
			_currentVerticalSpeed = 0;
	else:
		# Add modifier if jump ended early
		var fallSpeed = _fallSpeed * _earlyEndModifier if _endedJumpEarly and _currentVerticalSpeed < 0 else _fallSpeed
		
		_currentVerticalSpeed += fallSpeed * delta
		if _currentVerticalSpeed > _fallClamp:
			_currentVerticalSpeed = _fallClamp

# Calculate Jump Apex
func JumpApex():
	if !_isGrounded:
		_apexPoint = inverse_lerp(_jumpApexThreshold, 0, abs(_velocity.y))
		_fallSpeed = lerp(_minFallSpeed, _maxFallSpeed, _apexPoint)
	else:
		_apexPoint = 0

# Calculate Jump
func Jump():
	var canUseCoyote = _coyoteUsable and !_isGrounded and _lastTimeGrounded + _coyoteBuffer > Time.get_ticks_msec()
	var jumpBuffered = _isGrounded and _lastJumpPressed + _jumpBuffer > Time.get_ticks_msec()
	if _input.JumpDown and canUseCoyote or jumpBuffered:
		_currentVerticalSpeed = _jumpHeight
		_endedJumpEarly = false
		_coyoteUsable = false
		_jumpingThisFrame = true
		_lastTimeGrounded = 0
		_lastJumpPressed = 0
	else:
		_jumpingThisFrame = false
		
	if !_isGrounded and _input.JumpUp and !_endedJumpEarly and _velocity.y < 0:
		_endedJumpEarly = true
		
	if is_on_ceiling():
		if _currentVerticalSpeed < 0:
			_currentVerticalSpeed = 0

# Helper
func move_toward(actual:float, to:float, delta:float):
	if(actual < to):
		actual += delta
		actual = min(actual, to)
		
	return actual
