import unittest

import os
import sys
sys.path.append(os.environ['SVUNIT_INSTALL'] + "/bin")

import wavedromSVUnit

class BaseTest (unittest.TestCase):
  def setUp(self): 
    print ("the setup")

  def tearDown(self):
    print ("the teardown")

class ParseTests (BaseTest):
  def testz(self):
    print ("testz")
    assert True

if __name__ == "__main__":
    unittest.main()
