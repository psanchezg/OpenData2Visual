var static = require('node-static');

var file = new static.Server('./build');

require('http').createServer(function (request, response) {
    request.addListener('end', function () {
        //
        // Serve libraries and htmls!
        //
        file.serve(request, response);
    }).resume();
}).listen(process.env.PORT, process.env.IP);
