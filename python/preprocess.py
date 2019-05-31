# -*- coding: utf-8 -*-
#!/usr/bin/env python2.7


#preprocess.py: Script para realizar un preprocesado de datos textuales en español basado en técnicas de text mining y nlp.

#*******************************************************
#Librerias:
#*******************************************************

import os
import pymongo
from pymongo import MongoClient
import pandas as pd


#*******************************************************
#OBTENCIÓN DE DATOS:
#*******************************************************

#Obtenemos los datos de mongo

mongoClient = MongoClient('localhost',27017)
db=mongoClient.twitterdb
collection = db.twitter_search

data = pd.DataFrame(list(collection.find()))

head(data)
