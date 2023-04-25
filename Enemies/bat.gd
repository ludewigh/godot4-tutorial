extends CharacterBody2D

const FRICTION = 400

var knockback = Vector2.ZERO

@onready var stats : Node = $Stats

func _physics_process(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
		velocity = knockback
	if(move_and_slide()):
		pass
	
func _on_hurt_box_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 100


func _on_stats_no_health():
	queue_free()
