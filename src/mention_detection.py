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

class MDFeatureExtractor:
    def __init__():
        pass
    def do():
    
class MentionDetector:
    def __init__():
        self.fe = MDFeatureExtractor()
        pass
    
    def word2features(token):
        return {}

    def sent2features(xseq):
        return [word2features(x) for i in xseq]

    def sent2labels(yseq):
        return [word2]

    def train(self, X_sentences, Y_labels, modelfilename):
        
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
        pass


    
    def parse(self, xseq, model):
        tagger = pycrfsuite.Tagger()
        tagger.open(model)
        yseq = tagger.parse(xseq)
        return yseq

    def detect_mention(doc):
        
    
if __name__ == '__main__':
    for line in sys.stdin:
        
