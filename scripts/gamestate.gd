extends Node

var undo_stack: Array = []

const MAX_UNDO := 100

func clear_undo():
	undo_stack.clear()

func push_snapshot(snapshot):
	undo_stack.append(snapshot)
	if undo_stack.size() > MAX_UNDO:
		undo_stack.pop_front()

func pop_snapshot():
	if undo_stack.is_empty():
		return null
	return undo_stack.pop_back()
