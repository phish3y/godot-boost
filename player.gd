extends RigidBody3D

## How much vertical force to apply when moving
@export_range(750, 1500) var thrust: float = 1000.0

## How much torque to apply when turning
@export var torque_thrust: float = 100

var is_transitioning: bool = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"): # "boost" defined in input map
		apply_central_force(basis.y  * delta * thrust)
	
	if Input.is_action_pressed("rotate_left"): # same
		apply_torque(Vector3(0.0, 0.0, torque_thrust) * delta)
	if Input.is_action_pressed("rotate_right"): # same
		apply_torque(Vector3(0.0, 0.0, -torque_thrust) * delta)

func _on_body_entered(body: Node) -> void:
	if is_transitioning:
		return
	
	if "goal" in body.get_groups() && body is LandingPad:
		complete_level(body.file_path)
		
	if "hazard" in body.get_groups():
		crash_sequence()

func complete_level(next_level_file: String) -> void:
	is_transitioning = true
	set_process(false)
	
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
	
func crash_sequence() -> void:
	is_transitioning = true
	set_process(false)
	
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().reload_current_scene)
