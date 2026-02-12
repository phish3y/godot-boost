extends RigidBody3D

## How much vertical force to apply when moving
@export_range(750, 1500) var thrust: float = 1000.0

## How much torque to apply when turning
@export var torque_thrust: float = 100

@onready var win_audio: AudioStreamPlayer = $WinAudio
@onready var lose_audio: AudioStreamPlayer = $LoseAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var booster_particles_left: GPUParticles3D = $BoosterParticlesLeft
@onready var booster_particles_right: GPUParticles3D = $BoosterParticlesRight

var is_transitioning: bool = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"): # "boost" defined in input map
		booster_particles.emitting = true
		if not rocket_audio.playing:
			rocket_audio.play()
		apply_central_force(basis.y  * delta * thrust)
	else:
		booster_particles.emitting = false
		rocket_audio.stop()
	
	if Input.is_action_pressed("rotate_left"): # same
		booster_particles_left.emitting = true
		apply_torque(Vector3(0.0, 0.0, torque_thrust) * delta)
	else:
		booster_particles_left.emitting = false
	if Input.is_action_pressed("rotate_right"): # same
		booster_particles_right.emitting = true
		apply_torque(Vector3(0.0, 0.0, -torque_thrust) * delta)
	else:
		booster_particles_right.emitting = false
		
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
	
	win_audio.play()
	
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
	
func crash_sequence() -> void:
	is_transitioning = true
	set_process(false)
	
	lose_audio.play()
	
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
