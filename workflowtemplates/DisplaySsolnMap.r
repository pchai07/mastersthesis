#DisplaySsolnMap
#VarStart
#planninglayer,Input,STRING
#DisplayedZone,Input,STRING
#Transparent,Input,STRING
#OutDir,output,STRING
#VarEnd
library(sp)
library(maptools)
library(PBSmapping)
DisplaySsolnMap <- function(planningunits,displayzone,fTransparent)
{
  # display a summed solution map
  # displayzone is the zone we are displaying summed solution for
  blueramp <- colorRampPalette(c("white","blue"))(16) 
  png(filename="ssolnmap.png")
  if (isTRUE(fTransparent))
  {
    print(spplot(planningunits[paste0("SSOLN",displayzone)],col.regions=blueramp,col="transparent"))
  } else {
    print(spplot(planningunits[paste0("SSOLN",displayzone)],col.regions=blueramp))
  }
  dev.off()
  output <- paste0("file://",getwd(),"/ssolnmap.png",collpase=NULL)
  return(output)
}
OutDir <- DisplaySsolnMap(planninglayer,DisplayedZone,Transparent)
