## ANOVA MMSE
## Date: 7 March 2022
## Author: Mohammad Akradi
library(ggplot2)
library(dplyr)
library(readr)
library(emmeans)
library(ggpubr)
library(ggsignif)
library(rstatix)
library(sjmisc)
library(data.table)
library(stringr)
library(kableExtra)
library(jtools)
library(apaTables)

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

for (i in 1:512){
  
  src = paste("/home/mohammad/DataScience/Thesis_AD/final_subsamples/sub_samples/sub_sample_", i ,".csv", sep = "")
  data <- read_csv(src)
  
  data$Group <- data$`Research Group`
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
  
  
  res_aov <- data %>% anova_test(MMSCORE ~ Group*SDB + Apoe+Sex+Age+BMI, effect.size = "pes")
  # if ((res_aov$p[[1]] < 0.055) & (res_aov$p[[2]] < 0.055)) {
  #   next
  # }
  
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

table <- data.frame(p_Group, p_SDB,
                    p_inter, F_Group, F_SDB,
                    F_inter, F_total, ES_Group,
                    ES_SDB, ES_inter)
dst = paste("/home/mohammad/DataScience/Thesis_AD/July2022_Results/MMSE_Anova.csv")
write_csv(table, file = dst)

### Linear Regression
MMSE <- read_csv("/home/mohammad/DataScience/Thesis_AD/July2022_Results/MMSE_Anova.csv")
ANOVA <- read_csv("/home/mohammad/DataScience/Thesis_AD/July2022_Results/BSES_inter_8July2022.csv")

ANOVA <- ANOVA%>%
  filter(BS_mean >=0.04)

ANOVA$Regions <- str_c(ANOVA$Regions,"_",ANOVA$Modality)
Flt_aov <- transpose(ANOVA)
names(Flt_aov) <- as.matrix(Flt_aov[1, ])
Flt_aov <- Flt_aov[-c(1, 2, 3, 516, 517, 518, 519, 520, 521), ]
Flt_aov[] <- lapply(Flt_aov, function(x) type.convert(as.character(x)))
Flt_aov$MMSE <- MMSE$ES_inter
Flt_aov <- as.data.frame(Flt_aov)

lm_model <- lm(MMSE ~ ., data = Flt_aov)
sink('/home/mohammad/DataScience/Thesis_AD/July2022_Results/MMSE_LM04.txt')
summ(lm_model)

lm_model2 <- lm(MMSE ~ `RH-Vis-4_VBM`+ `LH-Default-Temp-1_VBM`+
                `RH-SomMot-5_VBM`+ `RH-DorsAttn-Post-3_FDG`+
                `LH-Default-Temp-1_Aβ`+ `RH-Vis-7_Aβ`, data = Flt_aov)
sink('/home/mohammad/DataScience/Thesis_AD/July2022_Results/MMSE_LM2_04.txt')
summ(lm_model2)


lm_model3 <- lm(MMSE ~ `RH-Vis-4_VBM`, data = Flt_aov)
sink('/home/mohammad/DataScience/Thesis_AD/July2022_Results/MMSE_LM3_04.txt')
summ(lm_model3)


apa.reg.table(lm_model)
lm_table <- summ(lm_model, confint = TRUE)
lm_table

plot_summs(lm_model, lm_model2, scale = TRUE, plot.distributions = TRUE)
export_summs(lm_model, lm_model2, scale = TRUE)

plot_summs(lm_model)
plot_summs(lm_model, scale = TRUE, plot.distributions = TRUE, inner_ci_level = .9)

Flt_aov$resp <- MMSE$ES_inter
Flt_aov$predictor <- Flt_aov$`LH-Default-Par-1_VBM`
ggplot(data=Flt_aov, aes(x=predictor, y = resp)) +
  geom_point() +
  stat_smooth(method = 'lm', se=TRUE)
