import re
import json
from os import listdir

class WD:
    def __init__(self):
        self.method = []

    def process(self):
        self.method = [ WDMethod(f) for f in listdir('.') if re.match('^[a-zA-Z_].*\.json$', f) ]
        

class WDMethod:
    def __init__(self, ifile):
        self.ifile = ifile
        self.name = ''
        self.clk = ''
        self.signal = []
        self.rawData = {}
        self.process()

    def process(self):
        with open(self.ifile) as _input:
            self.rawData = json.load(_input)

        self.name = self.rawData['name']
        self.clk = [ clk for clk in self.rawData['signal'] if re.match('p', clk['wave']) ][0]
        self.signal = [ signal for signal in self.rawData['signal'] if not re.match('p', signal['wave']) ]
