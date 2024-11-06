extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.reset_position()

	if body is XRToolsPlayerBody:
		var parent = body.get_parent()
		if parent.has_method('reset_position'):
			parent.reset_position()
