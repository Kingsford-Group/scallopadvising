#!/usr/bin/perl
use strict;
use warnings;

system("mkdir -p output/scallop/encode65/");

my @files = `cat data/encode65.list`;
foreach my $fileLine(@files){
  chomp $fileLine;
  my $file = $fileLine;
  $file =~ s/^([^:]*):.*/$1/;
  my $ref = $fileLine;
  $ref =~ s/.*:([^:]*)$/$1/;
  my $libType = $fileLine;
  $libType =~ s/.*:([^:]*):.*/$1/;
  next if !(-e "data/encode65/$file.bam");
  system("../ScallopAdvising.pl -working_dir output/scallop/encode65/ -input_bam data/encode65/$file.bam -reference $ref.gtf --library_type $libType --log_file output/scallop/encode65/$file.auc --output_gtf output/scallop/encode65/output_$file.gtf ../scallop_configs/*");
  system("rm output/scallop/encode65/output_$file.gtf");
}