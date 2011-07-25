start = ->
  canvas = document.getElementById('glcanvas')
  initWebGL(canvas)

  gl.clearColor(0.0, 0.0, 0.0, 1.0)
  gl.clearDepth(1.0)
  gl.enable(gl.DEPTH_TEST)
  gl.depthFunc(gl.LEQUAL)
  gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT)

  return

initWebGL = (canvas) ->
  gl = null

  try
    gl = canvas.getContext('experimental-webgl')
    # gl.viewportWidth = canvas.width
    # gl.viewportHeight = canvas.height
  catch e
  if (!gl)
    alert('Unable to initialize WebGL.')

  return

start()

