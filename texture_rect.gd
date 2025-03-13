@tool
extends TextureRect


@onready var img : Image = texture.get_image()
@export var bake : bool = false


func _process(_delta) -> void:
	if bake:
		create_polygon($Marker2D.position)
		bake = false


func create_polygon(at_pos : Vector2i) -> void:
	var sorted : Array = sort_border_pixels(get_border_pixels(at_pos))
	var optimized : Array = optimize_sorted_border_pixels(sorted)
	
	var poly : Polygon2D = Polygon2D.new()
	poly.polygon = optimized.duplicate()
	add_child(poly)
	poly.set_owner(get_tree().edited_scene_root)


func optimize_sorted_border_pixels(border_pixels : Array) -> Array:
	var corners : Array = []
	
	for i in range(1, border_pixels.size()-1):
		var line_segment_before : Vector2 = border_pixels[i] - border_pixels[i-1]
		var line_segment_after : Vector2 = border_pixels[i+1] - border_pixels[i]
		
		if line_segment_after.cross(line_segment_before) == 0:  # parallel
			continue
		else:
			corners.append(border_pixels[i])
	
	return corners


func sort_border_pixels(border_pixels: Array):
	var sorted = [border_pixels[0]]
	var current_base_px : Vector2i = border_pixels[0]
	
	while true:
		var found_next : bool = false
		
		var check_pxs : Array = [
			current_base_px + Vector2i.DOWN,
			current_base_px + Vector2i.UP,
			current_base_px + Vector2i.LEFT,
			current_base_px + Vector2i.RIGHT,
			
			current_base_px + Vector2i.UP + Vector2i.LEFT,
			current_base_px + Vector2i.UP + Vector2i.RIGHT,
			current_base_px + Vector2i.DOWN + Vector2i.LEFT,
			current_base_px + Vector2i.DOWN + Vector2i.RIGHT,
		]
		for current_check in check_pxs:
			if img.get_pixelv(current_check) == Color(0,0,0) and not current_check in sorted and current_check in border_pixels:
				sorted.append(current_check)
				current_base_px = current_check
				found_next = true
				break
		
		if not found_next:
			return sorted


func get_border_pixels(start_pos : Vector2i) -> Array:
	
	var known_pixels : Array = [start_pos]
	var border : Array = []
	
	var next_check_pass = [start_pos]
	
	while not next_check_pass.is_empty():
		for cp in next_check_pass.duplicate():
			next_check_pass = []
			var neighbors : Array = [  # neighbots of each pixel in check pass
				cp + Vector2i.UP,
				cp + Vector2i.DOWN,
				cp + Vector2i.LEFT,
				cp + Vector2i.RIGHT
			]
			for n in neighbors:
				if n in known_pixels:  # avoid check pixels re-marking each other
					continue
				
				if img.get_pixelv(n) == Color(0,0,0) and n not in border:
					border.append(n)
				elif img.get_pixelv(n) == Color(1,1,1) and n not in known_pixels:
					known_pixels.append(n)
					next_check_pass.append(n)
	
	return border


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
			
			if n.y > 0:
				if img.get_pixelv(n) == my_color and n not in my_pixels:
					my_pixels.append(n)
					next_check_pass.append(n)
				elif img.get_pixelv(n) == border_color and n not in border_px:
					border_px.append(n)
			
			if s.y < img.get_height():
				if img.get_pixelv(s) == my_color and s not in my_pixels:
					my_pixels.append(s)
					next_check_pass.append(s)
				elif img.get_pixelv(s) == border_color and s not in border_px:
					border_px.append(s)
			
			if w.x > 0:
				if img.get_pixelv(w) == my_color and w not in my_pixels:
					my_pixels.append(w)
					next_check_pass.append(w)
				elif img.get_pixelv(w) == border_color and w not in border_px:
					border_px.append(w)
			
			if e.x < img.get_width():
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
	
	return border_px
