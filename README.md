# Food inspection forecasting evaluation

The City of Chicago has conducted a pilot to test the potential for using predictive analytics to improve the effectiveness of food inspections.  The goal of the predictive model is to identify businesses that are most at risk for having critical violations, which are the types of violations that are most likely to contribute to food borne illness. 

The purpose of this repository is to share the evaluation of our results, which includes everything that we used to evaluate the effectiveness of this model.   In this analysis a test data set was used to construct a model, the model was given to the City of Chicago, and we used a completely separate set of data from the present to evaluate the effectiveness.  The date range of the training data is September 2011 through April 2014.  The model was provided to the City of Chicago in October, and was evaluated on data from October 1, 2014 through November 30, 2014.

Users are welcome to adopt this analysis for their own purposes, or explore the analysis.  Suggestions are welcome and can be made through Github pull requests, or by opening an issue in this project.

## System requirements

The analysis was conducted entirely in R, which is entirely free and open source statistical modeling software.  R can also be used for data management and manipulation, and within R we make use of a package known as `data.table`.  For best results, we also recommend using R Studio, which also has entirely free and open source distributions.

Required packages are loaded at the start of each script in an initialization section. 

## Running the model

This repository contains the scripts needed to acquire the necessary data and run the model.   For convenience, local copies of all the required data sets are also stored in this repository.  Most of the data comes from the City of Chicago’s data portal: https://data.cityofchicago.org/, however some data (such as weather) was stored locally for convenience. The data that comes from the portal can be downloaded again using our download scripts.  Advanced users are welcome to try other data sets and add variables or experiment with alternative models. 

Generally, the scripts are contained in the ```CODE``` folder and are intended to be run in their numeric order.  They rely on functions stored in the project folder ```CODE/functions```.

**NOTE** Because local copies were stored in the project, all the requisite data files have been already been generated locally.  So, the user could jump immediately to the ```30_glmnet_model.R```.

We owe a special thanks to our volunteers at Allstate for the model development.  They put in a tremendous amount of work into creating this model and into the code development. 


## Important Files
+ ```./CODE/00_Startup.R``` - Run this within R to download packages that require special installation, and to update pacakges.
+ ```./CODE/socrata_token.txt``` This is **your** socrata api key, which _you need to obtain_ from the Socrata website (below).  The key must be on the first line of the text file, and can contain white space and trailing comments, e.g. "123456qwerty  # this is my key from last year" would be a perfectly valid way to store your key.  You could also have more comments / keys stored in the file, because _only the first line will be used_.  You find out how to register for a free key here: https://support.socrata.com/hc/en-us/articles/202950038-How-to-obtain-an-App-Token-aka-API-Key-
+ ```./CODE/10_download_data.R``` **OPTIONAL** Download most of the necessary files from data.cityofchicago.org.  _You can also just use the included files_!  You will need to rely on some of the included files for data such as weather, unless you would like to modify the model and import your own variables.
+ ```./CODE/11_calculate_violation_matrix.R``` **OPTIONAL** This step is separate from the rest of the work flow because it takes a while to complete on most machines.  It parses the Violation description / text from the food inspection data, and creates a matrix of violation types arranged by number.  It then totals the violation types to determine how many violations there were for each inspection that were “critical”, “serious”, or “minor”.
+ ```./CODE/ 12_calculate_heat_map_values.R``` **OPTIONAL** This step is also separate because of runtime. This step calculates “heat map” style density values for three data sets used in the model.  This relies on a modified version of the `kde` function from the `MASS` package.
+ ```./CODE/ 13_generate_model_dat.R`` **OPTIONAL** This step combines the data sources and creates a single data set that can be used in the modeling step.  Additional features are also calculated in this step, as described in the comments in the code.
+ ```30_glmnet_model.R``` The precalculated output from previous scripts is imported and used in the model.  The main data set is indexed by time, and past data is used to independently create a model that is applied to future data (future from the perspective of the model).  In other words, the evaluation of the model uses no knowledge of current conditions to generate the results.  Several metrics of performance are also shown in this script.

The commands in these files should be run sequentially in order to reproduce results.  Each script should run independently.  You can "step through" the code in R Studio (or the R GUI, or other tools such as Eclipse) to interactively see the results.

### Compatibility
These files currently use several packages that are compatible with R >= 3.1. You may experience issues using older versions of R, including 3.0.x and 2.x.

## Acknowledgements
This research was completed in cooperation between the City of Chicago, Civic Consulting Alliance, and Allstate Insurance. We would especially like to thank the efforts of Stephen Collins, Gavin Smart for their collaboration on developing the model. We also appreciate the coordination provided by Kelsey Burr, Christian Hines, and Kiran Pookote.

## License
Copyright, 2014 City of Chicago

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Libraries and other software utilized in this repository are copyrighted and distributed under their respective open source licenses.
