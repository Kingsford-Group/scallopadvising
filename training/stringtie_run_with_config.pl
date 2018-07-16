#!/usr/bin/perl
use strict;
use warnings;
use threads;
use threads::shared;
use Data::Dumper;
use POSIX;


# takes an output directory, a BAM file and a config file. Runs Scallop with the designated
# configuration and puts the output in the given directory
# in {e}_c{p} file naming convention.

our $working_dir = shift;
chomp $working_dir;

our $experement_file = shift;
chomp $experement_file;

our $config_file = shift;
chomp $config_file;

my $file_name = $experement_file;
$file_name =~ s/.*\/([a-zA-Z0-9]*).bam/$1/;

my $config_name = $config_file;
$config_name =~ s/.*\/([^\/]*).config/$1/;

my $command = "stringtie -i $experement_file";
foreach my $l(`cat $config_file`){
  chomp $l;
  my @spl = split(/\s+/,$l);
  $command .= " -$spl[0] $spl[1]";
}

my $out_fname = "${file_name}_c$config_name";
system("mkdir -p $working_dir");
if(-e "$working_dir/$out_fname.auc" && `grep -c auc $working_dir/$out_fname.auc` > 0){
}else{
  if((-e "$working_dir/$out_fname.gtf.gz")){
      system("gunzip $working_dir/$out_fname.gtf.gz");
  }

  if(!(-e "$working_dir/$out_fname.gtf")){
      system("$command -o $working_dir/$out_fname.gtf > $working_dir/$out_fname.log 2>&1 ");
  }

  if((-e "$working_dir/$out_fname.gtf")){
    if(`grep -c "^chr" $working_dir/$out_fname.gtf` == 0){
      system("sed -i 's/^/chr/' $working_dir/$out_fname.gtf");
    }

    system("gffcompare -r data/GRCh38_chr.gtf -o $working_dir/$out_fname $working_dir/$out_fname.gtf");
    if((-e "$working_dir/$out_fname.$out_fname.gtf.tmap")){
      # $num_transcripts should match the number of transcripts in the reference
      my $num_transcripts = 197649;

      system("gtfcuff auc $working_dir/$out_fname.$out_fname.gtf.tmap $num_transcripts >  $working_dir/$out_fname.auc");
      system("rm $working_dir/$out_fname.$out_fname.gtf.refmap $working_dir/$out_fname.loci $working_dir/$out_fname.annotated.gtf $working_dir/$out_fname.tracking");
      system("gzip $working_dir/$out_fname.gtf");
    }
  }
}
