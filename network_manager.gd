extends Node

signal status_changed(message: String)

const PORT = 1488
const MAX_CLIENTS = 2

# Carrega a cena do jogador que você salvou
var player_scene = preload("res://Cenas/player.tscn")

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func host_game() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CLIENTS)

	if error != OK:
		status_changed.emit("Erro ao criar servidor: %s" % error)
		return

	multiplayer.multiplayer_peer = peer
	status_changed.emit("Servidor iniciado. Aguardando jogadores...")
	
	# Instancia o jogador do próprio Host (o ID do Host é sempre 1)
	add_player(1)


func join_game(ip: String) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, PORT)

	if error != OK:
		status_changed.emit("Erro ao iniciar conexão: %s" % error)
		return

	multiplayer.multiplayer_peer = peer
	status_changed.emit("Conectando ao servidor...")


func _on_connected_to_server() -> void:
	status_changed.emit("Conectado ao servidor!")


func _on_connection_failed() -> void:
	status_changed.emit("Falha ao conectar ao servidor.")


func _on_server_disconnected() -> void:
	status_changed.emit("Conexão com o servidor perdida.")


func _on_peer_connected(id: int) -> void:
	status_changed.emit("Jogador conectado: %s" % id)
	
	# Apenas o servidor (Host) deve criar os nós dos novos jogadores.
	# O MultiplayerSpawner replicará isso automaticamente para os clientes.
	if multiplayer.is_server():
		add_player(id)


func _on_peer_disconnected(id: int) -> void:
	status_changed.emit("Jogador desconectado: %s" % id)
	
	# O servidor remove o nó do jogador que saiu
	if multiplayer.is_server() and has_node(str(id)):
		get_node(str(id)).queue_free()


func add_player(id: int) -> void:
	var player_instance = player_scene.instantiate()
	player_instance.name = str(id)
	
	# Opcional: Adiciona um pequeno espaçamento para eles não nascerem grudados ou um dentro do outro
	player_instance.position = Vector3(randf_range(-2.0, 2.0), 1.0, randf_range(-2.0, 2.0))
	
	# CORREÇÃO: Adiciona o jogador DENTRO do nó 'Players' configurado no Spawn Path
	if has_node("Players"):
		$Players.add_child(player_instance)
	else:
		add_child(player_instance)
