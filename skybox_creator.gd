@tool
extends EditorScript

func _run():
	var paths := [
		"res://ShiverfrostSkybox/px.png",  # +X (right)
		"res://ShiverfrostSkybox/nx.png",  # -X (left)
		"res://ShiverfrostSkybox/py.png",  # +Y (up)
		"res://ShiverfrostSkybox/ny.png",  # -Y (down)
		"res://ShiverfrostSkybox/pz.png",  # +Z (back)
		"res://ShiverfrostSkybox/nz.png",  # -Z (front)
	]

	var faces: Array[Image] = []
	for p in paths:
		var tex := load(p) as Texture2D
		if tex == null:
			push_error("Could not load: " + p)
			return
		faces.append(tex.get_image())

	var cubemap := Cubemap.new()
	cubemap.create_from_images(faces)

	var err := ResourceSaver.save(cubemap, "res://sky.tres")
	if err == OK:
		print("Cubemap saved to res://ShiverfrostSkybox.cubemap")
	else:
		push_error("Save failed: " + str(err))
