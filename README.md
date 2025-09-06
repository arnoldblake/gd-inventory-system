# Inventory System

A minimal, opinionated GDScript inventory system for Godot 4.4 with starter items and container support.

## Features

- **Hybrid inventory design**: Quick-access bag slots (5 fixed slots) + expandable container storage
- **Item types**: Support for items, bags, keys, and quest items with custom properties
- **Drag-and-drop interface**: Intuitive item management with visual feedback
- **Container system**: Bags provide additional storage slots based on their container_size
- **Resource-based items**: Items defined as .tres files that can be duplicated and modified at runtime

## Quick Start

Open the project in Godot 4.4 and run the scene. The inventory comes pre-populated with sample items including a bag and consumables.

## Architecture

- Items are Godot Resources with configurable properties (name, icon, description, type, stackable)
- Inventory UI is generated procedurally with custom Button nodes supporting drag-and-drop
- Uses UniqueNode references (%BagGrid, %ContainerGrid) for reliable scene access 

## ToDo
- Create scenes for button for easier and simpler node creation.
- Support for multiple bags
- Drag and Drop between bags and from BagBar to inventory
- Implement right click on items