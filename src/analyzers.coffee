((undefined_) ->
  namespace = "od2v"
  @[namespace] = window[namespace] = window[namespace] or {}  if typeof window isnt "undefined"
  @[namespace] = module.exports = {}  if typeof module isnt "undefined"

  fakeFn = ->
    ->
      throw new Error("No function found")

  # From common monule
  forEach = @[namespace + "common"].forEach || fakeFn()
  transposeMtx = @[namespace + "common"].transposeMtx || fakeFn()
  isArray = @[namespace + "common"].isArray  || fakeFn()

  isntIndexTable = (table) ->
    table.dim[0] and table.dat and table.dim[0].length is table.dat.length and table.dim[1] and table.dat[0] and table.dim[1].length is table.dat[0].length
  
  removeIndex = (tables) ->
    filtered = []
    forEach tables, ((table) ->
      if isntIndexTable(table)
        @.push table
        
    ), filtered 
    filtered

  removeTotalTable = (mtx) ->
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
  
  extractTotals = (tables) ->
    filtered = []
    forEach tables, ((table) ->
      # Filas y Columnas
      if not table.tot
        table.tot = []
      forEach [1, 0], (k) ->
        if k == 1
          j = removeTotalTable table.dat
        else
          j = removeTotalTable transposeMtx(table.dat)

        if j isnt null
          tot = table.dim[k].splice j, 1
          table.tot[k] = tot
          if k == 0
            table.dat.splice j, 1
        
      # Transponerla y hacer lo mismo
      @.push table
    ), filtered 
    filtered

  groupCNAE2009Table = (table) ->
    # 1. Recorrer filas y ver si grupos CNAE2009
    groups = []
    order = 0
    forEach table.dim[0], ((row, idx) ->
      cnae = Number(row.substring(0, row.indexOf(" ")))
      if not isNaN(cnae)
        # Es un cnae. agrupar
        if cnae < 100
          if not @[cnae]
            obj =
              title: row
              from: idx-order
              to: idx-order
              order: order 

            @[cnae] = obj
            table.dat.splice(idx-order, 1)
            order++
        else
          # Es un subgrupo. añadir elementos
          cnae = Math.floor(cnae / 10)
          @[cnae].from = Math.min(@[cnae].from, idx-order)
          @[cnae].to = Math.max(@[cnae].to, idx-order)

    ), groups
    # Clean nulls
    groups = groups.filter (x) -> x
    sortarr = groups.sort((a, b) ->
      a.order - b.order
    )
    if not table.tot[0]
      table.tot[0] = []
    forEach groups, ((group, idx) ->
      obj = {}
      obj[group.title] = [group.from, group.to]
      @.push obj
    ), table.tot[0]
    table

  groupCNAE2009  = (tables) ->
    filtered = []
    forEach tables, ((table) ->
      @.push groupCNAE2009Table table
    ), filtered 
    filtered
  
  @[namespace].removeIndex = removeIndex
  @[namespace].extractTotals = extractTotals
  @[namespace].groupCNAE2009 = groupCNAE2009

)()