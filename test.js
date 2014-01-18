require("coffee-script");
var od2v = require("./src/requester");
var url = "http://opendata.aragon.es/render/resource/Directorio Central de Empresas (DIRCE).json";

od2v.get(url, function(err, data, resHeaders) {
    if (err) { return console.warn(err) }
    console.log(data.length, typeof data);
});