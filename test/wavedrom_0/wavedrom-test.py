import unittest

import os
import sys
sys.path.append(os.environ['SVUNIT_INSTALL'] + "/bin")
from wavedromSVUnit import WD

import re

class BaseTest (unittest.TestCase):
    ofile = ''

    def getWD(self, name):
        _wd = [ wd for wd in self.wd.method if re.match(name, wd.name) ]
        return _wd[0]

    def getWave(self, name, signal):
        try:
            _signal = [ _signal for _signal in self.getWD(name).signal if re.match(signal, _signal['name']) ]
            return _signal[0]['wave']
        except IndexError:
            return None

    def getSignal(self, name):
        return [ wd for wd in self.wd.method if re.match(name, wd.name) ][0]

    def setUp(self):
        if os.path.isfile('wavedrom.svh'):
            os.remove('wavedrom.svh')
        self.wd = WD()

    def tearDown(self):
        pass

class ParseTests (BaseTest):
    def testJSONOnly(self):
        assert len([ wd for wd in self.wd.method if re.match('.*\.json$', wd.ifile) ]) > 0
        assert len([ wd for wd in self.wd.method if not re.match('.*\.json$', wd.ifile) ]) == 0

    def testTaskNameFromJSON(self):
        # wavedrom0 has name: 'task0'
        assert self.getWD('task0') != None

    def testGetSignalWave(self):
        # wavedrom1 has name: 'task1'
        assert len(self.getWave('task1', 'psel')) == 2
        assert self.getWave('task1', 'psel') == '01'

    def testGetClock(self):
        assert self.getWD('task1').clk['name'] == 'clk'

    def testClockNotASignal(self):
        assert self.getWave('task1', 'clk') == None

class OutputTests (BaseTest):
    tf = None

    def fileAsArray(self, f):
        return [ l for l in f.read().split('\n') if l != '' ]

    def setUp(self):
        super().setUp()
        if os.path.isfile('wavedrom.svh'):
            self.ofile = open('wavedrom.svh', 'r')

    def tearDown(self):
        super().tearDown()
        if os.path.isfile('wavedrom.svh'):
            self.ofile.close()
        if self.tf:
            self.tf.close()

    def testIncludeFileCreated(self):
        assert self.ofile

    def testFilesIncluded(self):
        includes = self.fileAsArray(self.ofile)
        includes.sort()
        assert includes == ['`include "task0.svh"', '`include "task1.svh"']

    def testTask0(self):
        self.tf = open('task0.svh', 'r')
        tfStr = self.fileAsArray(self.tf)

        assert tfStr[0] == "task task0();"
        assert tfStr[1] == "  step();"
        assert tfStr[2] == "  nextSamplePoint();"
        assert tfStr[3] == "  step();"
        assert tfStr[4] == "  nextSamplePoint();"
        assert tfStr[5] == "endtask"

#   def testTask1(self):
#       self.tf = open('task1.svh', 'r')
#       tfStr = self.fileAsArray(self.tf)
#
#       assert tfStr[0] == "task task0();"
#       assert tfStr[1] == "  step();"
#       assert tfStr[2] == "  nextSamplePoint();"
#       assert tfStr[3] == "  psel = 0;"
#       assert tfStr[4] == "  step();"
#       assert tfStr[5] == "  nextSamplePoint();"
#       assert tfStr[6] == "  psel = 1;"
#       assert tfStr[7] == "endtask"
        

if __name__ == "__main__":
    unittest.main()
