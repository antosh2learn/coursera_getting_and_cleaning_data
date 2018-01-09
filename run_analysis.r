##############################################################################
#
# Name of File
#   run_analysis.R
#
# Details
#    Data is collected from accelerometers of a smartphone.This R script can be executed on this data and provide a clead data set and output the tidy data in "tidy_data.txt"
#   See README.md for details.
#

library(dplyr)
# Checking if directory exists, if not create one and download the data
if(!file.exists("./data")){dir.create("./data")}
UrlData <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(UrlData,destfile="./data/Dataset.zip",method="curl")

unzip(zipfile="./data/Dataset.zip",exdir="./data")

path_dt <- file.path("./data" , "UCI HAR Dataset")
#files<-list.files(path_dt, recursive=TRUE)

#Reading Activity Test and Training data
ActTestData  <- read.table(file.path(path_dt, "test" , "y_test.txt" ),header = FALSE)
ActTrainData <- read.table(file.path(path_dt, "train", "y_train.txt"),header = FALSE)

#Reading Subject Test and Training data
SubjectTrainData<- read.table(file.path(path_dt, "train", "subject_train.txt"),header = FALSE)
SubjectTestData  <- read.table(file.path(path_dt, "test" , "subject_test.txt"),header = FALSE)

#Reading Values Test and Training data
ValuesTestData  <- read.table(file.path(path_dt, "test" , "X_test.txt" ),header = FALSE)
ValuesTrainData <- read.table(file.path(path_dt, "train", "X_train.txt"),header = FALSE)

#Combining Subject,Activity and Values Train and Test Data
dataSubject <- rbind(SubjectTrainData, SubjectTestData)
dataActivity<- rbind(ActTrainData, ActTestData)
dataValues<- rbind(ValuesTrainData, ValuesTestData)

#Naming the Subject, Activity data by same name.Also naming values data columns from features.txt
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataValuesNames <- read.table(file.path(path_dt, "features.txt"),head=FALSE)
names(dataValues)<- dataValuesNames$V2

#Combining all the data in one dataframe
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataValues, dataCombine)

#Selecting only those names which contain 'mean' and 'std' as required
subdataValuesNames<-dataValuesNames$V2[grep("mean\\(\\)|std\\(\\)", dataValuesNames$V2)]

selectedNames<-c(as.character(subdataValuesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)


activityLabels <- read.table(file.path(path_dt, "activity_labels.txt"),header = FALSE)

#Adding a column for the descriptive name of activity from activity_labels.txt
Data$activity1 <- activityLabels$V2[match( Data$activity, activityLabels$V1)]
Data$activity <- Data$activity1
Data$activity1 <- NULL

#Giving proper names to all the values columns
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))


Data %>% group_by(subject,activity) %>% summarise_each(funs(mean))


