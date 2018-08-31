from contextlib import contextmanager
# Python 3.7 introduces surpress
# from contextlib import suppress
# with suppress(FileNotFoundError):
#   os.remove('somefile.tmp')

class CtxManagerClass(object):

    def __init__(self, msg):
        print('__init__()')
        self.msg = msg

    def __enter__(self):
        print('__enter__()')
        return self.msg
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        print('__exit__()')


@contextmanager
def ctx_manager_decor(msg):
    print('Equivalent to __init__()')
    try:
        yield msg
    except Exception:
        print('Treating exception')
    finally:
        print('Equivalent to __exit__()')

with CtxManagerClass('Content Class') as ctx:
    print('Inside class context manager.')

with ctx_manager_decor('Context decorator') as ctx_deco:
    print('Inside decorator context manager.')