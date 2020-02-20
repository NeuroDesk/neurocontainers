#!/usr/bin/env python
__author__ = 'mo466'

import warnings
import sys, subprocess
warnings.filterwarnings("always")
warnings.simplefilter(action='ignore', category=FutureWarning)
warnings.simplefilter(action='ignore', category=RuntimeWarning)
warnings.simplefilter(action='ignore', category=ImportWarning)
warnings.simplefilter(action='ignore', category=DeprecationWarning)

import nibabel as nib

# USAGE:   ./align_vasc_to_denoised.py PC_vasculature_thresholded.nii.gz PC_denoised.nii.gz PC_vasc_thresh_aligned.nii.gz
def main():
   
   print('+-+- Running ' + sys.argv[0]) 
   in_str = sys.argv[1]
   master_str = sys.argv[2]
   out_str = sys.argv[3]
   
   print('+-+- Running AFNI 3dresample')
   subprocess.call("3dresample -overwrite -master " + master_str + " -input " + in_str + " -prefix temp.nii.gz", shell=True)

   print('+-+- Converting header of ' + sys.argv[1] + " to " + sys.argv[2] + ' and saved as ' + sys.argv[3])

   in_img = nib.load('temp.nii.gz')
   master_img = nib.load(master_str)

   out_img = nib.Nifti1Image(in_img.get_data(), master_img.affine, header=master_img.header)
   out_img.to_filename(out_str)
   subprocess.call("rm temp.nii.gz", shell=True)

if __name__ == '__main__':
   main()
   
   
   

