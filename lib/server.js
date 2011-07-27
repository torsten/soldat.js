// note, io.listen() will create a http server for you
var io = require('socket.io').listen(1234);

io.configure('development', function () {
  io.set('log level', 1);
  io.enable('log');
});


io.sockets.on('connection', function (socket) {
  socket.on('position_update', function(msg, rinfo){
    socket.json.broadcast.send(msg);
  });
});

