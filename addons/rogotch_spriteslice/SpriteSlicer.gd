tool
extends EditorPlugin

#var xml_file_path = "res://Project/Images/space_shooter/spaceShooter2_spritesheet.xml"

var dock = null
var mainGuiPath = "MainVB/"
var select_spritesheet_popup = null
var select_slice_xml_popup = null

var spritesheet_img = null
var spritesheet_path = null
var xml_path = null
var region_img = null
var node_name = null
var rects_options = null

var all_regions = {}
var regions_list = []
var selected_region = null
var add_region_button = null

var spritesheet = null

func _enter_tree():
	dock = preload("res://addons/rogotch_spriteslice/SpriteSlicer_dock.tscn").instance()
	
	dock.get_node(mainGuiPath+"select_spritesheet_box/VBoxImage/select_spritesheet").connect("pressed", self, "select_spriteheet")
	dock.get_node(mainGuiPath+"select_spritesheet_box/ImageContainer/ImagePanel/TextureFrame/tbtn").connect("pressed", self, "select_spriteheet")
	
	spritesheet_img = dock.get_node(mainGuiPath+"select_spritesheet_box/ImageContainer/ImagePanel/TextureFrame")
	spritesheet_path = dock.get_node(mainGuiPath+"select_spritesheet_box/VBoxImage/name/lblName")
	select_spritesheet_popup = dock.get_node("FileDialogs/OpenSpritesheet")
	select_spritesheet_popup.connect("file_selected", self, "selected_spriteheet")
	
	dock.get_node(mainGuiPath+"select_slice_file_box/VBoxImage/select_slice_file").connect("pressed", self, "select_slice_xml")
	xml_path = dock.get_node(mainGuiPath+"select_slice_file_box/VBoxImage/name/lblName")
	select_slice_xml_popup = dock.get_node("FileDialogs/OpenSliceXML")
	select_slice_xml_popup.connect("file_selected", self, "selected_slice_xml")
	
	region_img    = dock.get_node(mainGuiPath+"select_region/ImageContainer/ImagePanel/TextureFrame")
	node_name     = dock.get_node(mainGuiPath+"select_region/VBoxImage/LineEdit")
	rects_options = dock.get_node(mainGuiPath+"select_region/VBoxImage/name/OptionButton")
	rects_options.connect("item_selected", self, "change_region")
	add_region_button = dock.get_node(mainGuiPath+"select_region/VBoxImage/add_region_to_scene")
	add_region_button.connect("pressed", self, "add_region_to_scene")
	add_control_to_dock( DOCK_SLOT_RIGHT_BL, dock )
#	dock.get_node(mainGuiPath+"")
	
#	select_spritesheet_popup.connect()
	pass

func select_spriteheet():
	select_spritesheet_popup.popup_centered_ratio()
	pass

func select_slice_xml():
	select_slice_xml_popup.popup_centered_ratio()
	pass

func selected_spriteheet(image_path):
	spritesheet = load(image_path)
	spritesheet_img.texture = spritesheet
	spritesheet_path.text = image_path
	pass

func selected_slice_xml(file_path):
	all_regions = get_all_regions(file_path)
	xml_path.text = file_path
	regions_list = all_regions.keys()
	
	rects_options.clear()
	var count = 0
	for region in regions_list:
		rects_options.add_item(region, count)
		count += 1
	
	if count > 0:
		rects_options.select(0)
		change_region(0)
	add_region_button.disabled = !(count > 0)
	pass

func change_region(id):
	selected_region = all_regions[regions_list[id]]
	var new_atlas = AtlasTexture.new()
	new_atlas.atlas = spritesheet
	new_atlas.region = selected_region
	region_img.texture = new_atlas
	pass

func add_region_to_scene():
	var _root =  get_tree().get_edited_scene_root()
	print(_root)
	var new_atlas = AtlasTexture.new()
	new_atlas.atlas = spritesheet
	new_atlas.region = selected_region
	region_img.texture = new_atlas
	
	var _newSpriteNode
	_newSpriteNode = Sprite.new()
	_root.add_child(_newSpriteNode)
	_newSpriteNode.set_owner(_root)
	_newSpriteNode.texture = new_atlas
	if node_name.text != null && node_name.text.length() > 0:
		_newSpriteNode.set_name(node_name.text)
#	_newSpriteNode.position = rects[rect_name].position

	pass

#func slice_image(image_path, xml_path):
#	var rects = get_all_regions(xml_path)
#	var spritesheet = load(image_path)
#
#	var _root =  get_tree().get_edited_scene_root()
#
#	for rect_name in rects.keys():
#		var _newSpriteNode
#		if !_root.has_node(rect_name):
#			var new_atlas = AtlasTexture.new()
#			new_atlas.atlas = spritesheet
#			new_atlas.region = rects[rect_name]
#			_newSpriteNode = Sprite.new()
#			_newSpriteNode.texture = new_atlas
#			_newSpriteNode.position = rects[rect_name].position
#	pass

func get_all_regions(xml_file_path) -> Dictionary:
	var parser = XMLParser.new()
	parser.open(xml_file_path)
	
	var all_rects = {}
	while parser.read() == OK:
		var pass_flag = true
		var new_rect = Rect2()
		var sprite_name
		for i in parser.get_attribute_count():
			match parser.get_attribute_name(i):
				"name":
					sprite_name = parser.get_attribute_value(i)
				"x":
					new_rect.position.x = int(parser.get_attribute_value(i))
				"y":
					new_rect.position.y = int(parser.get_attribute_value(i))
				"width":
					new_rect.size.x = int(parser.get_attribute_value(i))
				"height":
					new_rect.size.y = int(parser.get_attribute_value(i))
			if ["x", "y", "width", "height"].has(parser.get_attribute_name(i)):
				pass_flag = false
		if !pass_flag:
			all_rects[sprite_name] = new_rect
	return all_rects
	pass
