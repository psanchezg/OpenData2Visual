// Generated by CoffeeScript 1.6.3
(function() {
  (function(undefined_) {
    var extractTotals, fakeFn, forEach, groupCNAE2009, groupCNAE2009Table, isArray, isString, isntIndexTable, namespace, removeIndex, removeTotalTable, transposeMtx;
    namespace = "od2v";
    if (typeof window !== "undefined") {
      this[namespace] = window[namespace] = window[namespace] || {};
    }
    if (typeof module !== "undefined") {
      this[namespace] = module.exports = {};
    }
    fakeFn = function() {
      return function() {
        throw new Error("No function found");
      };
    };
    forEach = this[namespace + "common"].forEach || fakeFn();
    transposeMtx = this[namespace + "common"].transposeMtx || fakeFn();
    isArray = this[namespace + "common"].isArray || fakeFn();
    isString = this[namespace + "common"].isString || fakeFn();
    isntIndexTable = function(table) {
      return table.dim[0] && table.dat && table.dim[0].length === table.dat.length && table.dim[1] && table.dat[0] && table.dim[1].length === table.dat[0].length;
    };
    removeIndex = function(tables) {
      var filtered;
      filtered = [];
      forEach(tables, (function(table) {
        if (isntIndexTable(table)) {
          return this.push(table);
        }
      }), filtered);
      return filtered;
    };
    removeTotalTable = function(mtx) {
      var i, j, k, sortarr, sum;
      if (!(isArray(mtx) && mtx.length > 0 && mtx[0].length > 1)) {
        return null;
      }
      j = null;
      sortarr = mtx[0].slice(0).sort(function(a, b) {
        return b - a;
      });
      sum = 0;
      i = 1;
      while (i < sortarr.length) {
        if (!isNaN(Number(sortarr[i]))) {
          sum += sortarr[i];
        }
        i++;
      }
      if (sum === sortarr[0]) {
        j = mtx[0].indexOf(sortarr[0]);
        k = 0;
        while (k < mtx.length) {
          mtx[k].splice(j, 1);
          k++;
        }
      }
      return j;
    };
    extractTotals = function(tables) {
      var filtered;
      filtered = [];
      forEach(tables, (function(table) {
        if (!table.tot) {
          table.tot = [[], []];
        }
        forEach([1, 0], function(k) {
          var j, tot;
          if (k === 1) {
            j = removeTotalTable(table.dat);
          } else {
            j = removeTotalTable(transposeMtx(table.dat));
          }
          if (j !== null) {
            tot = table.dim[k].splice(j, 1);
            table.tot[k].push(tot);
            if (k === 0) {
              return table.dat.splice(j, 1);
            }
          }
        });
        return this.push(table);
      }), filtered);
      return filtered;
    };
    groupCNAE2009Table = function(table) {
      var groups, has_subgroups, new_dat, new_dims, order, sortarr;
      groups = [];
      order = 0;
      new_dims = [];
      new_dat = [];
      has_subgroups = false;
      forEach(table.dim[0], (function(row, idx) {
        var cnae, obj;
        new_dims.push(row);
        new_dat.push(table.dat[idx]);
        console.log("ROW", typeof row, row);
        cnae = (row && isString(row) ? row.substring(0, row.indexOf(" ")) : row);
        if (!isNaN(Number(cnae))) {
          if (cnae.length === 2) {
            if (!this[Number(cnae)]) {
              obj = {
                title: row,
                from: idx - order,
                to: idx - order,
                order: order
              };
              this[Number(cnae)] = obj;
              order++;
              new_dims.splice(new_dims.length - 1, 1);
              return new_dat.splice(new_dat.length - 1, 1);
            }
          } else if (cnae.length === 3) {
            has_subgroups = true;
            cnae = cnae.substring(0, 2);
            this[Number(cnae)].from = Math.min(this[Number(cnae)].from, idx - order);
            return this[Number(cnae)].to = Math.max(this[Number(cnae)].to, idx - order);
          }
        }
      }), groups);
      if (has_subgroups) {
        table.dim[0] = new_dims;
        table.dat = new_dat;
        if (groups.length === 0) {
          table;
        }
        groups = groups.filter(function(x) {
          return x;
        });
        sortarr = groups.sort(function(a, b) {
          return a.order - b.order;
        });
        forEach(groups, (function(group, idx) {
          return this.push([group.title, group.from, group.to]);
        }), table.tot[0]);
      }
      return table;
    };
    groupCNAE2009 = function(tables) {
      var filtered;
      filtered = [];
      forEach(tables, (function(table) {
        return this.push(groupCNAE2009Table(table));
      }), filtered);
      return filtered;
    };
    this[namespace].removeIndex = removeIndex;
    this[namespace].extractTotals = extractTotals;
    return this[namespace].groupCNAE2009 = groupCNAE2009;
  })();

}).call(this);
