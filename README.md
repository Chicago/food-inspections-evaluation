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

 To get started, first grab the code. 

```bash
git clone https://github.com/Chicago/food-inspections-evaluation.git
```

The ``./CODE`` directory contains the scripts to set up your R
environment, download the necessary data from Chicago’s open data
portal, prepare the analysis-ready data set, and build, train and test
the model.

Run the scripts in the `./CODE` directory in order or do

```bash
make dependencies
make all
```

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
