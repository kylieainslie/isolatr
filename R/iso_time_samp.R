# Sample time to isolation from infection for primary close contacts
# Draws n samples from the active detection distribution (contact tracing) for the specified TTIQ scenario

iso.time.samp <- function(n.ind, the.scenario = "optimal"){
  # Need this distribution from others, later make input n.
  # Consistent with JVR for now — assume they are idenfified somewhere between infection and symptom onset
  # pmax(incubation.periods*runif(length(incubation.periods)), incubation.periods - rexp(length(incubation.periods), rate = 1/4))

  # The context is PCC's of cases. Their time to isolation should come from the active component (contact-tracing), rather than passive
  distn.dat %>%
    filter(scenario == the.scenario) %>%
    mutate(x = as.numeric(time_to_active)) %>%
    select(x) %>%
    filter(is.finite(x)) %>%
    slice_sample(n = n.ind, replace = TRUE) %>%
    pull() %>% as.numeric()
}
