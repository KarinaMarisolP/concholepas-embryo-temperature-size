
library(tidyverse)
library(cowplot)
library(janitor)
library(emmeans)
library(betareg)
library(sjlabelled)
library(writexl)
library(here)
here()
#CLEAN DATA BASE---------------------------------------------------------------
df_final <- readRDS(here::here("data", "data_base_clean_ms.rds"))

#Cleaning data for figures and analysis
df= df_final %>% filter(!(temp_incubacion_procedencia_hembra == "14" & capsula == "Asinc")) %>% 
                          filter(!(temp_incubacion_procedencia_hembra == "14" & capsula == "DispO2"))

#Embryo packing cleaning........................................................
temp= df %>% filter(estadio =="Temprano", capsula == "Emp_Inv")

#Filter different data sets
temp_1= temp %>% filter(categoria_talla_hembra=="120")
temp_2 = temp %>% filter(!(temp_incubacion_procedencia_hembra == "14"))

#Clean outliers in temp_1
Q1 <- quantile(temp_1$emb_estd_mm2, 0.25, na.rm =T)
Q3 <- quantile(temp_1$emb_estd_mm2, 0.75, na.rm =T)
IQR <- Q3 - Q1
#Base sin outliers
temp_1 <- temp_1 %>%
  filter(emb_estd_mm2 > (Q1 - 1.5 * IQR) & emb_estd_mm2< (Q3 + 1.5 * IQR))

#Clean outliers in temp_2
Q1 <- quantile(temp_2$emb_estd_mm2, 0.25, na.rm =T)
Q3 <- quantile(temp_2$emb_estd_mm2, 0.75, na.rm =T)
IQR <- Q3 - Q1
#Base sin outliers
temp_2 <- temp_2 %>%
  filter(emb_estd_mm2 > (Q1 - 1.5 * IQR) & emb_estd_mm2< (Q3 + 1.5 * IQR))

#Inviables cleaning............................................................
inv = df %>% filter(capsula == "Emp_Inv",!(temp_incubacion_procedencia_hembra == "14")) #%>% 
#  filter(id!= "CL041-12-Tar" )
#Clean outliers of data base 
Q1 <- quantile(inv$porc_inviables, 0.25, na.rm =T)
Q3 <- quantile(inv$porc_inviables, 0.75, na.rm =T)
IQR <- Q3 - Q1
#Base sin outliers
inv <- inv %>%
  filter(porc_inviables > (Q1 - 1.5 * IQR) & porc_inviables< (Q3 + 1.5 * IQR))


#Asinc cleaninig...............................................................
asinc= df %>% filter(capsula == "Asinc", !(temp_incubacion_procedencia_hembra == "14"))# %>% 
 # filter(!(tipo_parche == "CT"))

Q1 <- quantile(asinc$porcentaje_asincronia, 0.25, na.rm =T)
Q3 <- quantile(asinc$porcentaje_asincronia, 0.75, na.rm =T)
IQR <- Q3 - Q1
#Base sin outliers
asinc <- asinc %>%
  filter(porcentaje_asincronia > (Q1 - 1.5 * IQR) & porcentaje_asincronia< (Q3 + 1.5 * IQR))


#Disp cleaning..................................................................
disp= df %>% filter(!(temp_incubacion_procedencia_hembra == "14"), capsula=="DispO2") %>% 
 filter(!(id == "CT051-12-Tar"))


temp_1 = temp_1 |> select(especie, tipo_parche, id, categoria_talla_hembra, temp_incubacion_procedencia_hembra, 
temp_incubacion_parche, estadio, capsula, largo_mm, ancho_promedio, area_capsula, embriones_totales, emb_estd_mm2, id_compuesto)

temp_2 = temp_2 |> select(especie, tipo_parche, id, categoria_talla_hembra, temp_incubacion_procedencia_hembra, 
temp_incubacion_parche, estadio, capsula, largo_mm, ancho_promedio, area_capsula, embriones_totales, emb_estd_mm2, id_compuesto)

inv = inv |> select(especie, tipo_parche, id, categoria_talla_hembra, temp_incubacion_procedencia_hembra, 
temp_incubacion_parche, estadio, capsula, largo_mm, ancho_promedio, area_capsula, inviables_totales, porc_inviables, id_compuesto)

asinc = asinc |> select(especie, tipo_parche, id, categoria_talla_hembra, temp_incubacion_procedencia_hembra, 
temp_incubacion_parche, estadio, capsula, largo_mm, ancho_promedio, area_capsula, n_total_asinc, n_retrasadas_asinc, porcentaje_asincronia, id_compuesto)

disp= disp |> select(especie, tipo_parche, id, categoria_talla_hembra, temp_incubacion_procedencia_hembra, 
temp_incubacion_parche, estadio, capsula, largo_mm, ancho_promedio, area_capsula, disp_o2, id_compuesto)

data_outliers_clean <- bind_rows(temp_1, temp_2, inv, disp, asinc) %>%
  distinct() |>  arrange(id)

#Verify duplicates
data_outliers_clean[duplicated(data_outliers_clean), ]

save(data_outliers_clean, file = "data_base_outliers_clean_ms.RData")
write_xlsx(data_outliers_clean, "data_base_outliers_clean_ms.xlsx")

saveRDS(data_outliers_clean, "data_base_outliers_clean.rds")
