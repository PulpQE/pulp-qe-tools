""""Pynds 2018-09-28

Bruno Rocha
Single Dispatching
Requires: Python3.6+
"""
from functools import singledispatch


@singledispatch
def fun(arg):
    print(f"default impl for {arg}")


@fun.register(int)
def _(arg):
    print(f"the impl for int {arg}")


@fun.register(float)
def _(arg):
    print(f"the impl for float {arg}")


fun("Hello")
fun(42)
fun(42.5)


class PackageError(Exception):
    ...


class PackageManager:
    def __init__(self, name):
        self.name = name

    def raise_error(self, name):
        raise PackageError(
            f"Cannot install {name} because {self.name}"
            " is not a supported package manager"
        )

    def _dnf_install(self, name):
        print(f"install {name} using dnf")

    def _yum_install(self, name):
        print(f"install {name} using YUM")

    def install(self, name):
        getattr(self, f"_{self.name}_install", self.raise_error)(name)


# Uniform API for Package manager

dnf = PackageManager("dnf")
dnf.install("ansible")

dnf = PackageManager("yum")
dnf.install("ansible")

dnf = PackageManager("apt")
dnf.install("ansible")  # should raise PackageError
