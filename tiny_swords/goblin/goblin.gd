extends CharacterBody2D

const ATTACK_AREA: PackedScene = preload("res://tiny_swords/goblin/enemy_attack_area.tscn")
@onready var collision = get_node("DetectionArea/Collision")

@export var move_speed: float = 150
@export var distance_threshold: float = 60
@export var health: int = 3

@onready var animation: AnimationPlayer = get_node("Animation")
@onready var texture: Sprite2D = get_node("Texture")
@onready var auxAnimationPlayer : AnimationPlayer = get_node("AuxAnimationPlayer")

var can_die: bool = false ##Na realidade essa variavel serve para verificar se esta morto
var player_ref : CharacterBody2D = null

func _physics_process(_delta: float) -> void :
	if can_die:
		return
		
	if player_ref == null or player_ref.can_die:
		velocity = Vector2.ZERO
		animate()
		return
	
	#se move na direção da referência
	var direction: Vector2 = global_position.direction_to(player_ref.global_position)
	var distance: float = global_position.distance_to(player_ref.global_position)
	
	if distance < distance_threshold:
		animation.play("attack")
		return
		
	velocity = direction * move_speed
	move_and_slide()
	animate()
	
func spawn_attack_area() -> void:
	var attack_area =  ATTACK_AREA.instantiate()
	attack_area.position = collision.position
	add_child(attack_area)
		
func animate() -> void:
	if velocity != Vector2.ZERO:
		if velocity.x > 0:
			texture.flip_h = false
			
		if velocity.x < 0:	
			texture.flip_h = true
			
		animation.play("run")
	else:
		animation.play("idle")

func on_detection_area_body_entered(body):
	player_ref = body

func on_detection_area_body_exited(_body):
	player_ref = null
	
func update_health(value: int = 1) -> void:
	health -= value
	print("Enemy:"+str(health))
	if health <= 0:
		can_die = true
		animation.play("death")
		return
	auxAnimationPlayer.play("hit")

func on_animation_animation_finished(anim_name: String)-> void:	
	match anim_name:
		"death":
			queue_free() #deleta o inimigo
