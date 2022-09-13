library(ggplot2)
library(dplyr)
library(readr)
library(emmeans)
library(ggpubr)
library(ggsignif)
library(rstatix)
library(sjmisc)
library(statsr)

data <- read_csv('/home/mohammad/DataScience/Thesis_AD/Thesis3/Doing_on_7Network_Atlas/Data_Complete_24Dec2021.csv')

data <- data %>% rename(Group = `Research Group`)
data <- data %>% mutate(SDB = ifelse(SDB==1, "Pos", "Neg"))
data$Group <- as.factor(data$Group)
data$SDB <- as.factor(data$SDB)
data$Sex <- as.factor(data$Sex)
data$Apoe <- as.factor(data$Apoe)

df <- data %>% distinct(RID, .keep_all = T)
df <- df %>% select(-c(`Unnamed: 0`, X1))


AD_Neg <- df %>% filter(Group_SDB == "AD_Neg")
AD_Pos <- df %>% filter(Group_SDB == "AD_Pos")
MCI_Neg <- df %>% filter(Group_SDB == "MCI_Neg")
MCI_Pos <- df %>% filter(Group_SDB == "MCI_Pos")
CN_Neg <- df %>% filter(Group_SDB == "CN_Neg")
CN_Pos <- df %>% filter(Group_SDB == "CN_Pos")

count = 0
for (i in 1:10000){
  #if (count == 100) {
  #  break
 # }
  AD_Neg_sample <- AD_Neg[sample(nrow(AD_Neg), size = 10, replace = FALSE), ]
  AD_Pos_sample <- AD_Pos[sample(nrow(AD_Pos), size = 10, replace = FALSE), ]
  
  MCI_Neg_sample <- MCI_Neg[sample(nrow(MCI_Neg), size = 10, replace = FALSE), ]
  MCI_Pos_sample <- MCI_Pos[sample(nrow(MCI_Pos), size = 10, replace = FALSE), ]
  
  CN_Neg_sample <- CN_Neg[sample(nrow(CN_Neg), size = 10, replace = FALSE), ]
  CN_Pos_sample <- CN_Pos[sample(nrow(CN_Pos), size = 10, replace = FALSE), ]
  df_sample <- rbind(AD_Neg_sample, AD_Pos_sample)
  df_sample <- rbind(df_sample, MCI_Neg_sample)
  df_sample <- rbind(df_sample, MCI_Pos_sample)
  df_sample <- rbind(df_sample, CN_Neg_sample)
  df_sample <- rbind(df_sample, CN_Pos_sample)
  
  #aov <- data %>% anova_test(Age~Group * SDB)
  #if (sum(aov$`p<.05` == "*") > 0){
   # next
  #}
  
  sdb.test <- df_sample %>%
    group_by(Group) %>%
    t_test(Age ~ SDB) %>%
    adjust_pvalue(method = "bonferroni") %>%
    add_significance()
  
  if (sum(sdb.test$p.adj.signif != "ns") > 0) {
    next
  }
  
  
  group.test <- df_sample %>%
    t_test(Age ~ Group) %>%
    adjust_pvalue(method = "bonferroni") %>%
    add_significance()
  if (sum(group.test$p.adj.signif != "ns") > 0){
    next
  }
  
  
  
  chis_sdb <- df_sample %>%
    group_by(Group) %>%
    summarise(gender_p_val = chisq.test(Sex, SDB)$p.value)
  
  if ((chis_sdb$gender_p_val[1] <= 0.05) | (chis_sdb$gender_p_val[2] <= 0.05) | (chis_sdb$gender_p_val[3] <= 0.05)){
    next
  }
  
  chis_group <- df_sample %>%
    summarise(gender_p_val = chisq.test(Sex, Group)$p.value)
  
  if (chis_group$gender_p_val <= 0.05){
    next
  }
  

  try({
    chis_group <- df_sample %>%
      summarise(apoe_p_val = chisq.test(Apoe, Group)$p.value)
    
    if (chis_group$apoe_p_val <= 0.05){
      next
    }
    
    chis_sdb <- df_sample %>%
      group_by(Group) %>%
      summarise(apoe_p_val = chisq.test(Apoe, SDB)$p.value)
    
    if ((chis_sdb$apoe_p_val[1] <= 0.05) | (chis_sdb$apoe_p_val[2] <= 0.05) | (chis_sdb$apoe_p_val[3] <= 0.05)){
      next
    }
    
  })
  
  
  count = count + 1
  write_csv(df_sample, file = paste("/home/mohammad/DataScience/Thesis_AD/Thesis3/sub_samples/sub_sample_",count,".csv", sep = ""))
}
