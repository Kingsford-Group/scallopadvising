#!/usr/bin/perl
use strict;
use warnings;

system("mkdir -p output/scallop/sra/");

my @files = `cat data/sra.list`;
foreach my $file(@files){
  chomp $file;
  next if !(-e "data/sra/$file.bam");
  system("../ScallopAdvising.pl -working_dir output/scallop/sra/ -input_bam data/sra/$file.bam -reference GRCh38.gtf --log_file output/scallop/sra/$file.auc --output_gtf output/scallop/sra/output_$file.gtf ../scallop_configs/*");
  system("rm output/scallop/sra/output_$file.gtf");
}