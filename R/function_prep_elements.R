#' @param plo the lo value of POS to go into the plot
#' @param phi the hi value
#' @param pby the step size
#' @param format  the C-print style format for the position text
prep_elements <- function(plo, phi, pby, format = "%.2f", sq_midy = -5, ar_shift = -9.8, DSET = big_haps2, Return_D_only = FALSE) {
  # get the haplotypes
  D <- DSET %>% 
    filter(POS >= plo, POS <= phi) %>%
    mutate(hnames = haplo_name,
           atypes = alle2)
  
  if(Return_D_only == TRUE) return(list(D = D))
  
  # get the position annotations/locations
  pos_annot <- tibble::tibble(pos = seq(min(D$POS), max(D$POS), by = pby))    %>%  
    mutate(pname = sprintf(format, pos/1e06))
  
  # get the annotation rows filtered down
  ann_rows <- annotation_rows_full %>%
    semi_join(D, by = "POS")
  
  repcontent <- tibble(POS = unique(D$POS)) %>%
    left_join(dna_repetitive_200, by = "POS") %>%
    rename(value = rep_mean_200) %>%
    select(POS, value)
  
  # get the annotation columns parameters for placing labels. This is sort of hacky
  tmp <- ecaRbioinf:::expand_anno_cols(annotation_columns, length(unique(D$POS)))
  anno_col_midpoints <- tmp %>% 
    group_by(column) %>%
    summarise(midx = (min(x) - 0.5 + max(x) + 0.5) / 2) %>%
    arrange(midx)
  
  # also get the annotation row paramers for placing labels
  tmp <- ecaRbioinf:::expand_anno_rows(annotation_rows_full, length(unique(D$haplo_name)))
  anno_row_midpoints <- tmp %>% 
    group_by(row) %>%
    summarise(midy = (min(y) - 0.5 + max(y) + 0.5) / 2) %>%
    arrange(desc(midy)) %>%
    mutate(midy = midy + ar_shift) %>%
    mutate(label = paste0(LETTERS[2:(n() + 1)], ")")) %>%
    bind_rows(tibble(row = "quant", midy = sq_midy, label = "A)"), .)

  
  list(D = D,
       pos_annot = pos_annot,
       ann_rows = ann_rows,
       repcontent = repcontent,
       ac_x_midpoints = anno_col_midpoints,
       ar_y_midpoints = anno_row_midpoints)
}
