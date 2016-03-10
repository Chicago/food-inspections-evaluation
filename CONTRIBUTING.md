# How to Contribute

We welcome efforts to improve this project, and we are open to contributions for model improvements, process improvements, and general good ideas.  Please use this guide to help structure your contributions and to make it easier for us to consider your contributions and provide feedback.  If we do use your work we will acknowledge your contributions to the best of ability, and all contributions will be governed under the license terms specified in the LICENSE.md file in this project. To get started, sign the [Contributor License Agreement](https://www.clahub.com/agreements/Chicago/food-inspections-evaluation).

In general we use the structure provided by GitHub for our workflow management, so if you're new to GitHub please see this guide first: https://guides.github.com/activities/contributing-to-open-source/#contributing

Your contributions have the potential to have a positive impact on not just us, but everyone who is impacted by anyone who uses this project.  So, consider that a big thanks in advance.

## Reporting an Issue

Food Inspections Evaluation uses [GitHub Issue Tracking](https://github.com/Chicago/food-inspections-evaluation/issues) to track issues. This is a good place to start and can be a helpful place to manage both technical and non-technical issues. 

## Submitting Code Changes

Please send a [GitHub Pull Request to City of Chicago](https://github.com/chicago/food-inspections-evaluation/pull/new/master) with a clear list of what you've done (read more about [pull requests](http://help.github.com/pull-requests/)). Always write a clear log message for your commits. 

## Demonstrating Model Performance

We welcome improvements to the analytic model that creates predictions for the Department of Public Health. The city may adopt a pull request that sufficiently improves the accuracy and prediction, thus, allowing you to contribute to the inspection practice for the City.

If your pull request is to improve the model, please consider the following steps when submitting a pull request:
* Identify how your model is improving prior results
* Run a test using the benchmark data provided in the repository
* Create a pull request which describes those improvements in the description.
* Work with the data science team to reproduce those results
 
### Training your data
Train your food inspection model using data between January 2009 and 2012. Use these fits to generate a forecast of food inspections for the time period between September 2, 2014, and October 31, 2014.

### Measuring improvement
The City sought to reduce the time to find critical violations. Thus, we are interested in a few key qualities in any improvements.
* Your model reduces the average time to find critical violations (currently: 7.4 days)
* Your model reduces the variance of the time to find critical violations (e.g., reduces the time by 7.5 days, but the standard deviation is lower)
* Similarly, all restaurants were found earlier with no restaurants being found later, even if the average time remains the same
* Your model increases the proportion of violations found in the first half of the pilot (e.g., percentage of critical violations found in September 2014).
The team has calculated metrics for each one of these measures. You can investigate how these measures were calculated by referring to "Forecasting Restaurants with Critical Violations". Let us know if there are other metrics that should be considered for model improvement.

### Ability to adopt model
If you would like to submit an improvement, please open a pull request that notes improvements to at least one of the aforementioned benchmarks. Your code should be able to reproduce those results by the data science team.

Model improvements that include new data must use data that is freely (*gratis* or *libre*) to the City of Chicago. There must not be any terms that would prohibit the City from storing data.on local servers.

Likewise, by submitting a pull request, you agree that the City of Chicago will be allowed to use your code for analytic purposes and that your software will be licensed under the licensing found in LICENSE.md in this repository.
