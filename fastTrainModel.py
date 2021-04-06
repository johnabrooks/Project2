# https://www.geeksforgeeks.org/python-word-embedding-using-word2vec/
# http://man.hubwiz.com/docset/gensim.docset/Contents/Resources/Documents/radimrehurek.com/gensim/install.html

# Prep: Go to Terminal
## sudo pip3 install nltk
## sudo pip3 install numpy
## sudo pip3 install scipy
## sudo pip3 install gensim
## sudo pip3 install python-Levenshtein

## Suggested but unsucessful
### sudo easy_install-3.9 numpy
### sudo easy_install-3.9 scipy
### sudo easy_install-3.9 --upgrade gensim ... doesn't work

## Reinstall numpy or other file just delete then reinstall
## Note the -r is recursive because these functions are all folders
## sudo rm -r /Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/numpy-1.20.2-py3.9-macosx-10.9-x86_64.egg
## Can also remove: numpy_quaternion-2021.4.5.14.42.35.dist-info

# Python program to generate word vectors using Word2Vec
  
# importing all necessary modules
from nltk.tokenize import sent_tokenize, word_tokenize
import warnings
  
warnings.filterwarnings(action = 'ignore')
  
import gensim
from gensim.models import Word2Vec
from gensim.test.utils import common_texts

# Begin training
# https://radimrehurek.com/gensim/models/word2vec.html
model = Word2Vec(sentences=common_texts, vector_size=100, window=5, min_count=1, workers=4)
model.save("word2vec.model")

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
  

