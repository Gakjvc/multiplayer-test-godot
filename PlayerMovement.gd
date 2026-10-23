extends CharacterBody3D

const WALKSPEED = 5.0
const SPRINTSPEED = 10.0
const JUMP_VELOCITY = 4.5
const STOPPING_TIME = 999


func _ready() -> void:
	# 1. Define o ID do jogador
	var player_id = str(name).to_int()
	
	# 2. Define a autoridade do corpo (CharacterBody3D)
	set_multiplayer_authority(player_id)
	
	# 3. CORREÇÃO: Define a autoridade do Sincronizador para que o cliente possa enviar sua posição
	if has_node("MultiplayerSynchronizer"):
		$MultiplayerSynchronizer.set_multiplayer_authority(player_id)
	
	# 4. Ativa a câmera se o jogo for do dono
	if is_multiplayer_authority():
		if has_node("CameraPivot/Camera3D"):
			$CameraPivot/Camera3D.make_current()

func _physics_process(delta: float) -> void:
	# Trava de Segurança: Se não for o dono do personagem, ignora os inputs e o movimento
	if not is_multiplayer_authority():
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var speed = SPRINTSPEED if Input.is_action_pressed("game_sprint") else WALKSPEED
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("game_left", "game_right", "game_up", "game_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, STOPPING_TIME * delta)
		velocity.z = move_toward(velocity.z, 0, STOPPING_TIME * delta)

	move_and_slide()
