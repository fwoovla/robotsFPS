extends Control

var selected_level = "res://levels/game_levels/Intro_level.tscn"

func _ready():
	print("ready")
	$Settings_panel/MenuButton.get_popup().connect("id_pressed", self, "item_menu_selected")
	$Settings_panel/MenuButton.text = "Buzz Saw"


func _on_Quit_button_pressed():
	get_tree().quit()

	
func _on_Username_edit_text_changed(new_text):
	$select_sound2.play()
	Players.username = new_text

	#print(Players.player_list)


func _on_Single_player_button_pressed():
	$start_sound.play()
	Players.set_info()
	yield(get_tree().create_timer(1),"timeout")
	start_game()

func start_game():
	get_tree().change_scene(selected_level)

func item_menu_selected(id):
	print("sellected")
	var text = $Settings_panel/MenuButton.get_popup().get_item_text(id)
	$Settings_panel/MenuButton.text = text
	Players.starting_item = text


func _on_intro_button_pressed():
	$select_sound.play()
	selected_level = "res://levels/game_levels/Intro_level.tscn"
	$Game_settings/level_label.text = "Intro Level"
	#Globals.current_level = 0

func _on_hub_button2_pressed():
	$select_sound.play()
	selected_level = "res://levels/game_levels/hub_level.tscn"
	$Game_settings/level_label.text = "Hub"
	#Globals.current_level = 1
