extends RigidBody2D

var vel = Vector2(0, 300)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.position == Vector2(0,0):
		self.position = Vector2(1050, 120)
	self.apply_central_impulse(-1*vel)
	

func _process(_float) -> void:
	if self.position.y > 1000:
		self.call_deferred("queue_free")
