game = null

window.onload = ->
  stage = initStage()
  initGame(stage)
  tick()
  return

window.addEventListener 'keyup', ((event) -> Key.onKeyup(event)), false
window.addEventListener 'keydown', ((event) -> Key.onKeydown(event)), false
window.addEventListener 'mousemove', ((event) -> Mouse.onMousemove(event)), false
window.addEventListener 'mousedown', (-> game.player.shoot()), false

class Game
  constructor: (@stage, @player = new Player(), @bullets = [], @ground = 458) ->

class Player
  constructor: (@x = 100, @y = 240) ->

  t = 0.01
  gy = 1000 # gravity
  bx = 4000
  vx = 0    # velocity x
  vy = 0    # velocity y
  ax = 0

  update: ->
    ax = 0

    if Key.pressed(Key.UP)
      this.moveUp(500)

    if Key.pressed(Key.RIGHT)
      this.moveRight(1000)

    if Key.pressed(Key.LEFT)
      this.moveLeft(1000)

    @y = @y + vy * t
    @x = @x + vx * t

    vy = vy + gy * t

    if vx > 0 && ax <= 0
      bx = Math.abs(bx) * -1
    else if vx < 0 && ax >= 0
      bx = Math.abs(bx)
    else
      bx = 0

    if this.onGround()
      @y = game.ground
      vy = 0
      if Math.abs(bx * t) > Math.abs(vx) && ax == 0
        vx = 0
      else
        vx = vx + (ax * t) + (bx * t)
    else
      if ax == 0
        bx = 0
      vx = vx + (ax * t) + (bx * t)

  moveUp: (_vy) ->
    return unless this.onGround()
    vy = _vy * -1

  moveRight: (_ax) ->
    ax = _ax

  moveLeft: (_ax) ->
    ax = _ax * -1

  onGround: ->
    return true if @y >= game.ground
    false

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

    # sound
    sound = new Audio('sounds/shoot.mp3')
    sound.play()

    game.bullets.push new Bullet(px, py, vx, vy)
    return true

class Bullet
  constructor: (@x, @y, @vx, @vy) ->

  update: ->
    @x += @vx
    @y += @vy

Mouse =
  constructor: (@x = 0, @y = 0) ->

  onMousemove: (event) ->
    @x = event.pageX
    @y = event.pageY
    return true

Key =
  # 38, 87
  # 39, 68
  # 40, 83
  # 37, 65
  UP: 87
  RIGHT: 68
  DOWN: 83
  LEFT: 65

  held_down: {}

  pressed: (keyCode) ->
    this.held_down[keyCode]

  onKeyup: (event) ->
    delete this.held_down[event.keyCode]

  onKeydown: (event) ->
    this.held_down[event.keyCode] = true

tick = ->
  requestAnimationFrame(tick)
  animate()
  return

animate = ->
  game.stage.clearRect(0, 0, 800, 500)
  game.player.update()

  # draw player
  img = new Image()
  img.src = 'images/soldier.gif'
  game.stage.drawImage(img, game.player.x, game.player.y, 43, 37)

  # print position
  context.fillText(parseInt(player.x) + ':' + parseInt(player.y), 10, 25)

  # draw bullets
  for bullet in game.bullets
    bullet.update()

  return

initGame = (stage) ->
  game = new Game(stage)
  return

initStage = ->
  bg = createCanvas('bg')
  bg_img = new Image()
  bg_img.src = 'images/bg.png'
  bg.drawImage(bg_img, 0, 0)

  createCanvas('stage')

createCanvas = (id) ->
  canvas = document.createElement('canvas')
  canvas.id = id
  canvas.width = 800
  canvas.height = 500
  document.body.appendChild(canvas)
  canvas.getContext('2d')

