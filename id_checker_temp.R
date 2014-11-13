

## Load and save ids from excel

# ids <- as.data.table(geneorama::clipped())
# setnames(ids, "Inspection_ID")
# setkey(ids, Inspection_ID)
# saveRDS(ids, "inspection_ids_in_recreated_data.Rds")


ids <- readRDS("inspection_ids_in_recreated_data.Rds")
geneorama::lll()
geneorama::inin(ids, foodInspect$Inspection_ID)

## Merge ids with foodInspect
setkey(foodInspect, Inspection_ID)
foodInspect[ids]

# temp1 <- foodInspect[ids]
# temp1
# geneorama::wtf(temp1)


setkey(foodInspect, Inspection_ID)
nrow(merge(foodInspect, ids, "Inspection_ID", all.y = F))
nrow(foodInspect[ids])

temp2 <- merge(foodInspect, ids, "Inspection_ID", all.y = F)
geneorama::wtf(temp2)

