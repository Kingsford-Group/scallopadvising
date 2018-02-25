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
