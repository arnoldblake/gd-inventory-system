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
		elif !_is_empty() && _can_combine(data) || _can_swap(data): return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if _is_empty() && _can_move(data): _do_move(data)
	elif !_is_empty() && _can_combine(data): _do_combine(data)
	elif !_is_empty() && _can_swap(data): _do_swap(data)

func do_update_ui() -> void:
	if is_node_ready():
		icon = contents.item_icon if contents else null
		label.text = "" if contents == null else str(contents.quantity) if contents.quantity > 1 else ""

func _is_empty() -> bool:
	return false if contents else true

func _can_combine(data: Variant) -> bool:
	return false

func _do_combine(data: Variant) -> void:
	pass

func _can_move(data: Variant) -> bool:
	return false

func _do_move(data: Variant) -> void:
	self.contents = data.contents	
	data.contents = null

func _can_swap(data: Variant) -> bool:
	return false

func _do_swap(data: Variant) -> void:
	pass