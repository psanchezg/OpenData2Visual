((undefined_) ->
  namespace = "od2v"
  @[namespace] = window[namespace] = window[namespace] or {}  if typeof window isnt "undefined"
  @[namespace] = module.exports = {}  if typeof module isnt "undefined"

  fakeFn = ->
    ->
      throw new Error("No function found")

  # From common monule
  trim = @[namespace + "common"].trim || fakeFn()
  cleanSep = @[namespace + "common"].cleanSep || fakeFn()
  forEach = @[namespace + "common"].forEach || fakeFn()
  transposeMtx = @[namespace + "common"].transposeMtx || fakeFn()
  
  extractTables = (jsondata) ->
    try
      tables = []
      forEach jsondata, ((value, key) ->
        if not value.rows
          return

        @push
          fue: ""
          tit: ""
          uni: ""
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
      ), tables
      [null, tables]

    catch err
      [err]

  @[namespace].extractTables = extractTables
  @[namespace].transposeMtx = transposeMtx
)()