extends Control

@onready var heartUIFull = $HeartUIFull
@onready var heartUIEmpty = $HeartUIEmpty

var max_hearts = 4 :
	set = setMaxHearts
		
var hearts = 4 :
	set = setHearts

func setHearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.set_size(Vector2(15 * hearts, 11))

func setMaxHearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.set_size(Vector2(15 * max_hearts, 10))

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.health_change.connect(setHearts)
	PlayerStats.max_health_change.connect(setMaxHearts)
