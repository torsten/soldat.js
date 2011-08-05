# game = null
context = null
player = null
bullets = []

window.addEventListener 'keyup', ((event) -> Key.onKeyup(event)), false
window.addEventListener 'keydown', ((event) -> Key.onKeydown(event)), false
window.addEventListener 'mousemove', ((event) -> Mouse.onMousemove(event)), false
window.addEventListener 'mousedown', (-> player.shoot()), false # TODO player.shoot may not defined yet

window.onload = ->
  initScene()
  player = new Player(100, 240)
  tick()
  return

Mouse =
  constructor: (@x = 0, @y = 0) ->

  onMousemove: (event) ->
    @x = event.pageX
    @y = event.pageY
    return true

Key =
  UP: 87    # 38, 87
  RIGHT: 68 # 39, 68
  DOWN: 83  # 40, 83
  LEFT: 65  # 37, 65

  held_down: {}

  pressed: (keyCode) ->
    this.held_down[keyCode]

  onKeyup: (event) ->
    delete this.held_down[event.keyCode]

  onKeydown: (event) ->
    this.held_down[event.keyCode] = true

class Bullet
  constructor: (@x, @y, @vx, @vy) ->

  update: ->
    @x = @x + @vx
    @y = @y + @vy

class Player
  constructor: (@x, @y, @vx = 0, @vy = 0, @ax = 0) ->

  update: ->
    @ax = 0

    if Key.pressed(Key.UP)
      this.moveUp(500)

    if Key.pressed(Key.RIGHT)
      this.moveRight(1000)

    if Key.pressed(Key.LEFT)
      this.moveLeft(1000)

    t = 0.01
    gy = 981
    bx = 4000

    @y = @y + @vy * t
    @vy = @vy + gy * t

    @x = @x + @vx * t

    if @vx > 0 && @ax <= 0
      bx = Math.abs(bx) * -1
    else if @vx < 0 && @ax >= 0
      bx = Math.abs(bx)
    else
       bx = 0

    if !this.on_ground()
      if @ax == 0
        bx = 0
      @vx = @vx + (@ax * t) + (bx * t)
    else
      if Math.abs(bx * t) > Math.abs(@vx) && @ax == 0
        @vx = 0
      else
        @vx = @vx + (@ax * t) + (bx * t)

    if @y >= 458
      @y = 458
      @vy = 0

    if @vx >= 500
      @vx = 500

    if @vx <= -500
      @vx = -500

  moveUp: (vy) ->
    return unless this.on_ground()
    @vy = vy * -1

  moveRight: (ax) ->
    @ax = ax

  moveLeft: (ax) ->
    @ax = ax * -1

  shoot: ->
    px = @x + 20
    py = @y + 20
    mx = Mouse.x
    my = Mouse.y

    # direction
    dx = mx - px
    dy = my - py
    length = Math.sqrt( (dx*dx) + (dy*dy) )

    # speed
    bs = 20
    vx = dx / length * bs
    vy = dy / length * bs

    bullets.push new Bullet(px, py, vx, vy)
    return true

  on_ground: ->
    return true if @y >= 458
    false

tick = ->
  requestAnimationFrame(tick)
  draw()
  animate()
  return

animate = ->
  player.update()
  for bullet in bullets
    bullet.update()

draw = ->
  context.clearRect(0, 0, 800, 500)

  img = new Image()
  if player.ax < 0 || player.vx < 0
    img.src = 'images/soldier-flip.gif'
  else
    img.src = 'images/soldier.gif'
  context.drawImage(img, player.x, player.y, 43, 37)

  for bullet in bullets
    context.beginPath()
    context.arc(bullet.x, bullet.y, 2, 0, 2*Math.PI, false)
    context.fillStyle = 'rbg(0,0,0)'
    context.fill()

initScene = ->
  bg_canvas = document.createElement('canvas')
  bg_canvas.id = 'bg'
  bg_canvas.width = 800
  bg_canvas.height = 500
  # bg_canvas.style = 'z-index: 1'
  bg_context = bg_canvas.getContext('2d')
  bg = new Image()
  bg.src = 'images/bg.png'
  bg_context.drawImage(bg, 0, 0)
  document.body.appendChild(bg_canvas)

  main_canvas = document.createElement('canvas')
  main_canvas.id = 'main'
  main_canvas.width = 800
  main_canvas.height = 500
  # main_canvas.style = 'z-index: 2'
  document.body.appendChild(main_canvas)
  context = main_canvas.getContext('2d')
  # Game.context = main_contaxt

