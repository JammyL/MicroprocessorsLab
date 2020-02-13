import matplotlib
matplotlib.use('Tkagg')
import matplotlib.pyplot as plt
import numpy as np

t, V = np.loadtxt('angle_pulse/0DEGS.CSV', unpack = True, skiprows = 1, delimiter = ',')

plt.plot(t, V)
plt.show()

