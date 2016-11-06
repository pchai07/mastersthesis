#MarxanOutputToDBFSHP
#VarStart
#PulayerDbf,Input,STRING
#MarxanDir,Input,STRING
#NumberofRuns,Input,STRING
#NumberofZones,Input,STRING
#PUID,Input,STRING
#PulayerShp,output,STRING
#VarEnd

GetOutputFileext <- function(sMarxanDir,sParam)
# For the specified Marxan output file, return the file extension (.csv or .txt)
# Scan input.dat for the parameter,
# if value = 1, .dat, tab delimited, no header
# if value = 2, .txt, comma delimited (Qmarxan sets this value)
# if value = 3, .csv, comma delimited
{
  inputdat <- readLines(paste0(sMarxanDir,"/input.dat"))
  iParam <- which(regexpr(sParam,inputdat)==1)
  
  iValue <- as.integer(unlist(strsplit(inputdat[iParam], split=" "))[2])
  
  if (iValue == 1)
  {
    return(".dat")
  }
  if (iValue == 2)
  {
    return(".txt")
  }
  if (iValue == 3)
  {
    return(".csv")
  }
}


GenerateSolnFilename <- function(iRunNumber,sMarxanDir)
{
      sFilename <- paste0(sMarxanDir,"/output/output_r")
  iPadding <- 5 - nchar(as.character(iRunNumber))
    if (iPadding > 0)
          {
                  for (i in 1:iPadding)
                          {
                                    sFilename <- paste0(sFilename,"0")
      }
    }
    sFilename <- paste0(sFilename,iRunNumber,GetOutputFileext(sMarxanDir,"SAVERUN"))
}

library(foreign)
library(sqldf)

ImportOutputsCsvToShpDbf <- function(sPuShapeFileDbf, sMarxanDir, iNumberOfRuns, iNumberOfZones, sPUID)
    # Imports the relevant contents of output files to the planning unit shape file dbf.
{
      # load and prepare pu_table
      pu_table <- read.dbf(sPuShapeFileDbf)
  pu_table <- sqldf(paste0("SELECT ", sPUID, " from pu_table"))
    colnames(pu_table)[1] <- "PUID"

    pu_table$PUID <- as.integer(pu_table$PUID)

      # load and prepare ssoln_table
      ssoln_table <- read.csv(paste0(sMarxanDir,"/output/output_ssoln",GetOutputFileext(sMarxanDir,"SAVESUMSOLN")))
      colnames(ssoln_table)[1] <- "PUID"

        if (iNumberOfZones > 2)
              {
                      # read in the the SSOLN fields for multiple zones
                      # "SELECT PUID, SSOLN1, SSOLN2, SSOLN3 from ssoln_table"
                      sSelectSQL <- "SELECT PUID"
          for (i in 1:iNumberOfZones)
                  {
                            colnames(ssoln_table)[i+2] <- paste0("SSOLN",i)
                sSelectSQL <- paste0(sSelectSQL,", SSOLN",i)
                    }
              sSelectSQL <- paste0(sSelectSQL," from ssoln_table")

              ssoln_table <- sqldf(sSelectSQL)
                } else {
                        colnames(ssoln_table)[2] <- "SSOLN2"
                  ssoln_table$SSOLN1 <- as.integer(iNumberOfRuns - ssoln_table$SSOLN2)
                      ssoln_table$SSOLN2 <- as.integer(ssoln_table$SSOLN2)
                    }

        # join pu_table and ssoln_table
        pu_table <- sqldf("SELECT * from pu_table LEFT JOIN ssoln_table USING(PUID)")

          # load and prepare best_table
          best_table <- read.csv(paste0(sMarxanDir,"/output/output_best",GetOutputFileext(sMarxanDir,"SAVEBEST")))
          if (iNumberOfZones > 2)
                {
                        # the field has a different field name in MarZone: "zone" instead of "SOLUTION"
                        colnames(best_table)[1] <- "PUID"
              colnames(best_table)[2] <- "SOLUTION"
                }
            best_table$BESTSOLN <- as.integer(best_table$SOLUTION + 1)
            best_table <- sqldf("SELECT PUID, BESTSOLN from best_table")

              # join pu_table and best_table
              pu_table <- sqldf("SELECT * from pu_table LEFT JOIN best_table USING(PUID)")

              for (i in 1:iNumberOfRuns)
                    {
                            sFieldName <- paste0("SOLN",i)

                  # load and prepare solnX_table
                  solnX_table <- read.csv(GenerateSolnFilename(i,sMarxanDir))
                      if (iNumberOfZones > 2)
                              {
                                        # the field has a different field name in MarZone: "zone" instead of "SOLUTION"
                                        colnames(solnX_table)[1] <- "PUID"
                        colnames(solnX_table)[2] <- "SOLUTION"
                            }
                      solnX_table[sFieldName] <- as.integer(solnX_table$SOLUTION + 1)
                          solnX_table <- sqldf(paste0("SELECT PUID, ",sFieldName," from solnX_table"))

                          # join pu_table and solnX_table
                          pu_table <- sqldf("SELECT * from pu_table LEFT JOIN solnX_table USING(PUID)")

                              rm(solnX_table)
                            }

                # save the new pu_table
                colnames(pu_table)[1] <- sPUID
                write.dbf(pu_table,sPuShapeFileDbf)
}

PulayerDbf <- "/home/ec2-user/Tas_Activity/pulayer/pulayer.dbf"
#PuShapefileDbf <- "~//Tas_Activity//pulayer//pulayer.dbf"
#mardir <- "/home/ec2-user/Tas_Activity/"
MarxanDir <- "/home/ec2-user/Tas_Activity/"
#intRuns <- as.integer(NumberofRuns)
#intZones <- as.integer(NumberofZones)
PUID <- "PUID"
intRuns <- 10
intZones <- 2
ImportOutputsCsvToShpDbf(PulayerDbf,MarxanDir,intRuns,intZones,PUID)
PulayerShp <- paste0(MarxanDir,"pulayer/pulayer.shp", collapse=NULL)
print(PulayerShp)
