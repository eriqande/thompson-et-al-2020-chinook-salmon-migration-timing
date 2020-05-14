
# this is run on the cluster to create the directory
# chinook_WGS_processed that holds the bam files (and
# their indexes), and the gzipped VCF files (one for
# each chromosome)
rclone copy --drive-shared-with-me gdrive-rclone:chinook_WGS_processed chinook_WGS_processed
