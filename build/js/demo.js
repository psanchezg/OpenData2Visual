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
  var init = function() {
    $scope.tables = [];
    $scope.selected = null;
    $scope.error = "";
    $scope.showTotal = $scope.showTotalCol = $scope.processing = false;
  };
  init();
  $scope.start = function() {
    init();
    $scope.processing = true;
    od2v.get($scope.url, function(err, data, resHeaders) {
      $scope.processing = false;
      if (err) {
        $scope.error = "Se produjo un error. Seguro que la URL es válida?";
        if (!$scope.$$phase) {
          $scope.$apply();
        }
        return console.warn(err);
      }
      od2v.extractTables(data, function(err, tables) {
        if (err) {
          $scope.error = "Se produjo un error al procesar el archivo. Por favor reportánoslo a través de los \"issues\" de Github";
          if (!$scope.$$phase) {
            $scope.$apply();
          }
          return console.warn(err);
        }
        console.log(tables);
        $scope.tables = tables;
      });
      if (!$scope.$$phase) {
        $scope.$apply();
      }
    });
  };
  
  $scope.show = function(idx) {
    $scope.showTotal = $scope.showTotalCol = false;
    $scope.selected = angular.copy($scope.tables[idx]);
  }
  
  var sumarFilas = function(mtx, dest) {
    angular.forEach(mtx, function(row) {
      //sumar
      sum = 0
      angular.forEach(row, function(col, idx) {
        if (!isNaN(Number(col))) { sum += col; }
      }, sum);
      if (!dest) {
        row.push(sum);
      } else {
        dest.push(sum);
      }
    });
    if (!$scope.$$phase) {
      $scope.$apply();
    }
  };
  
  $scope.$watch('showTotalCol', function(newVal, oldVal) {
    if (angular.isDefined(newVal) && newVal != oldVal) {
      // Actualizar tabla
      if (newVal) {
        // Antes no estaba. Añadir
        // TODO: si hay mas totales en la tabla???
        $scope.selected.dat.push([]);
        var len = $scope.selected.dat.length-1;
        tit = ($scope.selected.tot[0] && $scope.selected.tot[0].length > 0) ? $scope.selected.tot[0][0] : "Total";
        $scope.selected.dim[0].push(tit);
        var transpose = od2v.transposeMtx($scope.selected.dat);
        sumarFilas(transpose, $scope.selected.dat[len]);
      } else {
        // Quitar total (ultima fila)
        $scope.selected.dim[0].splice($scope.selected.dim[0].length-1, 1);
        $scope.selected.dat.splice($scope.selected.dat.length-1,1);
      }
    }
  }, true);
  
  $scope.$watch('showTotal', function(newVal, oldVal) {
    if (angular.isDefined(newVal) && newVal != oldVal) {
      // Actualizar tabla
      if (newVal) {
        // Antes no estaba. Añadir
        // TODO: si hay mas totales en la tabla???
        tit = ($scope.selected.tot[1] && $scope.selected.tot[1].length > 0) ? $scope.selected.tot[1][0] : "Total";
        $scope.selected.dim[1].push(tit);
        sumarFilas($scope.selected.dat);
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
