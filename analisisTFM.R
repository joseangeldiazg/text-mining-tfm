#***********************************************************************************
#***********************************************************************************
#Análisis de reglas
#***********************************************************************************
#***********************************************************************************

#Tenemos reglas obtenidas en el cluster vamos a ver si hay cosas interesantes

#Primero las pasamos al formato arules

rules <- as.arules("./data/Reglas0_001_0_8.txt")

#Limpiamos redundantes
reglas_redundantes <- rules[is.redundant(x = rules, measure = "confidence")]
reglas_redundantes

#Analizamos 

filtrado_reglas_psoe <- subset(x = reglas_redundantes,
                                  subset = lhs %in% c("psoe"))


inspect(head(reglas_redundantes))

inspect(filtrado_reglas_vox)


