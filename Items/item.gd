class_name Item extends Slottable

enum ItemType {
    ITEM,
    BAG,
    KEY,
    QUEST
}

@export var item_icon: Texture2D
@export var item_description: String = "Item Description"
@export var item_type: ItemType = ItemType.ITEM
@export var container_size: int = 0
@export var is_stackable: bool = false
@export var max_stack_size: int = 5
@export var quantity: int = 1