
## R Script created by Igor Alcantara as part of course assignment.
## Created at 2015-10-15

## The Data Source is available at
### http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

# The Assignment is: 
## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##################################################################
##################################################################
## Install (if not installed already) the necessary packages.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

##################################################################

##################################################################
##################################################################
# Read and Load the raw data 

## Train Data
df_subject_train <- read.table("./Data/train/subject_train.txt")
df_X_train <- read.table("./Data/train/X_train.txt")
df_y_train <- read.table("./Data/train/y_train.txt")

## Test Data
df_subject_test <- read.table("./Data/test/subject_test.txt")
df_X_test <- read.table("./Data/test/X_test.txt")
df_y_test <- read.table("./Data/test/y_test.txt")

# Features Data
df_features <- read.table("./Data/features.txt")

##################################################################


##################################################################
##################################################################
# Name the Columns

# add column name for subject files
names(df_subject_train) <- "SubjectID"
names(df_subject_test) <- "SubjectID"

# add column names for measurement files
names(df_X_train) <- df_features$V2
names(df_X_test) <- df_features$V2

# add column name for label files
names(df_y_train) <- "Activity"
names(df_y_test) <- "Activity"
##################################################################


##################################################################
##################################################################
# Merge the different Data Frames into one combined one

df_train <- cbind(df_subject_train, df_y_train, df_X_train)
df_test <- cbind(df_subject_test, df_y_test, df_X_test)
df_database <- rbind(df_train, df_test)

# Remove the previous Data Frames
rm(df_subject_train)
rm(df_y_train)
rm(df_X_train)

rm(df_subject_test)
rm(df_y_test)
rm(df_X_test)

rm(df_features)
rm(df_train)
rm(df_test)

##################################################################


##################################################################
##################################################################
# Define what columns have Mean() or Std()
## For that we will use grepl function.
### grepl search for matches to argument pattern within each element of a character vector

### Syntax:
#####    grepl(pattern, x, ignore.case = FALSE, perl = FALSE,
#####          fixed = FALSE, useBytes = FALSE)

# We will use this to later on remove the columns that are not related to 
## Mean or Standard Deviation

Cols_w_Mean_or_STD <- grepl("mean\\(\\)", names(df_database)) | 
                      grepl("std\\(\\)", names(df_database))

## Cols_w_Mean_or_STD returned a list of boolean values
## However, we want to keep columns 1 and 2 no matter what
## They are SubjectID and Activity
### So, let's force it to be TRUE
Cols_w_Mean_or_STD[1:2] <- TRUE

##################################################################


##################################################################
##################################################################
# Remove the unecessary columns

df_database <- df_database[, Cols_w_Mean_or_STD]

##################################################################


##################################################################
##################################################################
# convert the activity column from integer to factor
df_database$Activity <- factor(df_database$Activity, 
                               labels=c("Walking", "Walking Upstairs", 
                                        "Walking Downstairs", "Sitting", 
                                        "Standing", "Laying")
                               )

##################################################################


##################################################################
##################################################################
# Create and Save the Tidy Data Set

# create the tidy data set
df_melted_db <- melt(df_database, id=c("SubjectID", "Activity"))
df_tidy_db <- dcast(df_melted_db, SubjectID + Activity ~ variable, mean)

# write the tidy data set to a file
write.csv(df_tidy_db, "tidy_db.csv", row.names=FALSE)

##################################################################

