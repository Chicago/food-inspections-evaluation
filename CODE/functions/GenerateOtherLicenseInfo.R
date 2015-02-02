
GenerateOtherLicenseInfo <- function(inspection_data, 
                                     business_data, 
                                     max_cat = 99){
    
    ## For debugging:
    # inspection_data <- copy(foodInspect)
    # business_data <- copy(business)
    
    ## MAKE DATA COPIES AND SET KEY
    food_licenses <- inspection_data[i = TRUE,
                                     j = list(d_insp = Inspection_Date,
                                              id = Inspection_ID), 
                                     keyby = list(license_food = License)]
    biz <- business_data[i = TRUE, 
                              j = list(dba = DOING_BUSINESS_AS_NAME,
                                       addr = ADDRESS, 
                                       d_start = LICENSE_TERM_START_DATE, 
                                       d_end = LICENSE_TERM_EXPIRATION_DATE,
                                       desc = LICENSE_DESCRIPTION),
                              keyby = list(license = LICENSE_NUMBER)]
    
    ## JOIN BUSINESS NAMES TO FOOD DATA
    food_licenses_names <- biz[food_licenses, mult="first"]
    food_licenses_names <- food_licenses_names[i = TRUE, 
                                               j = list(license_insp = license, id),
                                               keyby = list(dba, addr, d_insp)]
    
    ## SUBSET OF BUSINESSES THAT ARE NOT LICENSED WITHIN THE FOOD DATABASE
    biz_nomatch <- biz[!(license %in% food_licenses_names$license_insp)]
    
    ## SET KEY FOR biz_nomatch TO ENABLE MATCHING IN food_licenses_names
    setkey(biz_nomatch, dba, addr, d_end)
    
    ## MAKE A COPY OF THE INSPECTION DATE, WHICH GETS OVERWRITTEN BY THE END DATE IN THE ROLLING JOIN
    food_licenses_names[ , d_insp_copy := d_insp]
    
    ## CREATE TABLE OF LICENSE DESCRIPTIONS
    tab <- food_licenses_names[biz_nomatch, roll=Inf]
    tab <- tab[!is.na(id)]
    tab <- tab[ , .N, keyby = list(dba, addr, d_insp=d_insp_copy, desc)]
    tab <- dcast.data.table(data = tab,
                            formula = dba + addr + d_insp ~ desc, 
                            value.var = "N", 
                            fill = 0L)
    
    ## SUMMARIZE TOTALS FOR EACH CATEGORY
    category_totals <- as.data.table(sapply(tab[,4:ncol(tab), with=F], sum), 
                                     keep.rownames = TRUE)[order(-V2)]
    setnames(category_totals, c("cat", "N"))
    ## LIMIT CATEGORY COLUMNS
    categories_keep <- category_totals[1:min(max_cat, nrow(category_totals)-3), 
                                       cat]
    tab_final <- tab[,c("dba", "addr", "d_insp", categories_keep), with=F]
    
    setkey(food_licenses_names , dba, addr, d_insp)
    tab_final[food_licenses_names]
    
    ## MERGE RESULTS BACK AND ONLY KEEP INSPECTION ID AS KEY
    ret <- food_licenses_names[tab_final][,c("id", categories_keep), with=F]
    setnames(ret, "id", "Inspection_ID")
    setnames(ret, colnames(ret)[-1], tolower(colnames(ret)[-1]))
    setnames(ret, colnames(ret)[-1], gsub("[[:punct:]]+", "", colnames(ret)[-1]))
    setnames(ret, colnames(ret)[-1], gsub("[ ]+", "_", colnames(ret)[-1]))
    
    setkey(ret, Inspection_ID)
    return(ret)
}


