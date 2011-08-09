class Bullet
  constructor: (@x, @y, @vx, @vy) ->

  update: ->
    @x += @vx
    @y += @vy

