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


# In[13]:


data = pd.read_csv(src_dir+"iter_0001/sub_sample_Result_1.csv")


# In[ ]:


errors = []
table = data[["Regions", "Modality"]]
for i in range(1,513):
	try:
	    csv_file = os.path.join(src_dir + sys.argv[1], 'sub_sample_Result_'+str(i)+'.csv')
	    df = pd.read_csv(csv_file)
	    
	    df.rename(columns={'p_Group': 'p_Group_'+str(i), 'p_SDB': 'p_SDB_'+str(i), 'p_inter': 'p_inter_'+str(i), 'F_Group': 'F_Group_'+str(i), 
	    'F_SDB': 'F_SDB_'+str(i), 'F_inter': 'F_inter_'+str(i), 'F_total': 'F_total_'+str(i),
		            'ES_Group': 'ES_Group'+str(i),
		            'ES_SDB': 'ES_SDB'+str(i),
		            'ES_inter': 'ES_inter'+str(i)}, inplace=True)
	    table = pd.concat([table, table.merge(right=df, how='left', on=['Regions', 'Modality'])[['p_Group_'+str(i),'p_SDB_'+str(i),'p_inter_'+str(i),'F_Group_'+str(i),'F_SDB_'+str(i),  'F_inter_'+str(i),'F_total_'+str(i), 'ES_Group'+str(i),'ES_SDB'+str(i), 'ES_inter'+str(i)]]], axis=1)
		  

	except:
	    errors.append(csv_file)

target = target_dir+sys.argv[1]
os.makedirs(target, exist_ok=True)
table.to_csv(target+"/All_in_one.csv", index = False)


# In[ ]:


with open(target_dir+"errors.txt", 'w') as f:
    for s in errors:
        f.write(str(s) + '\n')

print("first step finished successfully")
print("please run 'Null-Model3.py' to do remain analysis")

