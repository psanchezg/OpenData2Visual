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
        table.tot = [[], []]
      forEach [1, 0], (k) ->
        if k == 1
          j = removeTotalTable table.dat
        else
          j = removeTotalTable transposeMtx(table.dat)

        if j isnt null
          tot = table.dim[k].splice j, 1
          table.tot[k].push tot
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
    new_dims = []
    new_dat = []
    has_subgroups = false;
    forEach table.dim[0], ((row, idx) ->
      new_dims.push row
      new_dat.push table.dat[idx]
      cnae = row.substring(0, row.indexOf(" "))
      if not isNaN(Number(cnae))
        # Es un cnae. agrupar
        if cnae.length == 2
          if not @[Number(cnae)]
            obj =
              title: row
              from: idx-order
              to: idx-order
              order: order 

            @[Number(cnae)] = obj
            order++
            new_dims.splice new_dims.length-1, 1
            new_dat.splice new_dat.length-1, 1
        else if cnae.length == 3
          # Es un subgrupo. añadir elementos
          has_subgroups = true
          cnae = cnae.substring(0,2)
          @[Number(cnae)].from = Math.min(@[Number(cnae)].from, idx-order)
          @[Number(cnae)].to = Math.max(@[Number(cnae)].to, idx-order)
    ), groups

    if has_subgroups
        table.dim[0] = new_dims
        table.dat = new_dat
    
        if groups.length == 0
            table
        
        # Clean nulls
        groups = groups.filter (x) -> x
        # Sort
        sortarr = groups.sort((a, b) ->
          a.order - b.order
        )
        forEach groups, ((group, idx) ->
          @.push [group.title, group.from, group.to]
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