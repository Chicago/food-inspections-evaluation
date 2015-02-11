Food Inspections Evaluation
============================

Introduction
------------

The [City of Chicago](https://github.com/Chicago) conducts routine food inspections at various food establishments around the city. These food establishments include businesses from your favorite diner to the agency that serves food at a public school nearby your home. While the city public health department does a great job in keep Chicagoans safe from foodborne illnesses, we wondered if preditive analytics could be help. To test the potential of predictive analytics to improve the effectiveness of these food inspections, The City of Chicago recently conducted a pilot using data available on sanitary inspections performed at food establishments in Chicago between September 2011 and November 2014. We built a predictive model to identify food establishments that are most at risk for having ‘critical violations’-, The types of violations that are most likely to spread food borne illnesses. This GitHub repository hosts the code and data used to test and train the predictive model we built. Feel free to clone, fork, send pull requests and file bugs.

DATA
------

Data used for exploration and building, training and testing the predictive model is provided in the ``./DATA`` directory. Most of this data was sourced from the [Chicago’s Open Data Portal](http://data.cityofchicago.org). The following datasets were used in the building the analysis-ready dataset. 

```
Crime (Burglaries only)

Business Licenses(food related)

Food Inspections 

Garbage Carts Complaints

Sanitation Complaints

Weather (Not available at Chicago's Open Data Portal)

Inspectors Information (Not available at Chicago's Open Data Portal)
```

The various data sources are joined to create a dataset ready for analysis which paints a statistical picture of a ‘business license’- The primary modelling unit / unit of observation in this project.

The data sources are joined(in SQLesque manner) on appropriate composite keys. These keys include Inspection ID, Business License, and Geography expressed as a Latitude / Longitude combination among others. For a more detailed explanation of this process, read the [technical document](http://).


REQUIREMENTS
------------

Several packages are not compatible with ```R version < 3.1```. Thus, in order to reproduce all results it is advised to use ```R version >= 3.1```. 

The code makes extensive usage of the ``data.table`` package. If you are not familiar with the package, you might want to consult the package manual on [CRAN](http://cran.r-project.org/web/packages/data.table/index.html) and/or on its GitHub [repository](https://github.com/Rdatatable/data.table/wiki).

Multi-Core processing works only on Linux and OS X machines. It does not work with Windows machines.

CODE
-------------------

 
To get started, first grab the code using the following steps. The [submodule](http://git-scm.com/docs/git-submodule) will be required when you will generate [knitr](http://cran.r-project.org/web/packages/knitr/index.html) reports.



<a name="CODE"></a>

```
git clone https://github.com/Chicago/food-inspections-evaluation.git
cd REPORTS/assets/
git submodule init
git submodule update

```


The ``./CODE`` directory contains the scripts to set up your R environment, download the necessary data from Chicago’s open data portal, prepare the analysis-ready data set, and build, train and test the model.



After you have updated the R version, run the following scripts in the order specified below.

+    ```00_Startup.R``` Downloads the necessary packages required to step through the rest of the R scripts


+  ```socrata_token.txt``` This is your API token, which is needed to download files from the data portal. Register for an API token [here](https://support.socrata.com/hc/en-us/articles/202950038-How-to-obtain-an-App-Token-aka-API-Key-) and put the token in a new text file called socrata_token.txt in the ``./CODE`` directory. The key must be on the first line of the text file, and can contain white space and trailing comments, e.g. “123456qwerty # this is my key from last year” would be a perfectly valid way to store your key. You could also have more comments / keys stored in the file, as only the first line will be read while finding your key. 

       


+    ```10_download_data.R``` **OPTIONAL**  Some of the data such as the weather data set is not available at the city data portal and might not be available to you in the format as used in the project from other sources. Thus, it is recommended to use the data provided in the. /DATA directory. However, if you want  to modify the model and import your own variables than most of the data is available at the Data Portal. Make sure you change the value of ``multi`` variable based on the machine where you are running the script.



+	```11_calculate_violation_matrix.R``` Performs matrix calculations on types of violations in the inspections data. This step is performed in a separate script as it takes some time.



+	```12_calculate_heat_map_values.R``` Calculates heat maps for garbage, crime(burglary) and sanitation complaints data. 



+	```13_generate_model_dat.R``` Filter primary datsets, creates a basis for the model, creates features based on various data sets,attaches heat map, inspectors and weather and performs requisite merges to the basis model



+	```30_glmnet_model.R``` The pre-calculated output from previous scripts is imported and used in the model built, trained and tested in this script. The main data set is indexed by time, and past data is used to independently build the model. The model is then applied to test data.  Finally, this script also includes necessary code to evaluate the effectiveness of the City of Chicago’s data driven food inspections pilot.

REPORTS
-------

The reports may be reproduced compiling the knitr documents present in ``./REPORTS``. If you get errors here, it is likely that you forgot to initiate and update the [submodule](#CODE).


Acknowledgements
----------------
This research was conducted by the [City of Chicago](http://www.cityofchicago.org/city/en/depts/doit.html) with support from the [Civic Consulting Alliance](http://www.ccachicago.org/), and [Allstate Insurance](https://www.allstate.com/). The City would especially like to thank Stephen Collins, Gavin Smart for their efforts in developing the predictive model. We also appreciate the help of Kelsey Burr, Christian Hines, and Kiran Pookote in coordinating this research project. We owe a special thanks to our volunteers from Allstate for the developing the predictive model who put in a tremendous amount of work in building the model and writing the various scripts .

License
-------
Copyright, 2014 City of Chicago

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Libraries and other software utilized in this repository are copyrighted and distributed under their respective open source licenses.
