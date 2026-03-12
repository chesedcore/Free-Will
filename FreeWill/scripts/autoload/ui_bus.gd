extends Node

enum Feedback {
	DASH_STILL_UNDER_COOLDOWN,
	ACTION_STILL_UNDER_COOLDOWN,
}

signal attempted_dash(res: Result)
signal attempted_action(res: Result)
