#ReadShapeFiletoPoly
#VarStart
#PulayerShp,Input,STRING
#ShapeFile,Output,STRING
#PolygonFile,Output,STRING
#VarEnd
library(maptools)
ShapeFile <- readShapePoly(PulayerShp)
PolygonFile <- SpatialPolygons2PolySet(ShapeFile)
