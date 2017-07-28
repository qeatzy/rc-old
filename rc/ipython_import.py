from __future__ import (absolute_import, division, print_function, unicode_literals)
import collections, os, sys, types
from collections import Counter
from functools import partial

import numpy as np
# import pandas as pd
# import matplotlib as mpl;
# mpl.use('nbagg')
# %matplotlib inline    # `%matplotlib` to restore
# import matplotlib.pyplot as plt;
# import pandas as pd; DataFrame = pd.DataFrame; Series = pd.Series;

# tmp, ploting related
# %matplotlib inline    # TODO fix it, not work [TerminalIPythonApp] WARNING | Unknown error in handling IPythonApp.exec_files:

# tmp hacks
# g = lambda s: {k:v for k,v in mpl.rcParams.items() if s in k}

# !ln -s %:p ~/.ipython/profile_default/startup
