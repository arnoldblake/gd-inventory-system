@tool
extends MarginContainer

@export var bag_slots: int = 5
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


	var bag_grid = bag_bar.get_node("%GridContainer") as GridContainer
	bag_grid.columns = bag_slots
	bag_bar.get_node("MarginContainer/VBoxContainer/HBoxContainer").hide()
	for n in bag_slots:
		var button = create_button() 
		if equipped_bags[n] != null && equipped_bags.size() > n:
			button.icon = equipped_bags[n].item_icon
		button.parent_container = "BagBar"
		bag_grid.add_child(button)
		button.pressed.connect(_on_button_pressed.bind(button.container_index, button.get_index()))
		button.connect("swap_items", _on_swap_items)

	# Instance the inventory containers and add to scene
	for i in bag_slots:
		var inventory_container: PanelContainer = inventory_container_scene.instantiate()
		get_node("GridContainer").add_child(inventory_container)
		inventory_container.hide()
		var close_button = inventory_container.get_node("%CloseButton")
		close_button.pressed.connect(inventory_container.hide)

	# If a bag is equipped, populate the inventory grid with buttons
	for i in equipped_bags.size():
		if equipped_bags[i] != null:
			var inventory_container = get_node("GridContainer").get_child(i)
			inventory_container.show()
			var grid_container = inventory_container.get_node("%GridContainer") as GridContainer
			for j in equipped_bags[i].container_size:
				var button = create_button() 
				button.parent_container = "ContainerGrid" 
				button.container_index = i 
				grid_container.add_child(button)
				button.pressed.connect(_on_button_pressed.bind(button.container_index, button.get_index()))
				button.connect("swap_items", _on_swap_items)

	for item in starter_items:
		if item.item_type == Item.ItemType.ITEM:
			for x in inventory_items.size():
				if inventory_items[x] != null:
					for y in inventory_items[x].size():
						if inventory_items[x][y] == null:
							inventory_items[x][y] = item.duplicate()
							get_node("GridContainer").get_child(x).get_node("%GridContainer").get_child(y).icon = inventory_items[x][y].item_icon
							break
					break
			

func _on_button_pressed(container_index: int, index: int) -> void:
	print("Button Pressed at index: %d:%d" % [container_index, index])
	if container_index == -1:
		if equipped_bags[index] != null:
			var grid_container = get_node("GridContainer").get_child(index)	
			grid_container.visible = !grid_container.visible

func _on_swap_items(source_container: String, destination_container: String, source_container_index: int, source_index: int, target_container_index: int, target_index: int) -> void:
	print("Swap items in %s from %d:%d to %d:%d" % [source_container, source_container_index, source_index, target_container_index, target_index])

	if source_container == destination_container: # Same container movement
		if source_container == "BagBar":
			if equipped_bags[source_index] == null:
				print("No item to move")
			elif equipped_bags[target_index] == null: # Target is empty, move the item
				equipped_bags.set(target_index, equipped_bags[source_index])
				equipped_bags.set(source_index, null)
				get_node("BagBar/%GridContainer").get_child(target_index).icon = equipped_bags[target_index].item_icon
				get_node("BagBar/%GridContainer").get_child(source_index).icon = null
		elif source_container == "ContainerGrid":
			if inventory_items[source_container_index][source_index] == null:
				print("No item to move")
			elif inventory_items[target_container_index][target_index] == null: # Target is empty, move the item
				inventory_items[target_container_index].set(target_index, inventory_items[source_container_index][source_index])
				inventory_items[source_container_index].set(source_index, null)
				get_node("GridContainer").get_child(target_container_index).get_node("%GridContainer").get_child(target_index).icon = inventory_items[target_container_index][target_index].item_icon
				get_node("GridContainer").get_child(source_container_index).get_node("%GridContainer").get_child(source_index).icon = null
			else:
				print("Failed to move item, target is not empty")

	elif source_container == "BagBar" && destination_container == "ContainerGrid": # Moving from bag bar to container grid
		if equipped_bags[source_index] == null:
			print("No item to move")
		elif inventory_items[target_container_index][target_index] == null: # Target is empty, move the item
			# Check if the bag inventory contains any items, if so we cannot move the bag
			for item in inventory_items[source_index]:
				if item != null:
					print("Cannot move bag, it contains items")
					return
			# Check if we are trying to move the bag into itself
			if source_index == target_container_index:
				print("Cannot move bag into itself")
				return
			# Move the bag
			inventory_items[target_container_index].set(target_index, equipped_bags[source_index])
			equipped_bags.set(source_index, null)
			get_node("GridContainer").get_child(target_container_index).get_node("%GridContainer").get_child(target_index).icon = inventory_items[target_container_index][target_index].item_icon
			get_node("GridContainer").get_child(source_index).hide()
			get_node("BagBar/%GridContainer").get_child(source_index).icon = null
		else:
			print("Failed to move item, target is not empty")
	elif source_container == "ContainerGrid" && destination_container == "BagBar": # Moving from container grid to bag bar
		if inventory_items[source_container_index][source_index] == null:
			print("No item to move")
		elif inventory_items[source_container_index][source_index].item_type != Item.ItemType.BAG:
			print("Cannot move item, only bags can be moved to the bag bar")
		elif equipped_bags[target_index] == null: # Target is empty, move the item
			equipped_bags.set(target_index, inventory_items[source_container_index][source_index])
			inventory_items[source_container_index].set(source_index, null)
			get_node("BagBar/%GridContainer").get_child(target_index).icon = equipped_bags[target_index].item_icon
			get_node("GridContainer").get_child(source_container_index).get_node("%GridContainer").get_child(source_index).icon = null
