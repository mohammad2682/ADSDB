# Date: April, 2022
# Author: Mohammad Akradi

from enigmatoolbox.utils.parcellation import parcel_to_surface
from enigmatoolbox.plotting import plot_cortical, plot_subcortical 
from enigmatoolbox.datasets import load_fsa5, load_summary_stats
import numpy as np
import pandas as pd

brain_reg = input("Visualize Cortex or Subcortex? ")
modality = input("Visualize Which Modality? (AB, FDG, VBM, Overlap)")
#measure = input("What's your measurement? (default: ES_inter_mean)")

sum_stats = load_summary_stats('epilepsy')
SV = sum_stats['SubVol_case_vs_controls_ltle']


def Visualize(brain_reg = "Cortex", modality = "VBM", measure="BS_mean"):
    if modality == "AB":
        modality = "Aβ"
    df = pd.read_csv("July2022_Results/Vis_Data_29July.csv")
    df = df[(df["Modality"]==modality)].reset_index(drop=True)
    #df[measure][df["Regions"]<0.04] = 0
    cmp = "Oranges"
    if modality == "FDG":
        cmp = "Greens"
    elif modality == "Aβ":
        cmp = "Purples"
    elif modality == "Overlap":
        cmp = "PuRd"
    
    if brain_reg == "Subcortex":
        df = df[df["Networks"]=="SUBCORTEX"]
        subcort = SV[['Structure']]
        #sub_grp_vbm = df_grp[["Regions", "Significancy"]].iloc[300:314,:]
        df_new = subcort.copy()
        df_new[measure] = np.nan
        for sname in subcort['Structure']:
            for sname2 in df['Regions']:
                if sname[1:] in sname2:
                    if (sname[:1] == "L") and (sname2[:1]=="L"):
                        df_new[measure][df_new["Structure"]==sname] = df[df['Regions']==sname2][measure].values[0]
                    elif (sname[:1] == "R") and (sname2[:1]=="R"):
                        df_new[measure][df_new["Structure"]==sname] = df[df['Regions']==sname2][measure].values[0]
        print("Visualizing Subcorticals of", modality)
        plot_subcortical(array_name=df_new[measure], size=(800, 400),
                 cmap=cmp, color_bar=True, color_range=(0.03, 0.07))
    else:
        df = df[df["Networks"]!="SUBCORTEX"]
        print("Visualizing Corticals of", modality)
        CT_d_fsa5 = parcel_to_surface(df[measure].reset_index(drop=True), 'schaefer_100_fsa5')
        
        # Project the results on the surface brain
        plot_cortical(array_name=CT_d_fsa5, surface_name="fsa5", size=(800, 400),
                      cmap=cmp, color_bar=True, color_range=(0.03, 0.07))
        
Visualize(brain_reg=brain_reg, modality=modality)
