%matplotlib inline
import matplotlib.pyplot as plt
import numpy as np


1 + 1

for i in range(1,10):
    print(i)


xs = np.linspace(0,10)
ys = [x**2 for x in xs]
plt.plot(xs, ys)
