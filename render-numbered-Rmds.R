

files <- c(
  "001-align-coho-genome.Rmd",
#  "002-allele-frequencies.Rmd",  # Don't render this automatically because it depends on cluster-generated output that is not in the stored_results
  "003-extract-johnson-creek-variants.Rmd",
  "004-prepare-haplotypes.Rmd",
  "005-annotating-variants-near-greb1l.Rmd",
  "006-haplo-raster-plots.Rmd",
  "007-arg-inference-and-plotting.Rmd",
  "008-read-depths-and-duplications.Rmd",
  "009-rosa-dna-distance-trees.Rmd",
  "010-salmon-river-carcasses.Rmd",
  "011-recombinant-frequencies.Rmd",
  "012-coalescent-modeling-of-recombinants.Rmd",
  "100-RoSA-figure1-map.Rmd",
  "101-Klamath-estuary-GSI-rubias.Rmd",
  "102-Klamath-estuary-ANOVA-sampling-date-RoSA.Rmd",
  "102.1-Klamath-estuary-partial-correlation.Rmd",
  "103-Klamath-estuary-GonadSI-mixed-model-analysis.Rmd",
  "103.1-Klamath-estuary-GonadSI-power-analysis.Rmd",
  "104-Klamath-estuary-nonwaterfraction-adiposity-mixed-model-analysis.Rmd",
  "104.1-Klamath-estuary-nonwaterfraction-power-analysis.Rmd",
  "105-Klamath-estuary-figure4.Rmd",
  "106-TrinityRiver-ANOVA-etc.Rmd",
  "107-RoSA-population-genetics-survey.Rmd",
  "108-Klamath-basin-early-RoSA-haplotype-abundance-commercial-fishery-model-tableS10.Rmd",
  "201-01-prep-bams-to-seek-inversions.Rmd",
  "201-02-seek-inversions.Rmd",
  "202-01-genomewide-allele-freqs-from-the-bams.Rmd",
  "203-01-pca-for-gwas-covariate.Rmd",
  "203-02-gwas-with-angsd.Rmd",
  "204-01-assess-genotyping-error-rate-with-whoa.Rmd",
  "204-02-assess-genotype-error-from-subsampled-hi-read-depth-samples.Rmd",
  "204-03-simulate-imputation-and-phasing-error-for-trees.Rmd"
)

for(f in files) {
  
  outfile <- stringr::str_replace(f, "Rmd$", "stdout")
  errfile <- stringr::str_replace(f, "Rmd$", "stderr")
  
  message("")
  message("Processing         : " , f)
  message("Standard output to : ", outfile)
  message("Error output to    : ", errfile)
  message("")
  # a bunch of rigamoral to get it to render in an entirely fresh, clean R session.
  # See: https://github.com/rstudio/rmarkdown/issues/1204
  path <- callr::r(
    function(...) rmarkdown::render(...),
    args = list(input = f, 
                output_format = "html_document", 
                envir = globalenv()
    ),
    stdout = outfile,
    stderr = errfile
  )
}


# after generating those html files, this just hardlinks to them from the docs
# directory.  This is just a little thing to make it easy to commit them into the
# docs directory for serving up on GitHub pages, while gitignoring them in the main directory.
#system("cd docs; rm [012]??*.html; for i in ../[012]??*.html; do echo $i; ln $i $(basename $i);  done")


# Also, here let's copy the final figures over:
message("Creating directory final-figs and copying figures to it")
dir.create("final-figs", showWarnings = FALSE)

file.copy("outputs/100/RoSA_figure1_map_with_inset.pdf", "final-figs/fig-01.pdf", overwrite = TRUE)
file.copy("outputs/002/allele-frequencies.pdf", "final-figs/fig-02.pdf", overwrite = TRUE)
file.copy("hand-edited-images/ultra-heatmap-chopped.pdf", "final-figs/fig-03.pdf", overwrite = TRUE)
file.copy("outputs/105/RoSA_figure4_multipanel_estuary_gonadsi_fatness.pdf", "final-figs/fig-04.pdf", overwrite = TRUE)

file.copy("outputs/009/chinook-only-distance-unrooted-tree_jc.pdf", "final-figs/fig-S01.pdf", overwrite = TRUE)
file.copy("outputs/006/haplo-raster-alleles.pdf", "final-figs/fig-S02.pdf", overwrite = TRUE)
file.copy("outputs/009/tree-and-smooth.pdf", "final-figs/fig-S03.pdf", overwrite = TRUE)
file.copy("outputs/006/haplo-raster-read-depths.pdf", "final-figs/fig-S04.pdf", overwrite = TRUE)
file.copy("outputs/008/aggregate-read-depth-lines.pdf", "final-figs/fig-S05.pdf", overwrite = TRUE)
file.copy("outputs/008/dupie-read-depth-scatter.pdf", "final-figs/fig-S06.pdf", overwrite = TRUE)
file.copy("outputs/106/trh-gsi-plot.pdf", "final-figs/fig-S07.pdf", overwrite = TRUE)
file.copy("outputs/106/trh-spawn-date-plot.pdf", "final-figs/fig-S08.pdf", overwrite = TRUE)

# Fig S9 was created outside of this repository

file.copy("outputs/010/salmon-river-spatiotemporal-map-2006.pdf", "final-figs/fig-S10.pdf", overwrite = TRUE)
file.copy("outputs/010/salmon-river-map-all-years-faceted-by-geno.pdf", "final-figs/fig-S11.pdf", overwrite = TRUE)
file.copy("outputs/010/salmon-river_hwe_counts-3-panel.pdf", "final-figs/fig-S12.pdf", overwrite = TRUE)
file.copy("hand-edited-images/recomb-coal.pdf", "final-figs/fig-S13.pdf", overwrite = TRUE)
file.copy("outputs/012/prince-rosa-recomb-histos.pdf", "final-figs/fig-S14.pdf", overwrite = TRUE)



