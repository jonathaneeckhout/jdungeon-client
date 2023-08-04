extends Panel

@export var item: Item:
	set(new_item):
		item = new_item
		if item:
			$TextureRect.texture = load(item.inventory_texture_path)

		else:
			$TextureRect.texture = null

var grid_pos: Vector2

@onready var shop = $"../.."


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent):
	if event.is_action_pressed("right_click"):
		LevelsConnection.buy_shop_item_at_pos.rpc_id(1, shop.vendor, grid_pos)


func _on_mouse_entered():
	if item:
		shop.display_info(position + size / 2, item.item_class, item.price)


func _on_mouse_exited():
	shop.hide_info()
