#!/usr/bin/env python
# coding: utf-8

# Date: June 2022
# Author: Mohammad Akradi
# In[2]:


import numpy as np
import pandas as pd
import os


# In[3]:


src_dir = "/home/mtahmasian/final_subsamples/SDB/sub_samples_results/"
target_dir = "/home/mtahmasian/final_subsamples/SDB/Null_model_Results/"

files = os.listdir(src_dir)


# In[4]:


iterations = []
for item in files:
    if item.find('iter') != -1:
        iterations.append(item)


# In[13]:


data = pd.read_csv(src_dir + iterations[0]+"/sub_sample_Result_1.csv")


# In[ ]:


errors = []
for j, iteration in enumerate(iterations):
    table = data[["Regions", "Modality"]]
    for i in range(1,513):
        try:
            csv_file = os.path.join(src_dir + iteration, 'sub_sample_Result_'+str(i)+'.csv')
            df = pd.read_csv(csv_file)
            
            df.rename(columns={'p_Group': 'p_Group_'+str(i), 'p_SDB': 'p_SDB_'+str(i), 'p_inter': 'p_inter_'+str(i), 'F_Group': 'F_Group_'+str(i), 
            'F_SDB': 'F_SDB_'+str(i), 'F_inter': 'F_inter_'+str(i), 'F_total': 'F_total_'+str(i),
                            'ES_Group': 'ES_Group'+str(i),
                            'ES_SDB': 'ES_SDB'+str(i),
                            'ES_inter': 'ES_inter'+str(i)}, inplace=True)
            table = pd.concat([table, table.merge(right=df, how='left', on=['Regions', 'Modality'])[['p_Group_'+str(i),'p_SDB_'+str(i),'p_inter_'+str(i),'F_Group_'+str(i),'F_SDB_'+str(i),  'F_inter_'+str(i),'F_total_'+str(i), 'ES_Group'+str(i),'ES_SDB'+str(i), 'ES_inter'+str(i)]]], axis=1)
                  
            print('\x1bc')
            prc = ((i+j*512)/512000)*100
            print("First step of analysis started ==========================")
            print("%.2f"%prc,"%")
            
        except:
            errors.append(csv_file)
    target = target_dir+iteration
    os.makedirs(target, exist_ok=True)
    table.to_csv(target+"/All_in_one.csv", index = False)


# In[ ]:


print("first step finished successfully")
with open(target_dir+"errors.txt", 'w') as f:
    for s in errors:
        f.write(str(s) + '\n')
print("Second step of analysis started ==========================")


# In[34]:


table_inter = data[["Regions", "Modality"]]
table_SDB = data[["Regions", "Modality"]]
table_BSinter = data[["Regions", "Modality"]]
table_BSSDB = data[["Regions", "Modality"]]
iters = os.listdir(target_dir)
for j, iteration in enumerate(iters):
    print(iteration)
    df = pd.read_csv(os.path.join(target_dir, iteration)+"/All_in_one.csv")
    
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

table_inter.to_csv(target_dir+"ES_inter_1000.csv")
table_SDB.to_csv(target_dir+"ES_SDB_1000.csv")

table_BSinter.to_csv(target_dir+"BSES_inter_1000.csv")
table_BSSDB.to_csv(target_dir+"BSES_SDB_1000.csv")

