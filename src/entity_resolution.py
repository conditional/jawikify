import json
import sys

class CandidateGeneration:
    def __init__():
        pass
    def lookup(mention):
        return db[mention]

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
        pass

class CandidateFeatureExtractor:
    def __init__():
        pass
    def do(candidate):
        pass

class EntityResolution:
    def __init__():
        self.cg     = CandidateGeneration()
        self.ranker = Ranker()
        self.context_fe    = ContextFeatureExtractor()
        self.candidate_fe  = CandidateFeatureExtractor()
        pass

    def parse(self, doc):
        for mention in doc['mentions']:
            context_f = context_fe.do(doc, mention.position)
            for candidate in self.cg.lookup(mention.surface):
                candidate_f = candidate_fe.do(candidate)
                score = self.ranker.predict(candidate, context)
        pass

    
if __name__ == '__main__':
    tagger = EntityResolution()
    for line in sys.stdin:
        o = json.loads(line)
        ret = tagger.parse(o)
        
