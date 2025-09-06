@tool
extends Button
signal swap_items(container: String, source_index: int, target_index: int)

var parent_container: String = ""

func _get_drag_data (_position: Vector2) -> Dictionary:
	var preview = Control.new()
	var preview_icon = TextureRect.new()
	preview_icon.texture = icon 
	preview_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_icon.size = Vector2(64,64)
	preview.add_child(preview_icon) 
	set_drag_preview(preview)

	var drag_data = {}
	drag_data["source_index"] = get_index()
	return drag_data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data.has("source_index")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.has("source_index"):
		var source_index = data["source_index"]
		var target_index = get_index()
		if source_index != target_index:
			emit_signal("swap_items", parent_container, source_index, target_index)