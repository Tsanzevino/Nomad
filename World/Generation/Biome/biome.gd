class_name Biome extends NoiseComponent

const MAX_INTRUSION : float = 100.0
const MIN_INTRUSION : float = 0.0

@export var biomeName : String = ""
@export var biomeColor : Color = Color.WHITE
@export_range(MIN_INTRUSION, MAX_INTRUSION) var intrusion : float = 0.0
