# This file is used to check dependencies

import argparse
import numpy as np
import re
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
import tensorflow as tf

from minionn import minionn_model
# from resnet import resnet32_model
from tensorflow.keras.datasets import cifar10, cifar100
from tensorflow.keras.utils import get_custom_objects
from os import path

import argparse
import numpy as np
import os
import sys
import pickle
import errno
import itertools
import random
# import resnet32_model
from os import path


from tensorflow.keras.models import Model
from tensorflow.keras.utils import get_custom_objects
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.layers import Activation
from tensorflow.keras.callbacks import LearningRateScheduler, Callback
from tensorflow.keras import backend as K

print("All python dependencies installed!")
