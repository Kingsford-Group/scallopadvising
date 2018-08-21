#!/usr/bin/perl
use strict;
use warnings;

system("mkdir -p output/scallop/encode10/");

foreach my $e("SRR307903","SRR307911","SRR315323","SRR315334","SRR387661","SRR534291","SRR534307","SRR534319","SRR545695","SRR545723"){
  foreach my $a("tophat","hisat","star"){
    chomp $file;
    next if !(-e "data/encode10/$e/$a.sort.bam");
    system("../ScallopAdvising.pl -working_dir output/scallop/encode10/ -input_bam data/encode10/$e/$a.sort.bam -reference GRCh38.gtf --log_file output/scallop/encode10/$e.$a.auc --output_gtf output/scallop/encode10/output_$e.$a.gtf ../scallop_configs/*");
    system("rm output/scallop/encode10/output_$e.$a.gtf");
  }
}