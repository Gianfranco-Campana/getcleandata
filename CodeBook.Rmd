# Human Activity Recognition Using Smartphones tidy dataset

### Introduction:

#### One of the most exciting areas in all of data science right now is wearable computing - see for example this article: 

####   http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/ . 

#### Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. 
#### The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 

### Data Details:

#### A full description is available at the site where the data was obtained: 
   
#### http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
 
#### Here are the data for the project: 
   
####   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
 

### Following, the code and the explanations step by step for all transformation performed to clean up  the data.

The archives are downloaded, unzipped and then saved in the directory: ./data/FUCI_Dataset.

The directory /data is created, if it not exists.
```{r}
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download.file(fileUrl, destfile="./data/FUCI_Dataset.zip")
unzip("./data/FUCI_Dataset.zip", exdir = "./data", overwrite = TRUE)

```

Eight distinct dataset are loaded from the archives for train, test, subjects, features and lables data:
```{r}
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
X_test  <- read.table("./data/UCI HAR Dataset/test/X_test.txt"  )
Y_train <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
Y_test  <- read.table("./data/UCI HAR Dataset/test/Y_test.txt"  )

features <- read.table("./data/UCI HAR Dataset/features.txt"       )
labels   <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

subject_test  <- read.table("./data/UCI HAR Dataset/test/subject_test.txt"  )
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
```

Then train and test data ( subject, Y and X) are combined togheter respectively:
```{r}
df_train <- cbind(subject_train, Y_train, X_train)
df_test  <- cbind(subject_test,  Y_test,  X_test )
```

And the two dataset obtained are appended to build a single dataset:
```{r}
df_tot   <- rbind(df_train, df_test)
```

Next, to rename the dataset using descriptive activity names, we first cast the V2 column of the features dataset in a character vector:
```{r}
cfeatures <- as.character(levels(features$V2))[features$V2]

```

and then rename all the columns of the complete dataset using that vector, except for the first two, which are the column of the subject, and the activity code:
```{r}
names(df_tot)[3:563] <- cfeatures
```

Here a first, tidy dataset is building filtering all the column with a mean or a std value.

All the features column names, have an intrinsic and distinct meaning, with no exact overlapping between them, therefore the choice adopted is to mantain all the columns with a "mean" or "sdt" naming, to preserve all the information in agreement with the original task.

```{r}
tid <- cbind(
        df_tot[,1:2],
        df_tot[, grep("mean()" , names(df_tot) , value = T)],
        df_tot[, grep("std()"  , names(df_tot) , value = T)] 
        )

```

With the following command, the first two column of the dataset, relative to subject data and activity code, are renamed as "Subject" for the first one containing the subject ID, and V1 for the seconde one,  which will serve for the join.
```{r}
names(tid)[1:2] <- c("Subject","V1")
```

Now, using the plyr package, we join the tidy dataset created using V1 column, with the labels dataset, to appropriately labels the data set with descriptive activity names:
```{r}
library(plyr)
ntid <- join(tid, labels)
```

Next, we reorganize the order of the columns, as :
1) Subject, 2) Activity Code, 3) Activity Label 4) mean and std... 
```{r}
ntid <- cbind(ntid[,1:2],ntid[,ncol(ntid)],ntid[,4:ncol(ntid)-1])
```

and rename the second and third columns as Activity and Activity_Label to complete the renaming of all variables:
```{r}
names(ntid)[2:3] <- c("Activity","Activity_Label")
```

The last target is to build a second tidy dataset with the average of each  variable for each activity and each subject. To do this we use the reshape2 package and the aggregate function:
```{r}
library(reshape2)
aggr <- aggregate(. ~ Subject + Activity + Activity_Label, data = ntid, mean)
```

The result is a data frame with 180 rows and 82 columnns:
```{r}
dim(oaggr)
```

Lastly, for a better and cleaner final output, we rearrange the data ordering by Subject and Activity:
```{r}
oaggr <- aggr[with(aggr, order(Subject,Activity)),]
```

The final output is saved in the "./data/UCI HAR Dataset/tidy.txt" file :
```{r}

write.table(oaggr, file="./data/UCI HAR Dataset/tidy.txt", sep = ",", row.names=FALSE)

```






