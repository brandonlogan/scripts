def rename_kwargs(**renamed_kwargs):
    """Renames a class's variables and maintains backwards compatibility.
    :param renamed_kwargs: mapping of old kwargs to new kwargs.  For example,
           to say a class has renamed variable foo to bar the decorator would
           be used like: rename_kwargs(foo='bar')
    """
    def wrap(cls):
        def __getattr__(instance, name):
            if name in renamed_kwargs:
               return getattr(instance, renamed_kwargs[name])
            return getattr(instance, name)

        def __setattr__(instance, name, value):
            if name in renamed_kwargs:
               instance.__dict__[renamed_kwargs[name]] = value
            else:
               instance.__dict__[name] = value

        def wrapped_cls(*args, **kwargs):
            for old_kwarg, new_kwarg in renamed_kwargs.items():
                if old_kwarg in kwargs:
                   kwargs[new_kwarg] = kwargs[old_kwarg]
                   del kwargs[old_kwarg]
            cls.__getattr__ = __getattr__
            cls.__setattr__ = __setattr__
            return cls(*args, **kwargs)
        return wrapped_cls
    return wrap


@rename_kwargs(a='z')
class C(object):
    def __init__(self, x, y, z=None):
        self.x = x
        self.y = y
        self.z = z


if __name__ == '__main__':
    x = C(1,2, a=3)
    print("x.a = %d" % x.a)
    print("x.z = %d" % x.z)
    print("x.x = %d" % x.x)
    print("Setting x.a = 4")
    x.a = 4
    print("x.a = %d" % x.a)
    print("x.z = %d" % x.z)
    print("x.x = %d" % x.x)
