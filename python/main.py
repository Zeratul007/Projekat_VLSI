# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import serial as serial
import numpy as np
import scipy.signal as signal
import struct as struct
import matplotlib.pyplot as plt

IMAGE_SIZE = 256

# Uncomment for pyserial read
ser = serial.Serial('COM5', 115200)

fpgaImage = np.zeros([IMAGE_SIZE, IMAGE_SIZE])

pixelValsRaw = ser.read(int(IMAGE_SIZE*IMAGE_SIZE))
pixelVals = struct.unpack(f'<{int(IMAGE_SIZE*IMAGE_SIZE)}B', pixelValsRaw)

fpgaImage = np.reshape(np.array(pixelVals), [IMAGE_SIZE, IMAGE_SIZE])

print(fpgaImage)

plt.imshow(fpgaImage, cmap='gray', vmin=0, vmax=255)
plt.show()

swImage = plt.imread('lenaCorrupted.bmp')

plt.imshow(swImage, cmap='gray', vmin=0, vmax=255)
plt.show()

swImageDenoised = signal.medfilt2d(swImage, 3)

plt.imshow(swImageDenoised, cmap='gray', vmin=0, vmax=255)
plt.show()

