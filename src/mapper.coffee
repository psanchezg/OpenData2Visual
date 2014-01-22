((undefined_) ->
  namespace = "od2v"
  @[namespace] = window[namespace] = window[namespace] or {}  if typeof window isnt "undefined"
  @[namespace] = module.exports = {}  if typeof module isnt "undefined"

  # Code based on angular.js https://github.com/angular/angular.js/blob/master/src/Angular.js#L491
  isFunction = (value) ->
    typeof value is "function"
  
  # Code based on angular.js https://github.com/angular/angular.js/blob/master/src/Angular.js#L431
  isString = (value) ->
    typeof value is "string"
    
  # Code based on angular.js https://github.com/angular/angular.js/blob/master/src/Angular.js#L517
  isWindow = (obj) ->
    obj and obj.document and obj.location and obj.alert and obj.setInterval

  # Code based on angular.js https://github.com/angular/angular.js/blob/master/src/Angular.js#L475
  isArray = (value) ->
    toString.call(value) is "[object Array]"
    
  # Code based on angular.js https://github.com/angular/angular.js/blob/master/src/Angular.js#L163
  isArrayLike = (obj) ->
    return false  if not obj? or isWindow(obj)
    length = obj.length
    return true  if obj.nodeType is 1 and length
    isString(obj) or isArray(obj) or length is 0 or typeof length is "number" and length > 0 and (length - 1) of obj
    
  # Code based on angular.js https://github.com/angular/angular.js/blob/master/src/Angular.js#L184
  forEach = (obj, iterator, context) ->
    if not obj
      obj
      
    if isFunction(obj)
      for key of obj
        
        # Need to check if hasOwnProperty exists,
        # as on IE8 the result of querySelectorAll is an object without a hasOwnProperty function
        iterator.call context, obj[key], key  if key isnt "prototype" and key isnt "length" and key isnt "name" and (not obj.hasOwnProperty or obj.hasOwnProperty(key))
    else if obj.forEach and obj.forEach isnt forEach
      obj.forEach iterator, context
    else if isArrayLike(obj)
      key = 0
      while key < obj.length
        iterator.call context, obj[key], key
        key++
    else
      for key of obj
        iterator.call context, obj[key], key  if obj.hasOwnProperty(key)

  trim = (str) ->
    return str  unless typeof str is "string"
    str.replace new RegExp(/^\s+|\s+$/g), ""

  cleanSep = (str) ->
    return str  unless typeof str is "string"
    return trim str.substring(str.indexOf(":")+1)
  
  isIndexTable = (table) ->
    table.dim[0] and table.dat and table.dim[0].length is table.dat.length and table.dim[1] and table.dat[0] and table.dim[1].length is table.dat[0].length
  
  removeTotal = (mtx) ->
    return null unless isArray(mtx) and mtx.length > 0 and mtx[0].length > 1
    j = null
    sortarr = mtx[0].slice(0).sort((a, b) ->
      b - a
    )
    sum = 0
    i = 1
    while i < sortarr.length
      if not isNaN(Number(sortarr[i]))
        sum += sortarr[i]

      i++
    
    if sum is sortarr[0]
      j = mtx[0].indexOf(sortarr[0])
      k = 0
      while k < mtx.length
        mtx[k].splice j, 1
        k++
      
    return j;
  
  transposeMtx = (mtx) ->
    transpose = [new Array(mtx.length)]
    forEach mtx, (row, i) ->
      forEach row, (col, j) ->
        transpose[j] ?= []
        transpose[j][i] = mtx[i][j]
    
    transpose
  
  extractTables = (jsondata, cb) ->
    try
      tables = []
      forEach jsondata, ((value, key) ->
        if not value.rows
          return

        @push
          fue: ""
          tit: ""
          uni: ""
          tot: []
          dim: [[], []]
          dat: []

        len = 0
        forEach value.rows, ((row) ->
          if not row.values or row.values.length < 2 or (not @.tit and not row.values[0])
            return
        
          @.uni = cleanSep(row.values[0]) if not @.uni and @.tit
          @.tit = row.values[0] if not @.tit
          @.fue = cleanSep(row.values[0]) if len > 1 and not row.values[1] and not @.fue
        
          if "" is trim(row.values[1])
            return
        
          len++
          k = 0
          forEach row.values, ((col, k) ->
            if len == 1
              if k > 0
                @.dim[1].push trim(col)
            else
              if k == 0
                if trim(col)
                  @dim[0].push trim(col)
              else
                if not @dat[len-2]
                  @dat[len-2] = []

                @dat[len-2].push col
                        
          ), @
        
        ), tables[tables.length-1]
        if not isIndexTable tables[tables.length-1]
          delete tables[tables.length-1]
        else
          j = removeTotal tables[tables.length-1].dat
          if j isnt null
            col = tables[tables.length-1].dim[1].splice j, 1
            tables[tables.length-1].tot[1] = col
      
          trans = transposeMtx tables[tables.length-1].dat
          j = removeTotal trans
          if j isnt null
            tables[tables.length-1].dat.splice j, 1
            col = tables[tables.length-1].dim[0].splice j, 1
            tables[tables.length-1].tot[0] = col
      
      ), tables
      if cb
        cb(null, tables.filter (x) -> x)
      else
        tables.filter (x) -> x

    catch err
      if cb
        cb(err)
      else
        err

  @[namespace].extractTables = extractTables
  @[namespace].transposeMtx = transposeMtx
)()