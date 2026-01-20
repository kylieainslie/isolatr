# Script to read in and combine results 
# 
# David J Price
# 21 Oct 2021
# 

require(tidyverse)
setwd("~/Desktop/COVID_Misc/WP1/")

output.folder <- "output/27Oct2021_report"

# Load output
load(paste0(output.folder, "/opt_times_optimalttiq_14HQduration.RData"))
colnames(all.times) <- paste0("t",1:ncol(all.times))
out <- cbind(all.times, output) %>% mutate(scenario = "optimal", q.duration = 14)

load(paste0(output.folder, "/opt_times_optimalttiq_7HQduration.RData"))
colnames(all.times) <- paste0("t",1:ncol(all.times))
out <- out %>% 
  add_row(cbind(all.times, output)%>% mutate(scenario = "optimal", q.duration = 7))

load(paste0(output.folder, "/opt_times_partialttiq_14HQduration.RData"))
colnames(all.times) <- paste0("t",1:ncol(all.times))
out <- out %>% 
  add_row(cbind(all.times, output)%>% mutate(scenario = "partial", q.duration = 14))

load(paste0(output.folder, "/opt_times_partialttiq_7HQduration.RData"))
colnames(all.times) <- paste0("t",1:ncol(all.times))
out <- out %>% 
  add_row(cbind(all.times, output)%>% mutate(scenario = "partial", q.duration = 7))

load(paste0(output.folder, "/opt_times_current_nsw_case_initttiq_14HQduration.RData"))
colnames(all.times) <- paste0("t",1:ncol(all.times))
out <- out %>% 
  add_row(cbind(all.times, output)%>% mutate(scenario = "nsw_case_init", q.duration = 14))

load(paste0(output.folder, "/opt_times_current_nsw_case_initttiq_7HQduration.RData"))
colnames(all.times) <- paste0("t",1:ncol(all.times))
out <- out %>% 
  add_row(cbind(all.times, output)%>% mutate(scenario = "nsw_case_init", q.duration = 7))


##

out <- out %>% mutate(t2 = case_when(
  is.na(t2) ~ Inf,
  TRUE ~ t2
),
t3 = case_when(
  is.na(t3) ~ Inf,
  TRUE ~ t3
)) %>% 
  mutate(n.tests = 3 - is.infinite(t2) - is.infinite(t3))


## Scatter plot of design output to check patterns 
out %>%
  filter(!is.infinite(t1) & !is.infinite(t2) ) %>%
  # select(-t3) %>%
  pivot_longer(cols = t1:t3) %>%
  ggplot() + aes( x= value, y= IPq, colour = scenario) + geom_point() + facet_grid(q.duration ~ name)



# Sampling times
the.optimal.times <- out %>% 
  group_by(scenario, q.duration, n.tests) %>% 
  filter(IPq == min(IPq)) %>% 
  mutate(TT = paste0("(",t1, ",",t2, ",", t3, ")")) %>% 
  mutate(TT = gsub(pattern = ",Inf", replacement = "", x = TT)) %>% 
  select(scenario, q.duration, n.tests, TT) 


# The optimal ones, written to a csv
the.optimal.times %>% 
  pivot_wider(names_from = scenario, values_from = TT) %>% 
  write_csv("./output/optimal_testing_times.csv")


# Range of sampling times, written to a csv
out %>% 
  mutate(n.tests = 3 - is.infinite(t2) - is.infinite(t3)) %>% 
  group_by(scenario, q.duration, n.tests) %>% 
  arrange(IPq) %>% 
  mutate(efficiency = IPq / min(IPq)) %>% # filter(efficiency==1) %>% arrange(desc(scenario), desc(q.duration), desc(n.tests))
  # mutate(rank = row_number()) %>% 
  filter(efficiency <= 1.02) %>% 
  mutate(T1 = paste0(min(t1),"-",max(t1)),
         T2 = paste0(min(t2),"-",max(t2)),
         T3 = paste0(min(t3),"-",max(t3))) %>% 
  mutate(T2 = gsub("Inf-Inf","-",T2),
         T3 = gsub("Inf-Inf","-",T3)) %>% 
  select(scenario, q.duration, n.tests, T1, T2, T3) %>% 
  group_by(scenario, q.duration, n.tests) %>% 
  distinct() %>% 
  arrange(desc(q.duration), desc(n.tests)) %>% 
  mutate(TT = paste0(T1,", ", T2, ", ", T3)) %>% 
  select(-T1, -T2, -T3) %>% 
  pivot_wider(names_from = scenario, values_from = TT) %>% 
  write_csv("./output/optimal_testing_time_range.csv")



# Bar plot of the optimal test strategy under each delay distribution, quarantine duration, number of tests
# stick IPq values back onto the optimal... this is an odd way to do this, but whatever...
the.optimal.times %>% left_join(., out %>%  mutate(TT = paste0("(",t1, ",",t2, ",", t3, ")")) %>% 
                                  mutate(TT = gsub(pattern = ",Inf", replacement = "", x = TT)) %>% 
                                  select(scenario, q.duration, n.tests, TT, IPq), by = c("scenario","q.duration","n.tests","TT")) %>% 
  # add_row() %>% # ADD IN OTHER DESIGNS HERE
  mutate(scenario = factor(scenario, levels = c("optimal", "nsw_case_init","partial"), 
                           labels = c("Optimal delays", "NSW case-initiated delays","Partial delays"), ordered = TRUE)) %>%
  mutate(q.duration = factor(q.duration, levels = c("14", "7"), labels = c("14-days", "7-days"), ordered = TRUE)) %>% 
  # mutate(qd.tt = paste0(q.duration,"-days;\n",n.tests," tests;\n",TT)) %>% 
  ggplot() + 
  aes(x = TT, y = IPq) + 
  geom_col(position = position_dodge(preserve = "single")) + 
  scale_x_discrete("Test Strategy") +
  # scale_y_continuous("Mean Secondary Infections from SC of PCC") +
  scale_y_continuous("IPq") +
  # facet_wrap(scenario~q.duration, nrow = 1, scales = "free_x") +
  ggh4x::facet_nested(~ scenario + q.duration, scales = "free_x") +
  cowplot::theme_cowplot() +
  # theme_bw() +
  theme(text = element_text(size = 16),
        axis.text = element_text(size = 16))

ggsave("./output/plot_test_comparison_bw.png", height = 8, width = 16, units = "in", bg = "white")



# Compare 14 vs 7 day quarantine for vacc/unvacc PCCs, and "no test for vacc"

load(paste0(output.folder,"/opt_times_optimalttiq_7_and_14d_HQduration.RData"))
IPq_7_v_14_optimal <- average.IPq
tt7v14_optimal <- "Vacc:(1,6),\nUnvacc:(1,3,6)"
load(paste0(output.folder, "/opt_times_partialttiq_7_and_14d_HQduration.RData"))
IPq_7_v_14_partial <- average.IPq
tt7v14_partial <- "Vacc:(1,7),\nUnvacc:(1,3,10)"


load(paste0(output.folder,"/opt_times_optimalttiq_no_test_vacc_7.RData"))
IPq_notest7_optimal <- average.IPq
nt7_optimal <- "Vacc:-,\nUnvacc:(1,3,6)"
load(paste0(output.folder,"/opt_times_partialttiq_no_test_vacc_7.RData"))
IPq_notest7_partial <- average.IPq
nt7_partial <- "Vacc:-,\nUnvacc:(1,3,10)"


out2 <- tribble(
  ~TT, ~IPq, ~ scenario, ~ q.duration, ~n.tests,
  "Vacc 7D: (1,6)         \nUnvacc 14D: (1,3,6)", IPq_7_v_14_optimal, "optimal", 14, 3,
  "Vacc 7D: (1,7)           \nUnvacc 14D: (1,3,10)", IPq_7_v_14_partial, "partial", 14, 3,
  "Vacc 7D: -               \nUnvacc 14D: (1,3,6)", IPq_notest7_optimal, "optimal", 14, 3,
  "Vacc 7D: -                 \nUnvacc 14D: (1,3,10)", IPq_notest7_partial, "partial", 14, 3,
)

comparisons <- out %>% 
  group_by(scenario, q.duration, n.tests) %>% 
  filter(IPq == min(IPq)) %>% 
  mutate(TT = paste0("(",t1, ",",t2, ",", t3, ")")) %>% 
  mutate(TT = gsub(pattern = ",Inf", replacement = "", x = TT)) %>% 
  select(-t1, -t2, -t3) %>% 
  filter(q.duration == 14 & scenario %in% c("optimal","partial"), n.tests == 3) %>% 
  mutate(TT = paste0("Both ",q.duration, "D: ",TT)) %>%
  ungroup() %>% 
  add_row(out2) %>% 
  mutate(TT = factor(TT, levels = unique(.$TT), ordered = TRUE))


# Bar plot of the alternative quarantine arrangements for vaccinated individuals
comparisons %>% 
  mutate(scenario = factor(scenario, levels = c("optimal","partial"), 
                           labels = c("Optimal delays", "Partial delays"), ordered = TRUE)) %>%
  ggplot() + 
  aes(x = TT, y = IPq) + 
  geom_col() +
  facet_grid(~scenario, scales = "free_x") +
  scale_x_discrete("Test Strategy") +
  scale_y_continuous("IPq") +
  cowplot::theme_cowplot() +
  # theme_bw() +
  theme(text = element_text(size = 16),
        axis.text = element_text(size = 12))

ggsave("./output/bar_plot_vacc_differentq_xlabs.png",  width = 12, height = 5, units = "in", bg = "white")



# Plot dot/line plots of the test strategies (x) against the IPq (y)
plot.the.scenario <- "optimal"

the.opt <- out %>% 
  mutate(id = row_number()) %>%
  mutate(q.duration = factor(q.duration, levels = c("7", "14"), labels = c("7-day","14-day"), ordered = TRUE)) %>% 
  group_by(q.duration, scenario, n.tests) %>% 
  filter(IPq == min(IPq)) %>% 
  pivot_longer(cols = t1:t3) %>% filter(is.finite(value))

scatter1 <- out %>% 
  filter(scenario == plot.the.scenario, n.tests == 1) %>% 
  mutate(id = row_number()) %>% 
  mutate(q.duration = factor(q.duration, levels = c("7", "14"), labels = c("7-day","14-day"), ordered = TRUE)) %>% 
  pivot_longer(cols = t1) %>%
  select(-t2, -t3) %>%
  ggplot() + aes( x= value, y= IPq, group = id) + 
  # geom_line(alpha=0.2) + 
  geom_point(aes(colour = name), alpha = 0.6) + 
  
  geom_point(data = the.opt %>% 
               filter(scenario == plot.the.scenario, n.tests == 1), aes(x = value, y= IPq, group = id)) +
  # geom_line(data = the.opt %>% 
  #             filter(scenario == "optimal", n.tests == 1), aes(x = value, y= IPq, group = id)) +
  
  scale_y_continuous("IPq") +
  scale_x_continuous("Test day for PCC", breaks = seq(1,14,by = 1)) + 
  coord_cartesian(ylim = c(2, 6)) +
  facet_grid(q.duration~.) +
  scale_colour_manual("Test Number", values = c("darkviolet"), labels = c("1")) +
  cowplot::theme_cowplot() +
  # theme_bw() +
  theme(legend.position = "top")

ggsave("./output/dot_plot_one_test_bw.png", height = 6, width = 8, units = "in", bg = "white")

scatter2 <- out %>% 
  filter(scenario == plot.the.scenario, n.tests == 2) %>% 
  mutate(id = row_number()) %>% 
  mutate(q.duration = factor(q.duration, levels = c("7", "14"), labels = c("7-day","14-day"), ordered = TRUE)) %>% 
  pivot_longer(cols = t1:t2) %>%
  ggplot() + aes( x= value, y= IPq, group = id) + 
  geom_line(alpha=0.2) + 
  geom_point(aes(colour = name), alpha = 0.6) + 
  
  geom_point(data = the.opt %>% 
               filter(scenario == plot.the.scenario, n.tests == 2), aes(x = value, y= IPq, group = id)) +
  geom_line(data = the.opt %>% 
              filter(scenario == plot.the.scenario, n.tests == 2), aes(x = value, y= IPq, group = id)) +
  
  scale_y_continuous("IPq") +
  scale_x_continuous("Test day for PCC", breaks = seq(1,14,by = 1)) + 
  coord_cartesian(ylim = c(2, 6)) +
  facet_grid(q.duration~.) +
  scale_colour_manual("Test Number", values = c("darkviolet","green4"), labels = c("1","2")) +
  cowplot::theme_cowplot() +
  # theme_bw() +
  theme(legend.position = "top")

ggsave("./output/dot_plot_two_tests_bw.png", height = 6, width = 8, units = "in", bg = "white")


scatter3 <- out %>% 
  filter(scenario == plot.the.scenario, n.tests == 3) %>% 
  mutate(id = row_number()) %>% 
  mutate(q.duration = factor(q.duration, levels = c("7", "14"), labels = c("7-day","14-day"), ordered = TRUE)) %>% 
  pivot_longer(cols = t1:t3) %>%
  ggplot() + aes( x= value, y= IPq, group = id) + 
  geom_line(alpha=0.1) + 
  geom_point(aes(colour = name), alpha = 0.6) + 
  
  geom_point(data = the.opt %>% 
               filter(scenario == plot.the.scenario, n.tests == 3), aes(x = value, y= IPq, group = id)) +
  geom_line(data = the.opt %>% 
              filter(scenario == plot.the.scenario, n.tests == 3), aes(x = value, y= IPq, group = id)) +
  
  scale_y_continuous("IPq") +
  scale_x_continuous("Test day for PCC", breaks = seq(1,14,by = 1)) + 
  coord_cartesian(ylim = c(2, 6)) +
  facet_grid(q.duration~.) +
  scale_colour_manual("Test Number", values = c("darkviolet","green4","darkorange"), labels = c("1","2","3")) +
  cowplot::theme_cowplot() +
  # theme_bw() +
  theme(legend.position = "top")

ggsave("./output/dot_plot_three_tests_bw.png", height = 6, width = 8, units = "in", bg = "white")


# ggsave("./output/dot_plot_one_tests_bw_size.png", plot = scatter1, height = 8, width = 4, units = "in", bg = "white")
# ggsave("./output/dot_plot_two_tests_bw_size.png", plot = scatter2, height = 8, width = 4, units = "in", bg = "white")
# ggsave("./output/dot_plot_three_tests_bw_size.png", plot = scatter3, height = 4, width = 4, units = "in", bg = "white")


out %>% 
  filter(scenario == plot.the.scenario) %>% 
  mutate(id = row_number()) %>% 
  mutate(q.duration = factor(q.duration, levels = c("7", "14"), labels = c("7-day","14-day"), ordered = TRUE)) %>% 
  pivot_longer(cols = t1:t3) %>%
  filter(is.finite(value)) %>% 
  # select(-t2, -t3) %>%
  ggplot() + aes( x= value, y= IPq, group = id) + 
  geom_line(alpha=0.2) +
  geom_point(aes(colour = name), alpha = 0.6) + 
  
  geom_point(data = the.opt %>% 
               filter(scenario == plot.the.scenario), aes(x = value, y= IPq, group = id)) +
  # geom_line(data = the.opt %>% 
  #             filter(scenario == "optimal", n.tests == 1), aes(x = value, y= IPq, group = id)) +
  
  scale_y_continuous("IPq") +
  scale_x_continuous("Test day for PCC", breaks = seq(2,14,by = 2)) + 
  coord_cartesian(ylim = c(2, 6)) +
  facet_grid(q.duration~n.tests) +
  scale_colour_manual("Test Number", values = c("darkviolet","green4","darkorange"), labels = c("1","2","3")) +
  cowplot::theme_cowplot() +
  theme(legend.position = "top",
        text = element_text(size = 16))


ggsave("./output/dot_plot_all_tests.png", height = 8, width = 10, units = "in", bg = "white")




## Summary statistics of inputs ----

# Delay distributions
delay.dat <- data.frame("Optimal" = passive.detection.only(n = 5e4, the.scenario = "optimal"),
                        "Partial" = passive.detection.only(n = 5e4, the.scenario = "partial"),
                        "NSW case-initiated" = passive.detection.only(n = 5e4, the.scenario = "current_nsw_case_init"))

# delay.distn.cdf.plot <- 
delay.dat %>% 
  pivot_longer(cols = everything()) %>%
  mutate(name = case_when(
    name == "NSW.case.initiated" ~ "NSW case-initiated",
    TRUE ~ name
  )) %>% 
  mutate(name = factor(name, levels = c("Optimal", "NSW case-initiated","Partial"), ordered = TRUE)) %>% 
  ggplot() + 
  aes(x = value, colour = name) + 
  stat_ecdf(size = 1) +
  scale_x_continuous("Days", expand = c(0,0)) +
  scale_y_continuous("Cumulative Probability of Detection", expand = c(0,0)) +
  scale_colour_discrete("Delay to isolation") +
  coord_cartesian(xlim = c(0, 30)) +
  cowplot::theme_cowplot() +
  theme(legend.position = c(0.7, 0.2),
        axis.text = element_text(size = 18),
        text = element_text(size = 18))

ggsave("./output/delay_distributions.png", plot = delay.distn.cdf.plot, height = 8, width = 12, units = "in", bg = "white")

delay.dat %>% 
  pivot_longer(cols = everything()) %>% 
  mutate(name = case_when(
    name == "NSW.case.initiated" ~ "NSW case-initiated",
    TRUE ~ name
  )) %>% 
  mutate(name = factor(name, levels = c("Optimal", "NSW case-initiated","Partial"), ordered = TRUE)) %>% 
  group_by(name) %>% 
  summarise(q50 = quantile(value, probs = 0.5),
            q90 = quantile(value, probs = 0.9))


# Test turnaround times
tat.dats <- data.frame("Optimal" = test.turnaround.samp(n = 5e5, the.scenario = "optimal"),
                       "Partial" = test.turnaround.samp(n = 5e5, the.scenario = "partial"),
                       "NSW case-initiated" = test.turnaround.samp(n = 5e5, the.scenario = "current_nsw_case_init"))

# tat.cdf.plot <- 
tat.dats %>% 
  pivot_longer(cols = everything()) %>%
  mutate(name = case_when(
    name == "NSW.case.initiated" ~ "NSW case-initiated",
    TRUE ~ name
  )) %>% 
  mutate(name = factor(name, levels = c("Optimal", "NSW case-initiated","Partial"), ordered = TRUE)) %>% 
  ggplot() + 
  aes(x = value, colour = name) + 
  stat_ecdf(size = 1) +
  scale_x_continuous("Days", expand = c(0,0), breaks = seq(0, 10, by = 2)) +
  scale_y_continuous("Cumulative Probability", expand = c(0,0)) +
  scale_colour_discrete("TAT Delay") +
  coord_cartesian(xlim = c(0, 10)) +
  cowplot::theme_cowplot() +
  theme(legend.position = c(0.8, 0.2),
        axis.text = element_text(size = 18),
        text = element_text(size = 18))
