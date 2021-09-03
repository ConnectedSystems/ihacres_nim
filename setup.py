
# Setup.py tutorial:
# https://github.com/navdeep-G/setup.py
# Edit `packages=` to fit your requirements

import setuptools, pathlib, sysconfig
from setuptools.command.build_ext import build_ext
import nimporter


__version__ = "0.3.1"

class NoSuffixBuilder(build_ext):
    # NO Suffix: module.linux-x86_64.cpython.3.8.5.so --> module.so
    def get_ext_filename(self, ext_name):
        filename = super().get_ext_filename(ext_name)
        return filename.replace(sysconfig.get_config_var('EXT_SUFFIX'), "") + pathlib.Path(filename).suffix

setuptools.setup(
    name="ihacres_nim",
    version=__version__,
    packages=setuptools.find_packages(),  # Please read the above tutorial
    cmdclass={"build_ext": NoSuffixBuilder},
    ext_modules=nimporter.build_nim_extensions(exclude_dirs=['docs', 'tests', 'ihacres/stream_run.nim']),  # 
    setup_requires=["choosenim_install"],
    install_requires=[
        'choosenim_install',  # Optional. Auto-installs Nim compiler
        'nimporter',  # Must depend on Nimporter
    ],
)
