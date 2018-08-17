# Redirecting stdout
# @rochacbruno
# Aug 17 - 2018
"""
In python there are some functions
which `prints` its output to stdout/stderr
instead of retruning the value.
"""

# example
def my_function():
    print("hello")  # <- this string goes to stdout

# builtin examples
dir(int)  # <- prints out the members of class `int` to stdout
help(int)  # <- prints out the docstring of `int` to stdout

"""
Problem: We want to capture and store the value of those functions
"""

# wring attemp

help_of_int = help(int)  # <-- Will be None as the help does not retuns

"""
Solution: Redirect the stdout output to a file like object
"""

import contextlib, io

with open('output.txt', 'w') as f:  #  can use io.BytesIO in place of file
    with contextlib.redirect_stderr(f):
        help(int)
        dir(int)
        my_function()

my_output = open('output.txt').read()

print(my_output)

# caveats: Each call inside context manager will overwrite the values of the file

