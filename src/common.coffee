((undefined_) ->
  namespace = "od2vcommon"
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

  transposeMtx = (mtx) ->
    transpose = [new Array(mtx.length)]
    forEach mtx, (row, i) ->
      forEach row, (col, j) ->
        transpose[j] ?= []
        transpose[j][i] = mtx[i][j]
  
    transpose
  
  sumRows = (mtx, dest) ->
    forEach mtx, (row) ->
      sum = 0
      forEach row, ((col, idx) ->
        sum += col  unless isNaN(Number(col))
      ), sum
      unless dest
        row.push sum
      else
        dest.push sum
    
  # Public
  @[namespace].forEach = forEach
  @[namespace].trim = trim
  @[namespace].cleanSep = cleanSep
  @[namespace].transposeMtx = transposeMtx
  @[namespace].isArray = isArray
  @[namespace].isString = isString
  @[namespace].sumRows = sumRows

)()