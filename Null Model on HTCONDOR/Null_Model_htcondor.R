# Date: July 8, 2022
# Author: Mohammad Akradi
# this code will produce a null model based on Simon comments on the manuscript.
# we will shuffle the lable of each subject through 512 subsamples and repeat the
# two-way ANCOVA test and replicate average of disaese type * SDB condition effect-size.

library(dplyr)
library(readr)
library(rstatix)
library(sjmisc)


#### Null Model
working_dir = "/home/mtahmasian/final_subsamples/SDB"

# for (j in 1:1000) {
Args <- commandArgs(trailingOnly = TRUE)

folder_name = paste(working_dir, "/sub_samples_results/", Args[1], sep = "")
dir.create(folder_name, showWarnings = TRUE)
for (i in 1:512){
  
  src = paste(working_dir, "/sub_samples/sub_sample_", i ,".csv", sep = "")
  data <- read_csv(src)
  
  data$Group <- data$`Research Group`
  
  data <- data %>%
    mutate(Group = sample(Group),
           SDB = sample(SDB))
  
  data <- data %>%
    mutate(Sex = ifelse(Sex == 0, 'Female', 'Male'),
           SDB = ifelse(SDB == 'Neg', 'Negative', 'Positive'))
  data <- data %>%
    arrange(match(Group, c("CN", "MCI", "AD")))
  data$Group <- as.factor(data$Group)
  data$SDB <- as.factor(data$SDB)
  data$Apoe <- as.factor(data$Apoe)
  
  data <- data %>%
    mutate(subGroup = paste(Group, data$SDB, sep = "_"))
  
  data$subGroup <- factor(data$subGroup, levels=c("CN_Negative", "CN_Positive",
                                                  "MCI_Negative", "MCI_Positive",
                                                  "AD_Negative", "AD_Positive"))
  
  ###########
  
  Regions <- c()
  Modality <- c()
  p_Group <- c()
  p_SDB <- c()
  p_inter <- c()
  F_Group <- c()
  F_SDB <- c()
  F_inter <- c()
  F_total <- c()
  ES_Group <- c()
  ES_SDB <- c()
  ES_inter <- c()
  
  regs = colnames(data)[54:402]
  #regs = c("Abeta42", "TAU")
  for (reg in regs){
    if ((reg == "Apoe_x") | (reg == "Apoe_y") | (reg == "amy") | (reg == "BMI")){
      next
    }
    mod = "vbm"
    regg = reg
    if (substr(reg, 1, 3)=="vbm"){
      mod = "vbm"
      regg = substr(reg, 5, 100)
    }
    if (substr(reg, 1, 3)=="fdg"){
      mod = "fdg"
      regg = substr(reg, 5, 100)
    }
    if ((substr(reg, 1, 3)=="amy") | (substr(reg, 1, 2)=="av")){
      mod = "av"
      regg = substr(reg, 4, 100)
    }
    data$resp <- data[[reg]]
    res_aov <- data %>% anova_test(resp ~ Group*SDB + Apoe+Sex+Age+BMI, effect.size = "pes")
    
    Regions <- append(Regions, regg)
    Modality <- append(Modality, mod)
    p_Group <- append(p_Group, res_aov$p[[1]])
    p_SDB <- append(p_SDB, res_aov$p[[2]])
    p_inter <- append(p_inter, res_aov$p[[7]])
    F_Group <- append(F_Group, res_aov$F[[1]])
    F_SDB <- append(F_SDB, res_aov$F[[2]])
    F_inter <- append(F_inter, res_aov$F[[7]])
    F_total <- append(F_total, sum(res_aov$F))
    ES_Group <- append(ES_Group,res_aov$pes[[1]])
    ES_SDB <- append(ES_SDB,res_aov$pes[[2]])
    ES_inter <- append(ES_inter,res_aov$pes[[7]])
  }
  
  table <- data.frame(Regions, Modality, p_Group, p_SDB,
                      p_inter, F_Group, F_SDB,
                      F_inter, F_total, ES_Group,
                      ES_SDB, ES_inter)
  #dst = paste("/home/mohammad/DataScience/Thesis_AD/March2022_Results/sub_samples_Results/sub_sample_Result_", i, ".csv", sep = "")
  dst = paste(folder_name, "/sub_sample_Result_", i, ".csv", sep = "")
  write_csv(table, file = dst)
}
# }
