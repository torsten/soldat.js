io = require('socket.io').listen(1234)

io.configure 'development', ->
  io.set('log level', 1)
  io.enable('log')



io.sockets.on 'connection', (socket) ->
  socket.on 'position_update', (msg, rinfo) -> socket.json.broadcast.send(msg)

