extends CharacterBody2D

@export var FRICTION = 400
@export var ACCELERATION = 400
@export var MAX_SPEED = 50
@export var WANDER_TOLERANCE = 4

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

@onready var playerDetectionZone : Area2D = $PlayerDetectionZone
@onready var stats : Node = $Stats
@onready var sprite : AnimatedSprite2D = $BatAnimationSprite
@onready var hurtbox = $HurtBox
@onready var softcollision = $SoftCollision
@onready var wanderController = $WanderController
@onready var animationPlayer = $AnimationPlayer

enum {
	IDLE,
	WANDER,
	CHASE
}

var knockback = Vector2.ZERO
var state = CHASE

func _physics_process(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
		velocity = knockback
		
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= WANDER_TOLERANCE:
				update_wander()
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
	
	if softcollision.is_colliding():
		velocity += softcollision.get_push_vector() * delta * 400
	if(move_and_slide()):
		pass

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(randf_range(1,3))
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0
	
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func _on_hurt_box_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 100
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)


func _on_stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_hit_box_area_entered(_area):
	pass # Replace with function body.


func _on_hurt_box_invincibility_started():
	animationPlayer.play("Start")

func _on_hurt_box_invincibility_ended():
	animationPlayer.play("Stop")
