# One of the most exciting areas in all of data science right now is wearable computing - 
#   see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing 
# to develop the most advanced algorithms to attract new users. The data linked to from 
# the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 
# A full description is available at the site where the data was obtained: 
#   
#   http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
# 
# Here are the data for the project: 
#   
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 
# You should create one R script called run_analysis.R that does the following. 
# Merges the training and the test sets to create one data set.
#
# Extracts only the measurements on the mean and standard deviation for each measurement. 
#
# Uses descriptive activity names to name the activities in the data set
#
# Appropriately labels the data set with descriptive activity names. 
#
# Creates a second, independent tidy data set with the average of each 
# variable for each activity and each subject. 
#

# Dest files : "./data/UCI HAR Dataset/."


if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/FUCI_Dataset.zip")
unzip("./data/FUCI_Dataset.zip", exdir = "./data", overwrite = TRUE)
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
X_test  <- read.table("./data/UCI HAR Dataset/test/X_test.txt"  )
Y_train <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
Y_test  <- read.table("./data/UCI HAR Dataset/test/Y_test.txt"  )

features <- read.table("./data/UCI HAR Dataset/features.txt"       )
labels   <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

subject_test  <- read.table("./data/UCI HAR Dataset/test/subject_test.txt"  )
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

df_train <- cbind(subject_train, Y_train, X_train)
df_test  <- cbind(subject_test,  Y_test,  X_test )
df_tot   <- rbind(df_train, df_test)

cfeatures <- as.character(levels(features$V2))[features$V2]

names(df_tot)[3:563] <- cfeatures

tid <- cbind(
        df_tot[,1:2],
        df_tot[, grep("mean()" , names(df_tot) , value = T)],
        df_tot[, grep("std()"  , names(df_tot) , value = T)] 
        )

names(tid)[1:2] <- c("Subject","V1")

library(plyr)
ntid <- join(tid, labels)
ntid <- cbind(ntid[,1:2],ntid[,ncol(ntid)],ntid[,4:ncol(ntid)-1])
names(ntid)[2:3] <- c("Activity","Activity_Label")

library(reshape2)

aggr <- aggregate(. ~ Subject + Activity + Activity_Label, data = ntid, mean)
oaggr <- aggr[with(aggr, order(Subject,Activity)),]

dim(oaggr)

write.table(oaggr, file="./data/UCI HAR Dataset/tidy.txt", sep = ",", row.names=FALSE)




