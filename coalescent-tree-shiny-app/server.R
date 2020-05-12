if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

if (!("ggtree" %in% rownames(installed.packages())))  {
  BiocManager::install("ggtree")
}


library(shiny)
library(tidyverse)
library(ape)
library(treeio)
library(ggtree)




#### Loading up the data, etc ####

# get the data from the RENT+ runs
load("data/coal-trees-etc-for-shiny.rda")

# process the seq_meta into something we can join to the tree:
add_meta <- for_input %>%
  select(index, haplo_name) %>%
  left_join(seq_meta, by = "haplo_name") %>%
  mutate(
    haplo_lineage = ifelse(NumSs > 125, "E-lineage", "L-lineage"),
    RoSA_zygosity = ifelse(inHetFish, "Heterozygous", "Homozygous")
  )

# get the colors
source("R/define_fcolors_all_sf.R")
fcolors_all_sf["Homozygous"] <- "gray"
fcolors_all_sf["L-lineage"] <- "blue"
fcolors_all_sf["E-lineage"] <- "gold"



# define a function for the plot
# here is a function to print two trees left and right
# from: https://yulab-smu.github.io/treedata-book/chapter2.html#ggtree-fortify
#' color_connectors_by = "basin"
#' color_connectors_by = "ecotype"
#' color_connectors_by = "rosa_zygosity"
#' color_connectors_by = "population"
plot_facing_trees <- function(
  pos1,
  pos2,
  color_connectors_by = "haplo_lineage") 
{
  T1 <- all_trees[[pos1]]
  T2 <- all_trees[[pos2]]
  
  p1 <- ggtree(T1)
  p2 <- ggtree(T2)
  
  p1p <- p1 %<+% add_meta
  p2p <- p2 %<+% add_meta
  
  d1 <- p1p$data
  d2 <- p2p$data
  
  ## reverse x-axis and 
  ## set offset to make the tree in the right hand side of the first tree
  gap <- 35
  d2$x <- max(d2$x) - d2$x + max(d1$x) + 1 + gap
  
  dd <- bind_rows(d1, d2) %>% 
    filter(!is.na(label))
  
  g_base <- p1p + geom_tree(data = d2) +
    scale_colour_manual(values = fcolors_all_sf)
  
  g_next <- switch(
    color_connectors_by,
    haplo_lineage = g_base + geom_line(aes(x, y, group = label, colour = haplo_lineage), data = dd, size = 0.2),
    basin = g_base + geom_line(aes(x, y, group = label, colour = Basin), data = dd, size = 0.2),
    ecotype = g_base + geom_line(aes(x, y, group = label, colour = Ecotype), data = dd, size = 0.2),
    rosa_zygosity = g_base + geom_line(aes(x, y, group = label, colour = RoSA_zygosity), data = dd, size = 0.2),
    population = g_base + geom_line(aes(x, y, group = label, colour = Population), data = dd, size = 0.2)
  )
  
  g_next + guides(colour = guide_legend(override.aes = list(size = 1.5)))
}


# here are the positions of our RoSA Markers
marker_poses <- c(12267547, 12270268, 12273002, 12277551, 12279292, 12279328, 12281357, 12281401)

# here is a tibble of all the variant positions
var_poses <- tibble(pos = as.integer(names(all_trees))) %>%
  mutate(isAssay = pos %in% marker_poses)

# here is a function to plot the positions and the current tree positions
plot_line <- function(left, right) {
  ggplot(var_poses, aes(x = pos/1e6, colour = isAssay)) + 
    geom_vline(xintercept = as.numeric(left)/1e6, colour = "orange", size = 1.2) + 
    geom_vline(xintercept = as.numeric(right)/1e6, colour = "violet", size = 1.2) + 
    geom_rug(length = unit(0.3, "npc")) +
    scale_colour_manual(values = c(`TRUE` = "red", `FALSE` = "gray")) +
    theme_bw() +
    xlab("Variant Positions on Chromosome 28 (Mb). Left Tree at Orange Line, Right Tree at Violet Line") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    guides(colour = guide_legend(override.aes = list(size = 1.5)))
}

#### The reactive parts ####
function(input, output, session) {
  
  observeEvent(input$rtpp, {
    cidx <- which(names(all_trees) == input$right_tree)
    nidx <- cidx
    if (cidx < length(names(all_trees))) {
      nidx <- cidx + 1
    }
    new_pos <- names(all_trees)[nidx]
    
    updateSelectInput(session, "right_tree", selected = new_pos)
  })
  
  observeEvent(input$rtpm, {
    cidx <- which(names(all_trees) == input$right_tree)
    nidx <- cidx
    if (cidx > 1) {
      nidx <- cidx - 1
    }
    new_pos <- names(all_trees)[nidx]
    
    updateSelectInput(session, "right_tree", selected = new_pos)
  })
  
  output$pos_plot <- renderPlot({
    plot_line(left = input$left_tree, right = input$right_tree)
  },
  height = 110, width = 850)
  
  output$plot <- renderPlot({
    
    plot_facing_trees(
      pos1 = input$left_tree,
      pos2 = input$right_tree,
      color_connectors_by = input$color_by
    )
  }, height = 500, width = 850)
  
}



