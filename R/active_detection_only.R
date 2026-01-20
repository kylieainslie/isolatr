# Sample time to active detection (contact tracing) without infection times
# Draws n samples of time to active detection for the specified TTIQ scenario

active.detection.only <- function(n, the.scenario){

  distn.dat %>%
    filter(scenario == the.scenario) %>%
    select(time_to_active) %>%
    slice_sample(n = n) %>%
    pull() %>% as.numeric()
}
