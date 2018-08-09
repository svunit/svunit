import unittest

import os
import sys
sys.path.append(os.environ['SVUNIT_INSTALL'] + "/bin")
from wavedromSVUnit import WD

import re

class BaseTest (unittest.TestCase):
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
        self.wd = WD()
        self.wd.process()

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
        assert len(self.getWave('task1', 'psel')) == 2
        assert self.getWave('task1', 'psel') == '01'

    def testGetClock(self):
        assert self.getWD('task1').clk['name'] == 'clk'

    def testClockNotASignal(self):
        assert self.getWave('task1', 'clk') == None
        

if __name__ == "__main__":
    unittest.main()
