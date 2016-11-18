import json
import sys

from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
from kyotocabinet import DB 

class CandidateGeneration:
    def __init__(filename):
        self.db = kyotocabinet.
        pass
    def lookup(self, mention):
        return db[mention]

class TfIDFVector:
    def __init__():
        
    def do(document):
        document

class Ranker:
    def __init__(model):
        pass
    def predict(self, candidate, context):
        features = candidate + context
        self.model.predict(features)
        pass
    
    def train(examples, modelfilename):
        pass

class ContextFeatureExtractor:
    def __init__():
        pass
    
    def do(doc, position):
        return {
            bow: 
        }
        pass

class CandidateFeatureExtractor:
    def __init__():
        pass
    def do(candidate):
        pass

class PairedFeatureExtractor:
    def __init__():
        pass
    def do(mention, entity):
        pass

class EntityResolution:
    def __init__():
        self.cg     = CandidateGeneration()
        self.ranker = Ranker()
        self.context_fe    = ContextFeatureExtractor()
        self.candidate_fe  = CandidateFeatureExtractor()
        pass
    
    def nil_detection(self, doc, mention):
        self.cg.lookup(mention.surface)
        
    def parse(self, doc):
        er_results = doc['er_results']
        for mention in er_results['mentions']:
            context_f = context_fe.do(doc, mention.position)
            # FIXME: スコアを配列に入れる
            for candidate in self.cg.lookup(mention.surface):
                candidate_f = candidate_fe.do(candidate)
                score = self.ranker.predict(candidate_f, context_f)
            mention.entity = argmax(score)
        return doc

    
if __name__ == '__main__':
    tagger = EntityResolution()
    for line in sys.stdin:
        o = json.loads(line)
        ret = tagger.parse(o)
        
