library(devtools)
library(httr)
library(tm)
library(wordVectors)
library(rword2vec)
library(magrittr)
library(word2vec)
library(R.utils)

install.packages("reticulate")
library(reticulate)

py_install('pandas')
py_install('numpy')
py_install('bs4', pip=T)
py_install('regex', pip = T)
py_install('nltk')
py_install('gensim')
py_install('lxml')

# https://rpubs.com/rohanksingh/572839

model = read.word2vec("word2vecModel.bin")
