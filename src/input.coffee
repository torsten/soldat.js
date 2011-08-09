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

