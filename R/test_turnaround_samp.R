# Sample test turnaround times for a given TTIQ scenario
# Draws n samples from pre-loaded scenario-specific test turnaround time distributions

test.turnaround.samp <- function(n, the.scenario){
  # rexp(n, 0.5)
  # tat.dat %>%
  #   filter(scenario == the.scenario) %>%
  #   select(sampled_test_turnaround_time) %>%
  #   slice_sample(n = n, replace = TRUE) %>%
  #   pull()
  if(the.scenario == "partial"){
    sample(x = partial.tat.dat, size = n, replace = TRUE)}
  else { if(the.scenario == "optimal"){
    sample(x = optimal.tat.dat, size = n, replace = TRUE)
  } else{
    sample(x = nsw.ci.tat.dat, size = n, replace = TRUE)
  }
  }

}
