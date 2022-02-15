extends Node
"""
This is an autoload class for handling time slicing
This one is set up for the process and physics methods but can be expanded for any method which needs to be sliced
"""

class Slice:
	"""
	A general class for slicing along some commonly called method
	"""
	var num : int = 0
	var current : int = 0
	var id_aggregate : int = 0

	func _init(number : int) -> void:
		self.num = number
		current = 0
		id_aggregate = 0

	func increment() -> void:
		"""
		Increase the current id for next category of sliced calls
		"""
		current += 1;
		current %= num

	func get_new_id() -> int:
		"""
		returns a slice id for a time sliced object to check against
		"""
		id_aggregate += 1
		id_aggregate %= num
		return id_aggregate

var SliceProcess := Slice.new(4) # framerate independant
var SlicePhysics := Slice.new(4) # time sliced runs at 7.5fps for physics here

func _process(_delta: float) -> void:
	SliceProcess.increment()

func _physics_process(_delta: float) -> void:
	SlicePhysics.increment()

func get_current_process_slice() -> int:
	return SliceProcess.current

func get_current_physics_slice() -> int:
	return SlicePhysics.current

func get_new_time_slice_id_process() -> int:
	return SliceProcess.get_new_id()

func get_new_time_slice_id_physics() -> int:
	return SlicePhysics.get_new_id()

func current_process(id : int) -> bool:
	return id == get_current_process_slice()

func current_physics(id : int) -> bool:
	return id == get_current_physics_slice()
