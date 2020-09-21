# this script will take the raw data provided for the assignment and create
# a new file with the data reorganized and tidied as requested.

# everything was done on a Windows 10 pc, R version 4.0.2 64-bit, direct
# Internet connection (no proxy).

# the script will create a download folder, download the file and unzip it but
# to save some time on subsequent run each of these steps will be executed only
# if needed (so if no folder exists or no zip file exists or no unpacked folder
# exists). Since the download of the data is not in the scope of the script
# the corresponding instruction (lines 13 to 26) are commented out.

# # this is the zip url
# zip_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# # create the download folder if not already there
# if(!file.exists("./download")) dir.create("./download")
# # download the file if not already downloaded (to spare some bandwidth)
# if(!file.exists("./download/UCI_HAR_Dataset.zip")) download.file(zip_url, "./download/UCI_HAR_Dataset.zip", mode = "wb")
# # unzip the downloaded file if not already done (and change the name of the
# # folder to make it easier to use)
# if(!file.exists("./data")) {
#   unzip("./download/UCI_HAR_Dataset.zip")
#   file.rename("./UCI HAR Dataset", "./data")
# }
# ## cleanup the environment
# rm("zip_url")

# load the file in separate R variables. Having browsed the files in a text
# the files appear to be simple table with data separated by white spaces

# test files
x_test <- read.table("./data/test/X_test.txt")
y_test <- read.table("./data/test/y_test.txt")
subject_test <- read.table("./data/test/subject_test.txt")

# training files
x_train <- read.table("./data/train/X_train.txt")
y_train <- read.table("./data/train/y_train.txt")
subject_train <- read.table("./data/train/subject_train.txt")

# common files
features <- read.table("./data/features.txt")
activity_labels <- read.table("./data/activity_labels.txt")

# from the README.txt file we know that the files and thus now the variables
# contains:
# - x_test: the Test set
# - y_test: the Test Labels
# - subject_test: subject who performed the activity for each window sample
# - x_train: the Training set
# - y_test: the Training Labels
# - subject_train: subject who performed the activity for each window sample
# - features: the list of all the features
# - activity_labels: Links the class labels with their activity name

# following the assignment (instructions are with ** prefix to identify them):

# ** 1 - Merges the training and the test sets to create one data set.

# from the descriptions above and also looking at the dimensions of the
# variables we know we can merge all the test variables together and all
# the train variables together. We will obtain a single variable with the
# complete data for test and one for training

test <- cbind(subject_test, y_test, x_test)
train <- cbind(subject_train, y_train, x_train)

# we will now join the two set into one
complete <- rbind(test, train)

# a little cleanup of the now unused variables:
rm(list=c("x_test", "y_test", "subject_test", "x_train", "y_train",
          "subject_train", "test", "train"))

# now we can set the variable names for the complete dataset. The names
# are the features but for the first two columns that we added. We will
# create a new variable containing also the first two columns names
column_names <- rbind("subjects", "labels", features[2])

# we can now use this variable to set the column names for the complete set
names(complete) <- column_names[[1]]

# cleanup of the variables
rm("column_names", "features")

# ** 2 - Extracts only the measurements on the mean and standard deviation for each measurement.

# from the file features_info.txt we know that for each measurement a set of
# variables were estimated. Mean and standard deviation have -std() and -mean()
# as desinence.

# we search for "mean()" and "std()" into the names to find what column are of
# interests. We search for the parentheses to exclude meanFreq variables and
# also the additional variables used with angle() eg: 
# angle(tBodyGyroMean,gravityMean)
# The first three columns are the key to identify an activity
# performed (labels and activity, first two variables) by a subject (third
# variable) so we will keep them also

complete <- complete[, c(1:2, grep("mean\\()|std\\()", names(complete)))]

# ** 3 - Uses descriptive activity names to name the activities in the data set.

# we will now add a new variable decoding the labels variable looking up
# in the activity_labels object. Since the assignment asks for "descriptive
# activity names" we will change the case of the labels to lowercase and change
# the underscores '_' with spaces ' '

activity_labels$V2 <- sub("_", " ", tolower(activity_labels$V2))
complete <- merge(activity_labels, complete, by.x = "V1", by.y = "labels")
names(complete)[c(1,2)] <- c("activityid", "activity")

# 

# and we can clean also the now used variable:
rm("activity_labels")

# ** 4 - Appropriately labels the data set with descriptive variable names.

# at this stage the variable names are already "meaningful" since we got them
# from the features.txt file. However, in order to make the life easyer later
# for the analysis phase we can apply some more substitution like removing
# the parentheses and the dash inside the names, converting the names to
# lowercase as suggested also on the lecture "Editing text variables".
# To help even more we will also convert the "t" and "f" at the beginning of
# the names to "time" and "frequency". I choose to not ad an additional "axis"
# after the X or Y or Z because I think this would not improve the readability

# first we remove the dash and the parentheses
names(complete) <- gsub("[-\\()]", "", names(complete))
# then we convert the names to lower case
names(complete) <- tolower(names(complete))
# then we convert the initial "t" (if any) to "time"
names(complete) <- gsub("^t", "time", names(complete))
# and finally the initial "f" (if any) to "frequency"
names(complete) <- gsub("^f", "frequency", names(complete))

# the first data set is now ready. Actually, the first variable, activityid is
# reduntant since the same information is available as the activity variable.
# While it is not useful for the assignment it can be easier on some other
# use case to sort by a numeric instead of by a string so I will not remove
# it.

# 5 - From the data set in step 4, creates a second, independent tidy data set 
#     with the average of each variable for each activity and each subject.

# My understanding is that for each possible couple (activity, subject) that
# can be repeated many times in the data set "complete", we have to provide,
# for each variable (column) the mean value.

# For this we will use the dplyr package so we first load it (we assume it 
# already installed)
library("dplyr")

# we will use the pipe feature of dplyr to group by the table keys and
# summarize with the mean function
groupedaverage <- group_by(complete, activityid, activity, subjects) %>%
  summarize_all(mean)

# now the variable names need to be changed to reflect that we applied the mean
# function on each. Following the convention already used for the features we
# will add a "mean" at the end of each variable name (except the first three)
names(groupedaverage)[-(1:3)] <- paste(names(groupedaverage)[-(1:3)], "mean", sep = "")

# groupedaverage is now the tidy dataset requested
# to write it to a file, as requested to submit the assignment, we will create
# (if needed) an output folder and write the data file there.
# these last lines are really part of the assignment but are described in the
# submission form: "The output should be the tidy data set you submitted for
# part 1" so I add them
if(!file.exists("./output")) dir.create("./output")
write.table(groupedaverage, "./output/tidy2.txt", row.names = F)

# the file can then be read back with:
# tidy2 <- read.table("./output/tidy2.txt", header = T)