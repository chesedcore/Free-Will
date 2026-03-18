class_name ParryReport

enum Type {
	NORMAL,
}

var type: Type

static func as_normal() -> ParryReport:
	var rep := new()
	rep.type = Type.NORMAL
	return rep
