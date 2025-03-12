@tool
extends TextureRect


@onready var img : Image = texture.get_image()
@export var bake : bool = false


func _process(_delta) -> void:
	if bake:
		get_borders_floodfill($Marker2D.position)
		bake = false


func bake_map_data() -> void:
	
	var known_pixels = []
	
	for x in img.get_width():
		for y in img.get_height():
			var p = Vector2i(x, y)
			
			if p in known_pixels:
				continue
			
			var result = get_borders_floodfill(p)
			known_pixels.append(result[1])
			result[0]  # do stuff
	


func get_borders_floodfill(start_pos : Vector2i) -> Array:
	
	var border_color : Color = Color(0,0,0)
	var my_color : Color = img.get_pixelv(start_pos)
	var my_pixels = [start_pos]  # known good pixels
	
	var check_origins = [start_pos]  # active checking zone.
	var border_px = []  # the actual borders you want
	
	var next_check_pass = []
	for i in 10000:
		for checkpx in check_origins:
			
			var n : Vector2i = checkpx + Vector2i.UP
			var s : Vector2i = checkpx + Vector2i.DOWN
			var w : Vector2i = checkpx + Vector2i.LEFT
			var e : Vector2i = checkpx + Vector2i.RIGHT
			
			if img.get_pixelv(n) == my_color and n not in my_pixels:
				my_pixels.append(n)
				next_check_pass.append(n)
			elif img.get_pixelv(n) == border_color and n not in border_px:
				border_px.append(n)
			
			if img.get_pixelv(s) == my_color and s not in my_pixels:
				my_pixels.append(s)
				next_check_pass.append(s)
			elif img.get_pixelv(s) == border_color and s not in border_px:
				border_px.append(s)
			
			if img.get_pixelv(w) == my_color and w not in my_pixels:
				my_pixels.append(w)
				next_check_pass.append(w)
			elif img.get_pixelv(w) == border_color and w not in border_px:
				border_px.append(w)
			
			if img.get_pixelv(e) == my_color and e not in my_pixels:
				my_pixels.append(e)
				next_check_pass.append(e)
			elif img.get_pixelv(e) == border_color and e not in border_px:
				border_px.append(e)
		
		check_origins = []
		check_origins = next_check_pass.duplicate()
		next_check_pass = []
		
		if check_origins.size() == 0:
			break
	
	return [border_px, my_pixels]
