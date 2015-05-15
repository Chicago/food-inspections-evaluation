.PHONY : all
all : run_model

.PHONY : clean
clean :
	rm DATA/garbageCarts_heat.Rds DATA/sanitationComplaints_heat.Rds DATA/burglary_heat.Rds DATA/food_inspections.Rds DATA/bus_license.Rds DATA/violation_dat.Rds DATA/dat_model.Rds DATA/sanitation_code.Rds DATA/garbage_carts.Rds DATA/crime.Rds

dependencies :
	cd CODE; R --vanilla < 00_Startup.R

DATA/bus_license.Rds : 
	R --vanilla < CODE/11_business_download.R

DATA/crime.Rds :
	R --vanilla < CODE/12_crime_download.R

DATA/food_inspections.Rds : 
	R --vanilla < CODE/13_food_inspection_download.R

DATA/garbage_carts.Rds :
	R --vanilla < CODE/14_garbage_download.R

DATA/sanitation_code.Rds :
	R --vanilla < CODE/15_sanitation_download.R

DATA/violation_dat.Rds : DATA/food_inspections.Rds
	R --vanilla < CODE/21_calculate_violation_matrix.R

DATA/burglary_heat.Rds : DATA/food_inspections.Rds DATA/crime.Rds DATA/garbage_carts.Rds DATA/sanitation_code.Rds
	R --vanilla < CODE/22_calculate_heat_map_values.R 

DATA/garbageCarts_heat.Rds : DATA/burglary_heat.Rds # built with burglary_heat

DATA/sanitationComplaints_heat.Rds : DATA/burglary_heat.Rds # built with buglary_heat

DATA/dat_model.Rds : DATA/garbageCarts_heat.Rds DATA/sanitationComplaints_heat.Rds DATA/burglary_heat.Rds DATA/food_inspections.Rds DATA/bus_license.Rds DATA/violation_dat.Rds DATA/sanitation_code.Rds DATA/garbage_carts.Rds DATA/crime.Rds
	R --vanilla < CODE/23_generate_model_dat.R

run_model : DATA/dat_model.Rds
	R --vanilla < CODE/30_glmnet_model.R
