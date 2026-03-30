#Data bases
df_tk <- readRDS(here::here("data", "df_capsule_thickness.rds"))
df_dry_W <- readRDS(here::here("data", "df_dry_weight.rds"))


a= ggplot(df_tk, aes(x=talla, y=grosor_cap, fill=talla)) + 
  geom_boxplot()+
  stat_summary(fun = mean, geom = "point", aes(group = talla),
               position= position_dodge(width = 0.75) ,size = 1.5)+
  labs(x=NULL, y=NULL) + 
  theme_bw()+
  theme(axis.text.x=element_text(size = 9,angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 11, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 11, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        strip.text.y = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 5, r = 3, b = 10, l = 3),
        legend.position = "none")+
  scale_fill_manual(#name = "Female size \ncategory (mm)",
    values= c("white", "grey90", "grey60", "grey40"))+
  #facet_wrap(~ estadio)+
  xlab("Female size category (mm)")+
  ylab("Capsule thickness (mm)")+
  annotate("text", x = -Inf, y = Inf,
           label = "(A)",
           hjust = -0.5, vjust = 1.5,
           size = 3.5, fontface = "bold")


b = ggplot(df_dry_W, aes(x=talla, y=peso_area, fill=talla)) + 
  geom_boxplot()+
  stat_summary(fun = mean, geom = "point", aes(group = talla),
               position= position_dodge(width = 0.75) ,size = 1.5)+
  labs(x=NULL, y=NULL) + 
  theme_bw()+
  theme(axis.text.x=element_text(size = 9,angle=0, hjust=0.5, vjust=0.5),
        axis.title.y = element_text(family= NULL, size = 11, colour = "Black", face = "plain"),
        axis.title.x = element_text(family= NULL, size = 11, colour = "Black", face = "plain", vjust=-2),
        strip.text.x = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        strip.text.y = element_text(family= NULL, color= 'black', size = 8, face="bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = 'black'),
        plot.margin = margin(t = 5, r = 3, b = 10, l = 3),
        legend.position = "none")+
  scale_fill_manual(name = "Female size \ncategory (mm)",
                    values= c("white", "grey90", "grey60", "grey40"))+
  #facet_wrap(~ estadio)+
  xlab("Female size category (mm)")+
  ylab(expression("Dry weight / capsule area (mg · mm"^{-2}*")"))+
  annotate("text", x = -Inf, y = Inf,
           label = "(B)",
           hjust = -0.5, vjust = 1.5,
           size = 3.5, fontface = "bold");b



#Figure 3

ragg::agg_tiff("Figure3.tiff", width = 18, height = 10,
               units = "cm", res = 600, pointsize = 10)

plot_grid(a , b, rel_widths = c(1, 1.05))

dev.off()
