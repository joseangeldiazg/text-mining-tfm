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

require("arules")

rulesDifusas<-read.csv2("data/TestJoseAngel_compracion.csv", header=F, col.names = c("lhs","rhs","conf"), sep=";", stringsAsFactors = F)

antecedentes<-rulesDifusas$lhs
consecuentes<-rulesDifusas$rhs

antecedentes<-strsplit(antecedentes,",")
consecuentes<-strsplit(consecuentes,",")

antecedentes<-as(antecedentes, "itemMatrix")
consecuentes<-as(consecuentes, "itemMatrix")

itemUnion <- union(itemLabels(antecedentes), itemLabels(consecuentes))

antecedentes<-recode(antecedentes, itemUnion)
consecuentes<-recode(consecuentes, itemUnion)

reglasDifusas <- new("rules", lhs=antecedentes, rhs=consecuentes,
              quality = data.frame(confidence = as.numeric(rulesDifusas$conf)))


reglasDifusas_redundantes <- reglasDifusas[is.redundant(x = reglasDifusas, measure = "confidence")]
reglasDifusas_redundantes #33180

reglasDifusaslimpias<-reglasDifusas_redundantes[!is.redundant(x = reglasDifusas_redundantes, measure = "confidence")]
reglasDifusaslimpias #9192 


#Ahora vamos a ver si aplicando el apriori crisp hay mucha diferencia

rulesCrisp <- apriori(transactions.comparacion, parameter = list(sup = 0.001, conf = 0.7, target="rules", minlen=2, maxtime=Inf))

rulesCrisp_redundantes <-rulesCrisp[is.redundant(x = rulesCrisp, measure = "confidence")]
rulesCrisp_redundantes


reglasCrisplimpias<-rulesCrisp_redundantes[!is.redundant(x = rulesCrisp_redundantes, measure = "confidence")]
reglasCrisplimpias


#Ahora vamos a comparara las reglas más fuertes por ejemplo para trump  

filtrado_regla_fuzzy_donald <- subset(x = reglasDifusaslimpias,
                                 subset = lhs %in% c("donald.trump"))


filtrado_regla_crips_donald <- subset(x = reglasCrisplimpias,
                                   subset = lhs %in% c("donald-trump"))

top.rules.confidence_donald_fuzzy <- sort(filtrado_regla_fuzzy_donald, decreasing = TRUE, na.last = NA, by = "confidence")

top.rules.confidence_donald_crisp <- sort(filtrado_regla_crips_donald, decreasing = TRUE, na.last = NA, by = "confidence")


inspect(head(top.rules.confidence_donald_fuzzy,17))

inspect(head(top.rules.confidence_donald_crisp,17))

#***********************************************************************************
#***********************************************************************************
#Comparativa 2: TV vs TF-IDF
#***********************************************************************************
#***********************************************************************************

# En este caso tenemos que comparar si los items más relevantes en función del TF casan 
# en comparación con los mas relevantes del TF-IDF, de esta manera tratamos de acotar
# cual es la mejor manera de seleccionar los items relevantes para el algoritmo difuso

library("tm")
library("bigmemory")

#Primero obtenemos el document term matrix en funcion de TF-IDF


dtm.TF.IDF <- DocumentTermMatrix(finalCorpus,
                          control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE), wordLengths = c(1, 15)))

dtm.TF.IDF <- removeSparseTerms(dtm.TF.IDF, 0.99)

#Ahora obteneos el document term matrix en funcion del TF

dtm.TF <- DocumentTermMatrix(finalCorpus,
                                 control = list(weighting = function(x) weightTf(x), wordLengths = c(1, 15)))

dtm.TF <- removeSparseTerms(dtm.TF, 0.99)


#Vamos a pasar a matrices normales para trabajar con los gráficos. Tambien eliminamos aquellos terminos poco frecuentes.  

m.tf.idf <- as.matrix(dtm.TF.IDF)
m.tf.idf<-t(m.tf.idf)
v.tf.idf <- sort(rowSums(m.tf.idf),decreasing=TRUE)
d.tf.idf <- data.frame(word = as.character(names(v.tf.idf)),freq=v.tf.idf)


m.tf <- as.matrix(dtm.TF)
m.tf <- t(m.tf)
v.tf <- sort(rowSums(m.tf),decreasing=TRUE)
d.tf <- data.frame(word = as.character(names(v.tf)),freq=v.tf)
  

#Ahora visualizamos para obtener conclusiones al respecto, usaremos histograma y tag clouds


barplot(d.tf.idf[1:72,]$freq, las = 2, names.arg = d.tf.idf[1:72,]$word,
        col ="lightblue", main ="TF-IDF",
        ylab = "Frecuencia")

barplot(d.tf[1:72,]$freq, las = 2, names.arg = d.tf[1:72,]$word,
        col ="lightblue", main ="TF",
        ylab = "Frecuencia")


#Vamos a pintar ambas tablas a un lado y otro para ver los terminos que cambian

tf.and.tf.idf <- cbind(as.character(d.tf$word), as.character(d.tf.idf$word) )

# Podemos concluir que el resultado es diferente, aunque solo cambian algunos terminos. 
# Dado que en la literatura siempre se usa el TF-IDF nos decantaremos por este, ya que en un entorno con 
# más documentos (tweets) seguramente la diferencia sería más notable. 





