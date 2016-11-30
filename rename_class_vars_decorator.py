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
    def __init__(self, x, z=None):
        self.x = x
        self.z = z


def log_reads(instance):
    print("instance.a = %d" % instance.a)
    print("instance.z = %d" % instance.z)
    print("instance.x = %d" % instance.x)

def set_attribute(instance, attribute):
    print("Setting instance.%s = 4" % attribute)
    setattr(instance, attribute, 4)

if __name__ == '__main__':
    print("Passing old parameters to class: C(1, a=3)")
    old_style = C(1, a=3)
    log_reads(old_style)
    set_attribute(old_style, 'a')
    log_reads(old_style)

    print("\nPassing new parameters to class: C(1, z=5)")
    new_style = C(1, z=5)
    log_reads(new_style)
    set_attribute(new_style, 'z')
    log_reads(new_style)
