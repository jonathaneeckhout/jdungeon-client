extends Panel

const SIZE = Vector2(2, 5)

@export var gold := 0:
	set(amount):
		gold = amount
		$VBoxContainer/GoldValue.text = str(amount)

var panels = []
var mouse_above_this_panel: Panel
var location_cache = {}


func _ready():
	for x in range(SIZE.x):
		panels.append([])
		for y in range(SIZE.y):
			panels[x].append(null)

	var i = 0
	for y in range(SIZE.y):
		for x in range(SIZE.x):
			var panel = $GridContainer.get_child(i)
			panel.grid_pos = Vector2(x, y)
			panels[x][y] = panel
			i += 1



func _input(event):
	if event.is_action_pressed("toggle_equipment"):
		if visible:
			hide()
		else:
			show()


func get_panel_at_pos(pos: Vector2):
	var panel_path = "Panel_%d_%d" % [int(pos.x), int(pos.y)]
	return $GridContainer.get_node(panel_path)


