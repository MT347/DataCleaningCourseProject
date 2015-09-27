# this script expects to find all necessary files in the current working directory or in subfolders thereof
# subfolders are as contained in the zipped source data
# source data downloaded in September 2015 from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip



# read test subjects and activities into temporary tables
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_activity <- read.table("UCI HAR Dataset/test/y_test.txt")

# read test data into table
test_data <- read.table("UCI HAR Dataset/test/x_test.txt")

# combine testdata with activity- and subject-information
test_data <- cbind(test_subject,test_activity,test_data)

#remove temporary tables 'testactivity' and 'test_subject'
rm(test_subject,test_activity)


# now repeat the same steps for the training data:
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_activity <- read.table("UCI HAR Dataset/train/y_train.txt")
train_data <- read.table("UCI HAR Dataset/train/x_train.txt")
train_data <- cbind(train_subject,train_activity,train_data)
rm(train_subject,train_activity)


# now combine test- and training-data into one table and remove the separate table
all_data <- rbind(test_data,train_data)
rm(test_data,train_data)


# read features into a table
features <- read.table("UCI HAR Dataset/features.txt")
# using the features table, create a temporary vector that can be used as column names for the data
headers <- c("subject", "activity", as.vector(features[,2]))
# apply column names to the data an remove the temporary vector
colnames(all_data) <- headers
rm(features,headers)


# the data now contains duplicate column names
# this would be a problem when using dplyr functions later
# hance all columns with duplicate names will be removed from the data (they will not be needed)
all_data <- all_data[ , !duplicated(colnames(all_data))]


# replace the numeric values currently used in the 'activity'-column with more descriptive string values
all_data$activity[all_data$activity == 1] <- 'WALKING'
all_data$activity[all_data$activity == 2] <- 'WALKING_UPSTAIRS'
all_data$activity[all_data$activity == 3] <- 'WALKING_DOWNSTAIRS'
all_data$activity[all_data$activity == 4] <- 'SITTING'
all_data$activity[all_data$activity == 5] <- 'STANDING'
all_data$activity[all_data$activity == 6] <- 'LAYING'


# for the final operations dplyr and tidyr funtions will be use
# hence the dplyr packe will be loaded and the data frame prepared so fare will be converted into a data table
# the data frame will no longer be used and is removed
library(dplyr)
library(tidyr)
data <- tbl_df(all_data)
rm(all_data)


data %>%
# only keep (select) columns with either 'std' or 'mean' in the column name
select(matches("subject|activity|-std\\(|-mean\\(")) %>%

# group data frame by 'subject' and by 'activity'
group_by(subject,activity, add = FALSE) %>%
# calculate the mean for each variable
summarise_each(funs(mean)) %>%
# bring the table into a long format
gather(variable, value, -(subject:activity)) %>%
# the table is not tidy yet, as there is more than one variable (information) in the variable column
# do splits to seperate all variables (information) into sep. columns  
separate(variable, c("variable", "measure", "orientation"), sep = "-", remove = TRUE) %>%
separate(variable, c("type", "feature"), sep = 1, remove = TRUE) %>%

# write result to file
write.table(file = "tidy_output.txt", row.names=FALSE)
 




