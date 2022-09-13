#!/usr/bin/env python
# coding: utf-8

# Date: May 2022
# Author: Mohammad Akradi
# In[1]:


import pandas as pd
import numpy as np
import scipy.stats as st
from IPython.display import clear_output


# In[2]:


data = pd.read_csv('July2022_Results/ES_SDB_8July2022.csv').drop(columns="Unnamed: 0")


# In[5]:


data["BS_mean"] = np.nan
data["BS_CI_L"] = np.nan
data["BS_CI_U"] = np.nan
for i, reg in enumerate(data["Regions"]):
    bs_data = data.iloc[i, 3:515]
    boot_means = []
    for _ in range(10000):
        boot_sample = np.random.choice(bs_data,replace = True, size = bs_data.shape[0]) # take a random sample each iteration
        boot_mean = np.mean(boot_sample)# calculate the mean for each iteration
        boot_means.append(boot_mean) # append the mean to boot_means
    boot_means_np = np.array(boot_means) # transform it into a numpy array for calculation
    data.loc[i, "BS_mean"] = np.mean(boot_means_np)
    data.loc[i, "BS_CI_L"], data.loc[i, "BS_CI_U"]= st.t.interval(alpha=0.95, df=len(boot_means_np)-1, 
                                                                  loc=np.mean(boot_means_np), scale=st.sem(boot_means_np))
    
    clear_output(wait=True)
    prc = (i/data.shape[0]) * 100
    print("%.2f"%prc,"%")


# In[6]:


data.to_csv('July2022_Results/BSES_SDB_8July2022.csv', index=False)


# In[ ]:




