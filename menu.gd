extends Control

@onready var network_manager = $"../../NetworkManager"
@onready var ip_input: LineEdit = $IPInput
@onready var status_label: Label = $StatusLabel


func _ready() -> void:
	$HostButton.pressed.connect(_on_host_pressed)
	$JoinButton.pressed.connect(_on_join_pressed)

	network_manager.status_changed.connect(_on_status_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = not visible


func _on_host_pressed() -> void:
	network_manager.host_game()


func _on_join_pressed() -> void:
	var ip = ip_input.text.strip_edges()

	if ip.is_empty():
		status_label.text = "Digite o IP do host."
		return

	network_manager.join_game(ip)


func _on_status_changed(message: String) -> void:
	status_label.text = message
