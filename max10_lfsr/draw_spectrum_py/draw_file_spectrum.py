import numpy as np
from pylab import *
from scipy import *
import os

def read_bin_file(filename):
 f=open(filename, 'rb')
 values = np.fromfile(f,dtype="int8")
 return values

def plotSpectrum(y,Fs):
 n = len(y) # length of the signal
 k = np.arange(n)
 T = n/Fs
 frq = k/T # two sides frequency range
 frq = frq[range(n//2)] # one side frequency range

 Y = fft(y)/n # fft computing and normalization
 Y = Y[range(n//2)]
 
 plot(frq,abs(Y),'r') # plotting the spectrum
 xlabel('Freq (Hz)')
 ylabel('|Y(freq)|')

Fs=1024.0
#y = read_bin_file("samples_imp.bin")
#y = read_bin_file("samples_saw.bin")
#y = read_bin_file("samples_sin.bin")
y = read_bin_file("samples_rnd.bin")
t = np.arange(0,len(y),1) # time vector

subplot(2,1,1)
plot(t,y)
xlabel('Time')
ylabel('Amplitude')
subplot(2,1,2)
plotSpectrum(y,Fs)
show()
