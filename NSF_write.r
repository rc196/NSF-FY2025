  ##Script for writing data created by "NSF_transform.r" script and writing to specified cells in campus Excel files.
  ##The Excel output map file should be formatted as in the sample file to map desired data inputs to desired
  ##cells in ouptut files.
  ##
  ##MAKE SURE THE FILES YOU SPECIFY IN THIS SECTION EXIST IN THE APPROPRIATE DIRECTORIES BEFORE RUNNING THIS SCRIPT. 
  ##MAKE SURE THE "inCampus" CHARACTER VECTOR MATCHES HOW THE CAMPUSES ARE REPRESENTED IN YOUR DATA.
  ##
  #Load packages, set working directory, set character vectors.
  #
  library("tidyverse")
  library("XLConnect")
  setwd("C:/Users/rchan/Box/IRAP Shared/Data Usage and Reporting/Research/NSF/FY2024/")
  
  #inputData<-filter(inputData,location=="Riverside")
  
  inCampus <- inputData$location
  outMapFile <- c("Data/output_map.xlsx")
  outMapSheet <- c("outputs")
  outFileDir <- c("Uploads/")
  outFileRoot <- c("FY2024_HERD_Survey")
  #outFileCampus <-  c("_UCB","_UCD","_UCI","_UCLA","_UCM","_UCOP","_UCR","_UCSD","_UCSF","_UCSB","_UCSC")
  outFileCampus <-  c("_UCI")
  outFileExtension <- c(".xls")
  
  #Import the map file sheet to the "outMap" data frame and get its row count.
  #
  outMap <- loadWorkbook(outMapFile, create = FALSE) %>% readWorksheet(sheet = outMapSheet)
  outMapCount <- as.integer(count(outMap))
  
  #Add an "outputFile" column to "inputData" for paths to their corresponding output files, get column count.
  #
  inputData <- mutate(inputData, outputFile = str_c(outFileDir, outFileRoot, outFileCampus, outFileExtension))
  
  ##The following loops write data to the campus Excel files. The outer loop iterates through each campus, selecting its
  ##row of the "inputData" tibble into a "campusData" tibble and loading and later saving its Excel workbook (the file saving
  ##taking place after the inner loop has modified the contents of the workbook). The inner loop iterates through each "outMap" row,
  ##extracting parameters and using them to calculate the output needed for a cell (usually by performing simple math operations on
  ##one or more columns taken from the one-row "campusData" tibble) and writing the result to the appropriate cell in the appropropiate
  ##sheet. The inner loop calculation can also hard-code a response not in "campusData" that applies to all the campuses.
  ##
  #Initialize the loop variables.
  #
  campusData <-tibble("0")
  cellData <- c("0")
  cellSheet <- c("0")
  cellRow <- c("0")
  cellColumn <- c("0")
  
  #Start the outer loop, then extract data for a particular campus and load its Excel workbook.
  #
  for(i in 1:inputDataCount){
    campusData <- slice(inputData, i)
    wbOut <- loadWorkbook(campusData$outputFile, create = FALSE)
    
    #Start the inner loop.
    #
    for(j in 1:outMapCount){
  	
  	#Extract, parse, and evaluate the "outData" expression for calculating the desired value ("cellData") for the cell.
  	#
      cellData <- eval(parse(text = outMap$outData[j]))
  	
  	#Extract, parse, and evaluate expressions for finding the cell in the workbook. Parsing and evaluating in this manner avoids
  	#problems with certain Excel references not being compatible with the inputs needed for writeWorksheet command below.
  	#
      cellSheet <- eval(parse(text = outMap$outSheet[j]))
      cellRow <- eval(parse(text = outMap$outRow[j]))
      cellColumn <- eval(parse(text = outMap$outCol[j]))
  	
  	#Write the content of "cellData" to the appropriate cell and iterate the inner loop.
  	#
      writeWorksheet(wbOut, data = cellData, sheet = cellSheet, startRow = cellRow, startCol = cellColumn, header = FALSE)
    }
    
    #Save the modified workbook to file and iterate the outer loop.
    # 
    saveWorkbook(wbOut)
  }
  
  #After the outer loop is finished, we can remove the workbook object.
  rm(wbOut)
