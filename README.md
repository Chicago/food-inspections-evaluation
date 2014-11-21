# Food inspection forecasting evaluation

The City of Chicago has conducted a pilot to test the potential for using predictive analytics to improve the effectiveness of food inspections.  The goal of the predictive model is to identify businesses that are most at risk for having critical violations, which are the types of violations that are most likely to contribute to food borne illness. 

This code is (presently) written entirely in R, which is entirely free and open source statistical modeling software.  R can also be used for data management and manipulation, and within R we make use of a package known as `data.table`.  For best results, we also recommend using R Studio, which also has entirely free and open source distributions.

This repository contains the scripts and data to "run the model".  Specifically

+ Copies of the data used to test the evaluation of the model,
+ Scripts that _can_ be used to download the data used to train and test the model
+ Scripts to perform transformations on the data to prepare it for the model
+ Scripts to incorporate several sources of data,
+ Scripts to create the model used (based on training data), and finally
+ The necessary scripts to evaluate the effectiveness of the City of Chicago's food inspections pilot. 

The general theme througout the workflow is that various data sources are combined through various "keys", and these come together to paint a statistical picture of a business license, which is the primary modelling unit / unit of observation.  It's useful to remember that different keys are employed to join together different data sources, and these keys include things such as Inspection ID, Business License, and Geography expressed as a Latitude / Longitude combination.

We owe a special thanks to our volunteers at Allstate for the model development.  They put in a tremendous amount of work into creating this model and into the code development. 


## Important Files
+ ```./CODE/00_Startup.R``` - Run this within R to download the appropriate packages.
+ ```./CODE/10_download_data.R``` **OPTIONAL** Download most of the necessary files from data.cityofchicago.org.  _You can also just use the included files_!  You will need to rely on some of the included files for data such as weather, unless you would like to modify the model and import your own variables.
+ ```./CODE/11_Filter_data.R``` **OPTIONAL** Filter the large Rds (serialized data) files for more managable file sizes, and remove some unnecessary / incomplete data.
+ ```./CODE/12_Merge.R``` **OPTIONAL** Use this script to calculate field values / features, and merge them into one object for use in the model.  This script makes heavy use of the functions located in ```./CODE/functions```
+ ```30_glmnet_model.R``` The precalculated output from previous scripts is imported and used in the model.  The main data set is indexed by time, and past data is used to independently create a model that is applied to future data (future from the perspective of the model).  In other words, the evaluation of the model uses no knowledge of current conditions to generate the results.  Several metrics of performance are also shown in this script.

The past data is known as training data, and includes observations from September 2011 through January 2014.

The commands in these files should be run sequentially in order to reproduce results.  You can "step through" the code in R Studio (or the R GUI, or other tools such as Eclipse) to interactively see the results.

### Compatibility
These files currently use several packages that are compatible with R >= 3.1. You may experience issues using older versions of R, including 3.0.x and 2.x.

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