extends Control

@onready var heartUIFull = $HeartUIFull
@onready var heartUIEmpty = $HeartUIEmpty

var hearts = 4:
	get:
		return hearts
	set(value):
		hearts = clamp(value, 0, max_hearts)

var max_hearts = 4:
	get:
		return max_hearts
	set(value):
		max_hearts = max(value, 1)

func set_hearts(value):
	hearts = value
	if heartUIFull != null:
		heartUIFull.size.x = hearts * 15

func set_max_hearts(value):
	max_hearts = value
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null: 
		heartUIEmpty.size.x = max_hearts * 15

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.health_changed.connect(set_hearts)
	PlayerStats.max_health_changed.connect(set_max_hearts)
