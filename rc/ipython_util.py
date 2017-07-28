from __future__ import (absolute_import, division, print_function, unicode_literals)

# "ls

# import sys
# if sys.version_info[0] == 2:
#     def ida(*args, **kwargs):
#         if 'f' in kwargs:
#             f(map(id,args))
#         else:
#             print(map(id,args))
# else:
    def ida(*args,f=print): f(*map(id,args))

# pra = lambda seq=[]: map(print,seq) and None     # pra for 'print all'
def pra(seq=[]):
    for item in seq:
        print item

mlen = lambda seqs=[]: map(len, seqs)
mtype = lambda seqs=[]: map(type, seqs)

shape = np.vectorize(lambda x: x.shape)
mshape = lambda *seq: [x.shape for x in seq]    # `mshape tr,te,tr2,te2` with autocall turn on

def info(x):
    ret = {'type': type(x)}
    if hasattr(x,"shape"):
        ret['shape'] = x.shape
    elif hasattr(x,"__iter__"):
        ret['len'] = len(x)
        if ret['len'] > 0:
            ret['type [0]'] = type(x[0])
    return ret

def checkEqual(seq):    # http://stackoverflow.com/a/10285205/3625404
    return all(seq[0]==x for x in seq)    # works even for empty list (due to lazy evaluation), which return True, but may not be your desired behavior
def checkEqual1(iterable):  # http://stackoverflow.com/a/3844832/3625404
    iterator = iter(iterable)
    try:
        first = next(iterator)
    except StopIteration:
        return True
    return all(first == rest for rest in iterator)
def checkEqual2(seq):   # http://stackoverflow.com/a/3844948/3625404
    return seq.count(seq[0]) == len(seq)    # fails on empty sequence
