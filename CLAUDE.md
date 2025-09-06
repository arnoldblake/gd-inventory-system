# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.4 inventory system project written in GDScript. The project implements a minimal, opinionated inventory system with starter items and container support.

## Architecture

The inventory system is built around two main components:

### Core Classes
- `Item` (Items/item.gd): Resource class with ItemType enum (ITEM, BAG, KEY, QUEST) and properties: item_name, item_icon, item_description, item_type, container_size, is_stackable
- `Inventory` (Inventory/Inventory.gd): MarginContainer with @tool directive that procedurally generates UI from equipped_bags and inventory_items arrays
- `Button` (Inventory/Button.gd): Custom Button with drag-and-drop functionality, emits swap_items signal

### Key Design Patterns
- Items are Godot Resources (.tres files) that can be duplicated and modified at runtime
- Inventory uses a hybrid approach with bag slots (fixed 5 slots) and container slots (dynamic based on equipped bags)
- Container items (bags) create additional inventory slots based on their container_size property
- UI is generated procedurally in _ready(): creates Button nodes with custom script and connects swap_items signal
- Data structure: equipped_bags[5] for bag slots, inventory_items[5][container_size] for container contents
- Drag-and-drop system using _get_drag_data(), _can_drop_data(), and _drop_data() methods

## Development Commands

### Running the Project
```bash
# Open project in Godot Editor
/Applications/Godot.app/Contents/MacOS/Godot --editor --path .

# Run project directly
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

### VS Code Integration
The project includes VS Code launch configuration for debugging:
- Use "GDScript: Launch Project" debug configuration to launch and debug the project
- Requires the official Godot VS Code extension
- Debug options available: collisions, paths, navigation (currently disabled)

### File Structure
- `Items/`: Contains item definitions (.gd script and .tres resources)
- `Inventory/`: Contains inventory system code and scenes
- `Assets/`: Art assets organized by source (kenney asset packs)
- `project.godot`: Main project configuration

## Working with Items
- Item resources are defined in .tres files referencing the Item class
- New items should extend the Item resource and define appropriate properties
- Icons should reference textures in the Assets folder
- Container items use container_size > 0 to provide additional inventory slots

## Scene Structure
The main inventory scene (Inventory.tscn) uses UniqueNode names (%BagGrid, %ContainerGrid) for reliable node access from scripts. The scene includes:
- MarginContainer root with starter_items Array[Item] property
- BagBar/MarginContainer/%BagGrid for bag slots (populated procedurally)
- Container/MarginContainer/%ContainerGrid for container contents (populated procedurally)

## Implementation Notes
- The @tool directive allows inventory to update in the editor
- Button indices correspond to array positions for item management
- swap_items signal handles drag-and-drop with parent_container identification
- Current limitation: container grid assumes single bag (inventory_items[0])