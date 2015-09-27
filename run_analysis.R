# You should create one R script called run_analysis.R that does the following.
# REQ1. Merges the training and the test sets to create one data set.
# REQ2. Extracts only the measurements on the mean and standard deviation for each measurement.
# REQ3. Uses descriptive activity names to name the activities in the data set
# REQ4. Appropriately labels the data set with descriptive variable names.
# REQ5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## run_analysis: Main function for the Getting and Cleaning Data Course Project.
## args (optionals):
##  (bool) getProjectFiles: if set to TRUE it will download the required data files (will take some time)
##  (char) dataFolder: a subfolder of your WD in which the files will be downloaded
##  (char) dataSubFolder: a subfolder of the previos dataFolder that holds the project data files

run_analysis <- function(getProjectFiles = FALSE, dataFolder="data", dataSubFolder = "UCI HAR Dataset") {
    
    ## dplyr package is requerided for join, select and grouping functions
    ## the following function will install the package and load the package if needed
    loadPackage("dplyr")
    
    ## in case you want to download the files from the original source, just call the function in one of the following ways:
    ##  > use run_analysis(TRUE)
    ##  > use run_analysis(getProjectFiles = TRUE)
    
    if (getProjectFiles) { 
            get_ProjectFiles()
    }else {
        ## [ToDo] Check if all the files exists
    }
    
    ## put all the required files in working memory
    basePath <- paste(".", dataFolder, dataSubFolder, sep = "/") 
    activityLabels <- loadSingleFile( paste(basePath, "activity_labels.txt", sep = "/"))
    features <- loadSingleFile( paste(basePath, "features.txt", sep = "/"))
    
    trainSet <- loadSingleFile( paste(basePath, "train/X_train.txt", sep = "/"))
    trainActivities <- loadSingleFile( paste(basePath, "train/Y_train.txt", sep = "/"))
    trainSubjects <- loadSingleFile( paste(basePath, "train/subject_train.txt", sep = "/"))
    
    testSet <- loadSingleFile( paste(basePath, "test/X_test.txt", sep = "/"))
    testActivities <- loadSingleFile( paste(basePath, "test/Y_test.txt", sep = "/"))
    testSubjects <- loadSingleFile( paste(basePath, "test/subject_test.txt", sep = "/"))

    # Combine Train and Test 
    fullSet <- combineFiles(features, trainActivities, testActivities, activityLabels, trainSubjects, testSubjects, trainSet,  testSet)
    
    fullSet <- setColumnNames(fullSet, features)
    
    prepareAndExportTidy(fullSet, basePath)

}

combineFiles <- function(features, trainActivities, testActivities, activityLabels, trainSubjects, testSubjects, trainSet,  testSet)
{
    print( "Combining and merging the files...")
    ## use descriptive names for activities [REQ3]
    trainActivitiesNamed <- inner_join(trainActivities, activityLabels, by = "V1")[2]
    testActivitiesNamed <- inner_join(testActivities, activityLabels, by = "V1")[2]
    
    ## compose train and test datasets by combining the activities with the subjects and measures data
    train <- cbind(trainActivitiesNamed, trainSubjects, trainSet)
    test <- cbind(testActivitiesNamed, testSubjects, testSet)
    
    ## merge train and test datasets into one [REQ1]
    rbind(train,test) ## returns fullSet
}

setColumnNames <- function(fullSet, features) {
    # Use descriptive names for measures [REQ4]
    # first 2 are defined by me, the rest are taken from the features file
    print( "Making the data more human friendly...")
    colnames(fullSet)[1:2] <- c("Activity", "Subject")
    colnames(fullSet)[3:length(fullSet)] <- as.character(features[,2])
    
    # to make the labels more human readables we will perform some transformations
    names(fullSet) <- gsub("^t", "time-", names(fullSet))
    names(fullSet) <- gsub("^f", "frequency-", names(fullSet))
    names(fullSet) <- gsub("BodyBody", "body-", names(fullSet))
    names(fullSet) <- gsub("Body", "body-", names(fullSet))
    names(fullSet) <- gsub("Acc", "accelerometer-", names(fullSet))
    names(fullSet) <- gsub("Mag", "magnitude-", names(fullSet))
    names(fullSet) <- gsub("Gravity", "gravity-",names(fullSet))
    names(fullSet) <- gsub("Gyro", "gyroscope-", names(fullSet))
    names(fullSet) <- gsub("Jerk", "jerk-", names(fullSet))
    names(fullSet) <- gsub("--", "-",  names(fullSet))
    fullSet
}

prepareAndExportTidy <- function(fullSet, basePath) {
    ## get only the measures on the mean and standard deviation  [REQ2] 
    ## group by activity and subject and then compute the average for each measure [REQ5]
    print( "Grouping and summarizing...")
    tidySet <- fullSet %>% 
        select(Activity, Subject, matches("mean\\(\\)|std\\(\\)")) %>%
        group_by(Activity, Subject) %>% 
        summarise_each(funs(mean))
    
    ## generate the file to be uploaded following the specifications 
    write.table(tidySet, file = file.path(basePath, "tidy-dataset.txt"), row.names = FALSE, col.names = TRUE)
    print( paste("Tidy dataset successfully generated at: ", basePath, sep = "") )
}   

get_ProjectFiles <- function(){
   ## Create data folder if doesn't exists
    if (!file.exists("./data")) {
        dir.create("./data")
        print( paste("data folder created at: ", getwd(), sep = "") )
    }
    
    tempZip <- tempfile() ## a temporary file variable to store the downloaded zip file
    
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    
    print("Grab a coffee we are downloading project data...")
    download.file(fileUrl, tempZip) ## download the zip file into the temp variable
    
    print("Project data sucessfully downloaded, extracting the zip file now...")
    unzip(tempZip, exdir = "./data")
    unlink(tempZip) ## release the zip file
    print("Data sucessfully downloaded and unzipped")
}

loadSingleFile <- function(filename) {
    print(paste("loading: ", filename, "...", sep = ""))
    as.tbl(read.table(filename))
}

loadPackage <- function(packageName) {
    if ( !require(packageName,character.only = TRUE) ) {
        print(paste("loading package: ", packageName, "...", sep = ""))
        install.packages(pkgs = packageName)
        require(x,character.only = TRUE)
    }
}
