unless window.requestAnimationFrame
  window.requestAnimationFrame = (->
    window.mozRequestAnimationFrame ||
    window.oRequestAnimationFrame ||
    window.webkitRequestAnimationFrame ||
    window.msRequestAnimationFrame ||
    (callback, element) ->
      window.setTimeout(callback, 1000 / 60)
  )()

