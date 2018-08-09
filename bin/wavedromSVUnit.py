import re
import json
from os import listdir

class WD:
    def __init__(self):
        self.method = []
        self.parse()
        self.writeOutput()

    def parse(self):
        self.method = [ WDMethod(f) for f in listdir('.') if re.match('^[a-zA-Z_].*\.json$', f) ]

    def writeOutput(self):
        wavedromSVH = open('wavedrom.svh', 'w')

        for m in self.method:
            wavedromSVH.write('`include "%s"\n' % m.ofile)
            m.writeOutput()

        wavedromSVH.close()
        

class WDMethod:
    def __init__(self, ifile):
        self.ifile = ifile
        self.name = ''
        self.clk = ''
        self.signal = []
        self.rawData = {}
        self.parse()

    def parse(self):
        with open(self.ifile) as _input:
            self.rawData = json.load(_input)

        self.name = self.rawData['name']
        self.ofile = self.name + '.svh'

        # clk is anything that matches 'p' in the wave (but only 1 is valid hence the [0])
        self.clk = [ clk for clk in self.rawData['signal'] if re.match('p', clk['wave']) ][0]

        # signals are anything that don't match 'p' in the wave
        self.signal = [ signal for signal in self.rawData['signal'] if not re.match('p', signal['wave']) ]

    def writeOutput(self):
        cycles = []

        ofile = open(self.ofile, 'w')

        # header
        cycles.append('task %s();' % self.name)

        # build each clock cycle
        for i in range( 0, len(self.clk['wave']) ):
            thisCycle = '  step();\n  nextSamplePoint();'

            # if a signal has a new value for this cycle, assign it
            for s in self.signal:
                if self.isBinary(s['wave'][i]):
                    thisCycle += "\n  %s = %s;" % (s['name'], s['wave'][i])

            cycles.append(thisCycle)

        # footer
        cycles.append('endtask')

        ofile.write('\n'.join(cycles))

        ofile.close()

    def isBinary(self, value):
        return value in [ "0", "1" ]
