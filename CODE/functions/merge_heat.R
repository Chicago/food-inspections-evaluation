merge_heat <- function(events, dateCol, window, nGroups=3){
  row_batch <- split(1:nrow(foodInspect), ceiling(1:nrow(foodInspect)*nGroups/nrow(foodInspect)))
  sfInit(parallel=TRUE, cpus=min(nGroups,25)) 
  export <- c(deparse(substitute(events)),"foodInspect","kde", "heat")
  sfExport(list=export) 
  temp_heat <- sfLapply(row_batch, fun=get_heat, dat=events, dateColumn = dateCol, day_window=window)
  sfStop()
  do.call("c",temp_heat)
}

