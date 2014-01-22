require("coffee-script");
var od2v = require("./src/requester");
var od2vmap = require("./src/sync_mapper");
/*
var url = "http://opendata.aragon.es/render/resource/Directorio%20Central%20de%20Empresas%20(DIRCE)%202012.json";

od2v.get(url, function(err, data, resHeaders) {
    if (err) { return console.warn(err) }
    console.log(data.length, typeof data);
    //console.log(od2vmap.extractTables(data));
});
*/
var jsondata = require("./data/DIRCE2012.json");


var tables = od2vmap.extractTables(jsondata);
//console.log(tables[0]);
console.log(tables[tables.length-1]);
