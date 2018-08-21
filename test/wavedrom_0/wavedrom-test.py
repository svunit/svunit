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
    numOutputs = 99

    def fileAsArray(self, f):
        return [ l for l in f.read().split('\n') if l != '' ]

    def setUp(self):
        super().setUp()

        # figure out how many gold files there are
        self.numOutputs = len([ f for f in os.listdir('.') if re.match('.*\.gold$', f) ])

    def testIncludeFileCreated(self):
        assert os.path.isfile('wavedrom.svh')

        self.ofile = open('wavedrom.svh', 'r')
        includes = self.fileAsArray(self.ofile)
        includes.sort()
        self.ofile.close()

        actuals = [ '`include "task%d.svh"' % i for i in range (0, self.numOutputs) ]
        actuals.sort()

        assert includes == actuals

    def testGoldenTests(self):
        for i in range(0, self.numOutputs):
            with self.subTest(i = i):
                tf = open('task%0d.svh' % i, 'r')
                tfStr = self.fileAsArray(tf)
                tf.close()

                tg = open('task%0d.gold' % i, 'r')
                tfGold = self.fileAsArray(tg)
                tg.close()

                assert tfStr == tfGold
        

if __name__ == "__main__":
    unittest.main()
