# Get cumulative distribution of household sizes for a specific state
# Returns named vector of cumulative proportions for household sizes 1-8+ for the specified Australian state

hhsizes <- function(the.state){
  hhsize.dat %>% select(number, unabbreviate_states(the.state)) %>% to.named.vector() %>% cumsum()
}
