# -*- coding: utf-8 -*-
#!/opt/anaconda3/bin/python3


#preprocess.py: Script para realizar un preprocesado de datos textuales en español basado en técnicas de text mining y nlp.

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

import time
start = time.time()

#Obtenemos los datos de mongo

mongoClient = MongoClient('localhost')
db=mongoClient.twitterdb
collection = db.twitter_search
data = pd.DataFrame(collection.find({},{'text':1}))



#*******************************************************
#Limpieza de texto y tokenizacion:
#*******************************************************

# Vamos a llevar a cabo una tokenización especial para tweets.

# 1- Eliminamos enlaces

data['tokenized_text']=data['text'].apply(lambda x: re.sub(r"http\S+", "", x))

# 2- Separamos los tweets en palabras quedandonos con los posibles emoticonos.

tknzr = TweetTokenizer(reduce_len=True)

data['tokenized_text']=data['tokenized_text'].apply(tknzr.tokenize)

# 3- Eliminamos palabras vacias.

stop = stopwords.words('spanish')

data['tokenized_text']=data['tokenized_text'].apply(lambda x: [item for item in x if item not in stop])


# 4- Eliminamos signos de puntuación y caracteres de tamaño 1 así mantendremos los emoticonos como :) :

data['tokenized_text']=data['tokenized_text'].apply(lambda x: [item for item in x if len(item) > 1])


#5 - vamos a quitar palabras de uso comun en Twitter como RT o via.

stop_twitter=['RT', 'via', 'LoL', 'lol', '...', 'el']

data['tokenized_text']=data['tokenized_text'].apply(lambda x: [item for item in x if item not in stop_twitter])



#6-Pasamos todlas las palabras a ASCCI para posteriormente pasarlo a string

data['tokenized_text']=data['tokenized_text'].apply(lambda x: [item.encode('utf-8') for item in x])
data['tokenized_text']=data['tokenized_text'].apply(lambda x: [item.decode('utf-8') for item in x])


#7-Vamos a pasar todas las palabras a minusculas

data['tokenized_text']=data['tokenized_text'].apply(lambda x: [str.lower(item) for item in x])


#8- Comprobamos que las palabras estén bien ecritas y las cambiamos por las buenas en caso necesario
#from spellchecker import SpellChecker
#spell = SpellChecker(language='es')
#data['tokenized_text']=data['tokenized_text'].apply(lambda x: [spell.correction(item) for item in x if item != spell.correction(item)])


#9- Eliminamos los numeros

data['tokenized_text']=data['tokenized_text'].apply(lambda x: [re.sub(r'^([\s\d]+)$','',item) for item in x])

print(data)

#*******************************************************
#Estudio de frecuencias:
#*******************************************************

#primero concatenamos

data['cleaned_text']=data['tokenized_text'].apply(lambda x: [' '.join(x)])

data['cleaned_text'] = data['cleaned_text'].str.join(" ")

cvec = CountVectorizer( min_df=1, max_df=.5, ngram_range=(1,2))

cvec.fit(data['cleaned_text'])

list(islice(cvec.vocabulary_.items(), 20))

cvec = CountVectorizer(min_df=.0025, max_df=.1, ngram_range=(1,2))

cvec.fit(data['cleaned_text'])

cvec_counts = cvec.transform(data['cleaned_text'])

occ = np.asarray(cvec_counts.sum(axis=0)).ravel().tolist()

counts_df = pd.DataFrame({'term': cvec.get_feature_names(), 'occurrences': occ})

counts_df.sort_values(by='occurrences', ascending=False).head(20)

transformer = TfidfTransformer()
transformed_weights = transformer.fit_transform(cvec_counts)
transformed_weights

weights = np.asarray(transformed_weights.mean(axis=0)).ravel().tolist()
weights_df = pd.DataFrame({'term': cvec.get_feature_names(), 'weight': weights})
weights_df.sort_values(by='weight', ascending=False).head(100)

#*******************************************************
#creacion de transacciones:
#*******************************************************


#Creamos transacciones
#(((1517477*140727)/1024)/1024)/1024)-> 200GB de memoria necesito

#Obtenemos reglas de asociacion

association_rules = apriori(data['tokenized_text'], min_support=0.001, min_confidence=0.6, min_length=2)
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

print("Tiempo de ejecucion")
print(end - start)

