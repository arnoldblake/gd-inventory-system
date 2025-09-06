@tool
extends MarginContainer

const BAG_SLOTS = 5

@export var starter_items: Array[Item]
@export var inventory_container_scene: PackedScene
@onready var equipped_bags: Array[Item] = []
@onready var inventory_items: Array[Array] = []


func create_button() -> Button:
	var button = Button.new()
	button.set_script(preload("res://addons/inventory_system/Inventory/Button.gd"))
	button.expand_icon = true
	button.custom_minimum_size = Vector2(64,64)
	button.size = Vector2(64,64)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return button

func _ready() -> void:
	equipped_bags.resize(5)
	inventory_items.resize(5)
	var bag_bar: PanelContainer = inventory_container_scene.instantiate()
	bag_bar.name = "BagBar"
	bag_bar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bag_bar.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(bag_bar)

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

	var bag_grid = bag_bar.get_node("%GridContainer") as GridContainer
	bag_grid.columns = BAG_SLOTS
	bag_bar.get_node("MarginContainer/VBoxContainer/HBoxContainer").hide()
	for n in BAG_SLOTS:
		var button = create_button() 
		if equipped_bags[n] != null && equipped_bags.size() > n:
			button.icon = equipped_bags[n].item_icon
		button.parent_container = "BagBar"
		bag_grid.add_child(button)
		button.pressed.connect(_on_button_pressed.bind(button.get_index()))
		button.connect("swap_items", _on_swap_items)

	var inventory_container: PanelContainer = inventory_container_scene.instantiate()
	get_node("GridContainer").add_child(inventory_container)
	var grid_container = inventory_container.get_node("%GridContainer") as GridContainer
	for n in equipped_bags.size():
		if equipped_bags[n] != null && equipped_bags[n].container_size > 0:
			for i in equipped_bags[n].container_size:
				var button = create_button() 
				button.parent_container = "ContainerGrid" 
				button.container_index = n
				grid_container.add_child(button)
				button.pressed.connect(_on_button_pressed.bind(button.get_index()))
				button.connect("swap_items", _on_swap_items)
				
				if inventory_items[n][i] != null:
					button.icon = inventory_items[n][i].item_icon

func _on_button_pressed(index: int) -> void:
	print("Button Pressed at index: %d" % index)

func _on_swap_items(source_container: String, destination_container: String, source_container_index: int, source_index: int, target_container_index: int, target_index: int) -> void:
	print("Swap items in %s from %d:%d to %d:%d" % [source_container, source_container_index, source_index, target_container_index, target_index])
	if source_container == destination_container: # Same container movement
		if source_container == "BagBar":
			if equipped_bags[target_index] == null: # Target is empty, move the item
				equipped_bags.set(target_index, equipped_bags[source_index])
				equipped_bags.set(source_index, null)
				get_node("BagBar/%GridContainer").get_child(target_index).icon = equipped_bags[target_index].item_icon
				get_node("BagBar/%GridContainer").get_child(source_index).icon = null
		elif source_container == "ContainerGrid":
			if inventory_items[target_container_index][target_index] == null: # Target is empty, move the item
				inventory_items[target_container_index].set(target_index, inventory_items[source_container_index][source_index])
				inventory_items[source_container_index].set(source_index, null)
				get_node("GridContainer").get_child(target_container_index).get_node("%GridContainer").get_child(target_index).icon = inventory_items[target_container_index][target_index].item_icon
				get_node("GridContainer").get_child(source_container_index).get_node("%GridContainer").get_child(source_index).icon = null
