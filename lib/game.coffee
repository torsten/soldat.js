canvas = ''
gl = ''

squareVerticesBuffer1 = ''
squareVerticesBuffer2 = ''
squareVerticesColorBuffer = ''
squareXOffset1 = 0.0
squareYOffset1 = 0.0
squareZOffset1 = 0.0

squareXOffset2 = 0.0
squareYOffset2 = 0.0
squareZOffset2 = 0.0

mvMatrix = ''
shaderProgram = ''
vertexPositionAttribute = ''
vertexColorAttribute = ''
perspectiveMatrix = ''

socket = io.connect('http://127.0.0.1:1234');

##
## start
##
## Called when the canvas is created to get the ball rolling.
##
window.onload = ->
  canvas = $("#glcanvas")[0]
  $('body').keydown (event) =>
    k = event.keyCode || event.which
    switch k
      when 37 # left
        updateOffsets(-2, 0, 0)
      when 38 # up
        updateOffsets(0, 2, 0)
      when 39 # right
        updateOffsets(2, 0, 0)
      when 40 # down
        updateOffsets(0, -2, 0)
      when 65 # a
        updateEnemyOffsets(-2, 0, 0)
      when 87 # up
        updateEnemyOffsets(0, 2, 0)
      when 68 # right
        updateEnemyOffsets(2, 0, 0)
      when 83 # down
        updateEnemyOffsets(0, -2, 0)
    socket.emit('position_update', { x: squareXOffset1, y: squareYOffset1 })
    drawScene()
  socket.on 'message', (msg) ->
    setEnemyOffsets(msg.x, msg.y, 0)
    drawScene()

  initWebGL(canvas)      ## Initialize the GL context

  ## Only continue if WebGL is available and working
  if (gl)
    gl.clearColor(0.0, 0.0, 0.0, 1.0)  ## Clear to black, fully opaque
    gl.clearDepth(1.0)                 ## Clear everything
    gl.enable(gl.DEPTH_TEST)           ## Enable depth testing
    gl.depthFunc(gl.LEQUAL)            ## Near things obscure far things

    ## Initialize the shaders; this is where all the lighting for the
    ## vertices and so forth is established.

    initShaders()
    ## Here's where we call the routine that builds all the objects
    ## we'll be drawing.

    initBuffers()
    ## Set up to draw the scene periodically.

    initTexture()
    drawScene()

##
## initWebGL
##
## Initialize WebGL, returning the GL context or null if
## WebGL isn't available or could not be initialized.
##
initWebGL = ->
  gl = null

  try
    gl = canvas.getContext("experimental-webgl")
  catch e

  ## If we don't have a GL context, give up now
  alert("Unable to initialize WebGL. Your browser may not support it.") if !gl

##
## initBuffers
##
## Initialize the buffers we'll need. For this demo, we just have
## one object -- a simple two-dimensional square.
##
initBuffers = ->

  ## Create a buffer for the square's vertices.
  squareVerticesBuffer1 = gl.createBuffer()

  ## Select the squareVerticesBuffer1 as the one to apply vertex
  ## operations to from here out.
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesBuffer1)

  ## Now create an array of vertices for the square. Note that the Z
  ## coordinate is always 0 here.
  vertices = [
    2.0,  2.0,  0.0,
    -2.0, 2.0,  0.0,
    2.0,  -2.0, 0.0,
    -2.0, -2.0, 0.0
  ]

  ## Now pass the list of vertices into WebGL to build the shape. We
  ## do this by creating a Float32Array from the JavaScript array,
  ## then use it to fill the current vertex buffer.
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)

  ## Create a buffer for the square's vertices.
  squareVerticesBuffer2 = gl.createBuffer()

  ## Select the squareVerticesBuffer1 as the one to apply vertex
  ## operations to from here out.
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesBuffer2)

  ## Now create an array of vertices for the square. Note that the Z
  ## coordinate is always 0 here.
  vertices = [
    1.0,  1.0,  0.0,
    -1.0, 1.0,  0.0,
    1.0,  -1.0, 0.0,
    -1.0, -1.0, 0.0
  ]

  ## Now pass the list of vertices into WebGL to build the shape. We
  ## do this by creating a Float32Array from the JavaScript array,
  ## then use it to fill the current vertex buffer.
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)

  ## Now set up the colors for the vertices
  colors = [
    1.0,  1.0,  1.0,  1.0,    ## white
    1.0,  0.0,  0.0,  1.0,    ## red
    0.0,  1.0,  0.0,  1.0,    ## green
    0.0,  0.0,  1.0,  1.0     ## blue
  ]

  squareVerticesColorBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesColorBuffer)
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW)

playerTexture = ''
initTexture = ->
  playerTexture = gl.createTexture()
  playerTexture.image = new Image()
  playerTexture.image.onload = ->
    handleLoadedTexture(playerTexture)

  playerTexture.image.src = "images/cube.gif"
  return

handleLoadedTexture = (texture) ->
  gl.bindTexture(gl.TEXTURE_2D, texture)
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
  gl.generateMipmap(gl.TEXTURE_2D)
  gl.bindTexture(gl.TEXTURE_2D, null)
  return

##
## drawScene
##
## Draw the scene.
##
drawScene = ->
  ## Clear the canvas before we start drawing on it.
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

  ## Establish the perspective with which we want to view the
  ## scene. Our field of view is 45 degrees, with a width/height
  ## ratio of 640:480, and we only want to see objects between 0.1 units
  ## and 100 units away from the camera.
  perspectiveMatrix = makePerspective(45, 640.0/480.0, 0.1, 100.0)

  ## Set the drawing position to the "identity" point, which is
  ## the center of the scene.
  loadIdentity()

  ## Now move the drawing position a bit to where we want to start
  ## drawing the square.
  mvTranslate([-0.0, 0.0, -99.0])

  ## Save the current matrix, then rotate before we draw.
  mvPushMatrix()
  mvTranslate([squareXOffset1, squareYOffset1, squareZOffset1])

  ## Draw the square by binding the array buffer to the square's vertices
  ## array, setting attributes, and pushing it to GL.
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesBuffer1)
  gl.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0)

  gl.activeTexture(gl.TEXTURE0)
  gl.bindTexture(gl.TEXTURE_2D, playerTexture)
  gl.uniform1i(shaderProgram.samplerUniform, 0)

  ## Set the colors attribute for the vertices.
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesColorBuffer)
  gl.vertexAttribPointer(vertexColorAttribute, 4, gl.FLOAT, false, 0, 0)

  ## Draw the square.
  setMatrixUniforms()
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)

  ## Restore the original matrix
  mvPopMatrix()

    ## Save the current matrix, then rotate before we draw.
  mvPushMatrix()
  mvTranslate([squareXOffset2, squareYOffset2, squareZOffset2])

  ## Draw the square by binding the array buffer to the square's vertices
  ## array, setting attributes, and pushing it to GL.
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesBuffer2)
  gl.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0)

  ## Set the colors attribute for the vertices.
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesColorBuffer)
  gl.vertexAttribPointer(vertexColorAttribute, 4, gl.FLOAT, false, 0, 0)

  ## Draw the square.
  setMatrixUniforms()
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)

  ## Restore the original matrix
  mvPopMatrix()
  $('#position').text(squareXOffset1 + ', ' + squareYOffset1)
  $('#enemy_position').text(squareXOffset2 + ', ' + squareYOffset2)


updateOffsets = (x, y, z) ->
  squareXOffset1 += x
  squareYOffset1 += y
  squareZOffset1 += z

updateEnemyOffsets = (x, y, z) ->
  squareXOffset2 += x
  squareYOffset2 += y
  squareZOffset2 += z

setEnemyOffsets = (x, y, z) ->
  squareXOffset2 = x
  squareYOffset2 = y
  squareZOffset2 = z

##
## initShaders
##
## Initialize the shaders, so WebGL knows how to light our scene.
##
initShaders = ->
  fragmentShader = getShader(gl, "shader-fs")
  vertexShader = getShader(gl, "shader-vs")

  ## Create the shader program
  shaderProgram = gl.createProgram()
  gl.attachShader(shaderProgram, vertexShader)
  gl.attachShader(shaderProgram, fragmentShader)
  gl.linkProgram(shaderProgram)

  ## If creating the shader program failed, alert
  if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS))
    alert("Unable to initialize the shader program.")


  gl.useProgram(shaderProgram)

  vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition")
  gl.enableVertexAttribArray(vertexPositionAttribute)

  vertexColorAttribute = gl.getAttribLocation(shaderProgram, "aVertexColor")
  gl.enableVertexAttribArray(vertexColorAttribute)


##
## getShader
##
## Loads a shader program by scouring the current document,
## looking for a script with the specified ID.
##
getShader = (gl, id) ->
  shaderScript = document.getElementById(id)

  ## Didn't find an element with the specified ID; abort.
  return null if (!shaderScript)

  ## Walk through the source element's children, building the
  ## shader source string.
  theSource = ""
  currentChild = shaderScript.firstChild

  while(currentChild)
    theSource += currentChild.textContent if (currentChild.nodeType == 3)
    currentChild = currentChild.nextSibling


  ## Now figure out what type of shader script we have,
  ## based on its MIME type.
  shader

  if (shaderScript.type == "x-shader/x-fragment")
    shader = gl.createShader(gl.FRAGMENT_SHADER)
  else if (shaderScript.type == "x-shader/x-vertex")
    shader = gl.createShader(gl.VERTEX_SHADER)
  else
    return null  ## Unknown shader type


  ## Send the source to the shader object
  gl.shaderSource(shader, theSource)

  ## Compile the shader program
  gl.compileShader(shader)

  ## See if it compiled successfully
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS))
    alert("An error occurred compiling the shaders: " + gl.getShaderInfoLog(shader))
    return null

  return shader


##
## Matrix utility functions
##

loadIdentity = ->
  mvMatrix = Matrix.I(4)


multMatrix = (m) ->
  mvMatrix = mvMatrix.x(m)


mvTranslate = (v) ->
  multMatrix(Matrix.Translation($V([v[0], v[1], v[2]])).ensure4x4())


setMatrixUniforms = ->
  pUniform = gl.getUniformLocation(shaderProgram, "uPMatrix")
  gl.uniformMatrix4fv(pUniform, false, new Float32Array(perspectiveMatrix.flatten()))

  mvUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix")
  gl.uniformMatrix4fv(mvUniform, false, new Float32Array(mvMatrix.flatten()))


mvMatrixStack = []

mvPushMatrix = (m) ->
  if (m)
    mvMatrixStack.push(m.dup())
    mvMatrix = m.dup()
  else
    mvMatrixStack.push(mvMatrix.dup())

mvPopMatrix = ->
  throw("Can't pop from an empty matrix stack.") if (!mvMatrixStack.length)

  mvMatrix = mvMatrixStack.pop()

mvRotate = (angle, v) ->
  inRadians = angle * Math.PI / 180.0

  m = Matrix.Rotation(inRadians, $V([v[0], v[1], v[2]])).ensure4x4()
  multMatrix(m)

