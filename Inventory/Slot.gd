@tool
class_name Slot extends Button

@onready var label = get_node("%Label") as Label

var contents: Item: 
	get:
		return contents	
	set(value):
		contents = value
		do_update_ui()

func _ready() -> void:
	do_update_ui()

func _get_drag_data (_position: Vector2) -> Slot:
	var preview = Control.new()
	var preview_icon = TextureRect.new()
	preview_icon.texture = icon 
	preview_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_icon.size = Vector2(32,32)
	preview.add_child(preview_icon) 
	set_drag_preview(preview)

	var drag_data = self 
	return drag_data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data.contents:
		if _is_empty() && _can_move(data): return true
		elif !_is_empty() && _can_combine(data): return true
		elif _can_swap(data): return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.contents:
		if _is_empty() && _can_move(data): _do_move(data)
		elif !_is_empty() && _can_combine(data): _do_combine(data)
		elif _can_swap(data): _do_swap(data)

func do_update_ui() -> void:
	if is_node_ready():
		icon = contents.item_icon if contents else null
		label.text = "" if contents == null else str(contents.quantity) if contents.quantity > 1 else ""

func _is_empty() -> bool:
	return false if contents else true

func _can_combine(data: Variant) -> bool:
	if contents.id == data.contents.id and contents.is_stackable and contents.quantity + data.contents.quantity <= contents.max_stack_size && contents != data.contents:
		return true
	return false

func _do_combine(data: Variant) -> void:
	if contents.quantity + data.contents.quantity <= contents.max_stack_size && contents != data.contents:
		contents.quantity += data.contents.quantity
		data.contents = null
		contents = contents

func _can_move(data: Variant) -> bool:
	if get_parent().owner.container_type == data.get_parent().owner.container_type:
		return true
	elif get_parent().owner.container_type == 2 && data.contents.item_type == Item.ItemType.BAG:
		return true
	elif get_parent().owner.container_type == 3 && data.contents.item_type == Item.ItemType.BAG:
		if data.get_parent().owner.get_parent().get_node("GridContainer").get_child(data.get_index()).free_space() != data.contents.container_size:
			return false
		if get_parent().owner.get_index() == data.get_index():
			return false
		return true
	return false

func _do_move(data: Variant) -> void:
	if get_parent().owner.container_type == 3 && data.get_parent() && data.get_parent().owner.container_type == 2 && data.contents.item_type == Item.ItemType.BAG:
			if data.get_parent().owner.get_parent().get_node("GridContainer").get_child(data.get_index()).free_space() != data.contents.container_size:
				return
			if get_parent().owner.get_index() == data.get_index():
				return
			data.get_parent().owner.get_parent().get_node("GridContainer").get_child(data.get_index()).hide()

	self.contents = data.contents	
	data.contents = null

	if get_parent().owner.container_type == 2 && contents.item_type == Item.ItemType.BAG:
		var inventory_ui = get_parent().owner.get_parent().get_node("GridContainer").get_child(get_index()) # TODO: Change to signal
		inventory_ui.visible = !inventory_ui.visible
		inventory_ui.resize(contents.container_size)

func _can_swap(data: Variant) -> bool:
	if get_parent().owner.container_type == data.get_parent().owner.container_type:
		return true
	return false

func _do_swap(data: Variant) -> void:
	var temp = self.contents
	self.contents = data.contents
	data.contents = temp
	pass