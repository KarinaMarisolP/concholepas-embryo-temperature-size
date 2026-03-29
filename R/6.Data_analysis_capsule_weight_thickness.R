library(readxl)
library(writexl)
library(tidyverse)
library(cowplot)
library(janitor)
library(emmeans)
library(betareg)
library(sjlabelled)
library(here)


df_tk <- readRDS(here::here("data", "df_capsule_thickness.rds"))
df_dry_W <- readRDS(here::here("data", "df_dry_weight.rds"))



#Exploring staistical Analysis
#Checking normality
hist(df_tk$grosor_cap)
qqnorm(df_tk$grosor_cap)
qqline(df_tk$grosor_cap)

hist(df_dry_W$peso_area)
qqnorm(df_dry_W$peso_area)
qqline(df_dry_W$peso_area)


grosor = lm(grosor_cap ~ talla+ temperatura + estadio, 
           data = df_tk)
summary(grosor)
anova(grosor)


emmeans(grosor, pairwise ~ talla, adjust = "tukey")

peso = lm(peso_area ~ talla+ temperatura + estadio, 
           data = df_dry_W)
summary(peso)
anova(peso)

emmeans(peso, pairwise ~ talla, adjust = "tukey")