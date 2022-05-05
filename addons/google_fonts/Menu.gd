tool
extends PanelContainer

signal update_filesystem

onready var tree:Tree = $split/box/Tree
onready var text:TextEdit = $split/PanelContainer/VBoxContainer/TextEdit
onready var http:HTTPRequest = $HTTPRequest
onready var saveb:Button = $split/PanelContainer/VBoxContainer/save

var fonts
var tree_map = {}
var tree_map_index = 0
var display_type = 0
var font_name := ''

var dummy = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\neiusmod tempor incididunt ut labore et dolore magna aliqua.\nUt enim ad minim veniam, quis nostrud exercitation ullamco\nlaboris nisi ut aliquip ex ea commodo consequat.\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\nExcepteur sint occaecat cupidatat non proident,\nsunt in culpa qui officia deserunt mollit anim id est laborum.'


func load_json(path):
	var file = File.new()
	if file.open(path, file.READ) != OK:
		return
	var data_text = file.get_as_text()
	file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	return data_parse.result
	


func save_json(path, data:Dictionary):
	var file = File.new()
	if file.open(path, file.WRITE) != OK:
		return
	file.store_string(JSON.print(data))
	file.close()


func update_font_file():
	var response = load_json("res://addons/google_fonts/response.json")
	var files = {}
	for r in response['tree']:
		if  not r['path'].begins_with('.') and '/' in r['path']:
			var p = r['path'].split('/')
			var pointer = files
			for pp in p:
				if not pointer.has(pp):
					pointer[pp] = {}
				if not '.' in pp:
					pointer = pointer[pp]
				else:
					pointer[pp] = r['url']
#	print(Marshalls.base64_to_utf8('IyBPbmx5IHJ1biBnZnRvb2xzIHFhIG9uIHBycyB3aGljaCBoYXZlIG1vZGlm\naWVkIGZpbGVzIGluIGRpcmVjdG9yaWVzIHdoaWNoCiMgY29udGFpbiBmb250\nIGJpbmFyaWVzLgoKIyBGaW5kIGRpcmVjdG9yaWVzIHdoaWNoIGNvbnRhaW4g\nZmlsZXMgdGhhdCBoYXZlIGJlZW4gYWx0ZXJlZCBvciBhZGRlZC4gQWxzbwoj\nIFNraXAgL3N0YXRpYyBkaXJlY3Rvcmllcy4KQ0hBTkdFRF9ESVJTPSQoZ2l0\nIGRpZmYgb3JpZ2luL21haW4gLS1kaXJzdGF0PWZpbGVzIC0tZGlmZi1maWx0\nZXIgZCB8IHNlZCAicy9bMC05LiBdLiolLy9nIiB8IGdyZXAgLXYgInN0YXRp\nYyIpCk9VVD1vdXQKClBSX1VSTD0iJEdJVEhVQl9TRVJWRVJfVVJMLyRHSVRI\nVUJfUkVQT1NJVE9SWS9wdWxsLyRQUl9OVU1CRVIiCmVjaG8gIlBSIHVybDog\nJFBSX1VSTCIKCmZvciBkaXIgaW4gJENIQU5HRURfRElSUwpkbwogICAgZm9u\ndF9jb3VudD0kKGxzIC0xICRkaXIqLnR0ZiAyPi9kZXYvbnVsbCB8IHdjIC1s\nKQogICAgaXNfZGVzaWduZXJfZGlyPSQoZWNobyAkZGlyIHwgZ3JlcCAiZGVz\naWduZXJzIikKICAgIGlmIFsgJGZvbnRfY291bnQgIT0gMCBdCiAgICB0aGVu\nCgllY2hvICJDaGVja2luZyAkZGlyIgoJbWtkaXIgLXAgJE9VVAoJIyBJZiBw\nciBjb250YWlucyBtb2RpZmllZCBmb250cywgY2hlY2sgd2l0aCBGb250YmFr\nZXJ5LCBEaWZmZW5hdG9yIGFuZCBEaWZmQnJvd3NlcnMuCgkjIElmIHByIGRv\nZXNuJ3QgY29udGFpbiBtb2RpZmllZCBmb250cywganVzdCBjaGVjayB3aXRo\nIEZvbnRiYWtlcnkuCgltb2RpZmllZF9mb250cz0kKGdpdCBkaWZmIC0tbmFt\nZS1vbmx5IG9yaWdpbi9tYWluIEhFQUQgJGRpcioudHRmKQoJaWYgWyAtbiAi\nJG1vZGlmaWVkX2ZvbnRzIiBdCgl0aGVuCgkgICAgZWNobyAiRm9udHMgaGF2\nZSBiZWVuIG1vZGlmaWVkLiBDaGVja2luZyBmb250cyB3aXRoIGFsbCB0b29s\ncyIKCSAgICBnZnRvb2xzIHFhIC1mICRkaXIqLnR0ZiAtZ2ZiIC1hIC1vICRP\nVVQvJChiYXNlbmFtZSAkZGlyKV9xYSAtLW91dC11cmwgJFBSX1VSTAoJZWxz\nZQoJICAgIGVjaG8gIkZvbnRzIGhhdmUgbm90IGJlZW4gbW9kaWZpZWQuIENo\nZWNraW5nIGZvbnRzIHdpdGggRm9udGJha2VyeSBvbmx5IgoJICAgIGdmdG9v\nbHMgcWEgLWYgJGRpcioudHRmIC0tZm9udGJha2VyeSAtbyAkT1VULyQoYmFz\nZW5hbWUgJGRpcilfcWEgLS1vdXQtdXJsICRQUl9VUkwKCWZpCiAgICBlbGlm\nIFsgISAteiAkaXNfZGVzaWduZXJfZGlyIF0KICAgIHRoZW4KICAgICAgICBl\nY2hvICJDaGVja2luZyBkZXNpZ25lciBwcm9maWxlIgogICAgICAgIHB5dGVz\ndCAuY2kvdGVzdF9wcm9maWxlcy5weSAkZGlyCiAgICBlbHNlCgllY2hvICJT\na2lwcGluZyAkZGlyLiBEaXJlY3RvcnkgZG9lcyBub3QgY29udGFpbiBmb250\ncyIKICAgIGZpCmRvbmUKCg==\n')
	save_json('res://addons/google_fonts/fonts.json', files)
	print('fonts updated')
	return files


func populate_branch(tree, root, pointer:Dictionary):
	for p in pointer.keys():
		var branch = tree.create_item(root)
		branch.set_text(0, p)
		if typeof(pointer[p]) == TYPE_DICTIONARY:
			populate_branch(tree, branch, pointer[p])
		else:
			branch.set_meta('url', pointer[p])

func populate_tree():
	tree.clear()
	var root = tree.create_item()
	populate_branch(tree, root, fonts)


func _ready():
	var f = File.new()
	if f.file_exists('res://addons/google_fonts/fonts.json'):
		fonts = load_json("res://addons/google_fonts/fonts.json")
	else:
		fonts = update_font_file()
	populate_tree()
	saveb.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tree_cell_selected():
	var selected = tree.get_selected()
	if 'ttf' in selected.get_text(0): 
		display_type = 1
		font_name =  selected.get_text(0)
	else: 
		display_type = 0
		font_name = ''
		saveb.hide()
	var url = selected.get_meta('url')
	if url != null: 
		http.request(url)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		if display_type == 0:
			var content = Marshalls.base64_to_utf8(JSON.parse(body.get_string_from_utf8()).result['content'])
			text.text = content
			text.set("custom_fonts/font", null)
			saveb.hide()
		else:
			var f = DynamicFont.new()
			text.set("custom_fonts/font", f)
			var data = Marshalls.base64_to_raw(JSON.parse(body.get_string_from_utf8()).result['content'])
			var dir = Directory.new()
			var file = File.new()
			if file.file_exists('res://addons/google_fonts/test.ttf'):
				if dir.remove('res://addons/google_fonts/test.ttf') != OK:
					print('unabel to delete')
			file.open('res://addons/google_fonts/test.ttf', file.WRITE)
			file.store_buffer(data)
			file.close()
			text.text = dummy
			f.font_data = load('res://addons/google_fonts/test.ttf')
			saveb.show()


func _on_save_pressed():
	if font_name != '':
		var dir = Directory.new()
		dir.copy('res://addons/google_fonts/test.ttf', 'res://' + font_name)
		emit_signal('update_filesystem')


func _on_Button_pressed():
	_ready()
