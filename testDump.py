# https://www.geeksforgeeks.org/python-word-embedding-using-word2vec/
# http://man.hubwiz.com/docset/gensim.docset/Contents/Resources/Documents/radimrehurek.com/gensim/install.html
# https://www.datacamp.com/community/tutorials/discovering-hidden-topics-python
# https://swatimeena989.medium.com/training-word2vec-using-gensim-14433890e8e4
# https://towardsdatascience.com/a-beginners-guide-to-word-embedding-with-gensim-word2vec-model-5970fa56cc92
# https://phdstatsphys.wordpress.com/2018/12/27/word2vec-how-to-train-and-update-it/

# Prep: Go to Terminal
## sudo pip3 install nltk
## sudo pip3 install numpy
## sudo pip3 install scipy
## sudo pip3 install gensim
## sudo pip3 install python-Levenshtein
## sudo pip3 install pandas
## sudo pip3 install xlrd
## sudo pip3 install openpyxl

## Suggested but unsucessful
### sudo easy_install-3.9 numpy
### sudo easy_install-3.9 scipy
### sudo easy_install-3.9 --upgrade gensim ... doesn't work

## Reinstall numpy or other file just delete then reinstall
## Note the -r is recursive because these functions are all folders
## sudo rm -r /Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/numpy-1.20.2-py3.9-macosx-10.9-x86_64.egg
## Can also remove: numpy_quaternion-2021.4.5.14.42.35.dist-info

## Install Certificates
## go to Macintosh HD > Applications > Python3.6 folder (or whatever version of python you're using) > double click on "Install Certificates.command"
## nltk.download('punkt')

## Example read in
### https://www.datacamp.com/community/tutorials/pandas-read-csv
import pandas as pd
dataIn = "/Users/johnbrooks/Dropbox/My Mac (Johns-MacBook-Pro-3.local)/Downloads/data.csv"
df = pd.read_csv(dataIn)
df.head()
df['Maker_Model']= df['Make']+ " " + df['Model']

# filter the matrix
df1 = df[['Engine Fuel Type','Transmission Type','Driven_Wheels','Market Category','Vehicle Size', 'Vehicle Style', 'Maker_Model']]

# Combine all columns - every reow is a document
df2 = df1.apply(lambda x: ','.join(x.astype(str)), axis=1)

# Creates a data frame with clean as the column header from a matrix df2
df_clean = pd.DataFrame({'clean': df2})

# Create a concatenation of rows divided by a comma
sent = [row.split(',') for row in df_clean['clean']]

# Show first 2 entries
sent[:2]

# Other tools to add different data sets
## Add: model.build_vocab(inp,update=True)
## Reinitialize: model.build_vocab(inp_data)

# Example
# from gensim.models import Word2Vec
# old_sentences = [["bad","robots"],["good","human"]]
# new_sentences = [['yes', 'this', 'is', 'the', 'word2vec', 'model']\
# ,[ 'if',"you","have","think","about","it"]]
# old_model = Word2Vec(old_sentences,size = 10, window=5, min_count = 1, workers = 2)
# old_model.wv.vocab
# old_model.save("old_model")
# new_model = Word2Vec.load("old_model")
# new_model.build_vocab(new_sentences, update = True)
# new_model.train(new_sentences, total_examples=2, epochs = 1)
# new_model.wv.vocab

# Train
## Use multiprocessing package
cores= multiprocessing.cpu_count()
# in one go: model = Word2Vec(sent, min_count=1, vector_size=50, workers=cores-1, window =3, sg = 1, max_vocab_size=100000)
# Otherwise start with an empty model and populate
model = Word2Vec(min_count=1, vector_size=50, workers=cores-1, window =3, sg = 1, max_vocab_size=100000)

# note that as soon as the vocab is updated the corpus is updated
model.build_vocab(sent, update = False)

# Note the following are the same
# len(sent)
# model.corpus_count
# We train "total_examples" the number of sentences that are now going in
model.train(sent,total_examples=model.corpus_count,epochs=1)

pd.DataFrame(c14df)
sent = [row.split(',') for row in c14df['sentences']]

######
# Read in our data
c14df = pd.read_excel("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/c_14.xlsx", index_col=0) 
c22df = pd.read_excel("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/c_22.xlsx", index_col=0)
c30df = pd.read_excel("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/c_30.xlsx", index_col=0)
c40df = pd.read_excel("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/c_40.xlsx", index_col=0)
c41df = pd.read_excel("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/c_41.xlsx", index_col=0)
c43df = pd.read_excel("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/c_43.xlsx", index_col=0)
c45df = pd.read_excel("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/c_45.xlsx", index_col=0)
c46df = pd.read_excel("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/c_46.xlsx", index_col=0)
c48df = pd.read_excel("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/c_48.xlsx", index_col=0)
df = pd.read_csv(dataIn)


# Creates a data frame with clean as the column header from a matrix df2
df_clean = pd.DataFrame({'clean': c14df})

# Create a concatenation of rows divided by a comma
sent = [row.split(',') for row in df_clean['clean']]

# Create a concatenation of rows divided by a comma
sent = [row.split(',') for row in c14df['sentences']]





# Create functions
def load_data(path,file_name):
    """
    Input  : path and file_name
    Purpose: loading text file
    Output : list of paragraphs/documents and
             title(initial 100 words considred as title of document)
    """
    documents_list = []
    titles=[]
    with open( os.path.join(path, file_name) ,"r") as fin:
        for line in fin.readlines():
            text = line.strip()
            documents_list.append(text)
    print("Total Number of Documents:",len(documents_list))
    titles.append( text[0:min(len(text),100)] )
    return documents_list,titles

def preprocess_data(doc_set):
    """
    Input  : docuemnt list
    Purpose: preprocess text (tokenize, removing stopwords, and stemming)
    Output : preprocessed text
    """
    # initialize regex tokenizer
    tokenizer = RegexpTokenizer(r'\w+')
    # create English stop words list
    en_stop = set(stopwords.words('english'))
    # Create p_stemmer of class PorterStemmer
    p_stemmer = PorterStemmer()
    # list for tokenized documents in loop
    texts = []
    # loop through document list
    for i in doc_set:
        # clean and tokenize document string
        raw = i.lower()
        tokens = tokenizer.tokenize(raw)
        # remove stop words from tokens
        stopped_tokens = [i for i in tokens if not i in en_stop]
        # stem tokens
        stemmed_tokens = [p_stemmer.stem(i) for i in stopped_tokens]
        # add tokens to list
        texts.append(stemmed_tokens)
    return texts

def prepare_corpus(doc_clean):
    """
    Input  : clean document
    Purpose: create term dictionary of our courpus and Converting list of documents (corpus) into Document Term Matrix
    Output : term dictionary and Document Term Matrix
    """
    # Creating the term dictionary of our courpus, where every unique term is assigned an index. dictionary = corpora.Dictionary(doc_clean)
    dictionary = corpora.Dictionary(doc_clean)
    # Converting list of documents (corpus) into Document Term Matrix using dictionary prepared above.
    doc_term_matrix = [dictionary.doc2bow(doc) for doc in doc_clean]
    # generate LDA model
    return dictionary,doc_term_matrix

def create_gensim_lsa_model(doc_clean,number_of_topics,words):
    """
    Input  : clean document, number of topics and number of words associated with each topic
    Purpose: create LSA model using gensim
    Output : return LSA model
    """
    dictionary,doc_term_matrix=prepare_corpus(doc_clean)
    # generate LSA model
    lsamodel = LsiModel(doc_term_matrix, num_topics=number_of_topics, id2word = dictionary)  # train model
    print(lsamodel.print_topics(num_topics=number_of_topics, num_words=words))
    return lsamodel

def compute_coherence_values(dictionary, doc_term_matrix, doc_clean, stop, start=2, step=3):
    """
    Input   : dictionary : Gensim dictionary
              corpus : Gensim corpus
              texts : List of input texts
              stop : Max num of topics
    purpose : Compute c_v coherence for various number of topics
    Output  : model_list : List of LSA topic models
              coherence_values : Coherence values corresponding to the LDA model with respective number of topics
    """
    coherence_values = []
    model_list = []
    for num_topics in range(start, stop, step):
        # generate LSA model
        model = LsiModel(doc_term_matrix, num_topics=number_of_topics, id2word = dictionary)  # train model
        model_list.append(model)
        coherencemodel = CoherenceModel(model=model, texts=doc_clean, dictionary=dictionary, coherence='c_v')
        coherence_values.append(coherencemodel.get_coherence())
    return model_list, coherence_values

def plot_graph(doc_clean,start, stop, step):
    dictionary,doc_term_matrix=prepare_corpus(doc_clean)
    model_list, coherence_values = compute_coherence_values(dictionary, doc_term_matrix,doc_clean,
                                                            stop, start, step)
    # Show graph
    x = range(start, stop, step)
    plt.plot(x, coherence_values)
    plt.xlabel("Number of Topics")
    plt.ylabel("Coherence score")
    plt.legend(("coherence_values"), loc='best')
    plt.show()

start,stop,step=2,12,1
plot_graph(clean_text,start,stop,step)

# LSA Model
number_of_topics=7
words=10
document_list,titles=load_data("","articles.txt")
clean_text=preprocess_data(document_list)
model=create_gensim_lsa_model(clean_text,number_of_topics,words)
    







# Python program to generate word vectors using Word2Vec
  
# importing all necessary modules
import nltk
from nltk.tokenize import sent_tokenize, word_tokenize
import warnings
  
warnings.filterwarnings(action = 'ignore')
  
import gensim
from gensim.models import Word2Vec, KeyedVectors
from gensim.test.utils import common_texts

# Other
from nltk.corpus import stopwords
from gensim.test.utils import datapath
import re
import unicodedata
from tqdm import tqdm
import multiprocessing
import random
import xlrd
import openpyxl

# Model Location
basicModel = "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/project2basic.emb"
bias1model = "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/project2bias1.emb"
bias2model = "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/project2bias2.emb"

# Vectors Location
bias1vectr = "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/project2bias1.bin"
bias2vectr = "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/project2bias2.bin"

# Load Google Example
## gFile = "/Users/johnbrooks/Desktop/Course Work/STAT5702/Assignment-4/GoogleNews-vectors-negative300.bin"
## googleWords = KeyedVectors.load_word2vec_format(gFile, binary=True)
## googleWords.vectors.shape[0]
## del googleWords

# Begin training
## Read: https://radimrehurek.com/gensim/models/word2vec.html
model = Word2Vec(sentences=common_texts, vector_size=100, window=5, min_count=1, workers=4)

## Save the full model
model.save("word2vec.model")

# Save/Load a binary/"Projection" file
model.wv.save_word2vec_format("word2vecModel.bin", fvocab=None, binary=True)
wv_from_bin = KeyedVectors.load_word2vec_format("word2vecModel.bin", binary=True)
googleWords = KeyedVectors.load_word2vec_format(gFile, binary=True)
gFile

# Equivalent to
## word_vectors = model.wv
## word_vectors.save_word2vec_format("word2vecModel.bin", fvocab=None, binary=True)

# https://radimrehurek.com/gensim/models/keyedvectors.html
# Note that keyedVectors can save as a bin file but loose the information necessary to train future files
# This vector for words projection without the hidden layers is what the r word2vec banks
# This is why we can not progress the training of the 

# Now getting another model

# Loading a prior model
model = Word2Vec.load('pretrained_model.emb')

# Add in the vocabulary from the new set
model.build_vocab(new_sentences, update=True)

# Continue with training
model.train(new_sentences)




# Other available data

#  Reads ‘alice.txt’ file
sample = open("/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/cra1.txt", "r")
s = sample.read()
  
# Replaces escape character with space
f = s.replace("\n", " ")
  
data = []
  
# iterate through each sentence in the file
for i in sent_tokenize(f):
    temp = []
      
    # tokenize the sentence into words
    for j in word_tokenize(i):
        temp.append(j.lower())
  
    data.append(temp)
  
# Create CBOW model
model1 = gensim.models.Word2Vec(data, min_count = 1, 
                              size = 100, window = 5)
  
# Print results
print("Cosine similarity between 'alice' " + 
               "and 'wonderland' - CBOW : ",
    model1.similarity('alice', 'wonderland'))
      
print("Cosine similarity between 'alice' " +
                 "and 'machines' - CBOW : ",
      model1.similarity('alice', 'machines'))
  
# Create Skip Gram model
model2 = gensim.models.Word2Vec(data, min_count = 1, size = 100,
                                             window = 5, sg = 1)
  
# Print results
print("Cosine similarity between 'alice' " +
          "and 'wonderland' - Skip Gram : ",
    model2.similarity('alice', 'wonderland'))
      
print("Cosine similarity between 'alice' " +
            "and 'machines' - Skip Gram : ",
      model2.similarity('alice', 'machines'))
