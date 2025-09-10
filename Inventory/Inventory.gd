@tool
extends MarginContainer

@export var bag_slot_quantity: int = 5
@export var starter_items: Array[Item]
@export var inventory_ui: PackedScene = preload("res://addons/gd-inventory-system/Inventory/InventoryUI.tscn")

func _ready() -> void:
	# Instance the bag bar and add to scene
	var container: PanelContainer = inventory_ui.instantiate()
	container.container_type = 2
	container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(container)

	# Instance the inventory containers and add to scene
	for i in bag_slot_quantity:
		var inv_container = inventory_ui.instantiate()
		get_node("GridContainer").add_child(inv_container)
		var format_text = "Bag %d"
		inv_container.get_node("%Label").text = format_text % (inv_container.get_index() + 1)
		inv_container.container_type = 3
		inv_container.hide()
		var close_button = inv_container.get_node("%CloseButton")
		close_button.pressed.connect(inv_container.hide)

	var starter_bag: Item = preload("res://addons/gd-inventory-system/Items/bag.tres")

	var bag_grid = container.get_node("%GridContainer") as GridContainer
	bag_grid.columns = bag_slot_quantity
	container.get_node("MarginContainer/VBoxContainer/HBoxContainer").hide()
	container.resize(bag_slot_quantity)
	container.assign_item_at(0, starter_bag)
	
	for item in starter_items:
		for inventory_ui in get_node("GridContainer").get_children():
			var empty_slot = inventory_ui.find_empty_slot()
			if empty_slot >= 0:
				inventory_ui.assign_item_at(empty_slot, item)
				break

func _on_button_pressed(button: Slot) -> void:
	if button.get_parent().owner.container_type == 2 && button.contents && button.contents.item_type == Item.ItemType.BAG:
			var inventory_ui = get_node("GridContainer").get_child(button.get_index())	
			inventory_ui.visible = !inventory_ui.visible
