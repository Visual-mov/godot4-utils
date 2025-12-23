extends Node
class_name VUtils

## last updated: 11/15/25
## colletion of useful methods

## Pick n unique items from an array
static func pick_n_unique(array:Array, n:int) -> Array:
	var temp = array.duplicate()
	temp.shuffle()
	return temp.slice(0, n)

# add array sum and product functions
static func sum(array: Array) -> Array:
	return array.reduce(func(acc, n): return acc + n, 0)
static func prod(array: Array) -> Variant:
	return array.reduce(func(acc, n): return acc * n, 1)

## Returns list of angles (in radians) along an arc with n divisions.
static func arc_subdivide(angle:float, arc_angle:float, n:float) -> Array:
	var points = []
	for i in range(arc_angle / n):
		points.append(n*i + n/2 + (angle - arc_angle/2))
	return points
