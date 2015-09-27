---
title: "README"
author: "Santiago Silvestrini"
date: "September 27, 2015"
output: html_document
---

## Purpose:
This is to describe my approach fot the Final Project of the course: Getting and Cleaning Data by Johns Hopkins University on Coursera (part of the Data Sience Specialization).

## How to run this project:
1 Download the ***run_analysis.R*** script from this repository.

2 Copy the file into your working directory if you've previously downloaded the data files

3 Or just place it into a new folder and Set your working directory to it. You can tell the code to download the data files for you.

4 From the R Console, load the code as shown below:

    ```source("run_analysis.R")```

5 Call the main function from the console, like this:

    ```run_analysis()```
(Check below for a full description of the arguments accepted by this function)
    
## Structure of the code:
The code is splitted into different functions, in order to make it more readable and easy to follow.

### run_analysis(getProjectFiles, dataFolder, dataSubFolder):void
It's the main function, the starting point. From here the rest of the functions are invoked.

There are some optional args that you can specify and override the default values in order to gain some flexiblity:

(bool) ***getProjectFiles***: if set to TRUE it will download the required data files (will take some time). By default it's set to FALSE.
    
(char) ***dataFolder***: a subfolder in your WD in which the files will be extracted. By default is ***data***

(char) ***dataSubFolder***: a subfolder of the previos ***dataFolder*** that holds the project data files. The default values is set to ***UCI HAR Dataset***

***Sample calls:***
By poviding no args, the code will need the data files to be located in the data/UCI HAR Dataset folder or it will fail to load them

```run_analysis()```
    
If the files are located in a different folder structure, you can specify that by using dataFolder and dataSubFolder parameters.
    
```run_analysis(dataFolder="MyDatFolder", dataSubFolder="MyDataSubfolder")```

In case you want the code to take care of downloading and extracting the files you can use:

```run_analysis(getProjectFiles=TRUE)```

Or just:

```run_analysis(TRUE)```

As result of the execution you will get an output file containing the tidy dataset at the location specified on the ***dataFolder*** parameter.

### get_ProjectFiles():void
If ***getProjectFiles*** is set to TRUE then the main function will invoke this function in order to get the data files from the internet.
The zip file will be stored into a temporary variable and extracted into the filesystem on the path specified by your working directory and the optional arguments ***dataFolder*** and ***dataSubFolder***.

### loadSingleFile(filename):data.frame
This is a helper function that will load will load the specified file and return it so you can store it in memory. It will also prompt a message to the console for each file loaded.

### loadPackage(packageName):void
This is another helper function that will take care of loading the requerid packages into the working environment.
It is use by the main function to load the ***dplyr*** package.
In case the package is not installed this function will do it for you.

### combineFiles(features, trainActivities, testActivities, activityLabels, trainSubjects, testSubjects, trainSet,  testSet):data.frame
It takes the Test and Train datasets, translates the Activity IDs into names and adds the SubjectIds as a new column.
At the end the Test and Train datasets will be combined into a single one called ***fullSet***.

### setColumnNames(fullSet, features):data.frame
It will take the ***fullSet*** (a combination of the Test and Train datasets) and provide descriptive names for the dimensions and measures.
Names for the measures are taken from the ***features*** file, but to make them more readable we will also apply the following conversions:

    * initial t to time-
    * initial f to frequency-
    * BodyBody to body-
    * Body to body-
    * Acc to accelerometer-
    * Mag to magnitude-
    * Gravity to gravity-
    * Gyro to gyroscope-
    * Jerk to jerk-
    * -- to -

### prepareAndExportTidy(fullSet, basePath):void
This function is in charge of shaping what is going to be our output file.
Will select only those columns from the ***fullSet***  that are of the interest on this study, which are:
Activity (Name), SubjectId and all measures on the ***standard deviation*** and ***mean***.
It will also group and summarize the data by the mean for each ***Activity/Subject***.
It makes use of the ***dplyr*** functions for it.
In addition, this function will be the one who write the tidy dataset to the filesystem using the ***write.table*** as instructed.

## Thanks!
I just want to thank you for taking the time to review this assignment.
Any constructive feedback is more than welcome.





    