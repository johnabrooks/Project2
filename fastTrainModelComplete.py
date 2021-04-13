# LSA

# Premble
## LSA versus LDA
### https://medium.com/nanonets/topic-modeling-with-lsa-psla-lda-and-lda2vec-555ff65b0b05

# Preparation of Python
## General References
### https://www.geeksforgeeks.org/python-word-embedding-using-word2vec/
### http://man.hubwiz.com/docset/gensim.docset/Contents/Resources/Documents/radimrehurek.com/gensim/install.html
### https://www.datacamp.com/community/tutorials/discovering-hidden-topics-python
### https://swatimeena989.medium.com/training-word2vec-using-gensim-14433890e8e4
### https://towardsdatascience.com/a-beginners-guide-to-word-embedding-with-gensim-word2vec-model-5970fa56cc92
### https://phdstatsphys.wordpress.com/2018/12/27/word2vec-how-to-train-and-update-it/

## Prep: Go to Terminal
### sudo pip3 install nltk
### sudo pip3 install numpy
### sudo pip3 install scipy
### sudo pip3 install gensim
### sudo pip3 install python-Levenshtein
### sudo pip3 install pandas
### sudo pip3 install xlrd
### sudo pip3 install openpyxl
### sudo pip3 install -U scikit-learn

## If Reinstall Required
### Reinstall numpy or other file just delete then reinstall
### Note the -r is recursive because these functions are all folders
### sudo rm -r /Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/numpy-1.20.2-py3.9-macosx-10.9-x86_64.egg
### Can also remove: numpy_quaternion-2021.4.5.14.42.35.dist-info

## Install Certificates
### go to Macintosh HD > Applications > Python3.6 folder (or whatever version of python you're using) > double click on "Install Certificates.command"

## Install Other: From python
### nltk.download('punkt')
### nltk.download('stopwords')

## Install SK learn
### https://scikit-learn.org/stable/install.html

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
from statistics import median

## More for LSA
### Gensim
import os.path
from gensim import corpora
from gensim.models import LsiModel
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
from nltk.stem.porter import PorterStemmer
from gensim.models.coherencemodel import CoherenceModel

### sklearn
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD

### For plotting if required
## import matplotlib.pyplot as plt

## The following resource was used to direct further analysis
## https://www.datacamp.com/community/tutorials/discovering-hidden-topics-python

# Create functions
## For loading excel files
def load_excel(path,file_name):
    """
    Bring in an excel file
    """
    return pd.read_excel(os.path.join(path, file_name), index_col=0)

## For taking word units like paragraphs or sentences into word tokens
def process_tokens(input_text_units, target_column='sentences'):
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
    
    for i in input_text_units[target_column]:
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

## For taking word units like paragraphs or sentences into word tokens without frills
def reprocess_tokens(input_text_units, target_column='sentences'):
    """
    make just simple token lists
    """
    
    ## Tokenize
    processed_tokens = []
    
    for i in input_text_units[target_column]:
        ### clean and tokenize document string
        ### lower case attribute required for stemmer
        raw = i.lower()

        ### tokenizer
        tokens = word_tokenize(raw)
        
        ### put the tokens together
        ##linked_tokens = [i for i in tokens]
        
        ### add tokens to list
        processed_tokens.append(tokens)

    return processed_tokens

## detokenize for sklearn
### https://towardsdatascience.com/latent-semantic-analysis-deduce-the-hidden-topic-from-the-document-f360e8c0614b
### https://scikit-learn.org/
def detokenize_for_sk(input_tokens):
    """
    takes the tokens back to mutated sentences
    """
    detokenized_text = []
    for i in range(len(input_tokens)):
        t = ' '.join(input_tokens[i])
        detokenized_text.append(t)
    return detokenized_text

## Create A Document Term Matrix
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

## Create Latent Semantic Analysis Models
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

## Rep Modelling
def rep_coherence(dictionaryIn,DTMIn,tokensIn, num_iter = 10000):
    """
    find the average topic selection
    """
    coherence_lists = []
    for iter_num in range(num_iter):
        print(iter_num)
        modelList, cohere = get_coherence_for_set_DTM(dictionaryIn,
                                              DTMIn,
                                              tokensIn,
                                              10)
        max_value = max(cohere)
        max_index = cohere.index(max_value)
        coherence_lists.append(max_index)
        
    return median(coherence_lists)

# SK learn
## Reference
### https://towardsdatascience.com/latent-semantic-analysis-deduce-the-hidden-topic-from-the-document-f360e8c0614b

def SVD_topic(dfInIt, numTopicsIn = 2):
    """
    return words and topics
    """
    ## Create topic vector / list
    topicHeadings = []
    for num_topics_ind in range(1, numTopicsIn + 1):
        topicHeadings.append("topic_" + str(num_topics_ind))
    
    ## Instantiate Vectorizer
    vectorizer = TfidfVectorizer(smooth_idf=True)

    ## Instantiate Single Value Decomposition Model
    svd_model_topic = TruncatedSVD(n_components=num_topics_ind, algorithm='randomized', n_iter=100, random_state=12345)
    
    vectX = vectorizer.fit_transform(dfInIt['prep_sentences'])
    lsaX = svd_model_topic.fit_transform(vectX)

    topic_encoded_df = pd.DataFrame(lsaX, columns = topicHeadings)
    topic_encoded_df["documents"] = dfInIt['prep_sentences']
    topic_encoded_df["documents_raw"] = dfInIt['sentences']
    topic_encoded_df["identifier"] = dfInIt['c_1']
    dictionary = vectorizer.get_feature_names()

    # Note the transpose
    encoding_matrix = pd.DataFrame(svd_model_topic.components_, index = topicHeadings, columns = (dictionary)).T
    encoding_matrix["word"] = dictionary

    return topic_encoded_df, encoding_matrix

# Word2Vec
def create_sg_model(sentsIn, columnFocus = 'prep_sentences', num_iter = 100):
    """
    create skip gram models to find words commonly in the vacinity
    """
    # initiate model
    ## use skip gram model as we wish to take a focal word and predict its context
    modelX = Word2Vec(min_count=1, vector_size=50, workers=cores-1, window=5, sg=1, max_vocab_size=100000)

    ## get the tokens / words
    tokIn = reprocess_tokens(sentsIn,columnFocus)

    ## build the vocabulary with the tokens
    modelX.build_vocab(tokIn, update = False)

    ## train the model
    modelX.train(tokIn,total_examples=modelX.corpus_count,epochs=num_iter)
        
    return modelX

# Suppress warnings
warnings.filterwarnings(action = 'ignore')

# General variables
## data path
data_path = "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/"

## Use multiprocessing package to find the number of cores
cores= multiprocessing.cpu_count()

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

# 1. Gensim Segment
## Segment variables
number_Iterations = 1

## First run
varInIt = c14df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml14, c14 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
c14df['prep_sentences'] = detokenize_for_sk(xOut)

## Bootstrap number of topics by recalculating coherence and taking median of bootstraps
### We add 2 because the index is returned
#### The indicies indicate the number of topic where index 0 = 2 topics, 1 = 3...
top14 = rep_coherence(dOut,DTMOut,xOut,number_Iterations) + 2

varInIt = c22df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml22, c22 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
c22df['prep_sentences'] = detokenize_for_sk(xOut)
top22 = rep_coherence(dOut,DTMOut,xOut,number_Iterations) + 2

varInIt = c30df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml30, c30 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
c30df['prep_sentences'] = detokenize_for_sk(xOut)
top30 = rep_coherence(dOut,DTMOut,xOut,number_Iterations) + 2

varInIt = c40df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml40, c40 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
c40df['prep_sentences'] = detokenize_for_sk(xOut)
top40 = rep_coherence(dOut,DTMOut,xOut,number_Iterations) + 2

varInIt = c41df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml41, c41 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
c41df['prep_sentences'] = detokenize_for_sk(xOut)
top41 = rep_coherence(dOut,DTMOut,xOut,number_Iterations) + 2

varInIt = c43df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml43, c43 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
c43df['prep_sentences'] = detokenize_for_sk(xOut)
top43 = rep_coherence(dOut,DTMOut,xOut,number_Iterations) + 2

varInIt = c45df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml45, c45 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
c45df['prep_sentences'] = detokenize_for_sk(xOut)
top45 = rep_coherence(dOut,DTMOut,xOut,number_Iterations) + 2

varInIt = c46df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml46, c46 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
c46df['prep_sentences'] = detokenize_for_sk(xOut)
top46 = rep_coherence(dOut,DTMOut,xOut,number_Iterations) + 2

varInIt = c48df
xOut = process_tokens(varInIt)
dOut,DTMOut = dictionary_DTM(xOut)
ml48, c48 = get_coherence_for_set_DTM(dOut,DTMOut,xOut,10)
c48df['prep_sentences'] = detokenize_for_sk(xOut)
top48 = rep_coherence(dOut,DTMOut,xOut,number_Iterations) + 2

# 2. SK learn Segment
## Reference
### https://towardsdatascience.com/latent-semantic-analysis-deduce-the-hidden-topic-from-the-document-f360e8c0614b

## Use single variable decomposition for the number of topics elucidated in the prior segment
te14, em14 = SVD_topic(c14df,3)
te22, em22 = SVD_topic(c22df)
te30, em30 = SVD_topic(c30df,3)
te40, em40 = SVD_topic(c40df,3)
te41, em41 = SVD_topic(c41df)
te43, em43 = SVD_topic(c43df)
te45, em45 = SVD_topic(c45df)
te46, em46 = SVD_topic(c46df)
te48, em48 = SVD_topic(c48df,3)

## Write out results
with pd.ExcelWriter(os.path.join(data_path, "wordsOut.xlsx")) as writer:
    em14.to_excel(writer, sheet_name='c_14')
    em22.to_excel(writer, sheet_name='c_22')
    em30.to_excel(writer, sheet_name='c_30')
    em40.to_excel(writer, sheet_name='c_40')
    em41.to_excel(writer, sheet_name='c_41')
    em43.to_excel(writer, sheet_name='c_43')
    em45.to_excel(writer, sheet_name='c_45')
    em46.to_excel(writer, sheet_name='c_46')
    em48.to_excel(writer, sheet_name='c_48')

with pd.ExcelWriter(os.path.join(data_path, "topicOut.xlsx")) as writer:
    te14.to_excel(writer, sheet_name='c_14')
    te22.to_excel(writer, sheet_name='c_22')
    te30.to_excel(writer, sheet_name='c_30')
    te40.to_excel(writer, sheet_name='c_40')
    te41.to_excel(writer, sheet_name='c_41')
    te43.to_excel(writer, sheet_name='c_43')
    te45.to_excel(writer, sheet_name='c_45')
    te46.to_excel(writer, sheet_name='c_46')
    te48.to_excel(writer, sheet_name='c_48')

# 2. Word2Vec Segment
## Model the topic to find synonyms
model14 = create_sg_model(c14df)
model14.wv.most_similar('work')[:10]
model14.wv.most_similar('train')[:10]
model14.wv.most_similar('tool')[:10]

model22 = create_sg_model(c22df)
model22.wv.most_similar('email')[:10]
model22.wv.most_similar('team')[:10]

model30 = create_sg_model(c30df)
model30.wv.most_similar('servic')[:10]
model30.wv.most_similar('burden')[:10]

model40 = create_sg_model(c40df)
model40.wv.most_similar('project')[:10]
model40.wv.most_similar('procur')[:10]
model40.wv.most_similar('fund')[:10]

model41 = create_sg_model(c41df)
model41.wv.most_similar('time')[:10]
model41.wv.most_similar('servic')[:10]

model43 = create_sg_model(c43df)
model43.wv.most_similar('time')[:10]
model43.wv.most_similar('respons')[:10]

model45 = create_sg_model(c45df)
model45.wv.most_similar('time')[:10]
model45.wv.most_similar('manag')[:10]

model46 = create_sg_model(c46df)
model46.wv.most_similar('home')[:10]
model46.wv.most_similar('provid')[:10]

model48 = create_sg_model(c48df)
model48.wv.most_similar('listen')[:10]
model48.wv.most_similar('feedback')[:10]
model48.wv.most_similar('client')[:10]

# note that as soon as the vocab is updated the corpus is updated
# model.build_vocab(tokenized_sents, update = False)

# Integrate into r with reticulate
## https://rstudio.github.io/reticulate/articles/r_markdown.html
