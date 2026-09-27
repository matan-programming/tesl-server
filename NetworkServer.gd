extends Node
class_name NetworkServer

## WebSocket server for handling client connections and data transmission.

signal client_connected(peer_id: int, card_id: String, instance_id: String)
signal client_disconnected(peer_id: int)
signal packet_received(peer_id: int, packet: PackedByteArray)

const PORT: int = 7964
const BIND_ADDRESS: String = "*"

var tcp_server := TCPServer.new()
var _peers: Dictionary = {}
var _next_peer_id: int = 1

func _ready() -> void:
	start_server(PORT, BIND_ADDRESS)

func _process(_delta: float) -> void:
	_poll_new_connections()
	_poll_existing_peers()

## Starts the TCP server listening for incoming WebSocket connections.
func start_server(port: int = PORT, bind_address: String = BIND_ADDRESS) -> bool:
	var err := tcp_server.listen(port, bind_address)
	if err != OK:
		printerr("[NetworkServer] Failed to listen on port %d (Error: %d)" % [port, err])
		return false
	print("[NetworkServer] Server listening on %s:%d" % [bind_address, port])
	return true

## Stops the server and closes all active client connections.
func stop_server() -> void:
	for peer_id in _peers.keys():
		var peer: WebSocketPeer = _peers[peer_id]["peer"]
		peer.close(1000, "Server shutting down")
	_peers.clear()
	tcp_server.stop()
	print("[NetworkServer] Server stopped.")

func _poll_new_connections() -> void:
	while tcp_server.is_connection_available():
		var tcp_conn := tcp_server.take_connection()
		if tcp_conn == null:
			continue
		
		var ws_peer := WebSocketPeer.new()
		var err := ws_peer.accept_stream(tcp_conn)
		if err == OK:
			var peer_id := _next_peer_id
			_next_peer_id += 1
			_peers[peer_id] = {
				"peer": ws_peer,
				"is_open": false,
				"host": tcp_conn.get_connected_host(),
				"port": tcp_conn.get_connected_port()
			}
			print("[NetworkServer] Connection handshake initiated for peer %d from %s:%d" % [
				peer_id, tcp_conn.get_connected_host(), tcp_conn.get_connected_port()
			])
		else:
			printerr("[NetworkServer] Failed to accept stream as WebSocket (Error: %d)" % err)

func _poll_existing_peers() -> void:
	for peer_id in _peers.keys():
		var client_info: Dictionary = _peers[peer_id]
		var peer: WebSocketPeer = client_info["peer"]
		peer.poll()
		
		var state := peer.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			if not client_info["is_open"]:
				client_info["is_open"] = true
				_handle_client_connected(peer_id, peer)
			
			while peer.get_available_packet_count() > 0:
				var packet := peer.get_packet()
				_handle_packet_received(peer_id, packet)
				
		elif state == WebSocketPeer.STATE_CLOSED:
			var code := peer.get_close_code()
			var reason := peer.get_close_reason()
			print("[NetworkServer] Peer %d disconnected (code: %d, reason: '%s')" % [peer_id, code, reason])
			_peers.erase(peer_id)
			client_disconnected.emit(peer_id)

## Triggered the moment a client connects successfully (handshake complete, socket open).
func _handle_client_connected(peer_id: int, peer: WebSocketPeer) -> void:
	print("[NetworkServer] Client %d connected successfully!" % peer_id)
	
	# Select a random card_id from CardDatabase
	var selected_card_id := ""
	if CardDatabase != null:
		selected_card_id = CardDatabase.get_random_card_id()
	else:
		push_error("[NetworkServer] CardDatabase autoload is not accessible!")
	
	# Generate unique identifier (UUID v4)
	var instance_id := generate_uuid()
	
	# Prepare packet with only card_id and instance_id
	var packet_data: Dictionary = {
		"card_id": selected_card_id,
		"instance_id": instance_id
	}
	
	var json_string := JSON.stringify(packet_data)
	var send_err := peer.send_text(json_string)
	if send_err == OK:
		print("[NetworkServer] Sent packet to peer %d: %s" % [peer_id, json_string])
	else:
		printerr("[NetworkServer] Failed to send packet to peer %d (Error: %d)" % [peer_id, send_err])
	
	client_connected.emit(peer_id, selected_card_id, instance_id)

func _handle_packet_received(peer_id: int, packet: PackedByteArray) -> void:
	var message := packet.get_string_from_utf8()
	print("[NetworkServer] Received packet from peer %d: %s" % [peer_id, message])
	packet_received.emit(peer_id, packet)

## Sends a stringified JSON packet to a specific peer.
func send_to_peer(peer_id: int, data: Dictionary) -> Error:
	if not _peers.has(peer_id):
		printerr("[NetworkServer] Cannot send to unknown peer %d" % peer_id)
		return ERR_DOES_NOT_EXIST
	var peer: WebSocketPeer = _peers[peer_id]["peer"]
	if peer.get_ready_state() != WebSocketPeer.STATE_OPEN:
		printerr("[NetworkServer] Peer %d is not in OPEN state" % peer_id)
		return ERR_UNCONFIGURED
	return peer.send_text(JSON.stringify(data))

## Generates a standard RFC 4122 v4 UUID string.
static func generate_uuid() -> String:
	var b := PackedByteArray()
	for i in range(16):
		b.append(randi() % 256)
	b[6] = (b[6] & 0x0f) | 0x40  # Version 4
	b[8] = (b[8] & 0x3f) | 0x80  # Variant 1 (RFC 4122)
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
		b[0], b[1], b[2], b[3],
		b[4], b[5],
		b[6], b[7],
		b[8], b[9],
		b[10], b[11], b[12], b[13], b[14], b[15]
	]
