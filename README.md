Food Inspections Evaluation
============================

Introduction
------------

In an effort to reduce the public’s exposure to foodborne illness the [City of Chicago](https://github.com/Chicago) partnered with Allstate’s Quantitative Research & Analytics department to develop a predictive model to help prioritize the city's food inspection staff.  This Github project is a complete working evaluation of the model including the data that was used in the model, the code that was used to produce the statistical results, the evaluation of the validity of the results, and documentation of our methodology.

The model evaluation calculates individualized risk scores for more than ten thousand Chicagoland food establishments using publically available data, most of which is updated nightly on [Chicago’s data portal]( https://data.cityofchicago.org/).

The evaluation compares two months of Chicago’s Department of Public Health inspections to an alternative data driven approach based on the model. The two month evaluation period is a completely out of sample evaluation based on a model created using test and training data sets from prior time periods.

The data driven approach predicts which food establishments are most at risk for having ‘critical violations’, which are the types of violations that are most likely to spread food borne illnesses.

This GitHub repository hosts the code and data used to test and train the predictive model we built. Feel free to clone, fork, send pull requests and to file bugs.  Please note that we will need you to agree to our Contributor License Agreement (CLA) in order to be able to use any pull requests.

REQUIREMENTS
------------

All of the code in this project uses the open source statistical application, R.  We advise that you use ```R version >= 3.1``` for best results. 

The code makes extensive usage of the ``data.table`` package. If you are not familiar with the package, you might want to consult the data.table [FAQ available on CRAN] (http://cran.r-project.org/web/packages/data.table/vignettes/datatable-faq.pdf).


SCRIPT ORGANIZATION
------

The scripts contained in `./CODE` are ordered numerically and are intended to be executed in order. 

The output for each script is stored in `./DATA`

However, since all prerequisite data files are pre-calculated and stored in the project, so it is possible to clone this repository and run the scripts in any order.  The data acquisition scripts are provided for completeness.

DATA
------

Data used to develop the model is stored in the ``./DATA`` directory. [Chicago’s Open Data Portal](http://data.cityofchicago.org). The following datasets were used in the building the analysis-ready dataset. 

```
Business Licenses
Food Inspections 
Crime
Garbage Cart Complaints
Sanitation Complaints
Weather
Sanitarian Information
```

The data sources are joined to create a tabular dataset that paints a statistical picture of a ‘business license’- The primary modelling unit / unit of observation in this project.

The data sources are joined (in SQLesque manner) on appropriate composite keys. These keys include Inspection ID, Business License, and Geography expressed as a Latitude / Longitude combination among others. 

CODE
-------------------
 
To get started, first download the code using the following steps. The [submodule](http://git-scm.com/docs/git-submodule) will be required when you will generate [knitr](http://cran.r-project.org/web/packages/knitr/index.html) reports.

<a name="CODE"></a>
```
git clone https://github.com/Chicago/food-inspections-evaluation.git
cd REPORTS/ASSETS/
git submodule init
git submodule update

```


The ``./CODE`` directory contains the scripts to set up your R environment, download the necessary data from Chicago’s open data portal, prepare the analysis-ready data set, and build, train and test the model.

The scripts are intended to run in their numeric order, detailed below.

+    ```00_Startup.R``` Downloads the necessary packages required to step through the rest of the R scripts

+  ```socrata_token.txt``` This is your API token, which is needed to download files from the data portal. Register for an API token [here](https://support.socrata.com/hc/en-us/articles/202950038-How-to-obtain-an-App-Token-aka-API-Key-) and put the token in a new text file called socrata_token.txt in the ``./CODE`` directory. The key must be on the first line of the text file, and can contain white space and trailing comments, e.g. “123456qwerty # this is my key from last year” would be a perfectly valid way to store your key. You could also have more comments / keys stored in the file, as only the first line will be read while finding your key. 

+    ```1X_[various data downloads].R``` **OPTIONAL**  Although all of the data needed to reproduce our results is provided in the `./DATA` directory, it is possible to update many data sources using scripts starting with 11 to 15. If you want to modify the model and import your own variables, these scripts may serve as a useful template to download additional data.

+    ```21_calculate_violation_matrix.R``` Performs matrix calculations on types of violations in the inspections data. This step is performed in a separate script as it takes some time.

+	```22_calculate_heat_map_values.R``` Calculates heat maps for garbage, crime(burglary) and sanitation complaints data. 

+	```23_generate_model_dat.R``` Filter primary datsets, creates a basis for the model, creates features based on various data sets, merges everything together along with heat map calculations, inspector information, and relevant weather data.

+	```30_glmnet_model.R``` The pre-calculated output from previous scripts are imported and used to build the model, tested out of sample data is tested in this script. This script also includes necessary code to evaluate the effectiveness of the City of Chicago’s data driven food inspections pilot, and generate several plots to visualize the results.

REPORTS
-------

The reports may be reproduced compiling the knitr documents present in ``./REPORTS``. If you get errors here, it is likely that you forgot to initiate and update the [submodule](#CODE).


Acknowledgements
----------------
This research was conducted by the [City of Chicago](http://www.cityofchicago.org/city/en/depts/doit.html) with support from the [Civic Consulting Alliance](http://www.ccachicago.org/), and [Allstate Insurance](https://www.allstate.com/). The City would especially like to thank Stephen Collins, Gavin Smart for their efforts in developing the predictive model. We also appreciate the help of Kelsey Burr, Christian Hines, and Kiran Pookote in coordinating this research project. We owe a special thanks to our volunteers from Allstate who put in a tremendous effort to develop the predictive model.

License
-------
Copyright, 2014 City of Chicago

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Libraries and other software utilized in this repository are copyrighted and distributed under their respective open source licenses.
