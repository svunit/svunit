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
        self.arg = []
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
            self.arg = self.rawData['arg']
        except KeyError:
            pass

    def writeOutput(self):
        cycles = []
        lastStep = False

        ofile = open(self.ofile, 'w')

        # header
        if len(self.arg) > 0:
            cycles.append('task %s(%s);' % (self.name, ','.join( [ "input %s %s" % (_arg['type'], _arg['name']) for _arg in self.arg ] )))
        else:
            cycles.append('task %s();' % self.name)

        # build each clock cycle
        for i in range( 0, len(self.clk['wave']) ):
            thisCycle = ''
            if self.isWait(self.clk['wave'][i]):
                lastStep = True
                if self.isRangeDelay(self.clk['wait'][0]):
                    bounds = self.clk['wait'].pop(0)['delay']
                    thisCycle += self.step("$urandom_range(%s,%s)" % (bounds[0], bounds[1]))
                elif self.isConditionDelay(self.clk['wait'][0]):
                    thisCycle += self.step("!(%s)" % self.clk['wait'].pop(0)['condition'], 'while')
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
