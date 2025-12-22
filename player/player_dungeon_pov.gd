extends CharacterBody3D


const SPEED = 5.0
const TURN_ANGLE := PI / 2

@export var turn_time := 0.2

var turning := false
var facing := 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	rotate_player()
	var direction := get_movement_direction()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
func get_movement_direction() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input_vector := Vector3(input_dir.x, 0, input_dir.y).normalized()
	return transform.basis * input_vector
	
func rotate_player() -> void:
	if turning:
		return
	
	var direction := 0
	if Input.is_action_just_pressed("turn_left"):
		direction = 1
		rotation_tween(direction)
		print(rotation.y)
	elif Input.is_action_just_pressed("turn_right"):
		direction = -1
		rotation_tween(direction)
		print(rotation.y)
	else:
		return
		
func rotation_tween(direction: int) -> void:
	turning = true
	facing = (facing + direction) % 4
	var target_direction := facing * TURN_ANGLE
	target_direction = wrapf(target_direction, -PI, PI)
	
	var start := rotation.y
	var delta := angle_difference(start, target_direction)
	var tween_target := start + delta
	
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", tween_target , turn_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(
		func():
			rotation.y = target_direction
			turning = false
	)
