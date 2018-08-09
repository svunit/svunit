import re
from os import listdir

class WD:
    def __init__(self):
        self.methods = []

    def process(self):
        self.methods = [ WDMethod(f) for f in listdir('.') if re.match('.*\.json', f) ]
        

class WDMethod:
    def __init__(self, ifile):
        self.ifile = ifile
        print (self.ifile)
