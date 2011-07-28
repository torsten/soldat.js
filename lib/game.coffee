camera = ''
scene = ''
renderer = ''
player = ''
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

  ground = new jigLib.JPlane(null,[0, 0, 0, 0])
  ground.set_friction(10)
  system.addBody(ground)
  ground.moveTo([0,0,0,0])

  box = new jigLib.JBox(null, 100, 100, 0)
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
  enemy = new THREE.Mesh( geometry, enemy_material )
  player.position.y = 25
  enemy.position.y = 25
  scene.addObject( enemy )
  scene.addObject( player )

  geometry = new THREE.Geometry()
  geometry.vertices.push( new THREE.Vertex( new THREE.Vector3( -1000, 0, 0 ) ) )
  geometry.vertices.push( new THREE.Vertex( new THREE.Vector3( 1000, 0, 0 ) ) )
  line_material = new THREE.LineBasicMaterial(  color: 0x000000, opacity: 0.2  )
  line = new THREE.Line( geometry, line_material )
  scene.addObject( line )

  renderer = new THREE.WebGLRenderer()
  renderer.setSize( width, height )

  document.body.appendChild( renderer.domElement )

animate = ->
  requestAnimationFrame( animate )
  now = (new Date()).getTime()
  inttime = (now - lasttime) / 10000
  system.integrate(inttime)
  player.position.x = box._boundingBox._maxPos[0]
  player.position.y = box._boundingBox._maxPos[1]
  renderer.render( scene, camera )

register = ->
  step = 50
  $('body').keydown (event) =>
    k = event.keyCode || event.which
    switch k
      when 37 # left
        player.position.x += -1 * step
      when 38 # up
        player.position.y += step
      when 39 # right
        player.position.x += step
      when 40 # down
        player.position.y += -1 * step
    socket.emit('position_update',  x: player.position.x, y: player.position.y )
  socket.on 'message', ( position ) ->
    enemy.position.x = position.x
    enemy.position.y = position.y

