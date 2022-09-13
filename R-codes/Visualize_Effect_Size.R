#### Visualizing Effect Size
#### Date: 6 March 2022
#### Author: Mohammad Akradi

library(ggplot2)
library(reshape2)
library(dplyr)
library(readr)
library(emmeans)
library(ggpubr)
library(ggsignif)
library(rstatix)
library(sjmisc)
library(boot)

data <- read_csv('/home/mohammad/DataScience/Thesis_AD/July2022_Results/Null_and_Normal_SDB_21July2022.csv')
#data <- read_csv('/home/mohammad/DataScience/Thesis_AD/July2022_Results/BSES_inter_8July2022.csv')
#data <- read_csv('/home/mohammad/DataScience/Thesis_AD/March2022_Results/ES_inter_6Mar2022.csv')
#data <- read_csv('/home/mohammad/DataScience/Thesis_AD/March2022_Results/ES_Group_6Mar2022.csv')

data$Modality[data$Modality=="VBM"] <- "GMV"
data$Networks[data$Networks=="Subcortical"] <- "SUBCORTEX"
data$Modality <- as.factor(data$Modality)
data$Modality <- factor(data$Modality, levels = c("Aβ", "FDG", "GMV"))

data$Networks <- as.character(data$Networks)
data$Networks <- factor(data$Networks, levels=c("FPN", "DAN", "VAN", "DMN", "LIMBIC", "SMN", "VISUAL", "SUBCORTEX"))#, "Overlap"))

data$Regions <- as.character(data$Regions)
data$Regions <- factor(data$Regions, levels=unique(data$Regions))

## Be carefull with below commands:
cols <- colnames(data)[5:ncol(data)]
cols <- cols[-c(1001,1002,1003,1004,1005,1006)]
data_melt <- melt(data, id.vars = c('Regions', 'Modality', 'Networks'), measure.vars = cols)

## pay attention that you are visualizing "Group", "SDB" or "inter"
vis <- ggplot() + 
  geom_point(data = data, aes(x = BS_mean, y = Regions, color=Modality)) + 
  #geom_boxplot(data=data_melt, aes(x = value, y = Regions), alpha=0.5,
             #  outlier.alpha = 0.05) +
  geom_violin(data=data_melt, aes(x = value, y = Regions), alpha=0.1)+
  #geom_errorbar(aes(xmin=BS_CI_L, xmax=BS_CI_U)) +
  scale_color_manual(values=c("darkorchid3", "darkgreen", "orangered3")) +
  scale_x_continuous(limits = c(0.0, 0.065)) +
  geom_vline(xintercept = 0.04, linetype=2) +
  theme( text = element_text(size = 19),
         axis.text.y = element_text(size=12),
         axis.text.x.bottom = element_text(size=12),
         axis.title.x = element_text(margin = margin(t=20, r=0, l=0, b=0))) +
  facet_grid(Networks ~ Modality, scales = "free", space = "free") +
  labs(x = "Effect Size")

vis

ggsave(file="Programs/Educational/Thesis_ADSDB/Aug2022/BSES_SDB_6Aug2022.svg", plot=vis, width=15, height=20, limitsize = FALSE)

##### Visualize overlapped regions
data <- read_csv("/home/mohammad/DataScience/Thesis_AD/July2022_Results/Overlapped_Regs.csv")

data$Modality[data$Modality=="VBM"] <- "GMV"
data$Networks[data$Networks=="Subcortical"] <- "SUBCORTEX"
data$Modality <- as.factor(data$Modality)
data$Modality <- factor(data$Modality, levels = c("Aβ", "FDG", "GMV"))

data$Networks <- as.character(data$Networks)
data$Networks <- factor(data$Networks, levels=c("FPN", "DAN", "VAN", "DMN", "LIMBIC", "SMN", "VISUAL", "SUBCORTEX"))#, "Overlap"))

data$Regions <- as.character(data$Regions)
data$Regions <- factor(data$Regions, levels=unique(data$Regions))

vis <- ggplot(data = data, aes(x = Overlap, y = Regions, color=Modality)) + 
  geom_point(size=5) +
  scale_color_manual(values=c("darkorchid3", "darkgreen", "orangered3")) +
  scale_x_continuous(limits = c(0, 10)) +
  theme( text = element_text(size = 19),
         axis.text.y = element_text(size=12),
         axis.text.x.bottom = element_text(size=12),
         axis.title.x = element_text(margin = margin(t=20, r=0, l=0, b=0))) +
  facet_grid(Networks ~ Modality, scales = "free", space = "free") +
  labs(x = "Effect Size")

vis

ggsave(file="Programs/Educational/Thesis_ADSDB/July2022_Figs/Overlapped_Regs.svg", plot=vis, width=15, height=20, limitsize = FALSE)

## Set threshold for effect size:
data_filtered <- data %>%
  filter(ES_inter_mean>0.04)

vis <- ggplot(data = data_filtered, aes(x = ES_inter_mean, y = Regions, color=Modality)) + 
  geom_point() + 
  geom_errorbar(aes(xmin=CI_L, xmax=CI_U)) +
  scale_color_manual(values=c(4, "darkgoldenrod2", 2)) +
  scale_x_continuous(limits = c(0, 0.07)) +
  theme( text = element_text(size = 14),
         axis.text.y = element_text(size=9),
         axis.text.x.bottom = element_text(size=9)) +
  facet_grid(Networks ~ Modality, scales = "free", space = "free") +
  labs(x = "Effect Size")

vis
