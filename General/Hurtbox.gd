extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

signal invincibility_started
signal invincibility_ended

@onready var timer = $Timer
@onready var collisionShape = $CollisionShape2D

var invincible = false:
	get:
		return invincible
	set(value):
		invincible = value
		if invincible == true:
			emit_signal("invincibility_started")
		else:
			emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var hitEffect = HitEffect.instantiate()
	var main = get_tree().current_scene
	main.add_child(hitEffect)
	hitEffect.global_position = global_position

func _on_timer_timeout():
	self.invincible = false

func _on_invincibility_started():
	collisionShape.set_deferred("disabled", true)

func _on_invincibility_ended():
	collisionShape.set_deferred("disabled", false)
