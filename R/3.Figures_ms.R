library(tidyverse)
library(cowplot)
library(janitor)
library(emmeans)
library(betareg)
library(sjlabelled)
library(writexl)
library(here)
library(ragg)

#Upload data bases

df<- readRDS(here::here("data", "data_base_outliers_clean.rds"))


temp_1= df %>% filter(categoria_talla_hembra=="120", estadio=="Temprano", emb_estd_mm2!="NA")
temp_2 = df %>% filter(!(temp_incubacion_procedencia_hembra == "14"), estadio=="Temprano",emb_estd_mm2!="NA")
inv= df %>% filter(capsula == "Emp_Inv", porc_inviables!="NA")
asinc= df %>% filter(capsula == "Asinc", porcentaje_asincronia!="NA")
disp= df %>% filter(capsula=="DispO2", disp_o2!="NA") 

#Figure 2-----------------------------------------------------------------------
#Embryo packing


#Only for 120 size, 3 temp : 12, 14 y 16°C
emp_1 = ggplot(temp_1, aes(x=temp_incubacion_procedencia_hembra, y=emb_estd_mm2 ,  fill = temp_incubacion_procedencia_hembra)) + 
  geom_boxplot()+
  stat_summary(fun = mean, geom = "point", aes(group = temp_incubacion_procedencia_hembra),
               position= position_dodge(width = 0.75) ,size = 1.5)+
  labs(x=NULL, y=NULL) + 
  theme_bw()+
  theme(plot.background  = element_rect(),      # fondo externo
        panel.background = element_rect(),
        legend.background = element_rect(),   # fondo de la leyenda
        legend.key        = element_rect(),  
        axis.text = element_text(family= NULL,size = 9, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 11, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 11, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 8),
        strip.text.y = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 5, r = 1, b = 10, l = 1),
        # legend.title = element_text(size = 20), ##face="bold"),  # tamaño y estilo del título
        #legend.text  = element_text(size = 20),
        legend.position = "none")+
  scale_y_continuous(breaks = seq(0, 90, by = 10))+
  scale_fill_manual(#name = "Temperature (°C)",
                     values = c("grey40", "grey40", "grey40"))+
  #labs(color = "Temperatura experimental hembra")+
  ylab(expression(Number~of~embryos~mm^{-2}~capsule~area))+
  #xlab("Temperature (°C)")+
  annotate("text", x = -Inf, y = Inf,
           label = "(A)",
           hjust = -0.5, vjust = 1.5,
           size = 3.5, fontface = "bold");emp_1


#For all female sizes, 2 temp : 12y 16°C
emp_2= ggplot(temp_2, aes(x=temp_incubacion_procedencia_hembra, y=emb_estd_mm2, fill=categoria_talla_hembra)) + 
  geom_boxplot()+
  stat_summary(fun = mean, geom = "point", aes(group = categoria_talla_hembra),
               position= position_dodge(width = 0.75) ,size = 1.5)+
  labs(x=NULL, y=NULL) + 
  theme_bw()+
  theme(axis.text.y  = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.x=element_text(size = 9,angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 11, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 11, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        strip.text.y = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 5, r = 0, b = 10, l = 0),
        legend.title = element_text(size = 9, face = "plain"),
        legend.text  = element_text(size = 8),
        legend.key.size = unit(6, "mm"))+
  scale_fill_manual(name = "Female size \ncategory (mm)",
                     values= c("white", "grey90", "grey60", "grey40"))+
  annotate("text", x = -Inf, y = Inf,
           label = "(B)",
           hjust = -0.5, vjust = 1.5,
           size = 3.5, fontface = "bold"); emp_2
  # facet_wrap(~ estadio_desarrollo)+
  #ylab("N° embriones /mm2")+
  #xlab("Temperature (°C)"); emp_2

ylim_common <- c(15, 50)

emp_1 <- emp_1 + coord_cartesian(ylim = ylim_common)
emp_2 <- emp_2 + coord_cartesian(ylim = ylim_common)


ragg::agg_tiff("Figure2.tiff", width = 18, height = 10,
               units = "cm", res = 600)
ggdraw() +
  draw_plot(
    plot_grid(emp_1, emp_2,
      rel_widths = c(1, 1.5),
      nrow = 1,
      align = "hv",
      axis = "l"),x = 0,y = 0.05,width = 1, height = 0.95) +
  draw_label("Temperature (°C)",x = 0.45,y = 0.02,size = 11)


dev.off()



#-------------------------------------------------------------------------------
#Figure 3-------------------------------------------------------------------------------
#Oxygen availability

disp$estadio <- factor(
  disp$estadio,
  levels = c("Temprano", "Tardio"),
  labels = c("(A) Early stage", "(B) Late stage")
)


ragg::agg_tiff("Figure3.tiff", width = 18, height = 10,
               units = "cm", res = 600, pointsize = 10)

ggplot(disp, aes(x=temp_incubacion_parche, y=disp_o2, fill=categoria_talla_hembra)) + 
  geom_boxplot()+
  stat_summary(fun = mean, geom = "point", aes(group = categoria_talla_hembra),
               position= position_dodge(width = 0.75) ,size = 1.5)+
  labs(x=NULL, y=NULL) + 
  theme_bw()+
  theme(axis.text = element_text(family= NULL,size = 9, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 11, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 11, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 9, face="bold",  hjust = -0.001),
        strip.text.y = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 5, r = 10, b = 10, l = 5),
        legend.title = element_text(size = 9, face = "plain"),
        legend.text  = element_text(size = 8),
        legend.key.size = unit(6, "mm"))+
  scale_fill_manual(name = "Female size \ncategory (mm)",
                     values= c("white", "grey90", "grey60", "grey40"))+
  facet_wrap( ~ estadio)+
  ylab("Oxygen (% Air saturation)")+
  xlab("Temperature (°C)")

dev.off()



#---------------------------------------------------------------------------------
#Figure 4-----------------------------------------------------------------------
#Inviable embryo

inv$estadio <- factor(
  inv$estadio,
  levels = c("Temprano", "Tardio"),
  labels = c("Early stage", "Late stage")
)


ragg::agg_tiff("Figure4.tiff", width = 18, height = 10,
               units = "cm", res = 600, pointsize = 10)

#Female size category
inv_1=ggplot(inv, aes(x=categoria_talla_hembra, y=porc_inviables ,  fill = categoria_talla_hembra)) + 
  geom_boxplot()+
  stat_summary(fun = mean, geom = "point", aes(group = categoria_talla_hembra),
               position= position_dodge(width = 0.75) ,size = 1.5)+
  labs(x=NULL, y=NULL) + 
  theme_bw()+
  theme(plot.background  = element_rect(),      # fondo externo
        panel.background = element_rect(),
        legend.background = element_rect(),   # fondo de la leyenda
        legend.key        = element_rect(),  
        axis.text = element_text(family= NULL,size = 9, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 11, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 11, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 8),
        strip.text.y = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 5, r = 1, b = 10, l = 1),
        # legend.title = element_text(size = 20), ##face="bold"),  # tamaño y estilo del título
        #legend.text  = element_text(size = 20),
        legend.position = "none")+
  scale_y_continuous(breaks = seq(0, 15, by = 5))+
  scale_fill_manual(#name = "Temperature (°C)",
    values = c("grey90", "grey90", "grey90", "grey90"))+
  #labs(color = "Temperatura experimental hembra")+
  ylab("Non-viable embryos (%)")+
  xlab("Female size category (mm)")+
  #xlab("Temperature (°C)")+
  annotate("text", x = -Inf, y = Inf,
           label = "(A)",
           hjust = -0.5, vjust = 1.5,
           size = 3.5, fontface = "bold");inv_1


#Temperature and developmental stage
inv_2= ggplot(inv, aes(x=temp_incubacion_parche, y=porc_inviables, fill=estadio)) + 
  #geom_point() + 
  geom_boxplot()+
  stat_summary(fun = mean, geom = "point", aes(group = estadio),
               position= position_dodge(width = 0.75) ,size = 1.5)+
  # geom_point(size = 2, alpha = .3, position = position_dodge( width = .2))+
  labs(x=NULL, y=NULL) + 
  theme_bw()+
  theme(axis.text.y  = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text = element_text(family= NULL,size = 9, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 11, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 11, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 9, face="bold",  hjust = -0.001),
        strip.text.y = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 5, r = 10, b = 10, l = 5),
        legend.title = element_text(size = 9, face = "plain"),
        legend.text  = element_text(size = 8),
        legend.key.size = unit(6, "mm"))+
  scale_fill_manual(name = "Development \nstage",
                    values= c("white", "grey30"))+
 # facet_wrap( ~ estadio)+
  #ylab("Inviable embryos (%)")+
  xlab("Temperature (°C)")+
  annotate("text", x = -Inf, y = Inf,
           label = "(B)",
           hjust = -0.5, vjust = 1.5,
           size = 3.5, fontface = "bold");inv_2



ylim_common <- c(0, 15)

inv_1 <- inv_1 + coord_cartesian(ylim = ylim_common)
inv_2 <- inv_2 + coord_cartesian(ylim = ylim_common)

plot_grid(inv_1, inv_2,
          rel_widths = c(1, 1.3),
          nrow = 1,
          align = "hv",
          axis = "l")
dev.off()

#-------------------------------------------------------------------------------
#Figure 5-----------------------------------------------------------------------
#Asinchrony

asinc$estadio <- factor(
asinc$estadio,
  levels = c("Temprano", "Tardio"),
  labels = c("Early stage", "Late stage")
)

ragg::agg_tiff("Figure5.tiff", width = 14, height = 10,
               units = "cm", res = 600, pointsize = 10)

ggplot(asinc, aes(x=temp_incubacion_parche, y=porcentaje_asincronia, fill=estadio)) + 
  geom_boxplot()+
  stat_summary(fun = mean, geom = "point", aes(group = estadio),
               position= position_dodge(width = 0.75) ,size = 1.5)+
  labs(x=NULL, y=NULL) + 
  theme_bw()+
  theme(axis.text = element_text(family= NULL,size = 9, colour = "Black"),
        axis.text.x=element_text(angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 11, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 11, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 9, face="bold",  hjust = -0.001),
        strip.text.y = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 5, r = 10, b = 10, l = 5),
        legend.title = element_text(size = 9, face = "plain"),
        legend.text  = element_text(size = 8),
        legend.key.size = unit(6, "mm"))+
  scale_fill_manual(name = "Development \nstage",
                    values= c("white", "grey30"))+
#  facet_wrap( ~ estadio)+
  ylab("Asynchrony (%)")+
  xlab("Temperature (°C)")

dev.off()



