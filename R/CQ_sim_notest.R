# Evaluate quarantine with no testing strategy
# Takes simulation output and evaluates transmission potential without any testing schedule,
# using only passive detection to determine isolation times

CQ.sim.notest <- function(CQ.sim.output, n.ind, VE.trans, the.scenario){
  out <- CQ.sim.output %>%
    group_by(i) %>%
    # mutate(first.pos = testing.function2(test.times = test.times, iso.time = iso.time,
    #                                      inc.period = inc.period, the.scenario = the.scenario)) %>%
    mutate(first.pos = passive.detection.only(n = n(), the.scenario = the.scenario)) %>%
    mutate(first.pos = first.pos + test.turnaround.samp(n = n(), the.scenario = the.scenario)) %>%
    ungroup() %>%
    filter(who == "preiso" |
             who == "hh" & inf.times < first.pos |
             who == "postiso" & is.infinite(first.pos)) %>%
    mutate(ipq = gi.dist.cdf(q = pmin(first.pos, det) - inf.times) * TP * (1 - VE.trans*sc.vac.status)) %>%
    summarise(IPq = sum(ipq, na.rm = TRUE)/n.ind, sdIPq = sd(ipq, na.rm = TRUE), mean.cases = n()/n.ind)
  return(out)
}
