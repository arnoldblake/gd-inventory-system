@tool
extends MarginContainer

const BAG_SLOTS = 5

@export var starter_items: Array[Item]
@onready var equipped_bags: Array[Item] = []
@onready var inventory_items: Array[Array] = []

func _ready() -> void:
	equipped_bags.resize(5)
	inventory_items.resize(5)
	for item in starter_items:
		if item.item_type == Item.ItemType.BAG:
			for i in equipped_bags.size():
				if equipped_bags[i] == null:
					equipped_bags[i] = item.duplicate()
					inventory_items[i] = []
					inventory_items[i].resize(item.container_size)
					break

	for item in starter_items:
		if item.item_type == Item.ItemType.ITEM:
			for i in inventory_items:
				if i != null:
					for j in i.size():
						if i[j] == null:
							i[j] = item.duplicate()
							break

	var bag_grid = get_node("%BagGrid")
	for n in BAG_SLOTS:
		var button = Button.new()
		button.set_script(preload("res://addons/inventory_system/Inventory/Button.gd"))
		if equipped_bags[n] != null && equipped_bags.size() > n:
			button.icon = equipped_bags[n].item_icon
		button.expand_icon = true
		button.custom_minimum_size = Vector2(64,64)
		button.size = Vector2(64,64)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.parent_container = bag_grid.name
		bag_grid.add_child(button)
		button.pressed.connect(_on_button_pressed.bind(button.get_index()))
		button.connect("swap_items", _on_swap_items)

	var container_grid = get_node("%ContainerGrid")
	for n in equipped_bags.size():
		if equipped_bags[n] != null && equipped_bags[n].container_size > 0:
			for i in equipped_bags[n].container_size:
				var button = Button.new()
				button.set_script(preload("res://addons/inventory_system/Inventory/Button.gd"))
				button.expand_icon = true
				button.custom_minimum_size = Vector2(64,64)
				button.size = Vector2(64,64)
				button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				button.parent_container = container_grid.name
				container_grid.add_child(button)
				button.pressed.connect(_on_button_pressed.bind(button.get_index()))
				button.connect("swap_items", _on_swap_items)
				
				if inventory_items[n][i] != null:
					button.icon = inventory_items[n][i].item_icon

func _on_button_pressed(index: int) -> void:
	print("Button Pressed at index: %d" % index)

func _on_swap_items(parent_container: String, source_index: int, target_index: int) -> void:
	print("Swap items in %s from %d to %d" % [parent_container, source_index, target_index])
	if parent_container == "BagGrid":
		equipped_bags.set(target_index, equipped_bags[source_index])
		equipped_bags.set(source_index, null)
		get_node("%BagGrid").get_child(target_index).icon = equipped_bags[target_index].item_icon
		get_node("%BagGrid").get_child(source_index).icon = null
	elif parent_container == "ContainerGrid":
		inventory_items[0].set(target_index, inventory_items[0][source_index])
		inventory_items[0].set(source_index, null)
		get_node("%ContainerGrid").get_child(target_index).icon = inventory_items[0][target_index].item_icon
		get_node("%ContainerGrid").get_child(source_index).icon = null