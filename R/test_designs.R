# Generate all valid test schedule designs
# Creates combinations of test times with constraints on minimum spacing and first test timing

test.designs <- function(times, n, min.space, t1.prior.to = 5){
  l <- rep(list(times), n)
  all.times <- expand.grid(l)

  if(n > 1){
    all.times<- all.times %>% mutate(id = row_number()) %>%
      pivot_longer(cols = starts_with("Var")) %>%
      group_by(id) %>% filter(min(diff(value))>=min.space) %>%
      pivot_wider(names_from = "name", values_from = "value") %>%
      ungroup() %>%
      select(-id) %>%
      filter(Var1 <= t1.prior.to)
  }
  return(all.times)
}
