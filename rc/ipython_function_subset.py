import collections; from collections import defaultdict, Counter, OrderedDict
import types
from inspect import ismodule, isclass
from functools import partial
import re
import sys
from dis import dis

CCounter=lambda x:Counter(Counter(x).values())

def mb(op, a, b):   # map binary operator
    return [op(i,j) for i,j in zip(a,b)]

_sequence_types = (tuple,list)
if sys.version_info.major > 2:
    _sequence_types += (type({}.values()), type({}.keys()))
def mMap(f, *args):
    if not len(args) > 1:
        args = args[0]
    if isinstance(args, _sequence_types):
        return [f(x) for x in args]
    else:
        return f(args)

def mro(x): return (x if type(x) is type else type(x)).__mro__[:-1]

def mdir(obj=None, f=None, v=False):
    filter = f
    names = globals() if obj is None else {x:getattr(obj,x) for x in dir(obj)}
    if 'func' == filter:
        ret = [x for x,y in names.items() if isinstance(y, types.FunctionType)]
    elif 'call' == filter:
        ret = [x for x,y in names.items() if callable(y)]
    elif 'upper' == filter:
        ret = [x for x in names if x[0].isupper()]
    elif 'module' == filter or 'mod' == filter:
        ret = [x for x,y in names.items() if ismodule(y)]
    elif 'class' == filter or 'cls' == filter:
        ret = [x for x,y in names.items() if isclass(y)]
    elif callable(filter):
        ret = [x for x in names if filter(x)]
    elif isinstance(filter, type):
        ret = [x for x,y in names.items() if isinstance(y,filter)]
    elif isinstance(filter, str):
        pat = filter
        if pat.islower():
            filter = lambda s: re.search(pat, s, re.IGNORECASE)
        else:
            filter = lambda s: re.search(pat, s)
        ret = [x for x in names if filter(x)]
    else:
        ret = names
    ret = sorted(ret)
    return ret if not v else OrderedDict((x,names[x]) for x in ret)
md = mdir

def tl(x):  # type & length
    return  (type(x), len(x)) if hasattr(x, '__iter__') else type(x)

mcounter = partial(mMap, collections.Counter)
mshape = partial(mMap, lambda x: x.shape)
mtype = partial(mMap, type)
mlen = partial(mMap, len)

def mdtype(args,reduce=False):     # dtype of iterable of object,  mnemonic: map dtype of possible iterable
    if isinstance(args, collections.Iterable) and not isinstance(args, types.StringTypes):
        ret = [x.dtype for x in args]
        return set(ret) if reduce else ret
    else:
        return args.dtype

