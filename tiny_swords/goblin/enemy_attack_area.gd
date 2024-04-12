extends Area2D

@export var damaged: int = 1 

func on_body_entered(body) -> void:
	body.update_health(damaged)


func on_life_time_timeout() -> void:
	queue_free()
