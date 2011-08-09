class Bullet
  constructor: (@x, @y, @vx, @vy) ->

  update: (delta) ->
    @x += @vx
    @y += @vy

