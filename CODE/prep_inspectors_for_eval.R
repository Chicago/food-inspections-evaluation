
##
## The sanitarian identies are not publically available, so measures are taken 
## disguise their identities in this analysis.
## This script takes the original disguised data used in the evaluation and 
## modifies it to match the format that became available in the city in early 
## 2015 and is still available as of Dec 2017. 
##

##==========================================================================
## INITIALIZE
##==========================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)

## Load libraries & project functions
geneorama::loadinstall_libraries(c("data.table"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================

inspectors <- readRDS("DATA/inspectors.Rds")
food <- readRDS("DATA/13_food_inspections.Rds")

##==============================================================================
## PROCESS INSPECTOR DATA
##==============================================================================

## Removing letters out front, and numbers trailing hyphen are not needed 
## (e.g. -1006 I believe is the code for retail food license)
inspectors[ , License := gsub('[A-z]+|-.+$', "", License)]

## cleaning any leading zeros
inspectors[ , License := gsub('^[0]+', "", License)]

## removing possibly invalid license numbers
inspectors <- inspectors[nchar(License) > 3 & Inspector_Assigned != " "]

## if multiple inspections for same license number, then using the inspector 
## on the first inspection
inspectors <- inspectors[ , .N, by=list(License, Inspection_Date, Inspector_Assigned)]
inspectors$N <- NULL

## Convert to integer to match other data
inspectors[ , License := as.integer(License)]
setkey(inspectors, License, Inspection_Date)

## Further deduplication
inspectors_deduped <- inspectors[i = TRUE , 
                                 j = list(Inspector_Assigned = Inspector_Assigned[1]), 
                                 keyby = list(License, Inspection_Date)]

## Merge in the Inspection_ID from the food records
inspectors_deduped <- merge(x = food[ , list(License, Inspection_Date, Inspection_ID)],
                            y = inspectors_deduped,
                            by = c("License", "Inspection_Date"),
                            # all.x = TRUE,
                            sort = FALSE)
inspectors_deduped[duplicated(Inspection_ID)]
inspectors_deduped <- inspectors_deduped[!duplicated(Inspection_ID)]

## Make the key columns of the inspector data match the output that the model
## would have gotten from COC internal systems
inspectors_deduped_renamed <- inspectors_deduped[i = TRUE,
                                                 j = list(sanitarian = Inspector_Assigned),
                                                 keyby = list(inspectionID = Inspection_ID)]

geneorama::NAsummary(inspectors_deduped_renamed)

##------------------------------------------------------------------------------
## SAVE RESULT
##------------------------------------------------------------------------------

saveRDS(inspectors_deduped_renamed, "DATA/19_inspector_assignments.Rds")



