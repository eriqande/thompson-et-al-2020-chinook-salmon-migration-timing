library(shiny)
library(tidyverse)
library(ape)



# get the data from the RENT+ runs
load("data/coal-trees-etc-for-shiny.rda")

# here is a vector that holds the possible values to color connectors by:
color_by_vals <- c(
  "haplo_lineage",
  "ecotype",
  "basin",
  "rosa_zygosity",
  "population"
)


fluidPage(
  
  titlePanel(h4("Chinook salmon, Chromosome 28 RoSA-haplotype coalescent tree viewer. Use the selection box to choose positions between the leftmost and rightmost (inclusive) SNP assays developed in the RoSA region.  Increment right tree position with + and - buttons. Set colors of connecting lines to different attributes using the selection box. Note that tree topologies at all positions are highly similar, differing primarily by length scaling and rotations, with some few sequences swapping branches.")), 
  
  inputPanel(
    selectInput("left_tree", label = "Left Side Tree SNP Position:",
                choices = names(all_trees), selected = "12267547", selectize = FALSE),
    selectInput("right_tree", label = "Right Side Tree SNP Position:",
                choices = names(all_trees), selected = "12267609", selectize = FALSE),
    selectInput("color_by", label = "Color Connecting Lines By:",
                choices = color_by_vals, selected = "haplo_lineage", selectize = FALSE),
    actionButton("rtpm", "Right Tree Pos. -"),
    actionButton("rtpp", "Right Tree Pos. +")
  ),
  
  mainPanel(
 
            
    fluidRow(
      column(12, plotOutput('pos_plot', inline = TRUE), center = TRUE)
    ),
    fluidRow(
      column(12, plotOutput('plot', inline = TRUE), center = TRUE)
    )
  )
)
