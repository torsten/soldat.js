camera = ''
scene = ''
renderer = ''
player = ''
player_copy = ''
enemy = ''
box = ''
lasttime = (new Date()).getTime()
socket = io.connect('http://127.0.0.1:1234')
keys = { left:false, up:false, right:false, down:false }

system = jigLib.PhysicsSystem.getInstance()

window.onload = ->
  initJigLib()
  initThree()
  animate()
  register()

initJigLib = ->
  system.setGravity([0,-9.8,0,0])
  system.setSolverType('ACCUMULATED')

  ground = new jigLib.JPlane(null,[0, 1, 0, 0])
  system.addBody(ground)
  ground.moveTo([0,0,0,0])

  box = new jigLib.JSphere(null, 20)
  box.set_mass(20)
  box.moveTo([0, 200, 0, 0])
  box.set_movable(true)
  box.set_friction(0)
  system.addBody(box)

initThree = ->
  width = 600
  height = 600

  camera = new THREE.Camera( 75, width / height, 1, 10000 )
  camera.position.z = 1000 # 8888

  scene = new THREE.Scene()

  geometry = new THREE.SphereGeometry( 20, 16, 16 )
  player_material = new THREE.MeshBasicMaterial(
    color: 0x00ff00, wireframe: true )
  player = new THREE.Mesh( geometry, player_material )
  scene.addObject( player )

  geometry = new THREE.Geometry()
  geometry.vertices.push(
    new THREE.Vertex( new THREE.Vector3( -10000, 0, 0 ) )
  )
  geometry.vertices.push(
    new THREE.Vertex( new THREE.Vector3( 10000, 0, 0 ) )
  )
  line_material = new THREE.LineBasicMaterial(color: 0x000000, opacity: 0.2)
  line = new THREE.Line( geometry, line_material )
  scene.addObject( line )

  renderer = new THREE.WebGLRenderer(canvas: $('canvas')[0])
  renderer.setSize( width, height )

  document.body.appendChild( renderer.domElement )

animate = ->
  requestAnimationFrame( animate )
  # console.log(box._currState.linVelocity)
  # useLinVelocity()
  # useVelocity
  useBodyForce()
  now = (new Date()).getTime()
  inttime = (now - lasttime) / 10000
  system.integrate(inttime)
  player.position.x = box.get_currentState().position[0]
  player.position.y = box.get_currentState().position[1] + 10

  renderer.render( scene, camera )
  $('#player_position').text(player.position.x + ', ' + player.position.y)

useLinVelocity = ->
  force = 20
  if keys.left
    box._currState.linVelocity = [-1 * force, 0,0]
  else if keys.right
    box._currState.linVelocity = [force, 0,0]
  else
    # box._currState.linVelocity[0]= 0

  if keys.up
    box._currState.linVelocity = [0, force, 0]
  else if keys.down
    box._currState.linVelocity = [0, -1 * force, 0]
  else
    # box._currState.linVelocity[1]= 0

useVelocity = ->
  force = 2000
  if keys.left
    box.setVelocity [-1 * force, 0, 0]
  else if keys.right
    box.setVelocity [force, 0, 0]
  else
    # box._currState.linVelocity[0]= 0

  if keys.up
    box.setVelocity [0, force, 0]
  else if keys.down
    box.setVelocity [0, -1 * force, 0]
  else
    # box._currState.linVelocity[1]= 0

useBodyForce = ->
  force = 20
  if keys.left
    box.addBodyForce( [-1*force, 0, 0], [ 1, 0, 0] )
  else if keys.right
    box.addBodyForce( [force, 0, 0], [ -1, 0, 0] )
  else
    box.clearForces()

  if keys.up
    box.addBodyForce( [0, force, 0], [ 0, -1, 0] )
  else if keys.down
    box.addBodyForce( [0, -1*force, 0], [ 0, 1, 0] )
  else
    box.clearForces()

register = ->
  $('body').keydown (event) =>
    k = event.keyCode || event.which
    force = 20
    switch k
      when 37 # left
        keys.left = true
      when 38 # up
        keys.up = true
      when 39 # right
        keys.right = true
      when 40 # down
        keys.down = true
  $('body').keyup (event) =>
    k = event.keyCode || event.which
    force = 20
    switch k
      when 37 # left
        keys.left = false
      when 38 # up
        keys.up = false
      when 39 # right
        keys.right = false
      when 40 # down
        keys.down = false

