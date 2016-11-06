#ClusterPlotNMDSPNG
#VarStart
#ClusterSolutions,Input,STRING
#NMDSMap,Output,STRING
#VarEnd
library(maptools)
library(shiny)
library(vegan)
library(labdsv)

ClusterPlotNMDS <- function(solutions)
{
  soldist <- vegdist(solutions,distance="bray")
  
  sol.mds<-nmds(soldist,2)
  png("nmds.png")  
  plot(sol.mds$points, type='n', xlab='', ylab='', main='NMDS of solutions')
  text(sol.mds$points, labels=row.names(solutions))
  dev.off()
  output <- paste0("file://",getwd(),"/nmds.png",collapse=NULL)
  return(output)
}

NMDSMap <- ClusterPlotNMDS(ClusterSolutions)
