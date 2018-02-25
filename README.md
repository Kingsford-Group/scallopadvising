# Scallop Parameter Advising

This repo contains a wrapper for the [Scallop](http://github.com/Kingsford-Group/scallop) transcriptome assembly tool. 

## installation

The wrapper is written in perl but requires an installation of the following applications:
* [Scallop](http://github.com/Kingsford-Group/scallop)
* [gffcompare](https://github.com/gpertea/gffcompare)
* [rnaseqtools](https://github.com/Kingsford-Group/rnaseqtools)


Within ScallopAdvising.pl the the first 3 lines should be updated to reflect the applications location. 
```
my $scallop_path = "";
my $gffcompare_path = "";
my $gtfcuff_path = "";
```


## useage 

To use the script you will need to provide 3 command line parameters

```
./ScallopAdvising.pl <input_bam> <reference_gtf> <output_directory>
```

where 
* <input_bam> is an alignment of the RNA-seq reads to the reference *genome*,
* <reference_gtf> is the reference transcriptome in GTF format, and 
* <output_directory> is the path to a directory that will be used to store temporary files as well as the final transcriptome (as final.gtf)
