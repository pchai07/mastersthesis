#PlanningUnitSolutionToPNG
#VarStart
#PlanningLayer,Input,STRING
#DisplayedField,Input,STRING
#Transparent,Input,STRING
#OutDir,output,STRING
#VarEnd
library(sp)
library(maptools)
DisplayMap <- function(planningunits,displayfield,fTransparent)
{
  # display map of a single solution
  # 0, best solution
  # 1..100, solution X
  greenramp <- colorRampPalette(c("white","green"))(2)
  png(filename="solnmap.png")
  if (displayfield<1)
  {
    # 0, best solution
    if (identical(TRUE,fTransparent))
    {
      print(spplot(planningunits["BESTSOLN"],col.regions= greenramp,
                   col="transparent"))
    } else {
      print(spplot(planningunits["BESTSOLN"],col.regions= greenramp))
    }
  } else {
    # 1..100, solution X
    if (identical(TRUE,fTransparent))
    {
      print(spplot(planningunits[paste0("SOLN",displayfield)],
                   col.regions= greenramp,col="transparent"))
    } else {
      print(spplot(planningunits[paste0("SOLN",displayfield)],
                   col.regions= greenramp))
    }
  }
  dev.off()
  output <- paste0("file://",getwd(),"/solnmap.png",collapse=NULL)
}

