angular.module('components', [])
  .filter("numberOrStr", ["$filter", function($filter) {
    var angularNumberFilter = $filter("number");
    return function(val) {
      if (isNaN(Number(val))) {
        return val;
      }
      return angularNumberFilter(val);
    };
  }]);

angular.module('app', ['components'])
.controller('DemoCtrl', ['$scope', function($scope) {
  var selIdx = null;
  var init = function() {
    $scope.tables = [];
    $scope.selected = null;
    $scope.error = "";
    $scope.showTotal = $scope.showTotalCol = $scope.processing = false;
  };
  init();
  
  $scope.setUrl = function(url) {
    $scope.url = "http://opendata.aragon.es/catalogo/render/resource/"+url;
    //focus('focusMe');
    angular.element('input[autofocus]:visible:first').trigger('focus');
  }
  var process = function(jsondata, cfg) {
    // usar el mapper que recomienda la configuracion
    od2v[cfg.mapper] = od2v; // De momento solo hay uno
    if (od2v[cfg.mapper]) {
      tables = od2v[cfg.mapper].extractTables(jsondata);
        if (tables[0]) {
          $scope.error = "Se produjo un error al procesar el archivo. Por favor reportánoslo a través de los \"issues\" de Github";
          if (!$scope.$$phase) {
            $scope.$apply();
          }
          return console.warn(err);
        }
      if (!tables[0]) {
        tables = tables[1];
        od2vcommon.forEach(cfg.analyzers, function(key) {
          if (od2v[key]) {
            tables = od2v[key](tables);
          }
        });
        $scope.tables = tables;
        if (!$scope.$$phase) {
          $scope.$apply();
        }
        //console.log(tables[tables.length-1]);
      }
    }
  };
  
  $scope.start = function() {
    init();
    $scope.processing = true;
    od2v.get($scope.url, function(err, jsondata, resHeaders) {
      $scope.processing = false;
      if (err) {
        $scope.error = "Se produjo un error. Seguro que la URL es válida?";
        if (!$scope.$$phase) {
          $scope.$apply();
        }
        return console.warn(err);
      }
      od2v.get("config.json", function(err, cfg, resHeaders) {
          if (err) {
            $scope.error = "Se produjo un error. Seguro que la URL es válida?";
            if (!$scope.$$phase) {
              $scope.$apply();
            }
            return console.warn(err);
          }
          var found = false;
          angular.forEach(Object.keys(cfg), function(cfgkey) {
            if (found) {
                // Sólo la primera concordancia
                return;
            }
            if ($scope.url.match(new RegExp(cfgkey))) {
                found = true;
                //console.log("Processing with", cfg[cfgkey])
                process(jsondata, cfg[cfgkey]);
            }
          });
          if (!found) {
              process(jsondata, cfg[Object.keys(cfg)[0]]);
          }
        });
      });
  };
  
  $scope.show = function(idx) {
    $scope.showTotal = $scope.showTotalCol = false;
    $scope.selected = angular.copy($scope.tables[idx]);
    selIdx = idx;
    $scope.selected.cls = [[], []];
  }
  
  var sumRows = function(mtx, dest, i, j) {
    i = angular.isUndefined(i) ? 0 : i;
    j = angular.isUndefined(j) ? mtx.length-1 : j;
    for (var k=i; k<=j; k++) {
      //sumar fila
      sum = 0
      angular.forEach(mtx[k], function(col, idx) {
        if (!isNaN(Number(col))) { sum += col; }
      }, sum);
      if (!dest) {
        mtx[k].push(sum);
      } else {
        dest.push(sum);
      }
    }
  };
  
  var sumCols = function(mtx, dest, i, j) {
    i = angular.isUndefined(i) ? 0 : i;
    j = angular.isUndefined(j) ? mtx.length-1 : j;
    var sum, totsum = 0;
    angular.forEach(mtx[i], function(col, idx) {
      sum = 0;
      for (var k=i; k<=j; k++) {
      //sumar filas
        if (!isNaN(Number(mtx[k][idx]))) { sum += mtx[k][idx]; }
      };
      dest.push(sum);
      totsum += sum;
    });
    if ($scope.showTotal) {
      dest.push(totsum);
    }
  };
  
  $scope.$watch('showTotalCol', function(newVal, oldVal) {
    if (angular.isDefined(newVal) && newVal != oldVal) {
      // Actualizar tabla
      if (newVal) {
        // Antes no estaba. Añadir
        if (!$scope.selected.tot[0]) {
            $scope.selected.tot[0] = [];
        }
        if ($scope.selected.tot[0].length == 0 || $scope.selected.tot[0][$scope.selected.tot[0].length-1].length > 1) {
            // Crear total
            $scope.selected.tot[0].push(["Total"]);
        }
        var inserts = -1, insertAt;
        angular.forEach($scope.selected.tot[0], function(tot, idx) {
            if (tot.length == 1) {
                tot = angular.copy(tot);
                tot.push(1);
                tot.push($scope.tables[selIdx].dat.length);
                insertAt = $scope.selected.dat.length;
            } else {
                insertAt = tot[1]+inserts;
            }
            $scope.selected.dim[0].splice(insertAt, 0, tot[0]);
            $scope.selected.cls[0][insertAt] = "success";
            $scope.selected.dat.splice(insertAt, 0, []);
            sumCols($scope.tables[selIdx].dat, $scope.selected.dat[insertAt], tot[1]-1, tot[2]-1); // Depende de si se ha quitado el total
            inserts++;
        });
      } else {
        // TODO: Quitar totales
        var deleted = 0;
        angular.forEach($scope.selected.cls[0], function(cls, idx) {
            if (cls == 'success') {
                $scope.selected.dim[0].splice(idx-deleted, 1);
                $scope.selected.dat.splice(idx-deleted, 1);
                deleted++;
            }
        });
        $scope.selected.cls[0] = new Array($scope.selected.dat.length);
      }
    }
  }, true);
  
  $scope.$watch('showTotal', function(newVal, oldVal) {
    if (angular.isDefined(newVal) && newVal != oldVal) {
      // Actualizar tabla
      if (newVal) {
        // Antes no estaba. Añadir
        // TODO: si hay mas totales en la tabla???
        tit = ($scope.selected.tot[1] && $scope.selected.tot[1].length > 0) ? $scope.selected.tot[1][$scope.selected.tot[1].length-1][0] : "Total";
        $scope.selected.dim[1].push(tit);
        $scope.selected.cls[1][$scope.selected.dim[1].length-1] = "success";
        sumRows($scope.selected.dat);
      } else {
        // Quitar total
        $scope.selected.dim[1].splice($scope.selected.dim[1].length-1, 1);
        angular.forEach($scope.selected.dat, function(row) {
          row.splice(row.length-1, 1);
        });
      }
    }
  }, true);

}]);