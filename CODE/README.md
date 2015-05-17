# Files

- ```00_Startup.R``` Downloads the necessary packages required to step
  through the rest of the R scripts
- ```21_calculate_violation_matrix.R``` Performs matrix calculations
  on types of violations in the inspections data. This step is
  performed in a separate script as it takes some time.
- ```22_calculate_heat_map_values.R``` Calculates heat maps for
  garbage, crime(burglary) and sanitation complaints data.
- ```23_generate_model_dat.R``` Filter primary datsets, creates a
  basis for the model, creates features based on various data
  sets,attaches heat map, inspectors and weather and performs
  requisite merges to the basis model
- ```30_glmnet_model.R``` The pre-calculated output from previous
  scripts is imported and used in the model built, trained and tested
  in this script. The main data set is indexed by time, and past data
  is used to independently build the model. The model is then applied
  to test data.  Finally, this script also includes necessary code to
  evaluate the effectiveness of the City of Chicago’s data driven food
  inspections pilot.
