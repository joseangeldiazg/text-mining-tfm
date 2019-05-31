#SCRIPT PARA TRABAJAR CON REGLAS DE ASOCIACIÓN DIFUSAS

# Tenemos las reglas de asociación obtenidas de forma difusa, hay que obtener una rutina para limpiar
# aquellas reglas redundantes, es decir, con los mismos items en disintas posiciones. De paso también
# obtendremos los datos en un objeto de tipo arules, en el que podremos aplicar todos los métodos de este
# paquete a nuestras reglas difusas.

#Paso 1: Cargamos las reglas del fichero a un formato mas amigable en un dataframe.


require("arules")

rules<-read.csv2("./data/Rules_0.7.csv", header=F, col.names = c("lhs","rhs","conf"), sep=";", stringsAsFactors = F)

#Paso 2: Limpiamos los antecedentes y consecuentes

antecedentes<-rules$lhs
consecuentes<-rules$rhs

antecedentes<-strsplit(antecedentes,",")
consecuentes<-strsplit(consecuentes,",")

antecedentes<-as(antecedentes, "itemMatrix")
consecuentes<-as(consecuentes, "itemMatrix")

itemUnion <- union(itemLabels(antecedentes), itemLabels(consecuentes))

antecedentes<-recode(antecedentes, itemUnion)
consecuentes<-recode(consecuentes, itemUnion)

#Paso 3: Debemos cargar las reglas a un objeto de tipo arules, para ello, debemos crear itemMatrix

reglas <- new("rules", lhs=antecedentes, rhs=consecuentes,
             quality = data.frame(confidence = as.numeric(rules$conf)))


#Paso 4: Ya tenemos los datos en formato arules, por lo que ahora, limpiamos las redundantes. 

reglas_redundantes <- reglas[is.redundant(x = reglas, measure = "confidence")]
reglas_redundantes
#Tal y como parecia, hay muchas reglas iguales, las eliminamos. 

reglaslimpias<-reglas[!is.redundant(x = reglas, measure = "confidence")]
reglaslimpias

#Paso 5: Ahora ya tenemos nuestras reglas limpias y podemos realizar busquedas sobre ellas

filtrado_reglas_hillary <- subset(x = reglaslimpias,
                          subset = lhs %in% c("hillary.clinton"))


filtrado_reglas_donald <- subset(x = reglaslimpias,
                                  subset = lhs %in% c("donald.trump"))


inspect(filtrado_reglas_hillary)
inspect(filtrado_reglas_donald)


#Vamos a crear una version de fucion 

as.arules <- function(archivo)
{
  #leemos el archivo
  rules<-read.csv2(archivo, header=F, col.names = c("lhs","rhs","conf"), sep=";", stringsAsFactors = F)
  antecedentes<-rules$lhs
  consecuentes<-rules$rhs
  
  antecedentes<-strsplit(antecedentes,",")
  consecuentes<-strsplit(consecuentes,",")
  
  antecedentes<-as(antecedentes, "itemMatrix")
  consecuentes<-as(consecuentes, "itemMatrix")
  itemUnion <- union(itemLabels(antecedentes), itemLabels(consecuentes))
  
  antecedentes<-recode(antecedentes, itemUnion)
  consecuentes<-recode(consecuentes, itemUnion)
  
  reglas <- new("rules", lhs=antecedentes, rhs=consecuentes,
                quality = data.frame(confidence = as.numeric(rules$conf)))
  return(reglas)
}


