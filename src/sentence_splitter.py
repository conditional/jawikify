# -*- coding: utf-8 -*-

import re

class SentenceSplitter:
    def __init__(self):
        pass
    def split(self, text):
        return re.split('。', text)

#for line = gets.
