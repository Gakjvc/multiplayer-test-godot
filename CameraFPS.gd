
extends Node3D

@export var mouse_sensitivity: float = 0.002
@export var min_pitch: float = -89.0
@export var max_pitch: float = 89.0

var camera_pitch: float = 0.0
var mouse_visible = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotação vertical da câmera
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clampf(
			camera_pitch,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch)
		)

		rotation.x = camera_pitch

		# Rotação horizontal do personagem
		get_parent().rotate_y(
			-event.relative.x * mouse_sensitivity
		)

	if event.is_action_pressed("ui_cancel"):
		if !mouse_visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			mouse_visible = true
		elif mouse_visible:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			mouse_visible = false
