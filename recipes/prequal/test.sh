#!/bin/bash


# Test library dependencies
echo "Testing library dependencies..."
ldd $(which cmake) | grep -E "ssl|pthread|crypto|rhash"
ldd $(which antsRegistration) | grep -E "pthread|gomp"
ldd $(which mrview) | grep -E "Qt5|GL|pthread"

# Test CMake functionality and features
echo "Testing CMake features..."
cmake --version
cmake -E capabilities | grep -E "SSL|RHASH"

# Test Qt installation and MRtrix3 compilation
which qmake
which moc
which rcc
qmake --version
mrinfo --version
mrconvert -version

# Test CMake SSL support
cmake --version
cmake -E capabilities | grep "SSL"

# Test ANTs parallel processing
cd /tmp
antsRegistration --version
ImageMath 3 test.nii.gz noise 10x10x10 1
time OMP_NUM_THREADS=4 antsRegistration -d 3 \
  --transform Rigid[0.1] \
  --metric MI[test.nii.gz,test.nii.gz,1,32] \
  --convergence [100x50,1e-6,5] \
  --shrink-factors 2x1 \
  --smoothing-sigmas 1x0 \
  --use-histogram-matching 1 \
  -n 4
rm test.nii.gz

# Test FFTW support in MRtrix3
mrview -help 2>&1 | grep "GL"
mrdegibbs -info
dwifslpreproc -help | grep "Options"

# Test basic MRtrix3 functionality
mrinfo --help | grep "Options"
dwi2tensor --help | grep "Options"

# Test OpenMP functionality with virtual display
mkdir -p testdata
cd testdata
mrcalc 10 -ones 64 64 64 -mult testimg.mif
# This should use multiple threads if OpenMP is working
time OMP_NUM_THREADS=4 mrdegibbs -nthreads 4 testimg.mif denoised.mif
cd ..
rm -rf testdata

# Test visualization tools with virtual display
mrview -exit && echo "mrview test successful" || echo "mrview test failed"

# Test FSL and other tools needed by PreQual
flirt -version
c3d --version
antsRegistration --version

# Test Python environments
source /APPS/synb0/pytorch/bin/activate
python -c "import torch; print('PyTorch environment test passed')"
deactivate

source /CODE/dtiQA_v7/venv/bin/activate
python -c "
import numpy
import nibabel
print('dtiQA environment test passed')
"
deactivate

source /APPS/gradtensor/gradvenv/bin/activate
python -c "
import numpy
from scilpy.io.utils import assert_inputs_exist
print('Scilpy environment test passed')
"
deactivate

# Cleanup virtual framebuffer
kill %1