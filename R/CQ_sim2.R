# Community Quarantine simulation model for primary close contacts
# Simulates transmission from index cases accounting for: household structure, vaccination status,
# isolation timing, quarantine duration, and TTIQ scenario. Returns data frame of secondary infections.

CQ.sim2 <- function(n.ind, TP, k, p.vac.idx, p.vac.sc, vacc.cor, VE.trans, VE.inf, quarantine.duration, the.scenario, the.state = "NSW"){

  set.seed(1)
  # tic <- Sys.time()
  out <- data.frame("i" = 1:n.ind) %>%
    mutate(vacc.status = rbinom(n.ind, size = 1, prob = p.vac.idx), #) %>%
           inc.period = inc.period.samp(n.ind), #) %>%
           iso.time = iso.time.samp(n.ind, the.scenario), #) %>%
           ncases = ncases.samp(n.ind, TP, k), # ) %>%
           hh.size = samp.hh.size(n.ind, the.state)) %>% # individual-level details
    group_by(i) %>%
    mutate(inf.times = list(gi.dist.samp(ncases))) %>%
    unnest(inf.times) %>%
    # mutate(preiso = inf.times < iso.time,
    #        hh = inf.times > iso.time & inf.times < iso.time + quarantine.duration,
    #        postiso = inf.times > iso.time + quarantine.duration) %>%
    # group_by(i, hh) %>%
    # mutate(nh = row_number())
    mutate(who.original = case_when(
      inf.times < iso.time ~ "preiso",
      inf.times > iso.time & inf.times < iso.time + quarantine.duration ~ "hh",
      inf.times > iso.time + quarantine.duration ~ "postiso"
    )) %>%
    # # randomly sample preiso's to be hh instead
    mutate(who.new = hh.infections.pre.or.postiso(inf.times = inf.times, who = who.original, hh.size = hh.size, p = 0.5)) %>%
    group_by(i, who.new) %>%
    mutate(hh.counter = case_when(
      who.new == "hh" ~ row_number(),
      TRUE ~ 100L)) %>%
    ungroup() %>%
    mutate(keep.row = case_when(
      who.new == "hh" & who.original == "hh" & hh.counter >= hh.size ~ 0,
      TRUE ~ 1
    )) %>%
    filter(keep.row==1) %>%
    mutate(who = case_when(
      hh.counter >= hh.size ~ who.original,
      TRUE ~ who.new
    )) %>%
    select(-who.original, -who.new, -hh.counter, -keep.row) %>%
    group_by(i) %>%
    mutate(sc.vac.status = case_when(
      who == "hh" ~ cor.binary(n = n(), corr = vacc.cor, idx.vac.status = vacc.status),
      TRUE ~ rbernoulli(n = n(), p = p.vac.sc)
    )) %>%
    mutate(det = passive.detection(inf.times, the.scenario)) %>%
    ungroup() %>%
    mutate(unprotected = runif(n()) < (1 - VE.trans*vacc.status)*(1 - VE.inf*sc.vac.status)) %>%
    filter(unprotected) %>% select(-unprotected)
  # (toc <- Sys.time() - tic)
  # Break here as this is where the test.times comes in

  return(out)
}
