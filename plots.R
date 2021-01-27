# set working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# get the csv
# consider using rPraat next time? 
library(dplyr)
library(readxl)
library(magrittr)
library(tidyr)
library(brms)
library(ggpubr)
library(cowplot)
library(bayesplot)


df <- read_excel("f1f2_new.xlsx", sheet = "Sheet2")
# the difference between f1 and f2?
df <- subset(df, Hz != "NA")

df$Hz %<>% as.integer()
df %<>% spread(., value, Hz)

df$delta <- df$f2 - df$f1
df$type <- ifelse(df$sound=="bey", "/j/", "non-/j/")
avg <- df %>% 
  dplyr::group_by(type) %>%
  summarise(f1 = mean(f1),
            f2 = mean(f2),
            delta = mean(delta))
library(ggplot2)
# plot1 <- ggplot(data=df, aes(x=f2, y=f1)) +
#   stat_ellipse(type = "t", linetype=2, geom="polygon", alpha=0.25, aes(fill=type)) +
#   geom_point(aes(color=type)) +
#   geom_text(data = avg, aes(label=type), size=10) +
#   scale_x_reverse() +
#   scale_y_reverse() 
# print(plot1)
# avg_d <- avg
# avg_d$f_1 <- ifelse(avg_d$f1 <= 600, "low f1", "high f1")
# avg_d$f_2 <- ifelse(avg_d$f2 >= 1850, "low f2", "high f2")

# plot2 <- ggplot(data=df, aes(x=type, y=delta)) +
#   geom_boxplot()
# print(plot2)
# require(gridExtra)
# grid.arrange(plot1, plot2, nrow=2)


makeplot <- function() {
  sp <- ggscatter(df, x = "f2", y = "f1",
                  color = "type", palette = "jco",
                  #shape = "person",
                  size = 3, alpha = 0.6)+
    theme(text=element_text(family="Fira Sans", size = 14)) +
    geom_text(data = avg, aes(label=type, family = "Fira Sans"), size=10) +
    labs(x = "F2 values", y = "F1 values") +
    stat_ellipse(type = "t", linetype=2, geom="polygon", alpha=0.25, aes(fill=type)) +
    scale_x_reverse() +
    scale_y_reverse() +
    border()
  # Marginal density plot of x (top panel) and y (right panel)
  xplot <- ggdensity(df, "f2", fill = "type",
                     palette = "jco") + scale_x_reverse()
  yplot <- ggdensity(df, "f1", fill = "type", 
                     palette = "jco")+ 
    scale_x_reverse()+
    rotate()
  # Cleaning the plots
  sp <- sp + rremove("legend")
  yplot <- yplot + clean_theme() + rremove("legend")
  xplot <- xplot + clean_theme() + rremove("legend")
  # Arranging the plot using cowplot
  plot_grid(xplot, NULL, sp, yplot, ncol = 2, align = "hv", 
            rel_widths = c(3, 1), rel_heights = c(1, 3))  
  
}
makeplot()


ggboxplot(df, "type", "delta", fill = "type",
          palette = "jco",alpha = 0.6)+ 
  rremove("legend") +
  theme(text=element_text(family="Fira Sans", size = 18)) +
  labs(x = "Type of the following sound", y = "ΔHz")

ggboxplot(df, "type", "delta", fill = "type",
               palette = "jco", alpha = 0.6,
               add = "jitter",
          add.params = list(size = 3)) +
  rremove("legend") +
  theme(text=element_text(family="Fira Sans", size = 18)) +
  labs(x = "Type of the following sound", y = "ΔHz")



df$ctype <- ifelse(df$type == "/j/", .5, -.5)
df$person %<>% as.factor()
df$position %<>% as.factor()
df$cend <- ifelse(df$position == "end", .5, -.5)

model_null <- brm(delta ~ 1,
             family = gaussian(),
             core = 4,
             data = df)

model_norandom <- brm(delta ~ ctype*cend,
             family = gaussian(),
             core = 4,
             data = df)

model <- brm(delta ~ ctype * cend + (ctype * cend|person),
             family = gaussian(),
             core = 4,
             data = df)


model.coef.plot <-
  mcmc_intervals(
    model,
    pars = c("b_Intercept", "b_ctype", "b_cend", "b_ctype:cend"),
    point_est = "median",
    prob = 0.8, prob_outer = 0.95
  ) 
model.coef.plot <- model.coef.plot 

model.coef.plot <- model.coef.plot + vline_0(color = "blue", linetype = 2)