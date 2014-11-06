This repository contains the necessary data and scripts to evaluate the effectiveness of the City of Chicago's food inspections pilot. This repository contains the training data and evaluation data.

## Important FIles
+ ```./CODE/recreating_training_data.R``` - Generates training data from September 2011 through January 2014.
+ ```./CODE/out-of-sample-generation/create_out-of-sample_data.R``` - Generates out-of-sample data to evaluate the effectiveness of the model.
+ ```./CODE/fit_glmnet.R``` - fits the analytical model, generates coefficients.
+ ```./OUT/evaluation-summary.html``` - summarizes the findings of the program's evaluation. This was created with knitr and the underlying analytics can be seen in ```./OUT/evaluation-summary.R```.

## Running files

### Generating training data
Execute ```recreating_training_data.R``` to generate training data:
```shell
Rscript /path/to/food-inspections-evaluation/CODE/recreating_training_data.R
```

### Generating evaluation / out-of-sample data
Execute ```create_out-of-sample_data.R``` to generate the out-of-sample data used for the evaluation:
```shell
Rscript /path/to/food-inspections-evaluation/CODE/out-of-sample-generation/recreating_training_data.R
```

### Generating evaluation / out-of-sample data
Execute ```fit_glmnet_evaluation.R``` to generate the out-of-sample data used for the evaluation:
```shell
Rscript /path/to/food-inspections-evaluation/CODE/fit_glmnet_evaluation.R
```

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