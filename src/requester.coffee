((undefined_) ->
  namespace = "od2v"
  @[namespace] = window[namespace] = window[namespace] or {}  if typeof window isnt "undefined"
  @[namespace] = module.exports = {}  if typeof module isnt "undefined"

  fakeRequester = ->
    ->
      throw new Error("Cannot load URL. Neither XMLHttpRequest nor require(\"request\") were found")

  nodeGetter = ->
    return null  if typeof require is "undefined"
    (url, callback) ->
      opts = require('url').parse url

      req = require("http").get opts, (res) ->
        res.setEncoding 'utf8'
        data = ""
        res.on 'data', (chunk) ->
          data += chunk
        res.on 'end', () ->
          try
            data = JSON.parse(data)
          catch e
            return callback(e)

          callback null, data, res.headers
      
      req.on 'error', (err) ->
        return callback(err)  if err
        
      req.end()
  
  browserGetter = ->
    return null  if typeof XMLHttpRequest is "undefined"
    (url, callback) ->
      xhr = new XMLHttpRequest()
      xhr.open "GET", url, true
      xhr.onload = ->
        try
          data = JSON.parse(xhr.responseText)
        catch e
          return callback(e)

        resHeaders = xhr.getAllResponseHeaders()
        callback null, data, resHeaders
  
      xhr.onerror = (e) ->
        callback e
  
      xhr.send null
  
  @[namespace].get = browserGetter() || nodeGetter() || fakeGetter()
  
  # TODO: implementar otros parseadores de datos: xml, csv, xls?
)()