#' you gotta use miles at this point...
#' @param ls a linestring (as an sfc)
#' @param lo a distance in units::units() along the line string to start including points. Use, for example, units::set_units(2.4, mile)
#' @param hi a distance in units::units() along the linestring to stop including points
#' Note,  if either of lo or hi are negative then the distance is measured from the far end of the linestring.  They have to both be negative or both positive.  If they are not no warning is given
#' but it fails, likely.  Note that hi should be "bigger negative" than lo
line_seg_by_distance <- function(ls, lo, hi, asSFC = TRUE) {
  
  
  tlo <- lo
  thi <- hi
  if(lo < units::set_units(0, m)) {
    thi <- st_length(ls) + lo
  }
  if(hi < units::set_units(0, m)) {
    tlo <- st_length(ls) + hi
  }
  lo <- tlo
  hi <- thi
  
  # note that I tried computing just the distances between successive points
  # using the by_element = TRUE option of st_distance(), but this took even longer.
  # that was totally weird, I don't understand why it is slower...Oh well, I'll leave
  # it like this.
  lsb <- st_cast(ls, "POINT")
  lsb_dist <- st_distance(lsb)
  n <- nrow(lsb_dist)
  x <- 1:n
  updi <- lsb_dist[n * x + x]
  succ_dists <- c(units::set_units(0, mile), updi[-length(updi)])
  
  cum_dists <- cumsum(succ_dists)
  
  ppts <- lsb[cum_dists >= lo & cum_dists <= hi]
  
  ret <- st_linestring(st_coordinates(ppts))
  
  if(asSFC == FALSE) {
    return(ret)
  }
  ret <- st_sfc(ret, crs = st_crs(ls))
  
}