# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.4 inventory system implemented as an addon plugin. The project creates a minimal, opinionated inventory system with drag-and-drop functionality, supporting bags as containers and starter items.

## Architecture

### Plugin Structure
This is structured as a Godot addon located in `addons/gd-inventory-system/`:
- `plugin.cfg`: Defines the plugin metadata (name: "GD Inventory System", author: "Blake Arnold")
- `inventory_system.gd`: Main plugin script extending EditorPlugin (currently minimal)
- The plugin is enabled in `project.godot` under `[editor_plugins]`

### Core Classes
- `Item` (addons/gd-inventory-system/Items/item.gd): Resource class with ItemType enum (ITEM, BAG, KEY, QUEST) and properties: item_name, item_icon, item_description, item_type, container_size, is_stackable, max_stack_size
- `Inventory` (addons/gd-inventory-system/Inventory/Inventory.gd): MarginContainer with @tool directive that procedurally generates UI from equipped_bags and inventory_items arrays
- `Button` (addons/gd-inventory-system/Inventory/Button.gd): Custom Button with drag-and-drop functionality, emits swap_items signal
- `ItemGridContainer` (addons/gd-inventory-system/Inventory/item_grid_container.gd): GridContainer class with ContainerType enum (NONE, ACTION_BAR, BAG_BAR, INVENTORY)

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
- `addons/gd-inventory-system/`: Main addon directory
  - `Items/`: Contains item definitions (.gd script and .tres resources)
  - `Inventory/`: Contains inventory system code and scenes (Inventory.tscn, InventoryContainer.tscn)
  - `Assets/`: Art assets organized by source (kenney asset packs)
  - `plugin.cfg`: Plugin configuration
  - `inventory_system.gd`: Main plugin script
- `project.godot`: Main project configuration with plugin enabled

## Working with Items
- Item resources are defined in .tres files referencing the Item class
- New items should extend the Item resource and define appropriate properties
- Icons should reference textures in the Assets folder
- Container items (bags) use container_size > 0 to provide additional inventory slots
- Items support stacking with is_stackable boolean and max_stack_size property

## Scene Structure
The inventory system uses two main scenes:
- `Inventory.tscn`: Main inventory scene with MarginContainer root and starter_items Array[Item] property
- `InventoryContainer.tscn`: Template for individual bag containers with GridContainer and close button

Key UniqueNode names for reliable script access:
- `%GridContainer`: Used in both bag bar and container grids
- `%CloseButton`: Close button for inventory containers

## Implementation Notes
- The @tool directive allows inventory to update in the editor
- Button indices correspond to array positions for item management
- swap_items signal handles complex drag-and-drop logic between bag bar and container grids
- Supports movement between bag slots, from bags to containers, and container to bag (bags only)
- Container visibility is toggled by clicking bag buttons in the bag bar
- Bags cannot be moved if they contain items or if moving into themselves
- Dynamic button instantiation ensures proper UI updates when bags are moved between slots
- Container buttons are automatically created/cleared based on bag container_size when bags are equipped/unequipped

## Current Features (v1.0)
- Drag-and-drop inventory management with visual feedback
- 5-slot bag bar for equipping container items (bags)
- Dynamic inventory containers based on equipped bags
- Item validation (only bags can go in bag bar, bags can't move if they contain items)
- Container visibility toggling by clicking bag icons
- Automatic button instantiation when moving bags between slots
- Support for different item types (ITEM, BAG, KEY, QUEST)
- Starter items configuration for initial inventory setup