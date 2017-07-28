def mro(obj):
    return (obj if isinstance(obj, type) else type(obj)).__mro__
