#Comparativa de CRISP y Fuzzy 

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







