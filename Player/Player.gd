extends CharacterBody2D

const MAX_SPEED = 80
const ROLL_SPEED = 125
const ACCELERATION = 500
const FRICTION = 500
const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
 
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var animationTree : AnimationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var swordHitBox : Area2D = $HitBoxPivot/SwordHitBox
@onready var hurtbox = $HurtBox
@onready var blinkAnimationPlayer : AnimationPlayer = $BlinkAnimationPlayer

enum {
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE
var roll_vector : Vector2 = Vector2.DOWN
var stats = PlayerStats

func _ready():
	stats.no_health.connect(queue_free)
	animationTree.active = true
	swordHitBox.knockback_vector = roll_vector
	
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitBox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
		#print('slide')
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("Roll"):
		state = ROLL
		
func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	if( move_and_slide()):
		pass

func roll_animation_finished():
	#velocity = velocity / 2
	state = MOVE
	
func attack_animation_finished():
	state = MOVE


func _on_hurt_box_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.8)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instantiate()
	get_tree().current_scene.add_child(playerHurtSound)


func _on_hurt_box_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_hurt_box_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
