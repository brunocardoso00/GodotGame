extends CharacterBody2D

@export var move_speed: float = 250
@export var damage: int = 1
@export var health: int = 3

@onready var attack_area_colision: CollisionShape2D = get_node("AttackArea/Collision")
@onready var texture: Sprite2D = get_node("Texture")
@onready var animation: AnimationPlayer = get_node("Animation")
@onready var auxAnimationPlayer: AnimationPlayer = get_node("AuxAnimationPlayer")


var can_attack: bool = true
var can_die: bool = false


func _physics_process(_delta: float) -> void:
	if can_attack == false or can_die:
		return 
		
	move()
	animate()
	attack_handler()

func move()-> void:
	var direction: Vector2 = get_direction()
	velocity = direction * move_speed
	move_and_slide()
	
func get_direction()-> Vector2:
	return Vector2(
		Input.get_axis("move_left","move_right"), 
		Input.get_axis("move_up","move_down")).normalized() 
		#suavisa e normaliza a movimentação na diagonal 

func animate()-> void:
	if velocity.x > 0:
		texture.flip_h = false
		attack_area_colision.position.x = 59
		
	if velocity.x < 0:
		texture.flip_h = true
		attack_area_colision.position.x = -59
		
	if velocity != Vector2.ZERO:
		animation.play("run")
		return
		
	animation.play("idle")
	
func attack_handler() -> void:
	if Input.is_action_just_pressed("attack") and can_attack:
		can_attack = false
		animation.play("attack")

func on_animation_animation_finished(anim_name: String) -> void:
	match anim_name:
		"death":
			get_tree().reload_current_scene()
		"attack":
			can_attack = true


func on_attack_area_body_entered(body)-> void:
	body.update_health(damage)
	
	
func update_health(value: int) -> void:
	health -= value
	print(health)
	if health <= 0:
		can_die = true
		animation.play("death")
		attack_area_colision.set_deferred("disabled",true)
		return
	auxAnimationPlayer.play("hit")
