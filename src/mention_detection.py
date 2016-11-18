# -*- coding: utf-8 -*-

from itertools import chain
import pycrfsuite
import json
import sys
import argparse
parser = argparse.ArgumentParser()

parser.add_argument('--train', default='train.f',
                                        help='training file')

args = parser.parse_args()
#print args

def gfs(category, label="true", val=1.0):
    if val == 1.0:
        return "{category}={label}"
        #return "#{category}=#{label.gsub(/\n/,'NL')}"
    else:
        return "{category}={label}:{val}"
        #return "#{category}=#{label.gsub(/\n/,'NL')}:#{val}"
        #return "#{category}=#{label.gsub(/\n/,'NL')}:#{val}"

class MDFeatureExtractor:
    def __init__(self):
        pass
    def do(self, mecab, i):
        word = mecab[i][0]
        print word
        postag = mecab[i][1][0]
        features = [
            'bias',
            gfs('word', word)#,
            #gfs('word[-2]', word[-2]),
            #gfs('word[-3]', word[-3])
        ]
        if i > 0:
            word = mecab[i-1][0]
            features.extend([
                gfs('-1word', word)#,
               # gfs('-1word[-2]', word[-2]),
               # gfs('-1word[-3]', word[-3])
            ])
        else:
            features.append('BOS')

        if i < len(mecab)-1:
            word = mecab[i+1][0]
            features.extend([
                gfs('+1word', word)#,
               # gfs('+1word[-2]', word[-2]),
               # gfs('+1word[-3]', word[-3])
            ])
        else:
            features.append('EOS')
        return features

class MentionDetector:
    def __init__(self, model_filename = None):
        self.fe = MDFeatureExtractor()
        self.model = None
        if model_filename:
            self.model = pycrfsuite.Tagger()
            self.model.open(model_filename)
        pass
    
    def word2features(self, token):
        #self.fe.do(xseq, i)
        print token[0]
        #return [token[0]]

    def sent2features(self, xseq):
        #return [self.word2features(x) for x in xseq]
        return [self.fe.do(xseq, i) for i, x in enumerate(xseq)]
        
    #def sent2labels(yseq):
    #    return [word2]

    def generate_training_data(X_sentences, Y_labels):
        pass
        
    def train(self, X_sentences, Y_labels, model_filename = 'md.model'):
        
        trainer = pycrfsuite.Trainer(verbose=False)
        X_train = [sent2features(x) for x in X_sentences]
        Y_train = [sent2labels(y) for y in Y_labels]
        for xseq, yseq in zip(X_train, Y_train):
            trainer.append(xseq, yseq)

        trainer.set_params({
            'c1': 1.0,   # coefficient for L1 penalty
            'c2': 1e-3,  # coefficient for L2 penalty
            'max_iterations': 50,  # stop earlier
            # include transitions that are possible, but not observed
            'feature.possible_transitions': True
        })
        trainer.train(modelfilename)
    
    def _parse(self, xseq):
        yseq = self.model.parse(xseq)
        return yseq

    def parse(self, obj):
        YY = []
        for sentence in obj['mecab']:
            X = self.sent2features(sentence)
            #X = sent2features(x) for x in sentence]
            Y = self._parse(X)
            YY.append(Y)

    def detect_mention(doc):
        pass
        #y = 

def mecab_flatten(node):
    ret = []
    while node:
        ret.append((node.surface, node.feature.split(",")))
        node = node.next
    return ret
    
if __name__ == '__main__':
    from sentence_splitter import SentenceSplitter
    sys.path = ["/home/matsuda/virtualenv-15.0.1/jawikify/local/lib/python2.7/site-packages"] + sys.path
    #print sys.path
    import MeCab
    ma = MeCab.Tagger("")
    #print ma
    splitter = SentenceSplitter()
    tagger   = MentionDetector()
    for line in sys.stdin:
        o = json.loads(line)
        o['mecab'] = []
        texts = splitter.split(o['text'])
        for sentence in texts:
            #print sentence
            mecab  = ma.parseToNode(str(sentence))
            #print str(mecab_flatten(mecab)).decode("string-escape")
            o['mecab'].append(mecab_flatten(mecab))
            #mecab  = ma.parse(sentence)
            result = tagger.parse(o)
    
