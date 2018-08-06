# Scallop Parameter Advising

This repo contains a wrapper for the [Scallop](http://github.com/Kingsford-Group/scallop) transcriptome assembly tool.

## installation

The wrapper is written in perl but requires an installation of the following applications:
* [Scallop](http://github.com/Kingsford-Group/scallop)
* [gffcompare](https://github.com/gpertea/gffcompare)
* [rnaseqtools](https://github.com/Kingsford-Group/rnaseqtools)

If `scallop`, `gffcompare` and `gtfcuff` are not in your path they can be specified on the command line using the flags
`--scallop_path`, `-gffcompare_path` and `--gtfcuff_path` respectively.


## usage

The script `ScallopAdvising.pl` requires that the following options be given:
* `--working_dir` -- a folder in which temporary files will be stored
* `--input_bam` -- the mapping of RNA-seq reads to the reference *genome*
* `--output_gtf` -- the output file
* `--reference` -- the reference transcriptome corresponding to the reference genome used

Then a list of configuration files should be supplied (as described below).
An example of the full command is
```
./ScallopAdvising.pl --working_dir temp/ --input_bam in.bam --output_gtf out.gtf --reference ref.gtf default.config config1.config
```

optionally the `--log_file` parameter can be used to output a TSV file that lists the AUC for each of the input configurations. 

## config files

The configuration files are flat files on which each line contains one tunable parameter and its corresponding value.
Non-specified tunable parameters retain the default value.

An example of the default parameter configuration would be:
```
max_dp_table_size                   10000
max_edit_distance                   10
max_intron_contamination_coverage   2.0
max_num_exons                       1000
min_bundle_gap                      50
min_exon_length                     20
min_flank_length                    3
min_mapping_quality                 1
min_num_hits_in_bundle              20
min_router_count                    1
min_splice_boundary_hits            1
min_subregion_gap                   3
min_subregion_length                15
min_subregion_overlap               1.5
min_transcript_length_base          150
min_transcript_length_increase      50
uniquely_mapped_only                0
use_second_alignment                0
```
