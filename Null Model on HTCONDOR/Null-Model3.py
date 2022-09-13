#!/usr/bin/env python
# coding: utf-8

# Date: July 2022
# Author: Mohammad Akradi
# In[2]:


import numpy as np
import pandas as pd
import os
import sys


# In[3]:


src_dir = "/home/mtahmasian/final_subsamples/SDB/sub_samples_results/"
target_dir = "/home/mtahmasian/final_subsamples/SDB/Null_model_Results/"

output_dir = os.path.join(target_dir, "output")
os.makedirs(output_dir, exist_ok=True)
# In[13]:


data = pd.read_csv(src_dir+"iter_0001/sub_sample_Result_1.csv")


print("Second step of analysis started ==========================")


# In[34]:


table_inter = data[["Regions", "Modality"]]
table_SDB = data[["Regions", "Modality"]]
table_BSinter = data[["Regions", "Modality"]]
table_BSSDB = data[["Regions", "Modality"]]

df = pd.read_csv(os.path.join(target_dir, sys.argv[1])+"/All_in_one.csv")
    
feats = df.columns
new_feats = list(feats[feats.str.find("ES_inter")>=0])
identifiers = ['Modality', 'Regions']
for identifier in identifiers:
        new_feats.insert(0, identifier)
df_ES_inter = df[new_feats]
df_ES_inter["ES_inter_mean"] = np.mean(df_ES_inter.iloc[:,2:], axis=1)
    
for i, reg in enumerate(df_ES_inter["Regions"]):
        bs_data = df_ES_inter.iloc[i, 2:-1]
        boot_means = []
        for _ in range(10000):
            boot_sample = np.random.choice(bs_data,replace = True, size = bs_data.shape[0]) # take a random sample each iteration
            boot_mean = np.mean(boot_sample)# calculate the mean for each iteration
            boot_means.append(boot_mean) # append the mean to boot_means
        boot_means_np = np.array(boot_means) # transform it into a numpy array for calculation
        df_ES_inter.loc[i, "BS_mean"] = np.mean(boot_means_np)
    
new_feats = list(feats[feats.str.find("ES_SDB")>=0])
for identifier in identifiers:
        new_feats.insert(0, identifier)
df_ES_SDB = df[new_feats]
df_ES_SDB["ES_SDB_mean"] = np.mean(df_ES_SDB.iloc[:,2:], axis=1)
    
for i, reg in enumerate(df_ES_SDB["Regions"]):
        bs_data = df_ES_SDB.iloc[i, 2:-1]
        boot_means = []
        for _ in range(10000):
            boot_sample = np.random.choice(bs_data,replace = True, size = bs_data.shape[0]) # take a random sample each iteration
            boot_mean = np.mean(boot_sample)# calculate the mean for each iteration
            boot_means.append(boot_mean) # append the mean to boot_means
        boot_means_np = np.array(boot_means) # transform it into a numpy array for calculation
        df_ES_SDB.loc[i, "BS_mean"] = np.mean(boot_means_np)
        
table_inter["ES_inter_mean_"+str(j+1)] = df_ES_inter["ES_inter_mean"]
table_SDB["ES_SDB_mean_"+str(j+1)] = df_ES_SDB["ES_SDB_mean"]
    
table_BSinter["BS_mean_"+str(j+1)] = df_ES_inter["BS_mean"]
table_BSSDB["BS_mean_"+str(j+1)] = df_ES_SDB["BS_mean"]

table_inter.to_csv(output_dir+"/"+sys.agv[1]+"_ES_inter_1000.csv")
table_SDB.to_csv(output_dir+"/"+sys.agv[1]+"_ES_SDB_1000.csv")

table_BSinter.to_csv(output_dir+"/"+sys.agv[1]+"_BSES_inter_1000.csv")
table_BSSDB.to_csv(output_dir+"/"+sys.agv[1]+"_BSES_SDB_1000.csv")

