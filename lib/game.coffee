camera = ''
scene = ''
renderer = ''
player = ''
player_copy = ''
enemy = ''
box = ''
lasttime = (new Date()).getTime()
socket = io.connect('http://192.168.2.46:1234')

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
  ground.set_friction(10)
  system.addBody(ground)
  ground.moveTo([0,0,0,0])

  box = new jigLib.JBox(null, 84, 74, 0)
  box.set_mass(50)
  box.moveTo([0, 200, 0, 0])
  box.set_movable(true)
  system.addBody(box)

initThree = ->
  width = 600
  height = 600

  camera = new THREE.Camera( 75, width / height, 1, 10000 )
  camera.position.z = 1000

  scene = new THREE.Scene()

  geometry = new THREE.CubeGeometry( 50, 50, 0 )
  enemy_material = new THREE.MeshBasicMaterial( color: 0xff0000, wireframe: true )
  player_material = new THREE.MeshBasicMaterial( { map: THREE.ImageUtils.loadTexture( 'images/soldier.gif' ) } )

  player = new THREE.Mesh( new THREE.CubeGeometry( 84, 74, 0 ), player_material )
  player_copy = new THREE.Mesh( new THREE.CubeGeometry( 84, 74, 0 ), new THREE.MeshBasicMaterial( color: 0x00ff00, wireframe: true ) )
  enemy = new THREE.Mesh( geometry, enemy_material )
  player.position.y = 25
  enemy.position.y = 25
  scene.addObject( enemy )
  scene.addObject( player )
  scene.addObject( player_copy )

  geometry = new THREE.Geometry()
  geometry.vertices.push( new THREE.Vertex( new THREE.Vector3( -1000, 0, 0 ) ) )
  geometry.vertices.push( new THREE.Vertex( new THREE.Vector3( 1000, 0, 0 ) ) )
  line_material = new THREE.LineBasicMaterial(  color: 0x000000, opacity: 0.2  )
  line = new THREE.Line( geometry, line_material )
  scene.addObject( line )

  renderer = new THREE.WebGLRenderer(canvas: $('canvas')[0])
  renderer.setSize( width, height )

  document.body.appendChild( renderer.domElement )

animate = ->
  requestAnimationFrame( animate )
  now = (new Date()).getTime()
  inttime = (now - lasttime) / 10000
  system.integrate(inttime)
  player.position.x = box.get_currentState().position[0]
  player.position.y = box.get_currentState().position[1] + 74/2
  player_copy.position.x = box.get_currentState().position[0]
  player_copy.position.y = box.get_currentState().position[1] + 74/2

  renderer.render( scene, camera )
  $('#player_position').text(player.position.x + ', ' + player.position.y)
  $('#enemy_position').text(enemy.position.x + ', ' + enemy.position.y)

register = ->
  step = 50
  $('body').keydown (event) =>
    k = event.keyCode || event.which
    switch k
      when 37 # left
        console.log('left')
        box.addBodyForce(
          [-1000, 0, 0],
          null
        )
      when 38 # up
        console.log('up')
        box.addBodyForce(
          [0, 10000, 0],
          [0,0,0]
        )
      when 39 # right
        console.log('right')
        box.addBodyForce(
          [-1000, 0, 0],
          [0,0,0]
        )
      when 40 # down
        console.log('down')
        box.addBodyForce(
          [0, -1000, 0],
          [0,0,0]
        )
      when 82
        console.log('respawn')
        box.moveTo([0, 200, 0, 0])
        animate()


    socket.emit('position_update',  x: player.position.x, y: player.position.y )
  socket.on 'message', ( position ) ->
    enemy.position.x = position.x
    enemy.position.y = position.y

