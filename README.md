# Inventory System

A minimal, opinionated GDScript inventory system addon for Godot 4.4 with drag-and-drop functionality, starter items, and container support.

## Features

- **Plugin-based**: Structured as a Godot addon for easy integration into existing projects
- **Hybrid inventory design**: Quick-access bag slots (5 fixed slots) + expandable container storage
- **Item types**: Support for items, bags, keys, and quest items with custom properties
- **Drag-and-drop interface**: Intuitive item management with visual feedback and movement validation
- **Container system**: Bags provide additional storage slots based on their container_size
- **Dynamic UI**: Automatic button creation/removal when bags are equipped/unequipped
- **Container toggling**: Click bag icons to show/hide inventory containers
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

### Interaction
- **Drag and drop**: Click and drag items between slots
- **Container access**: Click bag icons in the bag bar to toggle their inventory containers
- **Close containers**: Use the close button (X) on container windows
- **Movement validation**: Only valid moves are allowed (bags to bag bar, items anywhere, etc.)

## Architecture

### Core Components
- **Item Resource**: Godot Resources with configurable properties (name, icon, description, type, container_size, stackable)
- **Inventory Scene**: Main MarginContainer that procedurally generates UI from equipped bags and inventory items  
- **Button Component**: Custom drag-and-drop buttons with swap_items signal for item movement
- **ItemGridContainer**: GridContainer with ContainerType enum for different container types
- **Container System**: Dynamic inventory containers that appear when bags are equipped with automatic button management

### File Structure
- `addons/inventory_system/Items/`: Item definitions (.gd script and .tres resources)
- `addons/inventory_system/Inventory/`: Main inventory scenes (Inventory.tscn, InventoryContainer.tscn)
- `addons/inventory_system/Assets/`: Art assets (kenney asset packs)

## Item Movement Rules

- **Within same container**: Items can be moved freely between slots
- **Bag bar to container**: Bags can be moved from bag slots to container slots if empty  
- **Container to bag bar**: Only bags can be moved from containers to bag slots
- **Bag bar movement**: Bags can be moved between bag bar slots (buttons auto-instantiate)
- **Restrictions**: 
  - Bags cannot be moved if they contain items
  - Bags cannot be moved into themselves
  - Only bags can occupy bag bar slots

## ToDo
- Implement right click on items
- Add item tooltips and descriptions
- Implement item consumption/usage system