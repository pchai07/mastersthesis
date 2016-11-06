#MarxanClusterSolutions
#VarStart
#MarxanSolutions,Input,STRING
#ClusterSolutions,Output,STRING
#VarEnd
library(maptools)
library(shiny)
library(vegan)
library(labdsv)

ClusterUniqueSolutions <- function(sSolutionsMatrix)
# Returns the set of unique solutions from a solutions matrix.
# Returns NULL if there is less than 2 unique solutions.
{
  solutions_raw<-read.table(sSolutionsMatrix,header=TRUE, row.name=1, sep=",")
  solutions <- unique(solutions_raw)
  iUniqueSolutions <- dim(solutions)[1]
  if (iUniqueSolutions < 2)
  {
    return(NULL)
  } else {
    return(solutions)
  }
}
#MarxanSolutions <- "~/Tas_Activity/output/output_solutionsmatrix.csv"

ClusterSolutions <- ClusterUniqueSolutions(MarxanSolutions)
