@tool
extends PanelContainer

enum ContainerType {
	NONE,
	ACTION_BAR,
	BAG_BAR,
	INVENTORY 
}

@export var container_type: ContainerType = ContainerType.NONE
@export var slot_ui: PackedScene = preload("res://addons/gd-inventory-system/Inventory/Slot.tscn")

func find_empty_slot() -> int:
	var slot: Array[Node] = get_node("%GridContainer").get_children() 
	for i in get_node("%GridContainer").get_children():
		if i._is_empty():
			return i.get_index()
	return -1

func _is_empty(index: int) -> bool:
	var slot = get_node("%GridContainer").get_child(index) as Slot
	return slot._is_empty()

func assign_item_at(index: int, item: Item) -> void:
	if _is_empty(index):
		var temp_slot = slot_ui.instantiate() as Slot
		temp_slot.contents = item.duplicate()
		var slot = get_node("%GridContainer").get_child(index) as Slot
		slot._do_move(temp_slot)

func resize(size: int) -> void:
	for child in get_node("%GridContainer").get_children():
		child.queue_free()
	for i in size:
		var slot = slot_ui.instantiate() as Slot
		get_node("%GridContainer").add_child(slot)

		if container_type == ContainerType.BAG_BAR:
			var inventory = get_parent()
			slot.pressed.connect(inventory._on_button_pressed.bind(slot))
		else:
			slot.pressed.connect(get_parent().owner._on_button_pressed.bind(slot))
		
func free_space() -> int:
	var free_slots: int = 0
	for slot in get_node("%GridContainer").get_children():
		if slot._is_empty():
			free_slots += 1
	return free_slots
