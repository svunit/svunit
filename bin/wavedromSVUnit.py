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
        lastStep = False

        ofile = open(self.ofile, 'w')

        # header
        if len(self.input) > 0:
            cycles.append('task %s(%s);' % (self.name, ','.join( [ "input %s %s" % (_input['type'], _input['name']) for _input in self.input ] )))
        else:
            cycles.append('task %s();' % self.name)

        # build each clock cycle
        for i in range( 0, len(self.clk['wave']) ):
            thisCycle = ''
            if self.isWait(self.clk['wave'][i]):
                lastStep = True
                thisCycle += self.getWaitFor(i)
            else:
                if lastStep:
                    lastStep = False
                else:
                    thisCycle += self.step()

                # if a signal has a new value for this cycle, assign it
                for s in self.signal:
                    if 'input' in s:
                        if s['input']:
                            break

                    if self.isBinary(s['wave'][i]):
                        thisCycle += "\n  %s = 'h%s;" % (s['name'], s['wave'][i])
                    elif self.isValue(s['wave'][i]):
                        thisCycle += "\n  %s = %s;" % (s['name'], s['data'].pop(0))

            if thisCycle != '':
                cycles.append(thisCycle)

        # footer
        cycles.append('endtask')

        ofile.write('\n'.join(cycles))

        ofile.close()

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

    def isRangeDelay(self, wait):
        if list(wait.keys())[0] == 'delay':
            return len(wait['delay']) == 2
        else:
            return False

    def isConditionDelay(self, wait):
        return list(wait.keys())[0] == 'condition'

    def getWaitFor(self, nodeIdx):
        if self.clk['node'][nodeIdx] == '.':
            cond = [ e for e in self.edge if re.match('.->%s' % self.clk['node'][nodeIdx+1], e) ][0]
            cond = re.sub('.* ', '', cond)
            return self.step("!(%s)" % cond, 'while')
        else:
            cond = [ e for e in self.edge if re.match('.->%s' % self.clk['node'][nodeIdx+1], e) ][0]
            cond = re.sub('.* ', '', cond)
            return self.step("$urandom_range(%s)" % cond)

        

if __name__ == "__main__":
    print ("Info: Writing wavedrom output.")
    wd = WD()
