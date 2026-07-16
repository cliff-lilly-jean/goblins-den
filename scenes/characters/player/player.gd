class_name Player extends CharacterBody3D

const MAX_ANGLE_LOOK_UP: float = deg_to_rad(10)
const MAX_ANGLE_LOOK_DOWN: float = deg_to_rad(-30)

@export var mouse_sensitivity: float
@export var joystick_sensitiity: float
@export var camera_distance: float
@export var walk_speed: float
@export var run_speed: float
@export var acceleration: float
@export var jump_force: float
@export var gravity: float

@onready var spring_arm: SpringArm3D = %SpringArm3D
@onready var input_dir : Vector2

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_arm.spring_length = camera_distance

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity) ## Used to rotate the viewing angle horizontally
		
		## Rotate the Spring Arm over the x axis and clamp the values so that they dont rotate around the player
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		spring_arm.rotation.x = clampf(spring_arm.rotation.x, MAX_ANGLE_LOOK_DOWN, MAX_ANGLE_LOOK_UP)
		

func _process(delta: float) -> void:
	
	## Get the input direction that is being pressed
	input_dir = Input.get_vector("strafe_left","strafe_right", "backward","forward").normalized()
	
	joystick_rotation(delta)
	
	## Toggle the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	
	move(delta)
	jump()
	process_gravity()
	
	move_and_slide()

func joystick_rotation(delta: float) -> void:
	
	var right_stick_vector = Input.get_vector("look_left","look_right","look_down","look_up").normalized()
	
	## Rotate the joystick around the y axis by a certain numbber and delta
	rotate_y(-right_stick_vector.x * joystick_sensitiity * delta) ## Used to rotate the viewing angle horizontally
		
	## Rotate the Spring Arm/Camera over the x axis and clamp the values so that they dont rotate around the player
	spring_arm.rotation.x -= -right_stick_vector.y * joystick_sensitiity * delta
	spring_arm.rotation.x = clampf(spring_arm.rotation.x, MAX_ANGLE_LOOK_DOWN, MAX_ANGLE_LOOK_UP)

func move(delta: float) -> void:
	var direction: Vector3 = Vector3(input_dir.x, 0, input_dir.y)
	
	var speed = run_speed if Input.is_action_pressed("run") else walk_speed
	
	var desired_velocity = transform.basis * direction * speed
	
	if direction == Vector3.ZERO:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)	
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)	
	velocity.x = move_toward(velocity.x, desired_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, desired_velocity.z, acceleration * delta)

func jump():
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
		
func process_gravity() -> void: 
	if not is_on_floor():
		velocity.y -= gravity
