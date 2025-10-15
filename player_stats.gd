extends Node

var player_height : float
var player : Player

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta):
	player_height = player.global_position.y
