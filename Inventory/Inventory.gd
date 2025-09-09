@tool
extends MarginContainer

@export var bag_slot_quantity: int = 5
@export var starter_items: Array[Item]
@export var container_scene: PackedScene = preload("res://addons/gd-inventory-system/Inventory/InventoryContainer.tscn")
@onready var equipped_bags: Array[Array] = []
@onready var inventory_items: Array[Array] = []


func create_button() -> Button:
	var button = Button.new()
	button.set_script(preload("res://addons/gd-inventory-system/Inventory/Button.gd"))
	button.expand_icon = true
	button.custom_minimum_size = Vector2(64,64)
	button.size = Vector2(64,64)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return button

func get_item_at(container_type: ItemGridContainer.ContainerType, container_index: int, slot_index: int) -> Item:
	if container_type == ItemGridContainer.ContainerType.BAG_BAR:
		return equipped_bags[container_index][slot_index]
	else:
		return inventory_items[container_index][slot_index]

func set_item_at(container_type: ItemGridContainer.ContainerType, container_index: int, slot_index: int, item: Item) -> void:
	if container_type == ItemGridContainer.ContainerType.BAG_BAR:
		equipped_bags[0][slot_index] = item
	else:
		inventory_items[container_index][slot_index] = item

func is_slot_empty(container_type: ItemGridContainer.ContainerType, container_index: int, slot_index: int) -> bool:
	return get_item_at(container_type, container_index, slot_index) == null

func _ready() -> void:
	equipped_bags.resize(1)
	equipped_bags[0] = []
	equipped_bags[0].resize(bag_slot_quantity)
	inventory_items.resize(bag_slot_quantity)
	var container: PanelContainer = container_scene.instantiate()
	container.get_node("%GridContainer").container_type = ItemGridContainer.ContainerType.BAG_BAR
	container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(container)

	for item in starter_items:
		if item.item_type == Item.ItemType.BAG:
			for i in equipped_bags[0].size():
				if equipped_bags[0][i] == null:
					equipped_bags[0][i] = item.duplicate()
					inventory_items[i] = []
					inventory_items[i].resize(item.container_size)
					break

	var bag_grid = container.get_node("%GridContainer") as GridContainer
	bag_grid.columns = bag_slot_quantity
	container.get_node("MarginContainer/VBoxContainer/HBoxContainer").hide()
	for n in bag_slot_quantity:
		var button = create_button() 
		if equipped_bags[0][n] != null && equipped_bags[0].size() > n:
			button.icon = equipped_bags[0][n].item_icon
		bag_grid.add_child(button)
		button.container_index = 0
		button.pressed.connect(_on_button_pressed.bind(ItemGridContainer.ContainerType.BAG_BAR, button.container_index, button.get_index()))
		button.connect("swap_items", _on_swap_items)

	# Instance the inventory containers and add to scene
	for i in bag_slot_quantity:
		container = container_scene.instantiate()
		get_node("GridContainer").add_child(container)
		container.get_node("%GridContainer").container_type = ItemGridContainer.ContainerType.INVENTORY
		container.hide()
		var close_button = container.get_node("%CloseButton")
		close_button.pressed.connect(container.hide)

	# If a bag is equipped, populate the inventory grid with buttons
	for i in equipped_bags[0].size():
		if equipped_bags[0][i] != null:
			var inventory_container = get_node("GridContainer").get_child(i)
			inventory_container.show()
			var grid_container = inventory_container.get_node("%GridContainer") as GridContainer
			for j in equipped_bags[0][i].container_size:
				var button = create_button() 
				grid_container.add_child(button)
				button.container_index = inventory_container.get_index()
				button.pressed.connect(_on_button_pressed.bind(ItemGridContainer.ContainerType.INVENTORY, button.container_index, button.get_index()))
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
			
func _validate_movement(source_container_type: ItemGridContainer.ContainerType, destination_container_type: ItemGridContainer.ContainerType, source_item: Item, source_index: int, target_container_index: int) -> bool:
	if destination_container_type == ItemGridContainer.ContainerType.BAG_BAR and source_item.item_type != Item.ItemType.BAG:
		print("Only bags can be moved to the bag bar")
		return false
	
	if source_item.item_type == Item.ItemType.BAG and source_container_type == ItemGridContainer.ContainerType.BAG_BAR:
		return _validate_bag_movement(source_index, target_container_index)
	
	return true

func _validate_bag_movement(source_index: int, target_container_index: int) -> bool:
	if inventory_items[source_index] != null:
		for item in inventory_items[source_index]:
			if item != null:
				print("Cannot move bag, it contains items")
				return false
	
	if source_index == target_container_index:
		print("Cannot move bag into itself")
		return false
	
	return true

func _on_button_pressed(container_type: ItemGridContainer.ContainerType, container_index: int, index: int) -> void:
	if container_type == ItemGridContainer.ContainerType.BAG_BAR:
		if equipped_bags[0][index] != null:
			var grid_container = get_node("GridContainer").get_child(index)	
			grid_container.visible = !grid_container.visible

func _update_ui_after_move(source_container_type: ItemGridContainer.ContainerType, destination_container_type: ItemGridContainer.ContainerType, source_container_index: int, source_index: int, target_container_index: int, target_index: int, moved_item: Item) -> void:
	if destination_container_type == ItemGridContainer.ContainerType.BAG_BAR:
		get_node("PanelContainer/%GridContainer").get_child(target_index).icon = moved_item.item_icon if moved_item else null
	else:
		get_node("GridContainer").get_child(target_container_index).get_node("%GridContainer").get_child(target_index).icon = moved_item.item_icon if moved_item else null
	
	if source_container_type == ItemGridContainer.ContainerType.BAG_BAR:
		get_node("PanelContainer/%GridContainer").get_child(source_index).icon = null
	else:
		get_node("GridContainer").get_child(source_container_index).get_node("%GridContainer").get_child(source_index).icon = null

func _instantiate_container_buttons(container_index: int, bag_item: Item) -> void:
	var inventory_container = get_node("GridContainer").get_child(container_index)
	var grid_container = inventory_container.get_node("%GridContainer") as GridContainer
	
	# Clear existing buttons
	for child in grid_container.get_children():
		child.queue_free()
	
	# Create new buttons for the bag's container size
	for j in bag_item.container_size:
		var button = create_button()
		grid_container.add_child(button)
		button.container_index = container_index
		button.index = j
		button.pressed.connect(_on_button_pressed.bind(ItemGridContainer.ContainerType.INVENTORY, button.container_index, button.index))
		button.connect("swap_items", _on_swap_items)

func _handle_bag_container_visibility(source_index: int, target_index: int) -> void:
	get_node("GridContainer").get_child(source_index).hide()
	
	# Instantiate buttons for the newly equipped bag
	var target_bag = equipped_bags[0][target_index]
	if target_bag != null:
		_instantiate_container_buttons(target_index, target_bag)
		get_node("GridContainer").get_child(target_index).show()

func _on_swap_items(source_container_type: ItemGridContainer.ContainerType, destination_container_type: ItemGridContainer.ContainerType, source_container_index: int, source_index: int, target_container_index: int, target_index: int) -> void:
	var source_item = get_item_at(source_container_type, source_container_index, source_index)
	
	if source_item == null:
		print("No item to move")
		return
	
	if not is_slot_empty(destination_container_type, target_container_index, target_index):
		print("Target slot is not empty")
		return
	
	if not _validate_movement(source_container_type, destination_container_type, source_item, source_index, target_container_index):
		return
	
	set_item_at(destination_container_type, target_container_index, target_index, source_item)
	set_item_at(source_container_type, source_container_index, source_index, null)
	
	_update_ui_after_move(source_container_type, destination_container_type, source_container_index, source_index, target_container_index, target_index, source_item)
	
	if source_item.item_type == Item.ItemType.BAG:
		_handle_bag_container_visibility(source_index, target_index)
