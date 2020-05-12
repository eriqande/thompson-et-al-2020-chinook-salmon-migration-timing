#' computes annotation column positions for plots
#' @param g the current ggplot object to add these things to
extra_labels <- function(g, D, h_ord, xmids, ymids, sq_midy = -5, pop_size = 9.0, lineage_size = 13.0, ecotype_size = 16.0, letter_size = 13.0, col_lab_size = 12.5, row_just = 0) {
  # first, figure out the y-midpoints of different column bits
  tmp <- D %>%
    select(haplo_name, ecotype, lineage, pop) %>%
    mutate(hnfact = factor(haplo_name, levels = rev(h_ord))) %>%
    arrange(hnfact) %>%
    group_by(hnfact) %>%
    slice(1) %>%
    ungroup() %>%
    mutate(ypos = 1:n())
  
  ecotype_pos <- tmp %>%
    group_by(ecotype) %>%
    summarise(midy = (min(ypos) - 0.5 + max(ypos) + 0.5) / 2) %>%
    mutate(midx = xmids$midx[xmids$column == "ecotype"])
  
  lineage_pos <- tmp %>%
    mutate(ecotype = ifelse(ecotype %in% c("Winter", "Late_Fall"), "Fall", ecotype)) %>%
    group_by(ecotype, lineage) %>%
    summarise(midy = (min(ypos) - 0.5 + max(ypos) + 0.5) / 2) %>%
    mutate(midx = xmids$midx[xmids$column == "lineage"])
  
  pop_pos <- tmp %>%
    group_by(ecotype, lineage, pop) %>%
    summarise(midy = (min(ypos) - 0.5 + max(ypos) + 0.5) / 2) %>%
    mutate(midx = xmids$midx[xmids$column == "pop"])
  
  # read in what we want to labels to be:
  labels <- read_csv("data/ac_labels.csv")
  
  # now get the labels all together for each
  pops_labels <- pop_pos %>%
    left_join(labels)
  
  lineage_labels <- lineage_pos %>%
    left_join(labels %>% group_by(ecotype, lineage) %>% slice(1))
  
  ecotype_labels <- ecotype_pos %>%
    left_join(labels %>% group_by(ecotype) %>% slice(1))
  
  # now, make a data frame of labels for the tops of the ac-columns
  col_labs <- tibble(label = c("Ecotype", "Basin/Lineage", "Population")) %>%
    mutate(xpos = xmids$midx,
           ypos = 1.01 * length(unique(D$haplo_name)) ) 
  
  # and now, add some layers to the plot
  g2 <- g +
    geom_text(data = pops_labels, 
              mapping = aes(x = midx, y = midy, label = pop_label), 
              angle = 90,
              colour = "black",
              size = pop_size
    ) +
    geom_text(data = lineage_labels, 
              mapping = aes(x = midx, y = midy, label = lineage_label), 
              angle = 90,
              colour = "black",
              size = lineage_size
    ) +
    geom_text(data = ecotype_labels, 
              mapping = aes(x = midx, y = midy, label = ecotype_label), 
              angle = 90,
              colour = "black",
              size = ecotype_size
    ) +
    geom_text(data = ymids, 
              mapping = aes(y = midy, label = label), 
              hjust = row_just,
              x = max(xmids$midx),
              colour = "black",
              size = letter_size
    ) + 
    geom_text(data = col_labs, 
              mapping = aes(x = xpos, y = ypos, label = label), 
              hjust = 1,
              angle = -78,
              colour = "black",
              size = letter_size
    )
  
  
  
  g2
  
}
