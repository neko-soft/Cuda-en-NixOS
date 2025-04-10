# Script para comprobar si CUDA funciona

import torch
import tensorflow as tf
import keras

print("")
print(keras.__version__)






print("")
print("¿Funciona CUDA para torch?")

print(torch.cuda.is_available())

print("")

print("GPUs detectadas para tensorflow:")
print(tf.config.list_physical_devices('GPU'))