from __future__ import print_function

# TODO Avoid wildcard imports
from numpy import *
import os

import numpy as np
import pyximport;
pyximport.install(setup_args={'include_dirs': np.get_include()})

from qsm_tgv_cython_helper import *

import progressbar


def qsm_tgv(laplace_phi0, mask, res, alpha=(0.2, 0.1), iterations=1000, vis=False, verbose=False):
    """
    Performs the actual actual tgv QSM calulation

    :param laplace_phi0: Laplace filtered phase
    :param mask: Mask of the support
    :param res: Resolution (3 scalars)
    :param alpha: Regularisation parameters (2 scalars)
    :param iterations: number of iterations to perform
    :param vis: plot intermediate results
    :param verbose: print status information
    :return:
    """

    # Ugly handling of matplotlib - defer import for faster responsiveness on CLI and only use
    if vis:
        # Avoid errors if matplotlib is missing - e.g. on "headless" cluster
        try:
            warnings.filterwarnings("ignore", module="matplotlib")
            import matplotlib.pyplot as mpl
            __MPL_AVAIL = True
        except ImportError:
            __MPL_AVAIL = False
    else:
        __MPL_AVAIL = False

    if vis and not __MPL_AVAIL:
        print('Matplotlib not available! No intermediate results will be shown!', file=sys.stderr)

    laplace_phi0 = require(laplace_phi0, float32, 'C')
    mask = require(mask != 0, float32, 'C')
    dtype = laplace_phi0.dtype

    # erode mask -- This is performed in addition to erosion already performed in the main file
    mask0 = zeros_like(mask)
    erode_mask(mask0, mask)
    #mask0 = mask
    #erode_mask(mask0, mask)

    # get shapes
    phi_shape = laplace_phi0.shape
    grad_phi_shape = list(phi_shape)
    grad_phi_shape.append(3)
    hess_phi_shape = list(phi_shape)
    hess_phi_shape.append(6)

    # initialize primal variables
    chi = zeros(phi_shape, dtype=dtype, order='C')
    chi_ = zeros(phi_shape, dtype=dtype, order='C')

    w = zeros(grad_phi_shape, dtype=dtype, order='C')
    w_ = zeros(grad_phi_shape, dtype=dtype, order='C')

    phi = zeros(phi_shape, dtype=dtype, order='C')
    phi_ = zeros(phi_shape, dtype=dtype, order='C')

    # initialize dual variables
    eta = zeros(phi_shape, dtype=dtype, order='C')
    p = zeros(grad_phi_shape, dtype=dtype, order='C')
    q = zeros(hess_phi_shape, dtype=dtype, order='C')

    # estimate squared norm
    grad_norm_sqr = 4.0*(sum(1.0/(res**2)))
    
    #wave_norm_sqr = (1.0/3.0*(1.0/(res[0]**2 + res[1]**2)) \
    #                 + 2.0/3.0*(1.0/res[2]**2))**2
    #norm_sqr = 0.5*(wave_norm_sqr + 2*grad_norm_sqr +
                     #sqrt((wave_norm_sqr - 1)**2 + 4*grad_norm_sqr)
                     #+ 1) #TODO
    norm_sqr = 2.0 * grad_norm_sqr**2 + 1

    # set regularization parameters
    alpha1 = float32(alpha[1])
    alpha0 = float32(alpha[0])

    # initialize resolution
    res0 = float32(abs(res[0]))
    res1 = float32(abs(res[1]))
    res2 = float32(abs(res[2]))

    k = 0
    if verbose:
        print("Starting QSM reconstruction...", file=sys.stderr)
    
    while k < iterations:

        progressbar.update_progress(float(k)/float(iterations))

        if verbose:
            print("Iteration %d" % k, file=sys.stderr)


        tau = float32(1.0/sqrt(norm_sqr))
        sigma = float32((1.0/norm_sqr)/tau)

        #############
        # dual update

        if verbose:
            print("updating eta...", file=sys.stderr)
        tgv_update_eta(eta, phi_, chi_, laplace_phi0,
                       mask0, sigma, res0, res1, res2)

        if verbose:
            print("updating p...", file=sys.stderr)
        tgv_update_p(p, chi_, w_, mask, mask0, sigma, alpha1,
                     res0, res1, res2)

        if verbose:
            print("updating q...", file=sys.stderr)
        tgv_update_q(q, w_, mask0, sigma, alpha0, res0, res1, res2)

        #######################
        # swap primal variables

        (phi_, phi) = (phi, phi_)
        (chi_, chi) = (chi, chi_)
        (w_  , w  ) = (w  , w_  )

        ###############
        # primal update

        if verbose:
            print("updating phi...", file=sys.stderr)
        tgv_update_phi(phi, phi_, eta, mask, mask0, tau,
                       res0, res1, res2)

        if verbose:
            print("updating chi...", file=sys.stderr)
        tgv_update_chi(chi, chi_, eta, p, mask0, tau,
                       res0, res1, res2)

        if verbose:
            print("updating w...", file=sys.stderr)
        tgv_update_w(w, w_, p, q, mask, mask0, tau, res0, res1, res2)

        ######################
        # extragradient update

        if verbose:
            print("updating chi_, w_...", file=sys.stderr)

        extragradient_update(phi_.ravel(), phi.ravel())
        extragradient_update(chi_.ravel(), chi.ravel())
        extragradient_update(w_.ravel(), w.ravel())

        if (__MPL_AVAIL and vis and (k % 10 == 0)):
            mpl.ion()
            mpl.figure(1)
            mpl.clf()
            mpl.imshow(chi[:, :, chi.shape[2] / 2], cmap=mpl.cm.gray, vmin=-pi, vmax=pi)
            mpl.draw()
            mpl.figure(2)
            mpl.clf()
            mpl.imshow(phi[:, :, phi.shape[2] / 2], cmap=mpl.cm.gray, vmin=-pi, vmax=pi)
            mpl.draw()
            mpl.ioff()

        k += 1

    progressbar.update_progress(1)

    return chi
