#SCRIPT PARA TRABAJAR CON REGLAS DE ASOCIACIÓN DIFUSAS

#Tenemos las reglas de asociación obtenidas de forma difusa, hay que obtener una rutina para limpiar
#aquellas reglas redundantes, es decir, con los mismos items en disintas posiciones.



require("arules")

read("./data/RulesAngel0.7.txt")

read.table()

transactions<-read.delim("./data/RulesAngel0.7.txt")
colnames(transactions)<-"Rule"
transactions$Rule<-as.character(transactions$Rule)
strsplit(transactions$Rule, "-->")

