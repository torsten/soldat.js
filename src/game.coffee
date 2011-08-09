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

  run: ->
    skipTicks = 1000 / 60
    nextGameTick = (new Date).getTime()

    (->
      while (new Date).getTime() > nextGameTick
        Game.update()
        nextGameTick += skipTicks

      Game.draw()
    )()

  draw: ->
    @stage.clearRect(0, 0, 800, 500)

    # player
    img = new Image()
    img.src = 'images/soldier.gif'
    @stage.drawImage(img, @player.x, @player.y, 43, 37)

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

  tick: =>
    requestAnimationFrame(Game.tick)
    Game.run()

Player =
  x: 100
  y: 240

  update: ->
    if Key.pressed(Key.UP)
      this.moveUp()

    if Key.pressed(Key.RIGHT)
      this.moveRight()

    if Key.pressed(Key.LEFT)
      this.moveLeft()

  moveUp: ->

  moveRight: ->

  moveLeft: ->

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

