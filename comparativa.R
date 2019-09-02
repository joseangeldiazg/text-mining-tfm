#***********************************************************************************
#***********************************************************************************
#Comparativa 1: de CRISP y Fuzzy 
#***********************************************************************************
#***********************************************************************************

#Cargamos los datos originales y las tranasacciones totales para hacer comparaciones

transacciones.completas<-read.transactions("./data/transaccionescrips.csv")
load("./data/export.Rdata")

#Vamos a obtener los datos que usamos para el algoritmo difuso y comparamos con las reglas obtenidas por el algoritmo CRISP

#Con esta rutina podemos obtener aquellos tweets (transacciones) que contienen alguna palabra en especifico. 

getIndexByNames<-function(items, salida)
{
  for(i in 1:140718)
  {
    if ("donald-trump" %in% items[[i]]==TRUE)
    {
      salida<-c(salida,i)
    }
    else if ("hillary-clinton" %in% items[[i]]==TRUE)
    {
      salida<-c(salida,i)
    }
  }
  return(unique(salida))
}

salida<-c(1)

indexObjetivo<-getIndexByNames(items, salida)
itemsObjetivo<-items[indexObjetivo]


#creamos transacciones, eliminamos tambien aquellas transacciones que implican items con mas de 15 letras

transactions.comparacion <- as(itemsObjetivo, "transactions")
transactions.comparacion<-transactions.comparacion[,!nchar(transactions.comparacion@itemInfo$labels)>15]


#Pasamos las transacciones a un dataframe para volver a obtener los resultados difusos

dataFuzzy.comparacion<-as.matrix(transactions.comparacion@data)
dataFuzzy.comparacion<-t(dataFuzzy.comparacion)
colnames(dataFuzzy.comparacion)<-transactions.comparacion@itemInfo$labels
dim(dataFuzzy.comparacion)
rownames(dataFuzzy.comparacion)<-paste("tweet", 1:1932, sep = "-", collapse = NULL)

df.dataFuzzy.comparacion<-as.data.frame(dataFuzzy.comparacion)
cols <- sapply(df.dataFuzzy.comparacion, is.logical)
df.dataFuzzy.comparacion[,cols] <- lapply(df.dataFuzzy.comparacion[,cols], as.numeric)

term.frequency <- function(row) {
  row / sum(row)
}

str(df.dataFuzzy.comparacion)
normalizado <- apply(df.dataFuzzy.comparacion, 1, term.frequency)
normalizado<-t(normalizado)

#Pasamos los datos a transaccion

#Eliminamos el nombre del tweet para evitar tener problemas con el difuso. 
row.names(normalizado)<-c()
write.csv2(normalizado, file = "./data/datosdifusos.comparacion.csv", sep="\t")

#Volvemos a generar los nombres

rownames(dataFuzzy.comparacion)<-paste("tweet", 1:1932, sep = "-", collapse = NULL)
df.dataFuzzy.comparacion<-as.data.frame(normalizado)

#Aplicamos en el servidor el algoritmo de reglas y en este punto podemos comprar el número de reglas que aparecen en ambas. 



#***********************************************************************************
#***********************************************************************************
#Comparativa 2: TF vs TF-IDF
#***********************************************************************************
#***********************************************************************************

# En este caso tenemos que comparar si los items más relevantes en función del TF casan 
# en comparación con los mas relevantes del TF-IDF, de esta manera tratamos de acotar
# cual es la mejor manera de seleccionar los items relevantes para el algoritmo difuso

library("tm")

#Primero obtenemos el document term matrix en funcion de TF-IDF


dtm.TF.IDF <- DocumentTermMatrix(finalCorpus,
                          control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE), wordLengths = c(1, 13), 
                                         stopwords = TRUE))

#Ahora obteneos el document term matrix en funcion del TF

dtm.TF <- DocumentTermMatrix(finalCorpus,
                                 control = list(weighting = function(x) weightTf(x), wordLengths = c(1, 13),
                                                stopwords = TRUE))


#Vamos a pasar a matrices normales para trabajar con los gráficos. Tambien eliminamos aquellos terminos poco frecuentes.  


m.tf.idf <- as.matrix(dtm.TF.IDF)
v.tf.idf <- sort(rowSums(m.tf.idf),decreasing=TRUE)
d.tf.idf <- data.frame(word = names(v.tf.idf),freq=v.tf.idf)


m.tf.idf <- as.matrix(dtm.TF.IDF)
v.tf.idf <- sort(rowSums(m.tf.idf),decreasing=TRUE)
d.tf.idf <- data.frame(word = names(v.tf.idf),freq=v.tf.idf)
  

#Ahora visualizamos para obtener conclusiones al respecto, usaremos histograma y tag clouds







