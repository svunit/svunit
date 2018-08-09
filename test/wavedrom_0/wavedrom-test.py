import unittest

import os
import sys
sys.path.append(os.environ['SVUNIT_INSTALL'] + "/bin")
from wavedromSVUnit import WD

import re

class BaseTest (unittest.TestCase):
    def setUp(self):
        self.wd = WD()
        self.wd.process()

    def tearDown(self):
        pass

class ParseTests (BaseTest):
    def testJSONFind(self):
        assert len([ wd for wd in self.wd.methods if re.match('.*\.json', wd.ifile) ]) > 0
        assert len([ wd for wd in self.wd.methods if not re.match('.*\.json', wd.ifile) ]) == 0
        

if __name__ == "__main__":
    unittest.main()
