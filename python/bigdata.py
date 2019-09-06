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

#*******************************************************
#OBTENCIÓN DE DATOS:
#*******************************************************

#Obtenemos los datos de mongo

mongoClient = MongoClient('localhost')
db=mongoClient.twitterdb
collection = db.twitter_search
data = pd.DataFrame(collection.find({},{'text':1}))


#*******************************************************
#Limpieza de texto y tokenizacion en BIG DATA:
#*******************************************************

import multiprocessing as mp
import time
start = time.time()

def limpieza(data):
    data['tokenized_text'] = re.sub(r"http\S+", "", data)

    tknzr = TweetTokenizer(reduce_len=True)
    data['tokenized_text'] = data['tokenized_text'].apply(tknzr.tokenize)

    stop = stopwords.words('spanish')

    data['tokenized_text'] = data['tokenized_text'].apply(lambda x: [item for item in x if item not in stop])

    data['tokenized_text'] = data['tokenized_text'].apply(lambda x: [item for item in x if len(item) > 1])

    # 5 - vamos a quitar palabras de uso comun en Twitter como RT o via.

    stop_twitter = ['RT', 'via', 'LoL', 'lol', '...', 'el']

    data['tokenized_text'] = data['tokenized_text'].apply(lambda x: [item for item in x if item not in stop_twitter])

    data['tokenized_text'] = data['tokenized_text'].apply(lambda x: [item.encode('utf-8') for item in x])
    data['tokenized_text'] = data['tokenized_text'].apply(lambda x: [item.decode('utf-8') for item in x])

    # 7-Vamos a pasar todas las palabras a minusculas

    data['tokenized_text'] = data['tokenized_text'].apply(lambda x: [str.lower(item) for item in x])

    # 9- Eliminamos los numeros

    data['tokenized_text'] = data['tokenized_text'].apply(lambda x: [re.sub(r'^([\s\d]+)$', '', item) for item in x])

    return data['tokenized_text']

pool = mp.Pool(mp.cpu_count())

results = pool.map(limpieza, [row for row in data['text']])

pool.close()

print(results)

end = time.time()

print("Tiempo de ejecucion")
print(end - start)
