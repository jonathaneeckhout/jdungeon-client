class_name Entity extends CharacterBody2D

enum STATES { IDLE, MOVE, ATTACK }

var server_synchronizer: Node2D

var max_hp: float = 100.0
var hp: float = max_hp

var state = STATES.IDLE
var prev_pos: Vector2
var face_direction: Vector2
var attack_buffer = []

@onready var sprites = $Sprites
@onready var original_sprites_scale = $Sprites.scale


func _ready():
	var server_synchronizer_scene = load("res://scenes/ServerSynchronizer/ServerSynchronizer.tscn")
	server_synchronizer = server_synchronizer_scene.instantiate()
	add_child(server_synchronizer)

	prev_pos = position
	$AnimationPlayer.play("idle")


func _physics_process(_delta):
	match state:
		STATES.IDLE:
			if check_if_attacking():
				state = STATES.ATTACK
				$AnimationPlayer.play("attack")
			elif prev_pos != position:
				state = STATES.MOVE
				$AnimationPlayer.play("move")
				face_direction = prev_pos.direction_to(position)
				update_face_direction()
		STATES.MOVE:
			if check_if_attacking():
				state = STATES.ATTACK
				$AnimationPlayer.play("attack")
			elif prev_pos == position:
				state = STATES.IDLE
				$AnimationPlayer.play("idle")
			else:
				face_direction = prev_pos.direction_to(position)
				update_face_direction()
		STATES.ATTACK:
			if not $AnimationPlayer.is_playing():
				if check_if_attacking():
					state = STATES.ATTACK
					$AnimationPlayer.play("attack")
				else:
					state = STATES.IDLE
					$AnimationPlayer.play("idle")

	prev_pos = position


func update_face_direction():
	if face_direction.x < 0:
		sprites.scale = original_sprites_scale
	else:
		sprites.scale = Vector2(original_sprites_scale.x * -1, original_sprites_scale.y)


func check_if_attacking():
	if attack_buffer.is_empty():
		return false

	for i in range(attack_buffer.size()):
		if attack_buffer[i]["timestamp"] <= LevelsConnection.clock:
			face_direction = attack_buffer[i]["direction"]
			update_face_direction()
			attack_buffer.remove_at(i)
			return true


func hurt(current_hp: int, _damage: int):
	hp = current_hp

	update_hp_bar()


func update_hp_bar():
	$Interface/HPBar.value = (hp / max_hp) * 100


func attack(timestamp: float, direction: Vector2):
	attack_buffer.append({"timestamp": timestamp, "direction": direction})
