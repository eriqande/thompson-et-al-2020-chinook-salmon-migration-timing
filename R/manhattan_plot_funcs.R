#' @param d data frame like sf_lite
#' @param len dataframe of chromosome lengths with columns Chromome and chrom_length
my_mh_prep <- function(d, len) {
  # first get cumulative position.  Note that chromosomes are ordered as they should be
  sandl <- d %>%
    count(Chromosome) %>%
    left_join(., len, by = "Chromosome") %>%
    mutate(chrom_start = cumsum(chrom_length) - chrom_length) %>%
    left_join(d, ., by = "Chromosome") %>%
    mutate(xpos = position + chrom_start) %>%
    mutate(cluster = ifelse(str_detect(Chromosome, "^NC_03"), Chromosome, "NWs")) %>%
    mutate(color_band = as.factor(as.integer(factor(cluster)) %% 2)) %>% # lump the NWs together to color and make names
    ungroup()

  axisdf <- sandl %>%
    group_by(Chromosome) %>%
    slice(1) %>%
    group_by(cluster) %>%
    summarize(
      clust_start = min(chrom_start),
      clust_length = sum(chrom_length),
      clust_center = (2 * clust_start + clust_length) / 2
    )

  list(snps = sandl, axisdf = axisdf)
}


#' a function to plot the prepped thing
plot_mh <- function(sandl, axisdf) {
  g <- ggplot(sandl, aes(x = xpos, y = abs_diff)) +
    geom_point(aes(color = color_band), alpha = 0.7, size = 0.9) +
    scale_color_manual(values = c("skyblue", "grey")) +

    # custom X axis:
    scale_x_continuous(label = axisdf$cluster, breaks = axisdf$clust_center) +
    scale_y_continuous(expand = c(0, 0.05)) + # remove space between plot area and x axis

    # Customize the theme:
    theme_bw() +
    theme(
      legend.position = "none",
      panel.border = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
    ) +
    ylim(0.25, 1.0)

  g
}
