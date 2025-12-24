extends CharacterBody3D

@export var step_size := 1.0
@export var step_time := 0.12
@export var turn_time := 0.2

const TURN_ANGLE := PI / 2

var moving := false
var queued_dir := Vector3.ZERO
var move_tween: Tween
var turning := false
var facing := 0

func _physics_process(delta: float) -> void:
	if not moving:
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.y = 0.0
		move_and_slide()
	rotate_player()
		
	var dir := get_grid_input_dir()
	if dir != Vector3.ZERO:
		try_step(dir)
		
func get_grid_input_dir() -> Vector3:
	var x := int(Input.is_action_just_pressed("move_right")) - int(Input.is_action_just_pressed("move_left"))
	var z := int(Input.is_action_just_pressed("move_backward")) - int(Input.is_action_just_pressed("move_forward"))

	if x == 0 and z == 0:
		return Vector3.ZERO
		
	if abs(x) > abs(z):
		z = 0
	else:
		x = 0

	var local := Vector3(x, 0, z).normalized()
	return (transform.basis * local).normalized()
	
func try_step(dir: Vector3) -> void:
	if moving:
		queued_dir = dir
		return
		
	dir.y = 0.0
	if dir == Vector3.ZERO:
		return
		
	var start := global_position
	var target := start + dir * step_size
	target.y = start.y
	
	var motion := (target - start)
	if test_move(global_transform, motion):
		return
		
	start_step_to(target)
	
func start_step_to(target: Vector3) -> void:
	moving = true
	queued_dir = Vector3.ZERO
	
	if move_tween and move_tween.is_valid():
		move_tween.kill()
		
	var start := global_position
	target.y = start.y
	
	move_tween = create_tween()
	move_tween.tween_property(self, "global_position", target, step_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	move_tween.finished.connect(
		func():
			moving = false
			if queued_dir != Vector3.ZERO:
				var next := queued_dir
				queued_dir = Vector3.ZERO
				try_step(next)
	)
	
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
