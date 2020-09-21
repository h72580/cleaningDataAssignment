# Peer-graded Assignment: Getting and Cleaning Data Course Project
In this repository I have uploaded the file related to the final assignemnt of
the **"Getting and Cleaning Data Course Project"**.

## list of files

### README.md
This file :-)

### run_analysis.R

The main script that takes in the raw data files and produces the two tidy
datasets requested. The complete description of the script is further down
in the README.md file.

### codebook.txt

The codebook describing both the data sets produced by the script.

## directory structure

````
https://github.com/h72580/cleaningDataAssignment
│   .gitignore
│   cleaningDataAssignment.Rproj
│   codebook.txt
│   README.html
│   README.md
│   run_analysis.R
│
├───data
│   │   activity_labels.txt
│   │   features.txt
│   │   features_info.txt
│   │   README.txt
│   │
│   ├───test
│   │   │   subject_test.txt
│   │   │   X_test.txt
│   │   │   y_test.txt
│   │   │
│   │   └───Inertial Signals
│   │           body_acc_x_test.txt
│   │           body_acc_y_test.txt
│   │           body_acc_z_test.txt
│   │           body_gyro_x_test.txt
│   │           body_gyro_y_test.txt
│   │           body_gyro_z_test.txt
│   │           total_acc_x_test.txt
│   │           total_acc_y_test.txt
│   │           total_acc_z_test.txt
│   │
│   └───train
│       │   subject_train.txt
│       │   X_train.txt
│       │   y_train.txt
│       │
│       └───Inertial Signals
│               body_acc_x_train.txt
│               body_acc_y_train.txt
│               body_acc_z_train.txt
│               body_gyro_x_train.txt
│               body_gyro_y_train.txt
│               body_gyro_z_train.txt
│               total_acc_x_train.txt
│               total_acc_y_train.txt
│               total_acc_z_train.txt
│
├───download
│       UCI_HAR_Dataset.zip
│
└───output
        tidy2.txt
````

## run_analysis.R description
I put a lot of comments in this file in order to allow anyone reviewing it to
understand step by step what I was doing.

To keep everything in one place at the beginning of the file there are also the
instruction to download the provided zip file in an appropriate directory and
unzip it. However, since those instruction are not required to actually perform
the required steps I commented out them.

Since the assignment explicitly asks for it, I will now describe it here below.

first of all, I load all the files of interest in memory, one R variable for
each file. Knowing that they will be not needed for the assignment I decided to
*not* load the files inside the *Inertial Signals* folders.

After that I basically followed the five steps layed out in the instructions:

#### 1 - Merges the training and the test sets to create one data set.

From the *README.txt* and *features_info.txt* and looking at the dimensions of
the variables it is clear that the files inside *test* and *train* can be merged
column wise: they have the same number of rows and each rows of each files is
related to data in the same row of the other files. I then *cbind*ed the
variables together in the order:

1. subject
2. y
3. x

in order to have the *"keys"* of the record as first variables.

The test and train data set at this stage are composed of different set of
observation of the same variables so I simply merged them row wise *rbind*ing
them.

From the information we have the features.txt file contains the name of the
variables in the X_test and Y_test dataset. So I use this dataset to provide
the names to the variables of the complete dataset from the third variable on.
The first two variables were added so I set for *subjects* and *labels*.

#### 2 - Extracts only the measurements on the mean and standard deviation for each measurement.

Features_info.txt states that for each measurement collected a set of variables
were estimated and the features naming convention used. We are only interested
in means and standard deviations so I can search for -mean() and -std() to find
the variable names related to mean and standard deviation. Among the features
there are other names that recall *mean* e.g.: tBodyGyroMean or meanFreq
variables but from the assignment description my understanding is that I do not
have to consider those. this is why I search for *-mean()* and *-std()*.

Once the variables of interest are identified I remove the other variables from
the complete dataset.

#### 3 - Uses descriptive activity names to name the activities in the data set.

For this step I simply merge the complete dataset with the activity_labels one
using the first variable of the activity_labels set and the lables variables of
the complete set as key. Since *descriptive activity names* is a vague
requirement I decided to change the activity names converting them to all lower
case and converting the underscore to space (i.e.: *WALKING_UPSTAIRS* is
converted to *walking upstairs*)

#### 4 - Appropriately labels the data set with descriptive variable names.

At this stage the variables names are already descriptive since I already
replaced the standard *V1*, *V2* etc. names with the names of the feature
measured by the variable.
As shown in the first lecture of the 4^th^ week of the course however data
scientists usually prefer to have variable names very clearly indicating the
content and with little formatting (mix of upper and lower cases, underscores,
dashes, etc...).
I decided that a good balance for this case would be:

1. no dash or parentheses
2. everything lower case
3. decode the starting *t* and *f* characters to *time* and *frequency* to better clarify.

Possibly there are other abbreviations used but expanding everything will just
lead to too long variables names so this was the balance I found.

This ends the 4^th^ point of the assignment.

Actually at this stage the complete data set has two variables with the same
information, the activity id and the activity label. It is possible to remove
the activity id but it is somewhat easier to order or join based on a numeric
than by a string so I decided to keep both.

#### 5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

For this step I decided to use the **dplyr** package. I assumed the package will
be available when the script runs and merely loaded it.

I then created the new data set grouping the complete data set by the first three
columns (which identifies a subject and an activity) and then summarizing it
using the *mean* function. In one single step, using the *dplyr pipe %>%*
operator.

Having modified the variables meaning, in order for the data set to be tidy I
changed the labels accordingly, adding at the end the *mean* suffix, following
the naming convention of the original features set.

Last thing: the instructions on the submit form states that the script have to
write this last data set so the script creates if needed the output folder and
write the data set there with name *tidy2.txt*.

This file can be read back into R with the instruction:

` tidy2 <- read.table("./output/tidy2.txt", header = T) `

which is also present in the script, commented.

## comments
the script was completely wrote by me, I used as a guide, besides the lectures,
the information posted on the course's forum and the very useful guide (also
suggested by *Mentor Leonard Greski and Nancy Irisarri*) at
https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/.

I hope to have clarified to the reader my choices regarding my understanding
of the assignment requests and the tiding steps applied to the data sets.

Regards,

Fabrizio
