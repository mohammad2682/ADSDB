## ADSDB Linear Regression
## Date: 30 May 2022
## Mohammad Akradi
library(ggplot2)
library(readr)
library(dplyr)
library(stringr)
library(rstatix)
library(data.table)
library(kableExtra)
library(jtools)
library(apaTables)

MMSE <- read_csv("/home/mohammad/DataScience/Thesis_AD/July2022_Results/MMSE_Anova.csv")
ANOVA <- read_csv("/home/mohammad/DataScience/Thesis_AD/July2022_Results/BSES_inter_8July2022.csv")
reg_names <- read_csv("/home/mohammad/DataScience/Thesis_AD/July2022_Results/Regions_name_withNull_21July2022.csv")
reg_names <- reg_names[c("Regions", "Modality", "Networks")]

ANOVA <- merge(ANOVA, reg_names, by=c("Regions", "Modality"))
#ANOVA <- ANOVA%>%
 # filter(BS_mean >=0.04)

ANOVA$Regions <- str_c(ANOVA$Regions,"_",ANOVA$Modality)
Flt_aov <- transpose(ANOVA)
names(Flt_aov) <- as.matrix(Flt_aov[1, ])
Flt_aov <- Flt_aov[-c(1, 2, 3, 516, 517, 518, 519, 520, 521, 522), ]
Flt_aov[] <- lapply(Flt_aov, function(x) type.convert(as.character(x)))
Flt_aov$MMSE <- MMSE$ES_inter
Flt_aov <- as.data.frame(Flt_aov)

lm_model <- lm(MMSE ~ ., data = Flt_aov)
sink('/home/mohammad/DataScience/Thesis_AD/July2022_Results/MMSE_LM_Null_pass_21July.txt')
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
