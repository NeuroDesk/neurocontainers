#!/usr/env python
"""
QSM reconstrcution using Total Generalized Variation (TGV-QSM)
Kristian Bredies and Christian Langkammer
June 2014 www.neuroimaging.at

Modification DB, DZNE Bonn

"""
from __future__ import division, print_function

import argparse
import sys

import nibabel as nib
import numpy as np

import resample
from .qsm_tgv_cython import *

def _aff_is_diag(aff):
    ''' Utility function returning True if affine is nearly diagonal '''
    rzs_aff = aff[:3, :3]
    return np.allclose(rzs_aff, np.diag(np.diag(rzs_aff)))

def dyp(u, step=1.0):
    """Returns forward differences of a 2D/3D array with respect to x."""
    if (u.ndim == 3):
        return concatenate((u[:,1:,:] - u[:,0:-1,:], \
                            zeros([u.shape[0],1,u.shape[2]], u.dtype)), 1)/step
    else:
        return hstack((u[:,1:]-u[:,0:-1],zeros([u.shape[0],1],u.dtype)))/step

def dym(u, step=1.0):
    """Return backward differences of a 2D/3D array with respect to x."""
    if (u.ndim == 3):
        return (concatenate((u[:,:-1,:],zeros([u.shape[0],1,u.shape[2]], u.dtype)), 1) \
               - concatenate((zeros([u.shape[0],1,u.shape[2]], u.dtype), u[:,:-1,:]), 1))/step
    else:
        return (hstack((u[:,:-1],zeros([u.shape[0],1],u.dtype))) \
               - hstack((zeros([u.shape[0],1],u.dtype),u[:,:-1])))/step

def dxp(u, step=1.0):
    """Returns forward differences of a 2D/3D array with respect to y."""
    if (u.ndim == 3):
        return concatenate((u[1:,:,:] - u[0:-1,:,:], \
                            zeros([1,u.shape[1],u.shape[2]], u.dtype)), 0)/step
    else:
        return vstack((u[1:,:]-u[0:-1,:],zeros([1,u.shape[1]],u.dtype)))/step

def dxm(u, step=1.0):
    """Return backward differences of a 2D/3D array with respect to y."""
    if (u.ndim == 3):
        return (concatenate((u[:-1,:,:],zeros([1,u.shape[1],u.shape[2]], u.dtype)), 0) \
               - concatenate((zeros([1,u.shape[1],u.shape[2]], u.dtype), u[:-1,:,:]), 0))/step
    else:
        return (vstack((u[:-1,:],zeros([1,u.shape[1]],u.dtype))) \
               - vstack((zeros([1,u.shape[1]],u.dtype),u[:-1,:])))/step

def dzp(u, step=1.0):
    """Returns forward differences of a 3D array with respect to z."""
    return concatenate((u[:,:,1:] - u[:,:,0:-1], \
                        zeros([u.shape[0],u.shape[1],1], u.dtype)), 2)/step

def dzm(u, step=1.0):
    """Return backward differences of a 3D array with respect to z."""
    return (concatenate((u[:,:,:-1],zeros([u.shape[0],u.shape[1],1], u.dtype)), 2) \
           - concatenate((zeros([u.shape[0],u.shape[1],1], u.dtype),u[:,:,:-1]), 2))/step


def read_magnitude_image(fname, force_diag=True, do_resampling=True, is_mask_image=True):
    """Returns image data and resolution for a given file

    fname : file name of data to load"""

    mag_data = nib.as_closest_canonical(nib.load(fname))

    if force_diag:
        if not do_resampling:
            if not _aff_is_diag(mag_data.affine):
                raise nib.orientations.OrientationError
        elif do_resampling:
            interp_type = 0 if is_mask_image else "continous"
            print('Resampling magnitude/mask data...', file=sys.stderr)
            mag_data = resample.resample_to_physical(mag_data, interpolation=interp_type)

    data = array(mag_data.get_data())
    aff = mag_data.affine
    res = diag(aff)[0:3]

    return data, res, aff


# TODO Very ugly method - refactor if there is time
def read_phase_image(fname, mode=0, force_diag=True, do_resampling=True):
    """Returns image data and resolution for a given file

    fname : file name of data to load
    mode: 0 or 1 - if 0 will rescale phase data from -4096.4096 to -pi...pi
    force_diag: Make sure data affine is diagonal afterwards. Implies dim[2] aligned with field z-axis
    do_resampling: if data was oblique will apply resampling by spline interpolation
    """

    pha_data = nib.as_closest_canonical(nib.load(fname))

    if mode == 0:
        print('Rescaling phase data...', file=sys.stderr)
        data = pha_data.get_data()
        data = array(data)/4096.0*pi
        pha_data = resample.new_img_like(pha_data, data)

    if force_diag:
        if not do_resampling:
            if not _aff_is_diag(pha_data.affine):
                raise nib.orientations.OrientationError
        elif do_resampling:
            print('Resampling phase data...', file=sys.stderr)
            cplx_nii = resample.phase_as_cplx(pha_data)
            cplx_nii_res = resample.resample_to_physical(cplx_nii)
            pha_data = resample.cplx_to_phase(cplx_nii_res)

            # if not resample:

            # else:
            #    pha_data,_,_ = read_phase_image(fname, mode=mode, force_diag=False)
            #    cplx_nii = resample.phase_as_cplx(pha_data)
            #    cplx_nii_res = resample.resample_to_physical(cplx_nii)
            #    pha_nii_res = resample.cplx_to_phase(cplx_nii_res)
            #    return pha_nii_res.get_data(), pha_nii_res.header.get_zooms()[0:3], pha_nii_res.affine
    
    aff = pha_data.affine
    res = diag(aff)[0:3]
    data = pha_data.get_data()

    return data, res, aff


def make_nifti(data, res=None, aff=None, description=""):
    affine = eye(4)
    if res is not None:
        for i in xrange(3):
            affine[i, i] = res[i]
            affine[i, 3] = -0.5 * (res[i] * (data.shape[i] - 1))
    elif aff is not None:
        affine = aff

    img = nib.Nifti1Image(data, affine)
    img.header["descrip"] = description
    return img


def save_nifti(fname, data, res=None, aff=None, description=""):
    img = make_nifti(data, res=res, aff=aff, description=description)
    img.to_filename(fname)


def get_grad_phase(phase, res):
    phi = exp(1.0j*phase)
    dx = imag(dxp(phi, res[0])/phi)
    dy = imag(dyp(phi, res[1])/phi)
    dz = imag(dzp(phi, res[2])/phi)
    grad_phase = concatenate((dx[...,newaxis], dy[...,newaxis],
                              dz[...,newaxis]), axis=-1)
    return grad_phase


def get_laplace_phase(phase, res):
    grad_phi = get_grad_phase(phase, res)
    laplace_phi = dxm(grad_phi[...,0], res[0]) \
                  + dym(grad_phi[...,1], res[1]) \
                  + dzm(grad_phi[...,2], res[2])

    return laplace_phi


def get_laplace_phase2(phase, res):
    phi = exp(1.0j*phase)
    laplace_phi = dxm(dxp(phi, res[0]), res[0]) + \
                  dym(dyp(phi, res[1]), res[1]) + \
                  dzm(dzp(phi, res[2]), res[2])
    laplace_phi = imag(laplace_phi / phi)

    return laplace_phi


def get_best_local_h1(dx, axis=0):
    F_shape = list(dx.shape)
    F_shape[axis] -= 1
    F_shape.append(9)

    F = zeros(F_shape, dtype=dx.dtype)
    for i in xrange(3):
        for j in xrange(3):
            if (axis == 0):
                F[...,i+3*j] = (dx[:-1,...] - 2*pi*(i-1))**2 + (dx[1:,...] + 2*pi*(j-1))**2
            if (axis == 1):
                F[...,i+3*j] = (dx[:,:-1,...] - 2*pi*(i-1))**2 + (dx[:,1:,...] + 2*pi*(j-1))**2
            if (axis == 2):
                F[...,i+3*j] = (dx[:,:,:-1,...] - 2*pi*(i-1))**2 + (dx[:,:,1:,...] + 2*pi*(j-1))**2

    G = F.argmin(axis=-1)
    I = (G  % 3) - 1
    J = (G // 3) - 1 # True integer division here!

    return I, J


def get_laplace_phase3(phase, res):
    #pad phase
    phase = concatenate((phase[0,...][newaxis,...], phase, phase[-1,...][newaxis,...]), axis=0)
    phase = concatenate((phase[:,0,...][:,newaxis,...], phase, phase[:,-1,...][:,newaxis,...]), axis=1)
    phase = concatenate((phase[:,:,0,...][:,:,newaxis,...], phase, phase[:,:,-1,...][:,:,newaxis,...]), axis=2)

    dx = (phase[1:,1:-1,1:-1] - phase[:-1,1:-1,1:-1])
    dy = (phase[1:-1,1:,1:-1] - phase[1:-1,:-1,1:-1])
    dz = (phase[1:-1,1:-1,1:] - phase[1:-1,1:-1,:-1])

    (Ix,Jx) = get_best_local_h1(dx, axis=0)
    (Iy,Jy) = get_best_local_h1(dy, axis=1)
    (Iz,Jz) = get_best_local_h1(dz, axis=2)

    laplace_phi = (-2.0*phase[1:-1,1:-1,1:-1]
                   + (phase[:-2,1:-1,1:-1] + 2*pi*Ix)
                   + (phase[2:,1:-1,1:-1] + 2*pi*Jx))/(res[0]**2)

    laplace_phi += (-2.0*phase[1:-1,1:-1,1:-1]
                    + (phase[1:-1,:-2,1:-1] + 2*pi*Iy)
                    + (phase[1:-1,2:,1:-1] + 2*pi*Jy))/(res[1]**2)

    laplace_phi += (-2.0 *phase[1:-1,1:-1,1:-1]
                    + (phase[1:-1,1:-1,:-2] + 2*pi*Iz)
                    + (phase[1:-1, 1:-1, 2:] + 2 * pi * Jz)) / (res[2] ** 2)

    return laplace_phi


def erode_mask(mask):
    mask = (mask != 0)
    mask0 = mask.copy()
    mask[1:,...] *= mask0[:-1,...]
    mask[:-1,...] *= mask0[1:,...]
    mask[:,1:,...] *= mask0[:,:-1,...]
    mask[:,:-1,...] *= mask0[:,1:,...]
    mask[:,:,1:,...] *= mask0[:,:,:-1,...]
    mask[:, :, :-1, ...] *= mask0[:, :, 1:, ...]

    return mask


############# main #############
def main():    

    GAMMA = 42.5781

    parser = argparse.ArgumentParser(description='''TGV based QSM reconstruction by Bredies and Langkammer 2014.
                                                    Will use OpenMP multithreading if available. Can be controlled using
                                                    the environment variable OMP_NUM_THREADS.
                                                ''',
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-p','--phase'  , help='Filename of the phase data', required=True                    )
    parser.add_argument('-m','--mask'   , help='Filename of the mask data', required=True                     )
    parser.add_argument('-o', '--output_suffix',
                        help='Filename suffix of output. Will be followed by a three digit integer if several iteration are reconstructeed.'
                             '', default="_qsm_recon", required=False)


    group = parser.add_mutually_exclusive_group()
    group.add_argument(      '--alpha', help='Regularisation Parameters alpha_0, alpha_1. ', type=float, nargs=2,
                                        required=False, default=[0.0015, 0.0005]                              )

    group.add_argument(      '--factors',help='Scaling factor for default values of regularisation parameters',
                                        type=float, nargs="+", required=False, default=[1.0])

    parser.add_argument('-e', '--erosions', help='Number of mask erosions using a box kernel', default=5, type=int)
    parser.add_argument('-i','--iterations', help='Number of iterations to perform', default=[1000], type=int,
                                            nargs='+', required=False                                         )

    # Those arguments are only necessary to scale the phase data (if not alread done)
    parser.add_argument('-f','--fieldstrength', help='FieldStrength in Tesla', type=float                     )
    parser.add_argument('-t', '--echotime', help='Echo time in seconds', type=float)

    parser.add_argument('-s','--rescale-phase', action='store_true', 
                            help='Rescale phase data assumming they are in Siemens int format (-4096..4096)'  )
    parser.add_argument('--ignore-orientation', action='store_true',
                        help='Ignore any orientation checks. Use with care')
    parser.add_argument(     '--save-laplacian', action='store_true', 
                            help='Save initial laplacian of data.'                                            )
    parser.add_argument('--output-physical', action='store_true',
                        help='If set will not resample back to data space.')
    parser.add_argument('--no-resampling', action="store_true", help="Will avoid any resampling. Error messages will "
                                                                     "be emitted if data does not meet requirements")

    parser.add_argument('--vis', action='store_true',
                        help='Show intermediate results')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='More verbose output')

    
    args = parser.parse_args()

    print(" >>>>  TGV-QSM  <<<<< ", file=sys.stderr)
    print("-----------------------------------------", file=sys.stderr)
    print("loading files...", file=sys.stderr)

    outfilename = args.phase.replace(".nii.gz", "").replace(".nii", "")
    outfilename += args.output_suffix.replace(".nii.gz", "").replace(".nii", "")
    outfilename += "_{number:03d}.nii.gz"

    print("  phase: " + args.phase, file=sys.stderr)
    print("  mask:  " + args.mask, file=sys.stderr)
    print("  output: " + outfilename, file=sys.stderr)

    # Read and scale the data
    mode = 0 if args.rescale_phase else 1

    orig_affine = nib.load(args.phase).affine

    (phase, res, aff) = read_phase_image(args.phase, mode, not args.ignore_orientation,
                                         do_resampling=not args.no_resampling)
    # 1 ... for data already scaled in [-pi, pi]
    (mask, res_mask, aff_mask) = read_magnitude_image(args.mask, not args.ignore_orientation,
                                                      do_resampling=not args.no_resampling)

    phase = phase.squeeze()
    mask = mask.squeeze()
    print ("mask.shape: ", mask.shape)
    print ("phase.shape: ", mask.shape)

    # DB check for correct affine - hopefully this is a good idea! Need to add a "force" option to arguments
    if not args.ignore_orientation and not (allclose(aff, aff_mask)):
        return "Orientation and/or resolution of mask and data does not match!"

    if not (mask.shape == phase.shape):
        return "Incompatible size of mask and data images!"

    if not (phase.ndim == 3 and mask.ndim == 3):
        return "Phase and data array need to be 3D cubes!"

    # Binarise the mask
    mask = mask > 0  
    mask_orig = mask.copy()
    
    # Set scaling if not already using regressioned field map
    # This should make sure that the output is ppm!
    # TODO  CHECK CHECK CHECK
    if args.echotime and args.fieldstrength:
        scale = (2.0*pi*args.echotime)*(args.fieldstrength*GAMMA)
    else:
        scale = 1.0  # TODO DB CHECK THIS!!! hmm is this correct? Probably not!

    print("Data looks good!", file=sys.stderr)

    print("Processing initial laplacian of %s ..." % args.phase, file=sys.stderr)
    laplace_phi0 = get_laplace_phase3(phase, res)

    if args.save_laplacian:
        save_nifti(args.output_suffix.replace(".nii.gz", "").replace(".nii", "") + "_phase_laplacian.nii.gz",
                   laplace_phi0,
                   res=res)

    print("Processing QSM %s ..." % args.phase, file=sys.stderr)

    number = 0
    for fc, fac in enumerate(args.factors):
        alpha0 = args.alpha[0]*fac
        alpha1 = args.alpha[1]*fac

        print('Factor {f} ({n} of {m}) - alpha = ({a0}, {a1})'.format(f=fac, n=fc + 1, m=len(args.factors), a0=alpha0,
                                                                      a1=alpha1), file=sys.stderr)

        # Copy mask
        mask = mask_orig.copy()
        # Hmmm not so nice... additional erode within the cython code!
        for i in xrange(args.erosions):
            mask = erode_mask(mask)

        # Stupid iteration loop... will not reuse old iterations!
        for ic, iteration in enumerate(args.iterations):
            print("  Iterations: {i} ({n} of {m})".format(i=iteration, n=ic + 1, m=len(args.iterations)))

            phi = qsm_tgv(laplace_phi0, mask, res, alpha=(alpha0, alpha1), iterations=iteration, vis=args.vis,
                          verbose=args.verbose)
            chi = phi/scale # Double check the scaling!!!!!

            # outfilename = args.output.replace(".nii.gz","").replace(".nii","") \
            #              + "_QSM_fac%f_" % fac + "iter_%d.nii.gz" % iteration


            desc_string = "a0={alpha0:1.8f},a1={alpha1:1.8f},iters={iters}"

            nii = make_nifti(chi, aff=aff,
                       description=desc_string.format(alpha0=alpha0, alpha1=alpha1, iters=iteration))

            # Resample back to the orientation of the input data
            if not args.output_physical and not np.allclose(orig_affine, nii.affine):
                nii = resample.resample_to_reference(nii, nib.load(args.phase), conform=True)

            # The description does not "survive" the resampling
            nii.header['descrip'] = desc_string.format(alpha0=alpha0, alpha1=alpha1, iters=iteration)
            outname = outfilename.format(number=number)
            nii.to_filename(outname)
            print("  Saved " + outname, file=sys.stderr)
            number += 1

    print("Finished!", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())