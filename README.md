# Generalized-Regression-Neural-Network-Ensemble-for-Single-Imputation

The project deals with development of MATLAB code for single imputation of missing data using a generalized regression neural network for an unlabelled numerical dataset. The incomplete data set will be divided into a complete and incomplete dataset. Relieff algorithm will be applied to choose the optimal subsets. The subsets shall be used to train the GRNN, and the model will be fed to impute the missing data. NRMS will be calculated by comparing the imputed data sets with the original data sets. Moreover, the algorithm shall be analyzed for runtime against the data size and dimensions.

# INTRODUCTION


Missing data is common in large data and occurs due to nonresponse of certain respondents due to lack of information, or unwillingness to share. These form of missingness takes different types and different impacts on the analysis.
There are basically three major forms of missing values

1. Missing at Random(MAR)
Example: One of the gender may be less likely to disclose their weight
Probability that Y(output) is missing depends only on the value of X(Input)

2. Missing Completely at Random(MCAR)
Example: There is no particular reason why some respondents disclose their weights and others do not;
Probability that Y is missing depends only on the value of X

3. Missing Not at Random(MNAR)
Example: Light (or heavy) persons are less likely to disclose their weight
The probability that Y is missing depends on the unobserved value of Y itself.
There are two major methods to deal with missing value, listwise deletion and Imputation. Listwise deletion removes all data for the row having one or more missing value. However, this leads to reduction in the size of complete dataset. Hence, its important to impute the missing values.

The imputation can be single or multiple. In single imputation, each missing value is computed in a each for loop, whereas in multiple imputation generate multiple datasets, perform statistical analysis on them.
The method of GESI bifurcates the data into complete data and incomplete dataset. Then complete dataset is then used to train GRNN and the trained values are used to impute the missing dataset. To impute the missing value, we consider the column contain missing value as our output and the other columns are input. However, it becomes computationally time consuming in case of a large no of features. Hence, we apply Relieff algorithm to select 10 optimal feature subsets as input, which reduces computational time.


RESULTS
The performance of the algorithm can be evaluated by computing the NRMS Value 

The following results for NRMS Values are obtained
