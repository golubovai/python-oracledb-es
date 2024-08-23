import os
import unittest

import test_env

if __name__ == "__main__":
    loader = unittest.TestLoader()
    path = os.path.dirname(os.path.abspath(__file__))
    tests = loader.discover(path, top_level_dir=path)
    testRunner = test_env.TimeLoggingTestRunner(verbosity=2)
    testRunner.run(tests)