DEBUG = false
stats = null

window.onload = ->
  drawStats() if DEBUG

  stage = initStage()
  Game.initialize(stage)
  Game.tick()

window.addEventListener 'keyup', ((event) -> Key.onKeyup(event)), false
window.addEventListener 'keydown', ((event) -> Key.onKeydown(event)), false
window.addEventListener 'mousedown', ((event) -> Game.player.shoot(event)), false

Game =
  bullets: []
  ground: 458

  initialize: (stage) ->
    @stage = stage
    @player = Player
    @lastTick = +new Date

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
    if DEBUG
      @stage.fillText(parseInt(@player.x) + ':' + parseInt(@player.y), 10, 25)

    # bullets
    for bullet in @bullets
      @stage.beginPath()
      @stage.arc(bullet.x, bullet.y, 2, 0, 2*Math.PI, false)
      @stage.fillStyle = 'rbg(0, 0, 0)'
      @stage.fill()

  update: (delta) ->
    # player
    @player.update(delta)

    # bullets
    for bullet in @bullets
      bullet.update(delta)

  tick: ->
    requestAnimationFrame(Game.tick)
    stats.update() if DEBUG

    delta = +new Date - Game.lastTick
    Game.lastTick = +new Date
    Game.update(delta)
    Game.draw()

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
  context = canvas.getContext('2d')
  context.clearRect(0, 0, 800, 500)
  context

drawStats = ->
  stats = new Stats()
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.right = '0'
  stats.domElement.style.top = '0'
  document.body.appendChild(stats.domElement)

