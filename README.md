# ABCD Database Builder
This is the code for the ABCD Database Builder app. To run it, open the Project in R Studio and hit 'Run App' (make sure to run it externally).

Unfortunately I can't include the datasets because of our data agreement, but  but the code is here for others to play with.

# Pre-reqs

Before using the app, the appropriate files need to be in place. It's quite simple for this app: all the data are located within a file called "2.0-ABCD-Release-R-format". All the spreadsheets created are pulled from this folder, which is located inside of the Project. 

# Inside the black box

First an initial spreadsheet called "Covariates" is created from these datasets:

* ABCD Longitudinal Tracking
* ABCD Parent Demographics Survey
* ABCD ACS Post Stratification Weights
* ABCD Longitudinal Parent Demographics Survey.

It contains 27,368 rows and the covariates commonly used in ABCD analyses. "Covariates" is the base spreadsheet from which every additional spreadsheet is built off of.

As you select more spreadsheets for your master one, a list of variable builds up. You can select individually the variables you want in your master spreadsheet, or leave the box blank if you just want all the spreadsheets combined in one.

The last step is to name the file. The file will be downloaded into your current directory.
