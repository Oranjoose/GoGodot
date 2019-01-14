
# GoGodot
A Godot add-on library to simplify common operations.

## Install instructions

Within the project, open the setup.tscn file. This should load the library into the project settings.
## Reference

-------

### function spawn_instance

To spawn an instance of a scene at set location, type
go.spawn_instance(<name of scene>, optional:<x position>, optional:<y position>, optional:<parent>)

Examples:

#spawn enemy at position 0, 0 as a child of the main scene root node
`go.spawn_instance("EnemyScene")`

#spawn enemy at position 200, 300 as a child of the main scene root node
`go.spawn_instance("EnemyScene", 200, 300)`

#spawn enemy at position 200, 300 as a child of the object calling the function
`go.spawn_instance("EnemyScene", 200, 300, self)`

-------

### function spawn_instance_grid

Spawns a rectangular grid of instances of a provided scene. This is good for creating formations of enemies, or arcade puzzle elements.

`go.spawn_instance_grid(sceneName, numberOfColumns, numberOfRows, columnSpacing, rowSpacing, xPosition, yPosition, whereToAddChildren)`

Examples:
#spawn a 4 by 5 grid of cards that are spread out with 100 pixels of space between them horizontally and vertically.
`go.spawn_instance_grid("CardScene", 4, 5, 100, 100)`

#the same as the above example, but the grid is placed at a position of 250, 150 from the root node.
`go.spawn_instance_grid("CardScene", 4, 5, 100, 100, 250, 150)`

#the same as the above example, but the grid is put as a child of the caller, rather than the scene's root node.
`go.spawn_instance_grid("CardScene", 4, 5, 100, 100, 250, 150, self)`

---
### get the main scene root node

#the following code gets a reference to the main scene root node:
`go.Main`

-------

### callback functions automatically connected to built-in signals

NOTE: This is a *breaking change*. This replaces go_collision and go_body_collision

Each node's built-in signals will automatically connect to a callback function whose name matches the signal name, within a script that is either on the node or its nearest ancestor node.
To activate, just write a function definition whose name is the desired signal's name inside the node's script, or its parent (or grandparent, etc.).

Examples:

```
Extends Area2D
#area_entered called when area overlaps another area
func area_entered(otherArea):
  #do collision related things
```

Note: normally, you would have to turn on contact monitor on the RigidBody2D and increase the number of contacts reporting from the default 0 value. Fortunately, if an ancestor node is found with the `body_entered` function, then GoGodot will automatically turn on contact monitor and increase contacts reporting so that it just works (without having to manually tweak those settings).

-------

### function restart_game

Example:
#The following code reloads the current main scene
`go.restart_game()`

-------

### function get_all_nodes_by_class

This function returns an array of all the nodes in the SceneTree that match a given class name.

Example:
```
var allLabels = go.get_all_nodes_by_class("Label")
for label in allLabels:
  label.text = "all labels now show this text!"
```

### function destroy

Example:

```
#remove myObj
go.remove(myObj)
```
Destroy is simply an alias for `queue_free()`, but ensures that the object trying to be removed can actually queue_free.

---

### function random_integer

Gets a random integer in range.

Example:
```
go.random_integer(2, 12) #get random integer, minimum of 2 and maximum of 12
```

If no arguments provided, then assume die roll 1 to 6. If only one argument provided, assume range of 1 to maximum of that argument provided. 

---

### function array_shuffle

Supply an array to shuffle, and the shuffled array is returned.

Example:
```
var shuffledFruitArray = go.array_shuffle(["apple", "banana", "orange"])
```

---
## Go Modules

Go Modules are nodes that can be found in the *go_modules* folder which give special powers to whatever node they are attached to. For example, adding the *Platformer* node to a Node2D will make that node behave like a platformer (moving and jumping, etc.).

---
### Platformer
Adding the *Platformer* node to any Node that has a transform (e.g. Node2D, Sprite, etc.) will make that Node automatically possess typical Platformer behavior.

Settings for the Platformer node can be tweaked in the Inspector with the following properties:
* Gravity - the strength of gravity
* Speed - the speed of the Platformer node
* Jump Strength - how "high" the Platformer node can "jump"
* Collision Bounds - the pixel dimensions of the collision area of the Platformer node. (Note: you may add your own custom collision shape if you like, but the Rectangle is the default option)
* Set Bounds To Sibling Sprite - when this is clicked, the first Sprite node that is a sibling to the Platformer node will be used to auto measure and determine the size of the collision area of the Platformer node.
* WASD - check this property to enable default WASD key controls.
* Arrow Keys - check this property to enable default arrow key controls.

---
### Spritesheet
This node expands the typical Sprite node to make spritesheet animations easier to set up.

The following properties of the Spritesheet node can be configured in the editor:
* Spritesheet - this is the Texture of the spritesheet, i.e., the spritesheet graphic itself. Note that the spritesheet's frames need to be evenly divided in a grid.
* Current Frame - this is the same as the `Frame` property, which states which frame of the animation is current.
* Framerate - set this to change how fast the animation plays in frames per second.
* Horz Frames - the same as `HFrames`, this tells Godot how many frames there are in each column.
* Vert Frames - the same as `VFrames`, this tells Godot how many frames there are in each row.
* First frame - if the desired animation does not begin on frame 0, you may choose which frame the animation starts on.
* Final frame - sometimes the grid ends before the final column, so this allows you to choose what the final frame actually is of the animation. Default assumes the final frame is the last frame in the grid calculated by the Horz Frames and Vert Frames.
* Loop - choose whether or not the animations should loop.
* Reverse - specify if the animation should be playing backwards. Note: this will play from the Final Frame to the First Frame.
* Is Playing - this allows you to preview the animation in the editor.
* Autostart - specify whether or not the spritesheet should start playing when it enters the scene at runtime.

The following are functions that belong to the Spritesheet node that you can run on the Spritesheet object in the code:
* play() - starts the animation
* stop() - stops the animation and returns to the First Frame
* pause() - stops the animation, but stays on the Current Frame

The following are callback functions that can be added to the nearest ancestor to the Spritesheet node that will automatically run under its respective conditions:
* func go_animation_end() - the nearest ancestor node to Spritesheet will run this function when the Spritesheet animation ends or loops.

---
### Linear Motion
Adding this node to any node with a transform (e.g. Node2D, Sprite, etc.) will enable you to easily make the node "go" at a fixed speed. Unlike the `linear_velocity` property found on *some* nodes, the speed is controlled with an angle and speed rather than x and y velocity.

The following properties can be modified in the editor in order to tweak the behavior of the Linear Motion module:
* Enabled - check this to enable the module to work. If it is unchecked (whether in the editor or in the code), the parent node will stop moving as a result of the Linear Motion node.
* Match Angle - check this to have the parent node move in the direction of its angle. Whatever angle the parent of Linear Motion is set to is the direction it will go. Otherwise, the node will go the direction of the Angle Of Motion property.
* Angle of Motion - if the Match Angle property is unchecked, the parent node will go the direction provided by the Angle of Motion property. This is good for when you don't want to rotate the parent node to have Linear Motion work.
* Speed - the speed of the Linear Motion in pixels per second.

---
### TopDownMovement
Adding this node to any node with a transform (e.g. Node2D, Sprite, etc.) gives that node traditional top-down movement mechanics, as in classic top-down games, such as _The Legend of Zelda_ and _Metal Gear_. 

The following properties can be configured in the editor to customize how the top-down motion works.
* Speed - pixels per second the node moves in the respective directions. Note that moving diagonally will move the given pixels per second _diagonally_, taking into account the correct vector magnitude.
* CollisionBounds - set the size of the default rectangular collision boundaries of the character.
* Set_Bounds_To_Sibling_Sprite - clicking this checkbox will have the module find the first Sprite sibling of the TopDownMovement node, and use its dimensions to automatically figure out the size of the rectangular collision shape.
* LimitFourDirections - with this selected, the TopDownMotion can only go one direction at a time, instead of diagonally.
* WASD - with this checked, the w, a, s, and d keys control the TopDownMotion in game.
* ArrowKeys - with this checked, the arrow keys control the TopDownMotion in game. Note that WASD and ArrowKeys can both be checked, allowing either set of keys to work for the TopDownMotion.
