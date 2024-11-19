extends Control

var dragging := false
var drag_start_position := Vector2()
var velocity = Vector2.ZERO
var gravity := 500
var bounce_factor := 0.4

var horizontal_speed := 100
var move_direction := 0
var move_timer := 0.0
var move_duration := 3.0

@onready var pet = $Pet

func _ready() -> void:
	pet.play("idle")
	randomize()

func _process(delta: float) -> void:
	update_animation()
	if not dragging:
		apply_gravity(delta)
		apply_horizontal_movement(delta)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start_position = get_global_mouse_position()
			else:
				dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		var displacement = get_global_mouse_position() - drag_start_position
		var current_position = DisplayServer.window_get_position()
		var new_position = current_position + Vector2i(displacement)
		DisplayServer.window_set_position(new_position)
		drag_start_position = get_global_mouse_position()

func apply_gravity(delta):
	velocity.y += gravity * delta
	var current_position = DisplayServer.window_get_position()
	var new_position = current_position + Vector2i(velocity * delta)
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	
	var workspace_height = DisplayServer.screen_get_usable_rect(0).size.y #Excluye la barra de tareas
	var max_y = workspace_height - window_size.y
	
	if new_position.y > max_y:
		new_position.y = max_y
		velocity.y = -velocity.y * bounce_factor
	DisplayServer.window_set_position(new_position)

func update_animation():
	if dragging:
		pet.play("dragging")
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_DRAG)
	else: 
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
		var window_position = DisplayServer.window_get_position()
		var window_size = DisplayServer.window_get_size()
		var workspace_height = DisplayServer.screen_get_usable_rect(0).size.y
		var max_y = workspace_height - window_size.y
		
		if window_position.y >= max_y:
			if move_direction != 0:
				pet.play("walking")
				if move_direction < 0:
					pet.flip_h = true
				else:
					pet.flip_h = false
			else:
				pet.play("idle")
		else:
			pet.play("falling")

func apply_horizontal_movement(delta):
	move_timer += delta
	if move_timer >= move_duration:
		choose_new_direction()
	
	var current_position = DisplayServer.window_get_position()
	var new_position = current_position + Vector2i(move_direction * horizontal_speed * delta, 0)
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	
	new_position.x = clamp(new_position.x, 0, screen_size.x - window_size.x)
	DisplayServer.window_set_position(new_position)

func choose_new_direction():
	move_timer = 0
	var choices = [-1, 0, 1]
	move_direction = choices[randi() % choices.size()]
