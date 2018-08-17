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
        self.input = []
        self.edge = []
        self.edgeTypes = '[<>~\-|]+'
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

        try:
            self.input = self.rawData['input']
        except KeyError:
            pass

        try:
            self.edge = self.rawData['edge']
        except KeyError:
            pass

    def writeOutput(self):
        cycles = []

        ofile = open(self.ofile, 'w')

        # header
        if len(self.input) > 0:
            cycles.append('task %s(%s);' % (self.name, ','.join( [ "input %s %s" % (_input['type'], _input['name']) for _input in self.input ] )))
        else:
            cycles.append('task %s();' % self.name)

        # build each clock cycle
        for i in range( 0, len(self.clk['wave']) ):
            thisCycle = ''

            waitThisCycle = self.isWait(self.clk['wave'][i])
            waitLastCycle = self.isWait(self.clk['wave'][i-1])
            waitBothCycles = waitThisCycle and waitLastCycle
            waitNeitherCycle = not (waitThisCycle or waitLastCycle)

            if not (waitThisCycle or waitLastCycle):
                thisCycle += self.step()
                thisCycle += self.writeSignals(i)

            elif waitThisCycle and not waitLastCycle:
                thisCycle += self.getWaitFor(i)

            elif waitLastCycle and not waitThisCycle:
                thisCycle += self.writeSignals(i)

            elif waitLastCycle and waitThisCycle:
                thisCycle += self.writeSignals(i)
                thisCycle += self.getWaitFor(i)
 
            if thisCycle != '':
                cycles.append(thisCycle)

        # footer
        cycles.append('endtask')

        ofile.write('\n'.join(cycles))

        ofile.close()

    def writeSignals(self, idx):
        _thisCycle = ''
        # if a signal has a new value for this cycle, assign it
        for s in self.signal:
            if 'input' in s:
                if s['input']:
                    break

            if self.isBinary(s['wave'][idx]):
                _thisCycle += "\n  %s = 'h%s;" % (s['name'], s['wave'][idx])
            elif self.isValue(s['wave'][idx]):
                _thisCycle += "\n  %s = %s;" % (s['name'], s['data'].pop(0))

        return _thisCycle

    def isBinary(self, value):
        return value in [ "0", "1", "x", "X" ]

    def isValue(self, value):
        return value in [ "=" ]

    def isWait(self, value):
        return value in [ "|" ]

    def step(self, num='1', loop='repeat'):
        step = ''
        step += '%sstep();\n' % ('  ' * (1 + int(num != '1')))
        step += '%snextSamplePoint();' % ('  ' * (1 + int(num != '1')))
        if num != '1':
            step = '  %s (%s) begin\n' % (loop, num) + step + '\n  end'
        return step

    def getWaitFor(self, nodeIdx):
        cond = [ e for e in self.edge if re.match('.%s%s' % (self.edgeTypes, self.clk['node'][nodeIdx+1]), e) ][0]
        cond = re.sub('.* ', '', cond)
        if self.clk['node'][nodeIdx] == '.':
            return self.step("!(%s)" % cond, 'while')
        else:
            return self.step("$urandom_range(%s)" % cond)

        

if __name__ == "__main__":
    print ("Info: Writing wavedrom output.")
    wd = WD()
