# Evaluate quarantine testing strategy with specified test times
# Takes simulation output and applies testing schedule, filters infections based on first positive test,
# and calculates infection potential in quarantine (IPq) and mean cases

CQ.sim.test.times <- function(CQ.sim.output, n.ind, test.times, VE.trans, the.scenario){
  out <- CQ.sim.output %>%
    group_by(i) %>%
    mutate(first.pos = testing.function2(test.times = test.times, iso.time = iso.time,
                                         inc.period = inc.period, the.scenario = the.scenario)) %>%
    mutate(first.pos = first.pos + test.turnaround.samp(n = 1, the.scenario = the.scenario) +
                                    other.delay.samp(n = 1, the.scenario = the.scenario)) %>%
    ungroup() %>%
    filter(who == "preiso" |
             who == "hh" & inf.times < first.pos |
             who == "postiso" & is.infinite(first.pos)) %>%
    mutate(ipq = gi.dist.cdf(q = pmin(first.pos, det) - inf.times) * TP * (1 - VE.trans*sc.vac.status)) %>%
    summarise(IPq = sum(ipq, na.rm = TRUE)/n.ind, sdIPq = sd(ipq, na.rm = TRUE), mean.cases = n()/n.ind)
  return(out)
}
