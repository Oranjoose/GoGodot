# GoGodot
A Godot add-on library to simplify common operations.

# Install instructions
Download files to the typical addons directory (res://addons/GoGodot) through AssetLib

Within the project, open the setup.tscn file. This should load the library into the project settings.

Close and re-open the project in order to have auto-complete on the go object while writing scripts.

# Reference

-------

# function spawn_instance

To spawn an instance of a scene at set location, type
go.spawn_instance(<name of scene>, optional:<x position>, optional:<y position>, optional:<parent>)

Examples:

#spawn enemy at position 0, 0 as a child of the main scene root node
go.spawn_instance("EnemyScene")

#spawn enemy at position 200, 300 as a child of the main scene root node
go.spawn_instance("EnemyScene", 200, 300)

#spawn enemy at position 200, 300 as a child of the object calling the function
go.spawn_instance("EnemyScene", 200, 300, self)

-------

# get the main scene root node

go.Main

-------

# callback function go_collision

Area2D nodes automatically call the go_collision function within their own script, or if they don't have a script, the script of their nearest ancestor.
To activate, just write a go_collision function definition inside an Area2D node's script, or its parent (or grandparent, etc.).
NOTE: This works on  

Examples:

#go_collision called when area overlaps another area
func go_collision(otherArea):
  #do collision related things

# function restart_game

Example:
#The following code reloads the current main scene
go.restart_game()
