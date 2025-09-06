@tool
extends Button
signal swap_items(source_container: String, target_container: String, source_container_index: int, source_index: int, target_container_index: int, target_index: int)

var parent_container: String = ""
var container_index: int = -1

func _get_drag_data (_position: Vector2) -> Dictionary:
	var preview = Control.new()
	var preview_icon = TextureRect.new()
	preview_icon.texture = icon 
	preview_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_icon.size = Vector2(64,64)
	preview.add_child(preview_icon) 
	set_drag_preview(preview)

	var drag_data = {}
	drag_data["source_container_index"] = container_index
	drag_data["source_index"] = get_index()
	drag_data["source_container"] = parent_container
	return drag_data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.has("source_index")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.has("source_index"):
		var source_container = data["source_container"]
		var source_container_index = data["source_container_index"]
		var source_index = data["source_index"]

		var target_container = parent_container
		var target_container_index = container_index
		var target_index = get_index()
		if source_index != target_index:
			emit_signal("swap_items", source_container, target_container, source_container_index, source_index, target_container_index, target_index)
