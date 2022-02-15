extends KinematicBody

export var view_distance := 10.0
export var speed := 10.0
export var steer_speed := 1.0
export var min_distance := 7.0 
export var poi_min_distance := 10.0

export (Resource) var ItemFishResource : Resource

onready var view_rays_root :Spatial= $view_rays

const DIRS := [
	Vector3(0,0,-1), # forwards

	Vector3(0,1,-2), # 1st order eg N, S, W, E
	Vector3(0,-1,-2),
	Vector3(1,0,-2),
	Vector3(-1,0,-2),

	Vector3(1,1,-3), # 2nd order eg NW, NE, SW, SE
	Vector3(1,-1,-3),
	Vector3(-1,1,-3),
	Vector3(-1,-1,-3),
]

const MAX_Y_POI_LOCATION := 100 # based off on testing in game


const POI_INFLUENCE := 5.0
const POI_RANGE_ALL := 100.0
const POI_RANGE := Vector3(POI_RANGE_ALL,POI_RANGE_ALL,POI_RANGE_ALL)

var ViewRays := []

# view information
var Colliding := []
var CollisionDistance := []

var steer_dir := Vector3()

var poi := Vector3()

# var time_slice_id_process : int
var time_slice_id_physics : int

func _ready() -> void:
	for _i in range(DIRS.size()):
		Colliding.append(false)
		CollisionDistance.append(0.0)
	gen_view_rays()
	randomize()
	create_new_poi()
	# time_slice_id_process = TimeSlice.get_new_time_slice_id_process()
	time_slice_id_physics = TimeSlice.get_new_time_slice_id_physics()

func rand_vec3() -> Vector3:
	return Vector3(rand_range(-1,1),rand_range(-1,1),rand_range(-1,1))

func gen_view_rays() -> void:
	for dir in DIRS:
		var ray := RayCast.new()
		view_rays_root.add_child(ray)
		ray.exclude_parent = true
		ray.enabled = true
		ray.cast_to = (dir as Vector3).normalized() * view_distance
		ViewRays.append(ray)
		
func refresh_view_info() -> void:
	for i in range(ViewRays.size()):
		var ray := ViewRays[i] as RayCast
		Colliding[i] = ray.is_colliding()
		if Colliding[i]:
			var delta :Vector3= view_rays_root.global_transform.origin - ray.get_collision_point()
			var dist = delta.length()
			if dist < min_distance:
				dist = 0.0
			CollisionDistance[i] = dist 
		else:
			CollisionDistance[i] = view_distance * 1.5

func get_dir(index : int) -> Vector3:
	#return DIRS[index].normalized()
	return global_transform.basis.xform(DIRS[index])

func create_new_poi() -> void:
	# TODO also set a timer for this in case the fish gets stuck?
	poi = global_transform.origin + POI_RANGE * rand_vec3()
	# this keeps them from swimming above the surface
	poi.y = min(poi.y, MAX_Y_POI_LOCATION)

func get_steer_dir() -> Vector3:
	var composite := Vector3()
	var flag := true
	for i in range(ViewRays.size()):
		var inf := 1.0
		var dir := get_dir(i)
		if Colliding[i]:
			inf *= 0.0 #(CollisionDistance[i] / view_distance) # closer collision = weaker interest
		else:
			flag = false
		
		composite += dir * inf
	var poi_delta := (poi - global_transform.origin) as Vector3
	if poi_delta.length() < poi_min_distance or flag:
		create_new_poi()
	composite += poi_delta.normalized() * POI_INFLUENCE * (poi_delta.length() / poi_min_distance)  
	return composite

func _physics_process(delta: float) -> void:
	if TimeSlice.current_physics(time_slice_id_physics):
		refresh_view_info() # physics checks happen here. Could do some frame splitting to make this more performant
	var steer := get_steer_dir() # this only uses the LUTs for logic, no need to split
	steer_dir = steer.normalized()
	rotate_body(delta)
	var _temp = move_and_slide(steer_dir * speed)

func rotate_body(delta : float) -> void:
	var dir := steer_dir
	var target_pos := global_transform.origin + dir
	var target := global_transform.interpolate_with(global_transform.looking_at(target_pos, Vector3.UP), steer_speed * delta)
	global_transform = target.orthonormalized()
