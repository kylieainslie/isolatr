# Convert a two-column data frame to a named vector
# Takes first column as names, second column as values

to.named.vector <- function(df){
  out <- df[,2] %>% pull()
  names(out) <- as.character(df[,1] %>% pull())
  return(out)
}
