
# coding: utf-8

# In[95]:


import matplotlib.pyplot as plt
import numpy as np


# In[96]:


n = 100
save_string = 'angle_pulse/{}DEGS.CSV'.format(n)


# In[97]:


t, V = np.loadtxt(save_string, unpack = True, skiprows = 1, delimiter = ',')
print(t[1] - t[0])


# In[98]:


t_low = []
V_low = []
t_high = []
V_high = []
for i in range(len(V)):
    if(V[i] < 3):
        t_low.append(t[i])
        V_low.append(V[i])
    else:
        t_high.append(t[i])
        V_high.append(V[i])
        
high_length = []
        
for i in range(1, len(t_low)):
    gap = t_low[i] - t_low[i-1]
    if gap > 0.0001:
        high_length.append(gap)
    
high_mean = np.mean(high_length)


# In[99]:


expectation = ((2.5 + (10 * n/180)) /100) * 20 * (10**(-3))
print(high_mean, expectation, high_mean - expectation)


# In[108]:


t_base, V_base = np.loadtxt('angle_pulse/BASE.CSV', unpack = True, skiprows = 1, delimiter = ',')
print(t_base[1] - t_base[0])


# In[109]:


plt.plot(t_base, V_base)


# In[111]:


t_base_low = []
V_base_low = []
t_base_high = []
V_base_high = []
for i in range(len(V_base)):
    if(V_base[i] < 3):
        t_base_low.append(t_base[i])
        V_base_low.append(V_base[i])
    else:
        t_base_high.append(t_base[i])
        V_base_high.append(V_base[i])
        
        
high_base_length = []
        
for i in range(1, len(t_base_low)):
    gap_base = t_base_low[i] - t_base_low[i-1]
    if gap_base > 0.00001:
        high_base_length.append(gap_base)
    
high_base_mean = np.mean(high_base_length)
print(high_base_length)


# In[112]:


expectation_base = ((1/18)/100) * 20 * (10**(-3))
print(high_base_mean, expectation_base, high_base_mean - expectation_base)

