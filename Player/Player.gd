class_name Player

extends KinematicBody2D

const DustEffect = preload("res://Effects/DustEffect.tscn")
const PlayerBullet = preload("res://Player/PlayerBullet.tscn")

export var ACCELERATION:int = 512
export var MAX_SPEED:int = 64
export var FRICTION:float = 0.24

export var GRAVITY:int = 200
export var JUMP_FORCE:int = 128
export var MAX_SLOPE_ANGLE:int = 46

export var BULLET_SPEED:int = 250

onready var sprite = $Sprite
onready var anim = $PlayerAnim
onready var coyote = $CoyoteTimer
onready var gun = $Sprite/PlayerGun
# onready var muzzle = $Sprite/PlayerGun/Sprite/Muzzle

var motion := Vector2.ZERO
var snap_vect := Vector2.ZERO
var just_jumped := false


# Funcs

func create_dust_effect():
  var dust_pos := global_position
  dust_pos.x += rand_range(-4, 4)
  var _d := Utils.instance_scene_on_main(DustEffect, dust_pos)

# func fire_bullet():
#   var bullet := Utils.instance_scene_on_main(PlayerBullet, muzzle.global_position)
#   bullet.velocity = Vector2.RIGHT.rotated(gun.rotation) * BULLET_SPEED
#   bullet.velocity.x *= sprite.scale.x
#   bullet.rotation = bullet.velocity.angle()


# Get Vector2 based on inputs pressed
func get_input_vect()-> Vector2:
  var v := Vector2.ZERO
  v.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
  return v


func apply_movement_input(inV:Vector2, d:float):
  if inV.x != 0:
    motion.x += inV.x * ACCELERATION * d
    motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)


func apply_friction(inV:Vector2):
  if inV.x == 0 && is_on_floor():
      motion.x = lerp(motion.x, 0, FRICTION)


func apply_gravity(d:float):
  if not is_on_floor():
    motion.y += GRAVITY * d
    motion.y = min(motion.y, JUMP_FORCE)


func apply_snap_to_ground():
  if is_on_floor():
    snap_vect = Vector2.DOWN * 4


func handle_jump():
  var pressed_jump := Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_accept")
  if is_on_floor() || coyote.time_left > 0:
    if pressed_jump:
      motion.y = -JUMP_FORCE
      snap_vect = Vector2.ZERO
      just_jumped = true
  else:
    if pressed_jump and motion.y < -JUMP_FORCE/2.0:
      motion.y = -JUMP_FORCE/2.0


func handle_shooting():
  if Input.is_action_pressed("fire"):
    gun.fire_bullet(sprite.scale.x)


func handle_sprite_direction() -> void:
  sprite.scale.x = sign(get_local_mouse_position().x)


func handle_anim(inV:Vector2) -> void:
  if inV.x != 0:
    anim.playback_speed = inV.x * sprite.scale.x
    anim.play("Run")
  else:
    anim.playback_speed = 1
    anim.play("Idle")
    
  if not is_on_floor():
    anim.playback_speed = 1
    anim.play('Jump')


func do_move():
  var was_in_air = !is_on_floor()
  var was_on_floor = is_on_floor()
  var prev_frame_pos = position
  var prev_frame_motion = motion

  motion = move_and_slide_with_snap(
    motion, 
    snap_vect,
    Vector2.UP, 
    true, 
    4, 
    deg2rad(MAX_SLOPE_ANGLE)
  )

  # Landing
  if was_in_air and is_on_floor():
    motion.x = prev_frame_motion.x
    create_dust_effect()

  # Just left ground
  if was_on_floor and not is_on_floor() and not just_jumped:
    motion.y = 0
    position.y = prev_frame_pos.y
    coyote.start()

# Signals


# Lifecycle Funcs

func _physics_process(delta):
  just_jumped = false
  var input_vect := get_input_vect()

  apply_movement_input(input_vect, delta)
  apply_friction(input_vect)
  apply_snap_to_ground()
  
  handle_jump()
  apply_gravity(delta)

  handle_sprite_direction()
  handle_anim(input_vect)

  do_move()
  
  handle_shooting()

