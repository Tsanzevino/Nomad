class_name HeightCondition extends Condition

@export var minimumHeight : float = 0
@export var maximumHeight : float = 100

func is_satisified() -> bool:
	var height : float = PlayerStats.player_height
	return minimumHeight < height and height < maximumHeight
