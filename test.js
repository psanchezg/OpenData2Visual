require("coffee-script");
var od2v = require("./src/requester");
var common = require("./src/common");

var mappers = {
  "jsonAsExcel": require("./src/mapper")
}

var analyzers = {
  "removeIndex": require("./src/analyzers").removeIndex,
  "extractTotals": require("./src/analyzers").extractTotals,
  "groupCNAE2009": require("./src/analyzers").groupCNAE2009
}

/*
var url = "http://opendata.aragon.es/render/resource/Directorio%20Central%20de%20Empresas%20(DIRCE)%202012.json";

od2v.get(url, function(err, data, resHeaders) {
    if (err) { return console.warn(err) }
    console.log(data.length, typeof data);
    //console.log(od2vmap.extractTables(data));
});
*/
var file = "DIRCE2012.json";
var jsondata = require("./build/data/" + file);
var tables;

var cfg = require("./build/config.json");
if (cfg[file]) {
  // usar el mapper que recomienda la configuracion
  if (mappers[cfg[file].mapper]) {
    tables = mappers[cfg[file].mapper].extractTables(jsondata);
    if (!tables[0]) {
      tables = tables[1];
      console.log("MAPPER:", tables.length);
      console.log(analyzers);
      common.forEach(cfg[file].analyzers, function(key) {
        console.log("KEY", key);
        if (analyzers[key]) {
          console.log("PROCESSING", key)
          tables = analyzers[key](tables);
        }
      });
      console.log("ANALYZED:", tables.length);
      console.log(tables[0].tot, tables[0].dat.length);
        
      //console.log(tables[tables.length-1]);
    }
  }
    
}
  

