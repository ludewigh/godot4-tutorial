extends Node

@export var max_health : int = 1 :
	set (value):
		max_health = value
		emit_signal("max_health_change", max_health)
		
@onready var health = max_health :
	set (value):
		health = min(value, max_health)
		emit_signal("health_change", health)
		if health <= 0:
			emit_signal("no_health")
	get:
		return health

signal no_health  
signal health_change(value)
signal max_health_change(value)
