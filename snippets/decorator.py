from functools import update_wrapper

class cls_wrapper:

    def __init__(self, wrapped):
        self.wrapped  = wrapped
        update_wrapper(self, wrapped)

    def __call__(self, *args, **kwargs):
        print('Calling from the class decorator.')
        return self.wrapped(*args, **kwargs)


@cls_wrapper
def func(x,y):
    print('Calling from the function.')
    print(x,y)
    
func(1,2)