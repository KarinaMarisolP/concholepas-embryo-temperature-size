library(tidyverse)
library(cowplot)
library(janitor)
library(emmeans)
library(betareg)
library(sjlabelled)
library(ggpmisc)
library(segmented)
library(here)

here()
#Cargo database
df_final <- readRDS(here::here("data", "data_base_clean_ms.rds"))
#Filtro para hacer regresion numero embriones
temp_a = df_final %>% filter(capsula == "Emp_Inv", estadio=="Temprano")
#Agrego metricas de volumen
temp_a <- temp_a %>%
  mutate( volumen_capsula_mm3=  pi * (temp_a$ancho_promedio / 2)^2 * temp_a$largo_mm,
          embriones_por_volumen = embriones_totales / volumen_capsula_mm3, 
          embriones_por_vol_estd = embriones_totales / (volumen_capsula_mm3^0.74))

#function for truncate numbers
trunc2 <- function(x, digits = 2) {
  trunc(x * 10^digits) / 10^digits
}


#LINEAR SIMPLE MODEL (N embriones x Largo)-------------------------------------------------------------

linear_reg <- lm(embriones_totales ~ largo_mm, data = temp_a)
summary(linear_reg)


a.l  <- coef(linear_reg)[1]
b.l  <- coef(linear_reg)[2]
r2.l <- summary(linear_reg)$r.squared

label_eq.l <- paste0(
  "N = ", trunc2(a.l, 2),
  " + ", trunc2(b.l, 2), " × L",
  "\nR² = ", trunc2(r2.l, 2))

#Figura 1 (A)------------------------------------------------------------------

lin =ggplot(temp_a, aes(x = largo_mm, y = embriones_totales)) +
  geom_point(size= 0.6) +
  geom_line(aes(y = predict(linear_reg)), color = "grey40", size = 1) +
  annotate("text", 
           x = Inf, y = -Inf, 
           hjust = 1.1, vjust = -0.5, 
           label = label_eq.l, size = 2.5) +
  theme_bw()+
  labs(x=NULL, y=NULL)+
  theme(plot.background  = element_rect(),      # fondo externo
        panel.background = element_rect(),
        legend.background = element_rect(),   # fondo de la leyenda
        legend.key        = element_rect(), 
        axis.text = element_text(family= NULL,size = 8, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 10, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 10, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 7),
        strip.text.y = element_text(family= NULL, color= 'black', size = 7),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 3, r = 3, b = 5, l = 3))+
  xlab("Capsule length (mm)")+
  ylab("Number of embryos")+
  annotate("text", x = -Inf, y = Inf,
           label = "(A)",
           hjust = -0.5, vjust = 1.5,
           size = 3, fontface = "bold");lin

#--------------------------------------------------------------------------------




#POWER REGRESSION (Numero embriones x Area)---------------------------------------------------------------

power_reg <- lm(log(embriones_totales) ~ log(area_capsula), data = temp_a)
lin = lm(embriones_totales ~ area_capsula, data = temp_a)
#Comparo con un modelo lineal
AIC(power_reg, lin)

summary(power_reg)
confint(power_reg)

a <- exp(coef(power_reg)[1])
b <- coef(power_reg)[2]
r2 <- summary(power_reg)$r.squared

#Grafico del modelo
#Agrego curva predicha AREA
temp_a<- temp_a %>%
  mutate(pred_embriones_pwr = a * area_capsula^b)

#Ecuacion para el grafico
label_eq <- paste0("N = ", trunc2(a, digits=2), " × A^", trunc2(b, digits=2), 
                   "\nR² = ", trunc2(r2, digits = 2))


#Figura 1 (B)---------------------------------------------------------------------
pwr=ggplot(temp_a, aes(x = area_capsula, y = embriones_totales)) +
  geom_point(size=0.6) +
  geom_line(aes(y = pred_embriones_pwr), color = "grey40", size = 1) +
  annotate("text", 
           x = Inf, y = -Inf, 
           hjust = 1.1, vjust = -0.5, 
           label = label_eq, size = 2.5) +
  theme_bw()+
  theme(plot.background  = element_rect(),      # fondo externo
        panel.background = element_rect(),
        legend.background = element_rect(),   # fondo de la leyenda
        legend.key        = element_rect(),  
        axis.text = element_text(family= NULL,size = 8, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 10, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 10, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 7),
        strip.text.y = element_text(family= NULL, color= 'black', size = 7),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 3, r = 3, b = 5, l = 3))+
  xlab(expression(Capsule~area~(mm^2)))+
  ylab("Number of embryos")+
  annotate("text", x = -Inf, y = Inf,
           label = "(B)",
           hjust = -0.5, vjust = 1.5,
           size = 3, fontface = "bold");pwr

#--------------------------------------------------------------------------------


#REGRESIION WITH STANDARIZED VARIABLE (N embriones/ Area x Largo)--------------------------------------------

estd_reg = lm(emb_estd_mm2 ~ largo_mm, data = temp_a)
summary(estd_reg)

a.e  <- coef(estd_reg)[1]
b.e  <- coef(estd_reg)[2]
r2.e<- summary(estd_reg)$r.squared

label_eq.e <- paste0(
  "N = ", trunc2(a.e, 2),
  " + ", trunc2(b.e, 2), " × L",
  "\nR² = ", trunc2(r2.e, 3)
)

#figura 1( C)---------------------------------------------------------------------

estd= ggplot(temp_a, aes(x = largo_mm, y = emb_estd_mm2 )) +
  geom_point(size=0.6) +
  geom_line(aes(y = predict(estd_reg)), color = "grey40", size = 1) +
  annotate("text", 
           x = Inf, y = -Inf, 
           hjust = 1.1, vjust = -8, 
           label = label_eq.e, size = 2.5) +
  theme_bw()+
  theme(plot.background  = element_rect(),      # fondo externo
        panel.background = element_rect(),
        legend.background = element_rect(),   # fondo de la leyenda
        legend.key        = element_rect(),  
        axis.text = element_text(family= NULL,size = 8, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 10, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 10, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 7),
        strip.text.y = element_text(family= NULL, color= 'black', size = 7),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 3, r = 3, b = 5, l = 3))+
  xlab("Capsule length (mm)")+
  ylab(expression(Number~of~embryos~mm^{-2}~capsule))+
  annotate("text", x = -Inf, y = Inf,
           label = "(C)",
           hjust = -0.5, vjust = 1.5,
           size = 3, fontface = "bold");estd

#----------------------------------------------------------------------------------





#Volumen power reg (N embriones x volumen )---------------------------------------------------------------------

vol_reg_pwr <- lm(log(embriones_totales) ~ log(volumen_capsula_mm3), data = temp_a)
vol_reg_s <- lm(embriones_totales ~ volumen_capsula_mm3, data = temp_a)
#comparo con un modelo lineal
summary(vol_reg_pwr)
confint(vol_reg_pwr)


AIC(vol_reg_pwr,vol_reg_s)

a.p <- exp(coef(vol_reg_pwr)[1])
b.p <- coef(vol_reg_pwr)[2]
r2.p <- summary(vol_reg_pwr)$r.squared

#Agrego curva predicha volumen
temp_a<- temp_a %>%
  mutate(pred_embriones_pwr_vol = a.p * volumen_capsula_mm3^b.p)

#Ecuacion para el grafico
label_eq.vp <- paste0("N = ", trunc2(a.p, digits=2), " × V^", trunc2(b.p, digits=2), 
                   "\nR² = ", trunc2(r2.p, digits = 2))


#Figura 1 (D)-----------------------------------------------------------------------
vol_pwr=ggplot(temp_a, aes(x = volumen_capsula_mm3, y = embriones_totales)) +
  geom_point(size=0.6) +
  geom_line(aes(y =pred_embriones_pwr_vol), color = "grey40", size = 1) +
  annotate("text", 
           x = Inf, y = -Inf, 
           hjust = 1.1, vjust = -0.5, 
           label = label_eq.vp, size = 2.5)+
  theme_bw()+
  theme(plot.background  = element_rect(),      # fondo externo
        panel.background = element_rect(),
        legend.background = element_rect(),   # fondo de la leyenda
        legend.key        = element_rect(),  
        axis.text = element_text(family= NULL,size = 8, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 10, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 10, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 7),
        strip.text.y = element_text(family= NULL, color= 'black', size = 7),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 3, r = 3, b = 3, l = 3))+
  xlab(expression(Capsule~volume~(mm^{3})))+
  ylab("Number of embryos")+
  annotate("text", x = -Inf, y = Inf,
           label = "(D)",
           hjust = -0.5, vjust = 1.5,
           size = 3, fontface = "bold"); vol_pwr
#----------------------------------------------------------------------


#VOLUMEN ESTANDARIZED (embriones/volumen x largo)-----------------------------------------------------------

vol_reg <- lm(embriones_por_volumen ~ largo_mm, data = temp_a)
summary(vol_reg)

a.v  <- coef(vol_reg)[1]
b.v  <- coef(vol_reg)[2]
r2.v <- summary(vol_reg)$r.squared

label_eq.v <- paste0(
  "N = ", trunc2(a.v, 2),
  " + ", trunc2(b.v, 2), " × L",
  "\nR² = ", trunc2(r2.v, 2)
)


#Figura 1 (E)---------------------------------------------------------------------

vol=ggplot(temp_a, aes(x = largo_mm, y = embriones_por_volumen )) +
  geom_point(size=0.6) +
  geom_line(aes(y = predict(vol_reg)), color = "grey40", size = 1) +
  annotate("text", 
           x = Inf, y = -Inf, 
           hjust = 1.1, vjust = -8, 
           label = label_eq.v, size = 2.5) +
  theme_bw()+
  theme(plot.background  = element_rect(),      # fondo externo
        panel.background = element_rect(),
        legend.background = element_rect(),   # fondo de la leyenda
        legend.key        = element_rect(),  
        axis.text = element_text(family= NULL,size = 8, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 10, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 10, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 7),
        strip.text.y = element_text(family= NULL, color= 'black', size = 7),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 3, r = 3, b = 3, l = 3))+
  xlab("Capsule length (mm)")+
  ylab(expression(Number~of~embryos~mm^{-3}~capsule))+
  annotate("text", x = -Inf, y = Inf,
           label = "(E)",
           hjust = -0.5, vjust = 1.5,
           size = 3, fontface = "bold");vol

#------------------------------------------------------------------------------








ragg::agg_tiff("Figure1.tiff", width = 19, height = 13,
               units = "cm", res = 300, pointsize = 10)

plot_grid(lin, pwr,estd, vol_pwr,vol , nrow = 2, ncol = 3,align = "hv",
          axis = "l")

dev.off()





#Segmented regression-----------------------------------------------------------------
seg_reg <- segmented(
  vol_reg,
  seg.Z = ~ largo_mm,
  psi = median(temp_a$largo_mm, na.rm = TRUE)
)


summary(seg_reg)

plot(
  embriones_por_volumen ~ largo_mm,
  data = temp_a,
  pch = 16
)
plot(seg_reg, add = TRUE, col = "blue", lwd = 2)
abline(v = seg_reg$psi[, "Est."], lty = 2)


anova(seg_reg, vol_reg)




