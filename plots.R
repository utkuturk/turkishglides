# set working directory
setwd("~/Documents/ma phonology/paper/rec")

# get the csv
# consider using rPraat next time? 
library(dplyr)
f1_f2 <- read.csv("f1f2ofbenbelbey.csv")

# the difference between f1 and f2?


f1_f2$delta <- f1_f2$f2-f1_f2$f1
f1_f2$bilingual <- ifelse(f1_f2$bilingual == 1, T, F)
#f1_f2 <- f1_f2 %>% subset(subject != 2)
avg <- f1_f2 %>% 
  dplyr::select(-pitch) %>%
  dplyr::group_by(word) %>%
  summarise(f1 = mean(f1),
            f2 = mean(f2),
            delta = mean(delta))
library(ggplot2)
plot1 <- ggplot(data=f1_f2, aes(x=f2, y=f1)) +
  stat_ellipse(type = "norm", linetype=2, geom="polygon", alpha=0.25, aes(fill=word)) +
  geom_point(aes(color=word)) +
  geom_text(data = avg, aes(label=word), size=10) +
  scale_x_reverse() +
  scale_y_reverse()
print(plot1)
avg_d <- avg
avg_d$f_1 <- ifelse(avg_d$f1 <= 600, "low f1", "high f1")
avg_d$f_2 <- ifelse(avg_d$f2 >= 1850, "low f2", "high f2")

plot2 <- ggplot(data=avg_d, aes(x=word, y=delta, color = f_2)) +
  geom_boxplot()
print(plot2)
require(gridExtra)
grid.arrange(plot1, plot2, nrow=2)



