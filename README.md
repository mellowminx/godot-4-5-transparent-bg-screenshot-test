# Partial transparency blended with black in screenshot images saved using get_viewport().get_texture().get_image().save_png()
### Update: Found a great workaround! Scroll to the bottom. ✅

This is a Godot MRP showing partially transparent pixels blended with black + hacky workaround.

![](https://github.com/mellowminx/godot-4-5-transparent-bg-screenshot-test/blob/main/game%20vs%20screenshot.png)

Godot v4.5.stable.official [876b29033]

Compatibility mode

MacOS 15.7.1

When using Godot's `get_viewport().get_texture().get_image().save_png()` function to save screenshot images of a game with partially transparent visuals (such as gradients which fade to transparent), using a transparent background window, the partially transparent pixels are blended with black, resulting in a darker (and uglier) image:

![](https://github.com/mellowminx/godot-4-5-transparent-bg-screenshot-test/blob/main/default-preview.png)

`fix_alpha_edges()` or `convert(Image.FORMAT_RGBA8)` or `linear_to_srgb()` don't work to fix this.

[A hacky workaround discussed in this Reddit thread](https://www.reddit.com/r/godot/comments/u2i065/when_rendering_a_viewport_with_transparent/) does work-- using a `CanvasItemMaterial` set to `Premultiplied alpha` blend mode allows the screenshot to be rendered correctly:

![](https://github.com/mellowminx/godot-4-5-transparent-bg-screenshot-test/blob/main/premultalpha-preview.png)

However, the in-game visuals then suffer greatly by having the partially transparent pixels show up as solid white instead.

In this Godot MRP, running the project saves two screenshots-- the default screenshot with the black-blended translucent pixels, and the hacky fixed screenshot. The screenshot images are just saved in the project folder.

In my own game I implemented the hacky workaround so that the material is only applied for a split-second while taking the screenshot, but it's still perceptible as a white flash, very unpleasant.

![](https://github.com/mellowminx/godot-4-5-transparent-bg-screenshot-test/blob/main/game%20vs%20screenshot%20premult%20alpha.png)

# ✅ Workaround: Un-premultiply pixels before saving image
Thanks so much to [normalized](https://forum.godotengine.org/u/normalized/) in [this Godot forum thread](https://forum.godotengine.org/t/partial-transparency-blended-with-black-in-screenshot-images/128560/4) for this solution: "un-premultiply the pixels by dividing RGB values by their alpha before saving. Skip the zero divisions."

![](https://github.com/mellowminx/godot-4-5-transparent-bg-screenshot-test/blob/main/unpremultiplied%20vs%20premultiplied.png)

Code from [normalized](https://forum.godotengine.org/u/normalized/):

```
# just before saving
for j in image_data.get_height():
		for i in image_data.get_width():
			var c = image_data.get_pixel(i, j)
			if c.a > 0:
				c.r /= c.a
				c.g /= c.a
				c.b /= c.a
			image_data.set_pixel(i, j, c)
```

[Godot issue reported as a bug here](https://github.com/godotengine/godot/issues/113103).
