library(data.table)
library(reshape)

##set dataset url
zipFile <- 'UCI HAR Dataset.zip'
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
#download.file(url,zipFile)

##unzip the data to ./data folder
unzip(zipFile)

##set dataset folder path
datasetPath <- './UCI HAR Dataset/'

##------- process features.txt file ---------------##

##read features.txt
datasetFeatures <- read.table( paste(datasetPath,'features.txt',sep=''))

##convert factors to character in column V2 of datasetFeaturesDT
datasetFeatures$V2 <- sapply(datasetFeatures$V2,as.character)

##add a new row
datasetFeatures <- rbind(datasetFeatures,c(562,'Activity'))
datasetFeatures <- rbind(datasetFeatures,c(563,'Subject'))

##-------- process activity_lables.txt -----------##

##read activity_labels.txt
activityLabels <- read.table( paste(datasetPath,'activity_labels.txt',sep=''))

##set column names
colnames(activityLabels) <- c('Activity','ActivityName')



##-------- process training dataset -------------##

##read training data file ()
trainX <- read.table(paste(datasetPath,'train/X_train.txt',sep=''))
trainY <- read.table(paste(datasetPath,'train/Y_train.txt',sep=''))
trainS <- read.table(paste(datasetPath,'train/subject_train.txt',sep=''))
train <- cbind(trainX,trainY,trainS)

##-------- process test dataset ---------------##

##read test data file ()
testX <- read.table(paste(datasetPath,'test/X_test.txt',sep=''))
testY <- read.table(paste(datasetPath,'test/Y_test.txt',sep=''))
testS <- read.table(paste(datasetPath,'test/subject_test.txt',sep=''))
test <- cbind(testX,testY,testS)


##------- prepare complete datast ------------- ##

##merge the training and test data tables vertically
completeDataset <- rbind(train,test)

##set column names to feature name (from features.txt)
colnames(completeDataset) <- datasetFeatures[,2]

##convert datasetFeatures dataframe to a datatable
datasetFeaturesDT <- data.table(datasetFeatures)


##------- prepare a filtered dataset of selected columns related to mean and std -------##

##sub select features related to mean and std
filteredFeaturesDT <- datasetFeaturesDT[((V2 %like% 'mean()') & !(V2 %like% 'meanFreq()')) | (V2 %like% 'std()') | (V2 == 'Activity') | (V2 == 'Subject')  , ]

##get selected dataset
selectedDataset <- completeDataset[,filteredFeaturesDT$V2]

##assign descriptive labels to activity number
selectedDataset <- merge(selectedDataset, activityLabels, by = 'Activity')



##------- prepare a tidy dataset  with the average of each variable for each activity and each subject -------##

##create a copy of selectedDataset as a data.table
selectedDatasetDT <- data.table(selectedDataset)

##melt the dataset
mSelectedDatasetDT <- melt(selectedDatasetDT,id=c('Activity','Subject'))

##convert the value to numric
mSelectedDatasetDT$value <- as.numeric(mSelectedDatasetDT$value)

##cast
cSelectedDatasetDT <- cast(mSelectedDatasetDT, Activity+Subject~variable,mean)

##write to file
write


