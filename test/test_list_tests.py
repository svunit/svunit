import subprocess

import pytest

from utils import *


def test_list_tests_option_exists(tmp_path):
    returncode = subprocess.call(
            ['runSVUnit', '--list-tests'],
            cwd=tmp_path)
    assert returncode == 255  # XXX Fix reliance on internal implementation detail: if the script can't run, it quietly returns `255`
