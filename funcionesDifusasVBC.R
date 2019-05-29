# TRABAJO DE FIN DE GRADO: INTRODUCCIÓN A LA LÓGICA DIFUSA. APLICACIÓN PARA BÚS-
#                          QUEDA DE REGLAS DE ASOCIACIÓN DIFUSA
# ALUMNO:                  VICENTE BENÍTEZ CIRICI
# TUTORA:                  MARÍA DOLORES RUIZ JIMÉNEZ
# -------------------------------------------------------------------------------
rm(list = ls())
# -------------------------------------------------------------------------------
metGD <- function(mu,VF,VGF,Q){
  j = mu
  GD = 0
  nf = mu # nf denota a nf(F)*
  acumF = 0
  acumGF = 0
  while (VF[nf] == 0)
    nf = nf - 1
  while (j > 0) {
    acumGF = acumGF + VGF[j]
    acumF = acumF + VF[j]
    if (j <= nf)
      GD = GD + Q(acumGF/acumF)
    j = j - 1
  }
  GD = GD/nf
  return(GD)
}
# -------------------------------------------------------------------------------
pertenece <- function(A,w) {
  for (k in 1:nrow(A)) { # recorre las filas de A
    if (all(c(A[k,] == w))) # si alguna coincide con w
      return(TRUE)
  }
  return(FALSE)
}
# -------------------------------------------------------------------------------
candidatos <- function(Fr) {
  aux1 = nrow(Fr)
  aux2 = ncol(Fr)
  Ca = matrix(NA,nrow = 0,ncol = (aux2+1))
  if (aux1 > 1) {
    # líneas 1--5 del pseudocódigo 2:
    for (i in 1:(aux1-1)) {
      for (j in (i+1):aux1) {
        if (aux2 == 1 | all(c(Fr[i,1:(aux2-1)] == Fr[j,1:(aux2-1)])))
          Ca = rbind(Ca,append(Fr[i,],Fr[j,aux2]))
      }
    }
    # líneas 6--12 del pseudocódigo 2:
    paso = nrow(Ca)
    while (paso > 0) {
      for (j in 1:(aux2+1)) {
        if (pertenece(Fr,Ca[paso,][-j]) == FALSE) {
          Ca = Ca[-paso,]
          if (class(Ca) == "character")
            Ca = matrix(Ca,nrow = 1)
          break
        }
      }
      paso = paso - 1
    }
  }
  return(Ca)
}
# -------------------------------------------------------------------------------
R <- function(y,mu) {
  k = 1
  while (y > (k/mu)) # obtiene k tal que (k-1)/mu < y <= k/mu
    k = k+1
  if (k == 1)
    return(k/mu)
  else {
    aproxinf = (k-1)/mu
    aproxsup = k/mu
    if ((y-aproxinf) < (aproxsup-y))
      return(aproxinf)
    else
      return(aproxsup)
  }
  
}
# -------------------------------------------------------------------------------
inclusion <- function(A,datos,i) { # datos[i,] es la transacción de interés
  grado = 1
  for (k in A) {
    print(datos[,k][i])
    if ((datos[,k][i]) < grado)
      grado = (datos[,k][i])
  }
  return(grado)
}


# -------------------------------------------------------------------------------
itemsetsfrecuentes <- function(datos,minsop,Q,mu){
  m = ncol(datos) # núm. ítems
  n = nrow(datos) # núm. transacciones
  # Línea 1 del pseudocódigo 8:
  Ca = matrix(NA,nrow = m,ncol = 1)
  for(j in 1:m)
    Ca[j, 1] = c(paste(c("i",j),collapse = ""))
  VT = rep(0,mu)
  VT[mu] = n
  iF = list()
  contador = 1 # contador para cardinalidad de iF
  soportesiF = rep(NA,0)
  ViF = matrix(NA,nrow = 0,ncol = mu)
  # Líneas 2--15 del pseudocódigo 8:
  while(nrow(Ca) > 0) {
    matrizV = matrix(0,nrow = nrow(Ca),ncol = mu)
    Fk = matrix(NA,nrow = 0,ncol = ncol(Ca)) # itemsets frec. en la iteración k
    # Líneas 3--7:
    for (i in 1:n) {
      for (j in 1:nrow(Ca)) {
        previo = mu*R(inclusion(Ca[j,],datos,i),mu)
        matrizV[j,previo] = matrizV[j,previo] + 1
      }
    }
    # Líneas 8--13:
    for (j in 1:nrow(Ca)) {
      soporte = metGD(mu,VT,matrizV[j,],Q)
      if (soporte >= minsop) {
        Fk = rbind(Fk,Ca[j,])
        iF[[contador]] = Ca[j,]
        soportesiF = append(soportesiF,soporte)
        ViF = rbind(ViF,matrizV[j,])
        contador = contador + 1
      }
    }
    Ca = candidatos(Fk)
  }
  return(list(iF,soportesiF,ViF))
}
# -------------------------------------------------------------------------------
buscarV <- function(set,iF,ViF) {
  cardinal = length(set)
  for (z in 1:length(iF)) {
    if (length(iF[[z]]) == cardinal) {
      if (all(c(iF[[z]] == set)))
        return(ViF[z,])
    }
  }
}
# -------------------------------------------------------------------------------
reglasdifusas <- function(minconf,sol,Q,mu) {
  s = 1
  while (length(sol[[1]][[s]]) == 1)
    s = s+1
  for (r in s:length(sol[[1]])) {
    Xk = sol[[1]][[r]]
    H1 = matrix(NA,nrow = 0,ncol = 1)
    for (h1 in Xk) {
      Xkmenosh1 = setdiff(Xk,h1)
      confianza = metGD(mu,buscarV(Xkmenosh1,sol[[1]],sol[[3]]),sol[[3]][r,],Q)
      if (confianza >= minconf) {
        # Línea 2 del pseudocódigo 5:
        cat(Xkmenosh1,"-->",h1,"con soporte",sol[[2]][r],
            "y confianza",confianza,"\n")
        H1 = rbind(H1,h1)
      }
    }
    genreglas(Xk,H1,r,minconf,sol,Q,mu)
  }
}
# -------------------------------------------------------------------------------
genreglas <- function(Xk,Hm,r,minconf,sol,Q,mu) {
  if (length(Xk) > (ncol(Hm)+1)) {
    Hm1 = candidatos(Hm)
    f = nrow(Hm1)
    while (f > 0) {
      Xkmenoshm1 = setdiff(Xk,Hm1[f,])
      confianza = metGD(mu,buscarV(Xkmenoshm1,sol[[1]],sol[[3]]),sol[[3]][r,],Q)
      if (confianza >= minconf)
        cat(Xkmenoshm1,"-->",Hm1[f,],"con soporte",sol[[2]][r],
            "y confianza",confianza,"\n")
      else {
        Hm1 = Hm1[-f,]
        if (class(Hm1) == "character")
          Hm1 = matrix(Hm1,nrow = 1)
      }
      f = f - 1
    }
    if (nrow(Hm1) > 1) # Nuevo
      genreglas(Xk,Hm1,r,minconf,sol,Q,mu)
  }
}
# -------------------------------------------------------------------------------
#                                   EJEMPLO:                                    
# -------------------------------------------------------------------------------
datos = rbind(c(1.0, 0.6, 0.6, 1.0),
              c(0.0, 0.0, 1.0, 0.4),
              c(0.2, 1.0, 0.4, 0.7),
              c(0.5, 0.5, 1.0, 1.0),
              c(0.6, 1.0, 0.4, 0.9),
              c(0.1, 0.7, 0.0, 0.1))
colnames(datos) = c("i1","i2","i3","i4")

minsop = 0.1
minconf = 0.65
Q <- function(x) return(x)
mu = 100

sol = itemsetsfrecuentes(datos,minsop,Q,mu)

if (length(sol[[1]]) > 0)
  reglasdifusas(minconf,sol,Q,mu)



# -------------------------------------------------------------------------------
#                           Experimento con datos reales                                   
# -------------------------------------------------------------------------------

#Obtenemos la matriz traspuesta de nuestra matriz normalizado ya que este algoritmo obtiene datos al revés que el nuestro

datos <- apply(normalizado, 2, rbind)
dim(datos)

colnames(datos)
rownames(datos)

minsop = 0.01
minconf = 0.7

Q <- function(x) return(x)
mu = 100

sol = itemsetsfrecuentes(datos,minsop,Q,mu)

if (length(sol[[1]]) > 0)
  reglasdifusas(minconf,sol,Q,mu)


