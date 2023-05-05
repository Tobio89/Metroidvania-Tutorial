extends Node

func instance_scene_on_main(scene:PackedScene, position:Vector2) -> Node:
  var main := get_tree().current_scene
  var inst := scene.instance()
  main.add_child(inst)
  inst.global_position = position
  return inst