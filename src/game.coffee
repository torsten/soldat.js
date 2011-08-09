window.onload = ->
  stage = initStage()
  Game.initialize(stage)
  Game.tick()

window.addEventListener 'keyup', ((event) -> Key.onKeyup(event)), false
window.addEventListener 'keydown', ((event) -> Key.onKeydown(event)), false
window.addEventListener 'mousemove', ((event) -> Mouse.onMousemove(event)), false
window.addEventListener 'mousedown', (-> Game.player.shoot()), false

Game =
  bullets: []
  ground: 458

  initialize: (stage) ->
    @stage = stage
    @player = Player

  draw: ->
    @stage.clearRect(0, 0, 800, 500)

    # player
    img = new Image()
    if @player.ax < 0 || @player.vx < 0
      img.src = 'images/soldier-flip.gif'
    else
      img.src = 'images/soldier.gif'
    @stage.drawImage(img, @player.x, @player.y, 43, 37)

    # position
    @stage.fillText(parseInt(@player.x) + ':' + parseInt(@player.y), 10, 25)

    # bullets
    for bullet in @bullets
      @stage.beginPath()
      @stage.arc(bullet.x, bullet.y, 2, 0, 2*Math.PI, false)
      @stage.fillStyle = 'rbg(0, 0, 0)'
      @stage.fill()

  update: ->
    # player
    @player.update()

    # bullets
    for bullet in @bullets
      bullet.update()

  tick: ->
    requestAnimationFrame(Game.tick)

    Game.update()
    Game.draw()

Player =
  x: 100
  y: 240
  vx: 0
  vy: 0
  ax: 0

  update: ->
    @ax = 0

    t = 0.01
    gy = 981
    bx = 4000

    max_speed = 500
    max_height = 458

    if Key.pressed(Key.UP)
      this.moveUp(500)

    if Key.pressed(Key.RIGHT)
      this.moveRight(1000)

    if Key.pressed(Key.LEFT)
      this.moveLeft(1000)

    @y = @y + @vy * t
    @vy = @vy + gy * t

    @x = @x + @vx * t

    if @vx > 0 && @ax <= 0
      bx = Math.abs(bx) * -1
    else if @vx < 0 && @ax >= 0
      bx = Math.abs(bx)
    else
       bx = 0

    if !this.onGround()
      if @ax == 0
        bx = 0
      @vx = @vx + (@ax * t) + (bx * t)
    else
      if Math.abs(bx * t) > Math.abs(@vx) && @ax == 0
        @vx = 0
      else
        @vx = @vx + (@ax * t) + (bx * t)

    if @y >= max_height
      @y = max_height
      @vy = 0

    if @vx >= max_speed
      @vx = max_speed

    if @vx <= -1 * max_speed
      @vx = -1 * max_speed

  moveUp: (vy) ->
    return unless this.onGround()
    @vy = vy * -1

  moveRight: (ax) ->
    @ax = ax

  moveLeft: (ax) ->
    @ax = ax * -1

  onGround: ->
    return true if @y >= 458
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

    Game.bullets.push new Bullet(px, py, vx, vy)
    return true

class Bullet
  constructor: (@x, @y, @vx, @vy) ->

  update: ->
    @x += @vx
    @y += @vy

Mouse =
  x: 0
  y: 0

  onMousemove: (event) ->
    @x = event.pageX
    @y = event.pageY
    return true

Key =
  UP: 87
  RIGHT: 68
  DOWN: 83
  LEFT: 65

  held_down: {}

  pressed: (keyCode) ->
    @held_down[keyCode]

  onKeyup: (event) ->
    delete @held_down[event.keyCode]

  onKeydown: (event) ->
    @held_down[event.keyCode] = true

initStage = ->
  # background
  bg = createCanvas('background')
  bg_img = new Image()
  bg_img.src = 'images/bg.png'
  bg.drawImage(bg_img, 0, 0)

  # stage
  createCanvas('stage')

createCanvas = (id) ->
  canvas = document.createElement('canvas')
  canvas.id = id
  canvas.width = 800
  canvas.height = 500
  document.body.appendChild(canvas)
  canvas.getContext('2d')

