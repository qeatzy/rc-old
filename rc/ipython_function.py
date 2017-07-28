import collections
import types
# if not isinstance(arg, types.StringTypes):
# "iterable but not string" http://stackoverflow.com/a/1055378/3625404

# "todo, see also " ls
# use pager -- vim -- to display output of expression, similar but not solved case, How to use Pipe in ipython  http://stackoverflow.com/questions/5740835/how-to-use-pipe-in-ipython

# "ls, see also " todo
# def mro(x): return (x if type(x) is type else type(x)).mro()
    # not work for torch.autograd.Variable, due to metaclass?
def mro(x): return (x if type(x) is type else type(x)).__mro__

def lmap(func, *iterables):
    return list(map(func, *iterables))

def pe(arg):    # print each item if iterable, http://stackoverflow.com/a/1952481/3625404
    # TODO if no arg, print last output
    if isinstance(arg, collections.Iterable) and not isinstance(arg, types.StringTypes):
        for x in arg:
            print(x)
    else:
        print(arg)

def mtype(arg,reduce=False):     # type of iterable of object,  mnemonic: map type of possible iterable
    if isinstance(arg, collections.Iterable) and not isinstance(arg, types.StringTypes):
        ret = [type(x) for x in arg]
        return set(ret) if reduce else ret
    else:
        return type(arg)

def mshape(arg):    # shape of iterable of numpy array-like object, eg, pandas.DataFrame
    if hasattr(arg, 'shape'):
        print(arg.shape)
    elif isinstance(arg, collections.Iterable) and not isinstance(arg, types.StringTypes):
        for x in arg:
            print(x.shape)
    else:
        raise TypeError("object has no 'shape'")

def dtypes(arg):    # print dtypes of iterable of numpy array-like object, eg, pandas.DataFrame
    if hasattr(arg, 'dtypes'):
        print(arg.dtypes)
    elif isinstance(arg, collections.Iterable) and not isinstance(arg, types.StringTypes):
        for x in arg:
            print(x.dtypes)
    else:
        raise TypeError("object has no 'dtypes'")

