# The BagSlot is a specialized Slot that only accepts Bag items.
# The only supported bag slot operations are move either from an inventory or to another bag slot

class_name BagSlot extends Slot

func _ready() -> void:
	super._ready()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data.contents && data.contents.item_type == Item.ItemType.BAG:
		if _is_empty() && _can_move(data): return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.contents:
		if _is_empty() && _can_move(data): _do_move(data)

func _can_move(data: Variant) -> bool:
	var source_container = data.get_parent().owner
	if source_container.container_type && source_container.container_type == 3: # Move from inventory to bag
		return true
	elif source_container.container_type == 2: # Move from bag to bag
		var source_inventory_container = data.get_parent().owner.get_parent().get_node("GridContainer").get_child(data.get_index())
		if source_inventory_container.free_space() == data.contents.container_size:
			return true
	return false

func _do_move(data: Variant) -> void:
	super._do_move(data)

	var source_inventory_container = get_parent().owner.get_parent().get_node("GridContainer").get_child(get_index()) # TODO: Change to signal
	source_inventory_container.visible = !source_inventory_container.visible
	source_inventory_container.resize(contents.container_size)
	source_inventory_container.hide()
	