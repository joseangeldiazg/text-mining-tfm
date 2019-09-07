# -*- coding: utf-8 -*-
#!/opt/anaconda3/bin/python3


#experimentos.py: Script para realizar experimentacion en secuencial.

#*******************************************************
#Librerias:
#*******************************************************


#para preprocesado
from nltk.tokenize import TweetTokenizer
import pandas as pd
from pymongo import MongoClient
from nltk.corpus import stopwords
import re


#para estudio de frecuencias

from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
from itertools import islice
import numpy as np

#para transacciones y reglas de asociación
from mlxtend.preprocessing import TransactionEncoder
import matplotlib.pyplot as plt
from apyori import apriori


#*******************************************************
#OBTENCIÓN DE DATOS:
#*******************************************************


#Obtenemos los datos de mongo

mongoClient = MongoClient('localhost')
db=mongoClient.twitterdb
collection = db.twitter_search
data = pd.DataFrame(collection.find({},{'text':1}))



experimento100000=data.sample(n=100000)
experimento300000=data.sample(n=300000)
experimento600000=data.sample(n=600000)

#*******************************************************
#Experimento con 100000 tweets, 0.01 de soporte y 0.7 de confianza
#*******************************************************


#*******************************************************
#Limpieza de texto y tokenizacion:
#*******************************************************

import time
start = time.time()

# Vamos a llevar a cabo una tokenización especial para tweets.

# 1- Eliminamos enlaces

experimento100000['tokenized_text']=experimento100000['text'].apply(lambda x: re.sub(r"http\S+", "", x))

# 2- Separamos los tweets en palabras quedandonos con los posibles emoticonos.

tknzr = TweetTokenizer(reduce_len=True)

experimento100000['tokenized_text']=experimento100000['tokenized_text'].apply(tknzr.tokenize)

# 3- Eliminamos palabras vacias.

stop = stopwords.words('spanish')

experimento100000['tokenized_text']=experimento100000['tokenized_text'].apply(lambda x: [item for item in x if item not in stop])


# 4- Eliminamos signos de puntuación y caracteres de tamaño 1 así mantendremos los emoticonos como :) :

experimento100000['tokenized_text']=experimento100000['tokenized_text'].apply(lambda x: [item for item in x if len(item) > 1])


#5 - vamos a quitar palabras de uso comun en Twitter como RT o via.

stop_twitter=['RT', 'via', 'LoL', 'lol', '...', 'el']

experimento100000['tokenized_text']=experimento100000['tokenized_text'].apply(lambda x: [item for item in x if item not in stop_twitter])



#6-Pasamos todlas las palabras a ASCCI para posteriormente pasarlo a string

experimento100000['tokenized_text']=experimento100000['tokenized_text'].apply(lambda x: [item.encode('utf-8') for item in x])
experimento100000['tokenized_text']=experimento100000['tokenized_text'].apply(lambda x: [item.decode('utf-8') for item in x])


#7-Vamos a pasar todas las palabras a minusculas

experimento100000['tokenized_text']=experimento100000['tokenized_text'].apply(lambda x: [str.lower(item) for item in x])


#8- Comprobamos que las palabras estén bien ecritas y las cambiamos por las buenas en caso necesario
#from spellchecker import SpellChecker
#spell = SpellChecker(language='es')
#data['tokenized_text']=data['tokenized_text'].apply(lambda x: [spell.correction(item) for item in x if item != spell.correction(item)])


#9- Eliminamos los numeros

experimento100000['tokenized_text']=experimento100000['tokenized_text'].apply(lambda x: [re.sub(r'^([\s\d]+)$','',item) for item in x])

print(experimento100000)


#Obtenemos reglas de asociacion

association_rules = apriori(experimento100000['tokenized_text'], min_support=0.01, min_confidence=0.6, min_length=2)
association_results = list(association_rules)

for item in association_results:

    # first index of the inner list
    # Contains base item and add item
    pair = item[0]
    items = [x for x in pair]
    print("Rule: " + items[0] + " -> " + items[1])

    #second index of the inner list
    print("Support: " + str(item[1]))

    #third index of the list located at 0th
    #of the third index of the inner list

    print("Confidence: " + str(item[2][0][2]))
    print("Lift: " + str(item[2][0][3]))
    print("=====================================")

end = time.time()

print("Tiempo de ejecucion 100000")
print(end - start)

print("Numero de reglas 100000")
print(len(association_results))


#*******************************************************
#Experimento con 300000 tweets, 0.01 de soporte y 0.7 de confianza
#*******************************************************


#*******************************************************
#Limpieza de texto y tokenizacion:
#*******************************************************

start = time.time()

# Vamos a llevar a cabo una tokenización especial para tweets.

# 1- Eliminamos enlaces

experimento300000['tokenized_text']=experimento300000['text'].apply(lambda x: re.sub(r"http\S+", "", x))

# 2- Separamos los tweets en palabras quedandonos con los posibles emoticonos.

tknzr = TweetTokenizer(reduce_len=True)

experimento300000['tokenized_text']=experimento300000['tokenized_text'].apply(tknzr.tokenize)

# 3- Eliminamos palabras vacias.

stop = stopwords.words('spanish')

experimento300000['tokenized_text']=experimento300000['tokenized_text'].apply(lambda x: [item for item in x if item not in stop])


# 4- Eliminamos signos de puntuación y caracteres de tamaño 1 así mantendremos los emoticonos como :) :

experimento300000['tokenized_text']=experimento300000['tokenized_text'].apply(lambda x: [item for item in x if len(item) > 1])


#5 - vamos a quitar palabras de uso comun en Twitter como RT o via.

stop_twitter=['RT', 'via', 'LoL', 'lol', '...', 'el']

experimento300000['tokenized_text']=experimento300000['tokenized_text'].apply(lambda x: [item for item in x if item not in stop_twitter])



#6-Pasamos todlas las palabras a ASCCI para posteriormente pasarlo a string

experimento300000['tokenized_text']=experimento300000['tokenized_text'].apply(lambda x: [item.encode('utf-8') for item in x])
experimento300000['tokenized_text']=experimento300000['tokenized_text'].apply(lambda x: [item.decode('utf-8') for item in x])


#7-Vamos a pasar todas las palabras a minusculas

experimento300000['tokenized_text']=experimento300000['tokenized_text'].apply(lambda x: [str.lower(item) for item in x])


#8- Comprobamos que las palabras estén bien ecritas y las cambiamos por las buenas en caso necesario
#from spellchecker import SpellChecker
#spell = SpellChecker(language='es')
#data['tokenized_text']=data['tokenized_text'].apply(lambda x: [spell.correction(item) for item in x if item != spell.correction(item)])


#9- Eliminamos los numeros

experimento300000['tokenized_text']=experimento300000['tokenized_text'].apply(lambda x: [re.sub(r'^([\s\d]+)$','',item) for item in x])

print(experimento300000)


#Obtenemos reglas de asociacion

association_rules = apriori(experimento300000['tokenized_text'], min_support=0.01, min_confidence=0.6, min_length=2)
association_results = list(association_rules)

for item in association_results:

    # first index of the inner list
    # Contains base item and add item
    pair = item[0]
    items = [x for x in pair]
    print("Rule: " + items[0] + " -> " + items[1])

    #second index of the inner list
    print("Support: " + str(item[1]))

    #third index of the list located at 0th
    #of the third index of the inner list

    print("Confidence: " + str(item[2][0][2]))
    print("Lift: " + str(item[2][0][3]))
    print("=====================================")

end = time.time()

print("Tiempo de ejecucion 300000")
print(end - start)

print("Numero de reglas 300000")
print(len(association_results))

#*******************************************************
#Experimento con 600000 tweets, 0.01 de soporte y 0.7 de confianza
#*******************************************************



#*******************************************************
#Limpieza de texto y tokenizacion:
#*******************************************************

start = time.time()

# Vamos a llevar a cabo una tokenización especial para tweets.

# 1- Eliminamos enlaces

experimento600000['tokenized_text']=experimento600000['text'].apply(lambda x: re.sub(r"http\S+", "", x))

# 2- Separamos los tweets en palabras quedandonos con los posibles emoticonos.

tknzr = TweetTokenizer(reduce_len=True)

experimento600000['tokenized_text']=experimento600000['tokenized_text'].apply(tknzr.tokenize)

# 3- Eliminamos palabras vacias.

stop = stopwords.words('spanish')

experimento600000['tokenized_text']=experimento600000['tokenized_text'].apply(lambda x: [item for item in x if item not in stop])


# 4- Eliminamos signos de puntuación y caracteres de tamaño 1 así mantendremos los emoticonos como :) :

experimento600000['tokenized_text']=experimento600000['tokenized_text'].apply(lambda x: [item for item in x if len(item) > 1])


#5 - vamos a quitar palabras de uso comun en Twitter como RT o via.

stop_twitter=['RT', 'via', 'LoL', 'lol', '...', 'el']

experimento600000['tokenized_text']=experimento600000['tokenized_text'].apply(lambda x: [item for item in x if item not in stop_twitter])



#6-Pasamos todlas las palabras a ASCCI para posteriormente pasarlo a string

experimento600000['tokenized_text']=experimento600000['tokenized_text'].apply(lambda x: [item.encode('utf-8') for item in x])
experimento600000['tokenized_text']=experimento600000['tokenized_text'].apply(lambda x: [item.decode('utf-8') for item in x])


#7-Vamos a pasar todas las palabras a minusculas

experimento600000['tokenized_text']=experimento600000['tokenized_text'].apply(lambda x: [str.lower(item) for item in x])


#8- Comprobamos que las palabras estén bien ecritas y las cambiamos por las buenas en caso necesario
#from spellchecker import SpellChecker
#spell = SpellChecker(language='es')
#data['tokenized_text']=data['tokenized_text'].apply(lambda x: [spell.correction(item) for item in x if item != spell.correction(item)])


#9- Eliminamos los numeros

experimento600000['tokenized_text']=experimento600000['tokenized_text'].apply(lambda x: [re.sub(r'^([\s\d]+)$','',item) for item in x])

print(experimento600000)


#Obtenemos reglas de asociacion

association_rules = apriori(experimento600000['tokenized_text'], min_support=0.01, min_confidence=0.6, min_length=2)
association_results = list(association_rules)

for item in association_results:

    # first index of the inner list
    # Contains base item and add item
    pair = item[0]
    items = [x for x in pair]
    print("Rule: " + items[0] + " -> " + items[1])

    #second index of the inner list
    print("Support: " + str(item[1]))

    #third index of the list located at 0th
    #of the third index of the inner list

    print("Confidence: " + str(item[2][0][2]))
    print("Lift: " + str(item[2][0][3]))
    print("=====================================")

end = time.time()

print("Tiempo de ejecucion 600000")
print(end - start)

print("Numero de reglas 600000")
print(len(association_results))