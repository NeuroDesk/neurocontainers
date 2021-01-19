"""A setuptools based setup module.
See:
https://packaging.python.org/en/latest/distributing.html
https://github.com/pypa/sampleproject
"""

# Always prefer setuptools over distutils
from setuptools import setup, find_packages
# To use a consistent encoding
from codecs import open
from Cython.Build import cythonize
import os
import shutil
import tempfile
import subprocess
import numpy

here = os.path.abspath(os.path.dirname(__file__))


def make_ext(modname, pyxfilename):
    from setuptools.extension import Extension

    omp_test = \
        r"""
        #include <omp.h>
        #include <stdio.h>
        int main() {
        #pragma omp parallel
        printf("Hello from thread %d, nthreads %d\n", omp_get_thread_num(), omp_get_num_threads());
        }
        """

    def check_for_openmp():
        tmpdir = tempfile.mkdtemp()
        curdir = os.getcwd()
        os.chdir(tmpdir)

        filename = r'test.c'
        with open(filename, 'w') as file:
            file.write(omp_test)
        with open(os.devnull, 'w') as fnull:
            result = subprocess.call(['cc', '-fopenmp', filename],
                                     stdout=fnull, stderr=fnull)

        os.chdir(curdir)
        # clean up
        shutil.rmtree(tmpdir)
        # zero error code means everything was fine
        return result == 0

    extra_compile_args = ['-O3', '-march=native']
    extra_link_args = []

    if check_for_openmp():
        print("Building with OpenMP support!")
        extra_compile_args.append('-fopenmp')
        extra_link_args.append('-fopenmp')
    else:
        print("NO OpenMP support!")


    return Extension(name=modname, sources=[pyxfilename],
                     extra_compile_args=extra_compile_args,
                     extra_link_args=extra_link_args,
                     include_dirs=[numpy.get_include()],
                     )


# Get the long description from the relevant file
with open(os.path.join(here, 'DESCRIPTION.rst'), encoding='utf-8') as f:
    long_description = f.read()

# Extension
extensions = [make_ext(modname="qsm_tgv_cython_helper", pyxfilename="TGV_QSM/qsm_tgv_cython_helper.pyx")]

setup(
    name='TGV_QSM',

    version='0.1',
    description='A sample Python project',
    long_description=long_description,
    # The project's main homepage.
    # url='https://github.com/pypa/sampleproject',
    # Author details
    author='Christian Langkammer',
    author_email='christian@neuroimaging.at',
    # Choose your license
    license='',

    # What does your project relate to?
    keywords='MRI QSM TGV',

    # You can just specify the packages manually here if your project is
    # simple. Or you can use find_packages().
    packages=find_packages(),

    # List run-time dependencies here.  These will be installed by pip when
    # your project is installed. For an analysis of "install_requires" vs pip's
    # requirements files see:
    # https://packaging.python.org/en/latest/requirements.html

    # We explicitly do not list nipype as a dependency here! Should be installable without nipype
    install_requires=['numpy', 'cython', 'nibabel'],

    ext_modules = cythonize(extensions),

    entry_points={
        'console_scripts': [
            'tgv_qsm=TGV_QSM.qsm_tgv_main:main',
        ]
    }
)
