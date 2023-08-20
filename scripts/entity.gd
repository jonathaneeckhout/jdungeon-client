class_name Entity extends CharacterBody2D

enum STATES { IDLE, MOVE, ATTACK }

var server_synchronizer: Node2D

var max_hp: int = 10
var hp: int = max_hp

var state = STATES.IDLE
var prev_pos: Vector2
var face_direction: Vector2
var attack_buffer = []
var hurt_buffer = []
var heal_buffer = []

@onready var sprites = $Sprites
@onready var original_sprites_scale = $Sprites.scale

@onready var floating_text_scene = preload("res://scenes/FloatingText/FloatingText.tscn")


func _ready():
	var server_synchronizer_scene = load("res://scenes/ServerSynchronizer/ServerSynchronizer.tscn")
	server_synchronizer = server_synchronizer_scene.instantiate()
	add_child(server_synchronizer)

	prev_pos = position
	$Sprites/AnimationPlayer.play("idle")

	update_hp_bar()
	check_if_heal()


func _physics_process(_delta):
	match state:
		STATES.IDLE:
			if check_if_attacking():
				state = STATES.ATTACK
				$Sprites/AnimationPlayer.play("attack")
			elif prev_pos != position:
				state = STATES.MOVE
				$Sprites/AnimationPlayer.play("move")
				face_direction = prev_pos.direction_to(position)
				update_face_direction()
		STATES.MOVE:
			if check_if_attacking():
				state = STATES.ATTACK
				$Sprites/AnimationPlayer.play("attack")
			elif prev_pos == position:
				state = STATES.IDLE
				$Sprites/AnimationPlayer.play("idle")
			else:
				face_direction = prev_pos.direction_to(position)
				update_face_direction()
		STATES.ATTACK:
			if not $Sprites/AnimationPlayer.is_playing():
				if check_if_attacking():
					state = STATES.ATTACK
					$Sprites/AnimationPlayer.play("attack")
				else:
					state = STATES.IDLE
					$Sprites/AnimationPlayer.play("idle")

	prev_pos = position

	check_if_hurt()
	check_if_heal()


func update_face_direction():
	if face_direction.x < 0:
		sprites.scale = original_sprites_scale
	else:
		sprites.scale = Vector2(original_sprites_scale.x * -1, original_sprites_scale.y)


func check_if_attacking():
	if attack_buffer.is_empty():
		return false

	for i in range(attack_buffer.size() - 1, -1, -1):
		if attack_buffer[i]["timestamp"] <= LevelsConnection.clock:
			face_direction = attack_buffer[i]["direction"]
			update_face_direction()
			attack_buffer.remove_at(i)
			return true


func hurt(timestamp: float, current_hp: int, damage: int):
	hurt_buffer.append({"timestamp": timestamp, "current_hp": current_hp, "damage": damage})


func check_if_hurt():
	for i in range(hurt_buffer.size() - 1, -1, -1):
		if hurt_buffer[i]["timestamp"] <= LevelsConnection.clock:
			hp = hurt_buffer[i]["current_hp"]

			update_hp_bar()

			var text = floating_text_scene.instantiate()
			text.amount = hurt_buffer[i]["damage"]
			text.type = text.TYPES.DAMAGE
			add_child(text)

			hurt_buffer.remove_at(i)
			return true


func heal(timestamp: float, current_hp: int, healing: int):
	print("HEALING")
	heal_buffer.append({"timestamp": timestamp, "current_hp": current_hp, "healing": healing})


func check_if_heal():
	for i in range(heal_buffer.size() - 1, -1, -1):
		if heal_buffer[i]["timestamp"] <= LevelsConnection.clock:
			hp = heal_buffer[i]["current_hp"]

			update_hp_bar()

			var text = floating_text_scene.instantiate()
			text.amount = heal_buffer[i]["healing"]
			text.type = text.TYPES.HEALING
			add_child(text)

			heal_buffer.remove_at(i)
			return true


func update_hp_bar():
	$Interface/HPBar.value = (hp * 100 / max_hp)


func attack(timestamp: float, direction: Vector2):
	attack_buffer.append({"timestamp": timestamp, "direction": direction})
