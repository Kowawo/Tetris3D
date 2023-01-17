extends Node


var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909

var timeForConnect = 5
var tmpTime = 0


func connectToServer(delta):
	tmpTime += delta
	if (tmpTime > timeForConnect):
		network.create_client(ip, port)
		get_tree().set_network_peer(network)
		Globals.network = network
		tmpTime = 0

func closeConnection():
	network.close_connection()

func createGame(roomName, password):
	rpc_id(1, "createGame", roomName, password)

remote func gameExists(boolean):
	get_node("/root/Root/MultiplayerScreen").gameExists(boolean)

func deleteGame():
	rpc_id(1, "deleteGame")

remote func receiveRooms(rooms):
	Globals.rooms = rooms

func sendData(points, level, deletedRows):
	rpc_id(1, "receiveData", points, level, deletedRows)

remote func receiveData(points, level, deletedRows):
	print("Punkte: ", points, " Level: ", level, " Gelöschte Reihen: ", deletedRows)
