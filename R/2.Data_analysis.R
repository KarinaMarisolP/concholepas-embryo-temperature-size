library(tidyverse)
library(cowplot)
library(janitor)
library(emmeans)
library(betareg)
library(sjlabelled)
library(writexl)
library(here)

df<- readRDS(here::here("data", "data_base_outliers_clean.rds"))


temp_1= df %>% filter(categoria_talla_hembra=="120", estadio=="Temprano", emb_estd_mm2!="NA")
temp_2 = df %>% filter(!(temp_incubacion_procedencia_hembra == "14"), estadio=="Temprano",emb_estd_mm2!="NA")
inv= df %>% filter(capsula == "Emp_Inv", porc_inviables!="NA")
asinc= df %>% filter(capsula == "Asinc", porcentaje_asincronia!="NA")
disp= df %>% filter(capsula=="DispO2", disp_o2!="NA") 


#Embryo packing----------------------------------------------------------------
#Checking normality
hist(temp_1$emb_estd_mm2)
qqnorm(temp_1$emb_estd_mm2)
qqline(temp_1$emb_estd_mm2)

#Modeling only for 120 size category
emp_1 = lm(emb_estd_mm2 ~ temp_incubacion_procedencia_hembra, 
                      data = temp_1)

plot(emp_1, which = 1) #Homoscedasticity check
summary(emp_1)
anova(emp_1)

#Modeling for 12 and 16 temperature and size category
emp_2 = lm(emb_estd_mm2 ~ temp_incubacion_procedencia_hembra + categoria_talla_hembra, 
           data = temp_2)
summary(emp_2)
anova(emp_2)

#Inviables Analysis------------------------------------------------------------

inv$porc_inviables = inv$porc_inviables/100

modelo_beta_inv <- betareg(
  porc_inviables ~ temp_incubacion_parche*estadio+ categoria_talla_hembra,
  data = inv)

summary(modelo_beta_inv)

#Tuckey post hoc
emmeans(modelo_beta_inv, pairwise ~ categoria_talla_hembra, adjust = "tukey")

#Disp--------------------------------------------------------------------------
disp$disp_o2 <- disp$disp_o2/ 100


modelo_beta <- betareg(disp_o2 ~ temp_incubacion_parche*estadio + categoria_talla_hembra,
                       data = disp)


summary(modelo_beta)
plot(modelo_beta)

emmeans(modelo_beta, pairwise ~ categoria_talla_hembra, adjust = "tukey")

#Asincronia--------------------------------------------------------------------

asinc$no_retrasados <- asinc$n_total_asinc - asinc$n_retrasadas_asinc

modelo_qbin_asinc <- glm(cbind(n_retrasadas_asinc, no_retrasados)~ temp_incubacion_parche+ estadio + categoria_talla_hembra,
                  data = asinc,
                  family = quasibinomial)

summary(modelo_qbin_asinc)
