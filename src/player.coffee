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

