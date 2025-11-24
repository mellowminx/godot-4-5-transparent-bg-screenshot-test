# This test project shows how Godot's screen capture renders
# partially transparent pixels incorrectly by blending
# them with black by default

# Running the same saves two screenshot PNG images in the 
# game project folder-- one showing the default rendering
# with partially transparent pixels blended with black
# And the other showing the correctly rendered partially
# transparent pixels using a hacky workaround

# The hacky workaround is to use CanvasItemMaterial set to
# Premultiplied Alpha mode-- this makes the saved PNG
# image  but it severely affects the in-game appearance of
# visuals by making partially transparent pixels show up as
# solid white in-game

extends Node2D

@export var sprite: Sprite2D

func _ready() -> void:

	var _rid = get_tree().get_root().get_viewport_rid()
	RenderingServer.viewport_set_transparent_background(_rid, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	RenderingServer.set_default_clear_color(Color(1.0, 1.0, 1.0, 0.0))
	get_viewport().transparent_bg = true
	
	await RenderingServer.frame_post_draw
	save_screenshot()
	await RenderingServer.frame_post_draw
	save_screenshot_premultalpha()

func save_screenshot() -> void:
	var path := ""
	_check_and_create_dir(path)
	await RenderingServer.frame_post_draw
	var viewport_texture = get_viewport().get_texture()
	var image_data = viewport_texture.get_image()
	image_data.save_png(path + Time.get_datetime_string_from_system().replace(":", "-") + "-" + str(Time.get_ticks_usec()) + ".png")

func save_screenshot_premultalpha() -> void:
	var path := ""
	_check_and_create_dir(path)
	sprite.toggle_material(true)
	await RenderingServer.frame_post_draw
	var viewport_texture = get_viewport().get_texture()
	var image_data = viewport_texture.get_image()
	sprite.toggle_material(false)
	image_data.save_png(path + Time.get_datetime_string_from_system().replace(":", "-") + "-" + str(Time.get_ticks_usec()) + "premultalpha-" + ".png")

func _check_and_create_dir(path: String) -> void:
	var dir_path := path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
