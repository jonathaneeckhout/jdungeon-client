extends Panel

@export var item: Item:
	set(new_item):
		item = new_item
		if item:
			$TextureRect.texture = load(item.inventory_texture_path)
		else:
			$TextureRect.texture = null

var item_uuid: String

var grid_pos: Vector2
var selected = false
var drag_panel_offset: Vector2

@onready var camera = $"../../../../.."
@onready var inventory = $"../.."
@onready var drag_panel = $"../../DragPanel"


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		drag_panel.texture = $TextureRect.texture
		drag_panel.show()
		selected = true
	elif event.is_action_released("left_click"):
		drag_panel.texture = null
		drag_panel.hide()
		selected = false
		if Global.above_ui and inventory.mouse_above_this_panel:
			inventory.swap_items(self, inventory.mouse_above_this_panel)
		else:
			if item_uuid and item_uuid != "":
				LevelsConnection.drop_inventory_item.rpc_id(1, item_uuid)
	elif event.is_action_pressed("right_click"):
		if not selected:
			if item_uuid and item_uuid != "":
				LevelsConnection.use_inventory_item.rpc_id(1, item_uuid)
		else:
			selected = false
			drag_panel.hide()


func _physics_process(_delta):
	if selected:
		drag_panel.position = get_local_mouse_position() + drag_panel_offset


func _on_mouse_entered():
	inventory.mouse_above_this_panel = self


func _on_mouse_exited():
	inventory.mouse_above_this_panel = null
