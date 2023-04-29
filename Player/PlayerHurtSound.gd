extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	self.finished.connect(queue_free)
