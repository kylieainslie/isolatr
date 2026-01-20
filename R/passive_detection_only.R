# Sample time to passive detection without infection times
# Draws n samples of time to passive detection for the specified TTIQ scenario

passive.detection.only <- function(n, the.scenario){


  distn.dat %>%
    filter(scenario == the.scenario) %>%
    select(time_to_passive) %>%
    slice_sample(n = n) %>%
    pull() %>% as.numeric()


}
