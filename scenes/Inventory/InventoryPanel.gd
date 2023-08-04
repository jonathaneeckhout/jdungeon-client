extends Panel

@export var item: Item:
	set(new_item):
		item = new_item
		if item:
			$TextureRect.texture = load(item.inventory_texture_path)
		else:
			$TextureRect.texture = null
var grid_pos: Vector2
var selected = false
var drag_panel_offset: Vector2

@onready var camera = $"../../../../.."
@onready var drag_panel = $"../../DragPanel"


func _gui_input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		drag_panel.texture = $TextureRect.texture
		drag_panel.show()
		selected = true
	elif event.is_action_released("left_click"):
		drag_panel.texture = null
		drag_panel.hide()
		selected = false
	elif event.is_action_pressed("right_click"):
		if not selected:
			LevelsConnection.use_inventory_item_at_pos.rpc_id(1, grid_pos)
		else:
			selected = false
			drag_panel.hide()


func _physics_process(_delta):
	if selected:
		drag_panel.position = get_local_mouse_position() + drag_panel_offset
