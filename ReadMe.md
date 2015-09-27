README
-> this text explains how the script 'run_analysis.R' works

The script expects to find all files in the current working directory or in subfolders thereof.
The subfolders are as contained in the zipped source data downloaded (in September 2015) from:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

In the first part of the script the test- data and the training-data are treated individually as follows:
2 additional columns are added to the data (for each column a sep. file from the original data can be used):
- one containing information about the observed subjects
- one containing information about the observed activities

Then, after both test- and training data have been extended by two columns in exactly the same way the two data sets are combinied into one data set.

The feature list contained in the original data is used to name the columns of the combined data set.
As the data set has been extended with two additional columns ('subject', 'activitiy') these two labels are added to the feature list before it is used to name the columns in the data set.

As it turns out the data now has various columns with identical names.
This would be a problem when working with dplyr- and tidyr-functions because these functions expect unique column names.
As all the columns with dublicate names will not be needed in the final data set (only columns with names containing 'mean()' or 'std()' will be retained) they are now removed from the data set.

In the final data set information about activies is expected to be expressed as descriptive strings rather than as numerical codes.
So the numerical codes contained in the original data are replaced with the corresponding string labels given in one of the sep. files contained in the original data source.

For all remaining transformations dplyr- and tidyr-functions will be used.
So the corresponding libraries are loaded and the current data frame is turned into a data table.

All columns not containing 'mean()' or 'std()' in their names are removed from the data table.
The data table is then grouped by 'subject' and by 'activity' and the mean is then calculated for all other colums.
The data table is then converted into a long data from.

The resulting data table is not tidy yet. This is because the column 'variable' contains up to four different types of information:
- type information: 'time signal' vs. 'frequency signal'
- feature: BodyAcc, BodyAccJerk, BodyAccJerkMag etc.
- measure: 'mean()' vs. 'std()'
- orientation in space(where applicalbe): X, Y, Z

To solve this and make the data table tidy the column 'variable' is thus split into four individual columns with only one type of information per column.

The resulting tidy data frame is then stored in a txt file.