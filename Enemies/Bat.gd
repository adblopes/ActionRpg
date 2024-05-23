extends CharacterBody2D

@onready var animatedSprite = $AnimatedSprite
@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var sprite = $AnimatedSprite
@onready var hurtbox = $Hurtbox
@onready var softCollision = $SoftCollision
@onready var wanderController = $WanderController
@onready var animationPlayer = $AnimationPlayer

@export var ACCELERATION = 500
@export var MAX_SPEED = 35
@export var FRICTION = 300

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE	
}

var knockback = Vector2.ZERO

var state = IDLE

func _ready():
	sprite.frame = randi_range(0, 4)
	animatedSprite.play("Fly")

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(randi_range(1, 3))
		
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(randi_range(1, 3))
			
			var direction = global_position.direction_to(wanderController.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			sprite.flip_h = velocity.x < 0 	
			
			if global_position.distance_to(wanderController.target_position) <= MAX_SPEED * delta:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(randi_range(1, 3))	
#
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				if global_position.distance_to(player.global_position) >= MAX_SPEED * delta:
					var direction = global_position.direction_to(player.global_position)
					velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
					sprite.flip_h = velocity.x < 0 	
			else:
				state = IDLE
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400	
	
	move_and_slide()

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	velocity =  area.knockback_vector * 200
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)
	
func _on_stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_hurtbox_invincibility_started():
	animationPlayer.play("Start")

func _on_hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
