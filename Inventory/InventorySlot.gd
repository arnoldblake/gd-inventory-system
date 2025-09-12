class_name InventorySlot extends Slot


func _ready() -> void:
	super._ready()


func _can_move(data: Variant) -> bool:
	if get_parent().owner.container_type == data.get_parent().owner.container_type:
		return true
	elif data.contents.item_type == Item.ItemType.BAG: # Bags must be empty and not the same bag
		var source_inventory_container = data.get_parent().owner.get_parent().get_node("GridContainer").get_child(data.get_index())
		if source_inventory_container.free_space() == data.contents.container_size && get_parent().owner.get_index() != data.get_index():
			return true
	return false 

func _can_combine(data: Variant) -> bool:
	if contents.id == data.contents.id and contents.is_stackable and contents.quantity + data.contents.quantity <= contents.max_stack_size && contents != data.contents:
		return true
	return false

func _can_swap(data: Variant) -> bool:
	if get_parent().owner.container_type == data.get_parent().owner.container_type && contents != data.contents:
		return true
	return false

func _do_move(data: Variant) -> void:
	if data.contents.item_type == Item.ItemType.BAG:
		if data.get_parent() && data.get_parent().owner.container_type == 2: # Move from bag to inventory
			var source_inventory_container = data.get_parent().owner.get_parent().get_node("GridContainer").get_child(data.get_index())
			source_inventory_container.hide()
	super._do_move(data)

func _do_combine(data: Variant) -> void:
	if contents.quantity + data.contents.quantity <= contents.max_stack_size && contents != data.contents:
		contents.quantity += data.contents.quantity
		data.contents = null
		contents = contents

func _do_swap(data: Variant) -> void:
	var temp = self.contents
	self.contents = data.contents
	data.contents = temp