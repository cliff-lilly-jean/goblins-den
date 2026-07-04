class_name Player extends CharacterBody3D

const MAX_ANGLE_LOOK_UP: float = deg_to_rad(10)
const MAX_ANGLE_LOOK_DOWN: float = deg_to_rad(-30)

@export var mouse_sensitivity: float
@export var joystick_sensitiity: float
@export var camera_distance: float

@onready var spring_arm: SpringArm3D = %SpringArm3D

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
	
	joystick_rotation(delta)


func joystick_rotation(delta: float) -> void:
	
	## Get the joystick input vector
	var right_stick_vector = Input.get_vector("look_left","look_right","look_down","look_up").normalized()
	
	## Rotate the joystick around the y axis by a certain numbber and delta
	rotate_y(-right_stick_vector.x * joystick_sensitiity * delta) ## Used to rotate the viewing angle horizontally
		
	## Rotate the Spring Arm/Camera over the x axis and clamp the values so that they dont rotate around the player
	spring_arm.rotation.x -= -right_stick_vector.y * joystick_sensitiity * delta
	spring_arm.rotation.x = clampf(spring_arm.rotation.x, MAX_ANGLE_LOOK_DOWN, MAX_ANGLE_LOOK_UP)
