camera = ''
scene = ''
renderer = ''
player = ''
enemy = ''
socket = io.connect('http://192.168.2.46:1234');

window.onload = ->
  init()
  animate()
  register()

init = ->
  width = 600
  height = 600

  camera = new THREE.Camera( 75, width / height, 1, 10000 )
  camera.position.z = 1000

  scene = new THREE.Scene()

  geometry = new THREE.CubeGeometry( 50, 50, 0 )
  enemy_material = new THREE.MeshBasicMaterial( color: 0xff0000, wireframe: true )
  player_material = new THREE.MeshBasicMaterial( color: 0x00ff00, wireframe: true )

  player = new THREE.Mesh( geometry, player_material )
  enemy = new THREE.Mesh( geometry, enemy_material )
  scene.addObject( enemy )
  scene.addObject( player )

  renderer = new THREE.WebGLRenderer()
  renderer.setSize( width, height )

  document.body.appendChild( renderer.domElement )

animate = ->
  requestAnimationFrame( animate )
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
    socket.emit('position_update', { x: player.position.x, y: player.position.y })
  socket.on 'message', ( position ) ->
    enemy.position.x = position.x
    enemy.position.y = position.y

