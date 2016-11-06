#ClusterDendogramPlotPNG
#VarStart
#ClusterSolutions,Input,STRING
#DendogramPlot,Output,STRING
#VarEnd
library(maptools)
library(shiny)
library(vegan)
library(labdsv)
ClusterPlotDendogram <- function(solutions)
{
  soldist <- vegdist(solutions,distance="bray")
  
  h<-hclust(soldist, method="complete")
  png("dendogram.png") 
  plot(h, xlab="Solutions", ylab="Disimilarity", main="Bray-Curtis dissimilarity of solutions")
  dev.off()
  output <- paste0("file://",getwd(),"/dendogram.png",collapse=NULL)
  return(output)
}

DendogramPlot <- ClusterPlotDendogram(ClusterSolutions)
