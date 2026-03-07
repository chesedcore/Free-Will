##a class enforcing either the existence, or nonexistence of a value.
class_name Option[T]

var _val: T
var _is_some: bool = false

##create a new option from a value that has something in it.
static func some(val: T) -> Option[T]:
	var opt: Option[T] = Option.new()
	opt._val = val
	opt._is_some = true
	return opt

##create an option that has nothing in it.
static func none() -> Option[T]:
	return Option.new()

##get the value inside this option; explodes if nothing was found.
##the check is disabled on release modes.
func unwrap() -> T:
	assert(_is_some, "Tried to unwrap an empty option!")
	return _val

##take the value inside this option, leaving None behind.
##explodes if nothing was found.
func take() -> T:
	assert(_is_some, "Tried to take something from an empty option!")
	_is_some = false
	return _val

##does this option have something in it? true if yes
func is_some() -> bool:
	return _is_some

##does this option have nothing in it? true if yes
func is_none() -> bool:
	return not _is_some
