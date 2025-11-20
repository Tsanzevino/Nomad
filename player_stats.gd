extends Node

var player_height : float
var player_biome : Biome
var player : Player
var biomeMap : BiomeMap

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta):
	if player == null: return
	player_height = player.global_position.y
	if player_biome != biomeMap.get_biome(player.global_position.x,player.global_position.z):
		player_biome = biomeMap.get_biome(player.global_position.x,player.global_position.z)
		print(player_biome.biomeName)
