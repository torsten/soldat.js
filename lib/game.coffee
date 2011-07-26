gl = ''
mvMatrix = mat4.create()
pMatrix = mat4.create()
triangleVertexPositionBuffer = ''
squareVertexPositionBuffer = ''
shaderProgram = ''

window.onload = ->
  canvas = document.getElementById('glcanvas')
  initWebGL(canvas)
  initShaders()
  initBuffers()

  gl.clearColor(0.0, 0.0, 0.0, 1.0)
  gl.enable(gl.DEPTH_TEST)

  drawScene()

  return

initWebGL = (canvas) ->
  try
    gl = canvas.getContext('experimental-webgl')
    gl.viewportWidth = canvas.width
    gl.viewportHeight = canvas.height
  catch e
  if (!gl)
    alert('Unable to initialize WebGL.')

initShaders = ->
  fragmentShader = getShader("shader-fs")
  vertexShader = getShader("shader-vs")

  shaderProgram = gl.createProgram()
  gl.attachShader(shaderProgram, vertexShader)
  gl.attachShader(shaderProgram, fragmentShader)
  gl.linkProgram(shaderProgram)

  if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS))
    alert("Could not initialise shaders")

  gl.useProgram(shaderProgram)

  shaderProgram.vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition")
  gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute)

  shaderProgram.pMatrixUniform = gl.getUniformLocation(shaderProgram, "uPMatrix")
  shaderProgram.mvMatrixUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix")
  gl

getShader = (id) ->
  shaderScript = document.getElementById(id)
  return null if !shaderScript

  k = shaderScript.firstChild
  str = ''
  while k
    str += k.textContent if k.nodeType == 3
    k = k.nextSibling


  if shaderScript.type == "x-shader/x-fragment"
    shader = gl.createShader(gl.FRAGMENT_SHADER)
  else if (shaderScript.type == "x-shader/x-vertex")
    shader = gl.createShader(gl.VERTEX_SHADER)
  else
    return null

  gl.shaderSource(shader, str)
  gl.compileShader(shader)

  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS))
    alert(gl.getShaderInfoLog(shader))
    return null

  shader

initBuffers = ->
  triangleVertexPositionBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer)
  vertices = [
       0.0,  1.0,  0.0,
      -1.0, -1.0,  0.0,
       1.0, -1.0,  0.0
  ]
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)
  triangleVertexPositionBuffer.itemSize = 3
  triangleVertexPositionBuffer.numItems = 3

  squareVertexPositionBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer)
  vertices = [
       1.0,  1.0,  0.0,
      -1.0,  1.0,  0.0,
       1.0, -1.0,  0.0,
      -1.0, -1.0,  0.0
  ]
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW)
  squareVertexPositionBuffer.itemSize = 3
  squareVertexPositionBuffer.numItems = 4

setMatrixUniforms = ->
  gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix)
  gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix)

drawScene = ->
  gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight)
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

  mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix)

  mat4.identity(mvMatrix)

  mat4.translate(mvMatrix, [-1.5, 0.0, -9.0])
  gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer)
  gl.vertexAttribPointer(
    shaderProgram.vertexPositionAttribute,
    triangleVertexPositionBuffer.itemSize,
    gl.FLOAT, false, 0, 0
  )
  setMatrixUniforms()
  gl.drawArrays(gl.TRIANGLES, 0, triangleVertexPositionBuffer.numItems)


  mat4.translate(mvMatrix, [3.0, 0.0, 0.0])
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer)
  gl.vertexAttribPointer(
    shaderProgram.vertexPositionAttribute,
    squareVertexPositionBuffer.itemSize,
    gl.FLOAT, false, 0, 0
  )
  setMatrixUniforms()
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, squareVertexPositionBuffer.numItems)

