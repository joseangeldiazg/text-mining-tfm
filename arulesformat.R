#Funcion para cargar reglas de csv a formato arules

require("arules")

as.arules <- function(archivo)
{
  #leemos el archivo, debe ir separado con ; y en formado antecedente, consecuente , confianza
  
  rules<-read.csv2(archivo, header=F, col.names = c("lhs","rhs","conf"), sep=";", stringsAsFactors = F)
  
  #Paso 2: Limpiamos los antecedentes y consecuentes
  
  antecedentes<-rules$lhs
  consecuentes<-rules$rhs
  
  antecedentes<-strsplit(antecedentes,",")
  consecuentes<-strsplit(consecuentes,",")
  
  #Paso 3: Debemos cargar las reglas a un objeto de tipo arules, para ello, debemos crear itemMatrix
  
  antecedentes<-as(antecedentes, "itemMatrix")
  consecuentes<-as(consecuentes, "itemMatrix")
  itemUnion <- union(itemLabels(antecedentes), itemLabels(consecuentes))
  
  antecedentes<-recode(antecedentes, itemUnion)
  consecuentes<-recode(consecuentes, itemUnion)
  
  #Paso 4 cargamos las reglas en el formato rules y las devolvemos
  
  reglas <- new("rules", lhs=antecedentes, rhs=consecuentes,
                quality = data.frame(confidence = as.numeric(rules$conf)))
  return(reglas)
}