# Calculate passive detection times for infected individuals
# Adds time to passive detection (from scenario data) to infection times

passive.detection <- function(inf.times, the.scenario){

  it <- unlist(inf.times)
  n <- length(it)

  # if rand < xx, sample below, else, Inf
  distn.dat %>%
    filter(scenario == the.scenario) %>%
    select(time_to_passive) %>%
    slice_sample(n = n, replace = TRUE) %>%
    pull() %>% as.numeric() + it

}
