extends PanelContainer

enum ContainerType {
    NONE,
    ACTION_BAR,
    BAG_BAR,
    INVENTORY 
}

@export var container_type: ContainerType = ContainerType.NONE