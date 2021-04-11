# Preparation
## General References
### https://www.geeksforgeeks.org/python-word-embedding-using-word2vec/
### http://man.hubwiz.com/docset/gensim.docset/Contents/Resources/Documents/radimrehurek.com/gensim/install.html
### https://www.datacamp.com/community/tutorials/discovering-hidden-topics-python
### https://swatimeena989.medium.com/training-word2vec-using-gensim-14433890e8e4
### https://towardsdatascience.com/a-beginners-guide-to-word-embedding-with-gensim-word2vec-model-5970fa56cc92
### https://phdstatsphys.wordpress.com/2018/12/27/word2vec-how-to-train-and-update-it/

# Prep: Go to Terminal
## sudo pip3 install nltk
## sudo pip3 install numpy
## sudo pip3 install scipy
## sudo pip3 install gensim
## sudo pip3 install python-Levenshtein
## sudo pip3 install pandas
## sudo pip3 install xlrd
## sudo pip3 install openpyxl

## If Reinstall Required
### Reinstall numpy or other file just delete then reinstall
### Note the -r is recursive because these functions are all folders
### sudo rm -r /Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/numpy-1.20.2-py3.9-macosx-10.9-x86_64.egg
### Can also remove: numpy_quaternion-2021.4.5.14.42.35.dist-info

# Install Certificates
## go to Macintosh HD > Applications > Python3.6 folder (or whatever version of python you're using) > double click on "Install Certificates.command"

# Install Other: From python
## nltk.download('punkt')
## nltk.download('stopwords')

# Python program to generate word vectors using Word2Vec
# importing all necessary modules
## Data managment
import pandas as pd

## Gensim Main
import gensim
from gensim.models import Word2Vec, KeyedVectors
from gensim.test.utils import common_texts

## Tokenizing
import nltk
from nltk.tokenize import sent_tokenize, word_tokenize, regexp_tokenize
import warnings
  
## Other
from nltk.corpus import stopwords
from gensim.test.utils import datapath
import re
import unicodedata
from tqdm import tqdm
import multiprocessing
import random
import xlrd
import openpyxl

## More for LSA
import os.path
from gensim import corpora
from gensim.models import LsiModel
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
from nltk.stem.porter import PorterStemmer
from gensim.models.coherencemodel import CoherenceModel

## import matplotlib.pyplot as plt

## The following resource was used to direct further analysis
## https://www.datacamp.com/community/tutorials/discovering-hidden-topics-python
## Create functions
def load_excel(path,file_name):
    """
    Bring in an excel file
    """
    return pd.read_excel(os.path.join(path, file_name), index_col=0)

def process_tokens(input_text_units):
    """
    Input: What ever division of data is desired, paragraphs or sentences
    Output: processed tokens for analysis
    """
    
    ## Tokenize
    ### https://medium.com/0xcode/tokenizing-words-and-sentences-using-nltk-in-python-a11e5d33c312
    processed_tokens = []

    ### Create a tokenizer unless word_tokenize is used
    #### tokenizer = RegexpTokenizer(r'\w+')

    ### Get usual english stop words
    eng_stop = set(stopwords.words('english'))
    
    ### Create a Stemmer if desired
    ## Stemming: https://tartarus.org/martin/PorterStemmer/
    p_stemmer = PorterStemmer()
    
    for i in input_text_units['sentences']:
        ### clean and tokenize document string
        ### lower case attribute required for stemmer
        raw = i.lower()

        ### tokenizer
        tokens = word_tokenize(raw)
        
        ### remove stop words from tokens if desired
        stopped_tokens = [i for i in tokens if not i in eng_stop]
        
        ### stem tokens
        stemmed_tokens = [p_stemmer.stem(i) for i in stopped_tokens]
        
        ### add tokens to list
        processed_tokens.append(stemmed_tokens)

    return processed_tokens

## Create functions
def dictionary_DTM(clean_list):
    """
    Create the dictionary and Document Term Matrix (DTM)
    """
    # Create dictionary for courpus
    dictionary = corpora.Dictionary(clean_list)
    
    # Create Document Term Matrix using dictionary
    doc_term_matrix = [dictionary.doc2bow(doc) for doc in clean_list]
    
    # generate LDA model
    return dictionary,doc_term_matrix

## Create LSA
def create_lsa_model(clean_list,number_of_topics):
    """
    Create LSA from the input text given a number of topics and number of words associated with a topic
    """
    dictionary,DTM=dictionary_DTM(clean_list)
    
    # generate LSA model
    lsamodel = LsiModel(DTM, num_topics=number_of_topics, id2word = dictionary)  
    #print(lsamodel.print_topics(num_topics=number_of_topics, num_words=words))
    return lsamodel

## Find Coherence
def get_coherence_for_set_DTM(dictionary, DTM, clean_list, stop, step=1, start=2):
    """
    find topic coherence and output models for use
    """

    # Initialize
    coherence_values = []
    model_list = []
    for num_topics in range(start, stop, step):

        # generate LSA model
        model = LsiModel(DTM, num_topics=num_topics, id2word = dictionary)  

        # store the model
        model_list.append(model)

        # compute coherence
        ## Multiple coherence techniques to choose from:
        ### 'u_mass', 'c_v', 'c_uci', 'c_npmi'
        ## https://radimrehurek.com/gensim/models/coherencemodel.html
        ## https://mimno.infosci.cornell.edu/papers/mimno-semantic-emnlp.pdf
        ## https://www.aclweb.org/anthology/D12-1087.pdf
        ## Selected Umass because it is rapid and 
        coherencemodel = CoherenceModel(model=model, texts=clean_list, dictionary=dictionary, coherence='u_mass')

        # append coherence values
        coherence_values.append(coherencemodel.get_coherence())
        
    return model_list, coherence_values

## Suppress warnings
warnings.filterwarnings(action = 'ignore')

# General variables
data_path = "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/"

# Read in our data
c14df = load_excel(data_path,"c_14.xlsx")
c22df = load_excel(data_path,"c_22.xlsx")
c30df = load_excel(data_path,"c_30.xlsx")
c40df = load_excel(data_path,"c_40.xlsx")
c41df = load_excel(data_path,"c_41.xlsx")
c43df = load_excel(data_path,"c_43.xlsx")
c45df = load_excel(data_path,"c_45.xlsx")
c46df = load_excel(data_path,"c_46.xlsx")
c48df = load_excel(data_path,"c_48.xlsx")

# Create a concatenation of rows divided by a comma
varInIt = c14df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml14, c14 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
print(ml14[1].print_topics(num_topics=2, num_words=5))

varInIt = c22df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml22, c22 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
print(ml22[1].print_topics(num_topics=2, num_words=5))

varInIt = c30df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml30, c30 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
print(ml30[1].print_topics(num_topics=2, num_words=5))

varInIt = c40df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml40, c40 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
print(ml40[1].print_topics(num_topics=2, num_words=5))

varInIt = c43df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml43, c43 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
print(ml43[1].print_topics(num_topics=2, num_words=5))

varInIt = c45df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml45, c45 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
print(ml45[1].print_topics(num_topics=2, num_words=5))

varInIt = c46df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml46, c46 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
print(ml46[1].print_topics(num_topics=2, num_words=5))

varInIt = c48df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml48, c48 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
print(ml48[1].print_topics(num_topics=2, num_words=5))

#lower_sents = [i.lower() for i in c22df['sentences']]
#tokenized_sents = [lower_sents(i.lower()) for i in c22df['sentences']]
#stemmed_tokens = [p_stemmer.stem(i) for i in tokenized_sents]

## Alternative
### tokenized_sents = [regexp_tokenize(i,"[\w']+") for i in c22df['sentences']]
        ### there is an ever so subtle difference between algorhthyms
        ### note the number of sentece lines


## https://www.datacamp.com/community/tutorials/discovering-hidden-topics-python
## Stemming: https://tartarus.org/martin/PorterStemmer/



# p_stemmer = PorterStemmer()
# Train
## Use multiprocessing package
cores= multiprocessing.cpu_count()

# initiate model
model = Word2Vec(min_count=1, vector_size=50, workers=cores-1, window =3, sg = 1, max_vocab_size=100000)

# note that as soon as the vocab is updated the corpus is updated
# model.build_vocab(tokenized_sents, update = False)





# Integrate into r with reticulate
## https://rstudio.github.io/reticulate/articles/r_markdown.html
