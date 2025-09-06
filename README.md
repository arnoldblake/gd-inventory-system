# Inventory System

A minimal, opinionated GDScript inventory system addon for Godot 4.4 with drag-and-drop functionality, starter items, and container support.

## Features

- **Plugin-based**: Structured as a Godot addon for easy integration into existing projects
- **Hybrid inventory design**: Quick-access bag slots (5 fixed slots) + expandable container storage
- **Item types**: Support for items, bags, keys, and quest items with custom properties
- **Drag-and-drop interface**: Intuitive item management with visual feedback and complex movement rules
- **Container system**: Bags provide additional storage slots based on their container_size
- **Resource-based items**: Items defined as .tres files that can be duplicated and modified at runtime
- **Item stacking**: Configurable stacking support with max_stack_size property

## Installation

1. Copy the `addons/inventory_system/` directory to your project's `addons/` folder
2. Enable the plugin in Project Settings → Plugins → "Inventory System"

## Usage

To add an inventory to your scene:
1. Instance the `Inventory.tscn` scene from `addons/inventory_system/Inventory/Inventory.tscn`
2. Configure the `starter_items` array in the inspector to define initial inventory items
3. The inventory will automatically generate UI for bag slots and container grids based on equipped bags

## Architecture

### Core Components
- **Item Resource**: Godot Resources with configurable properties (name, icon, description, type, container_size, stackable)
- **Inventory Scene**: Main MarginContainer that procedurally generates UI from equipped bags and inventory items
- **Button Component**: Custom drag-and-drop buttons with swap_items signal for item movement
- **Container System**: Dynamic inventory containers that appear when bags are equipped

### File Structure
- `addons/inventory_system/Items/`: Item definitions (.gd script and .tres resources)
- `addons/inventory_system/Inventory/`: Main inventory scenes (Inventory.tscn, InventoryContainer.tscn)
- `addons/inventory_system/Assets/`: Art assets (kenney asset packs)

## Item Movement Rules

- **Within same container**: Items can be moved freely between slots
- **Bag to container**: Bags can be moved from bag slots to container slots if empty
- **Container to bag**: Only bags can be moved from containers to bag slots
- **Restrictions**: Bags cannot be moved if they contain items or into themselves

## ToDo
- Implement right click on items
- Add item tooltips and descriptions
- Implement item consumption/usage system