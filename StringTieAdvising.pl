#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

srand(time());
sub rndStr{ join '', @_[ map{ rand @_ } 1 .. shift ] }


my $stringtie_path = "stringtie";
my $gffcompare_path = "gffcompare";
my $gtfcuff_path = "gtfcuff";

my $working_dir = ".";
my $input_bam = "";
my $output_gtf = "";
my $reference = "";
my $logfname = "";
my $library_type = "";

GetOptions ("stringtie_path=s"    => \$scallop_path,
            "gffcompare_path=s" => \$gffcompare_path,
            "gtfcuff_path=s"    => \$gtfcuff_path,
            "working_dir=s"     => \$working_dir,
            "input_bam=s"       => \$input_bam,
            "output_gtf=s"      => \$output_gtf,
            "reference=s"       => \$reference,
            "log_file=s"        => \$logfname
            "library_type=s"    => \$library_type)
 or die("Error in command line arguments\n");

my @configs;
foreach my $c(@ARGV){
  chomp $c;
  if(-e $c){
    push @configs, $c;
  }else{
    die("Configuration file $c does not exist\n");
  }
}
my $best_auc = -1;

my $reference_length = `grep -c "\ttranscript\t" $reference`;

open LOGFILE,">$logfname" if $logfname ne "";

foreach my $config_file (@configs){

  my $temp_file_prefix = "temp" . (rndStr 8, 'a'..'z', 0..9);

  my $command = "$stringtie_path -i $input_bam -c 0.001 ";
  
  if($library_type eq "first"){
    $command .= " --rf ";
  }elsif($library_type eq "second"){
    $command .= " --fr ";
  }

  foreach my $l(`cat $config_file`){
    chomp $l;
    my @spl = split(/\s+/,$l);
    $command .= " --$spl[0] $spl[1]";
  }

  system("$command -o $working_dir/$temp_file_prefix.gtf > $working_dir/$temp_file_prefix.log 2>/dev/null ");
  if((-e "$working_dir/$temp_file_prefix.gtf")){
    if(`grep -c "^chr" $working_dir/$temp_file_prefix.gtf` == 0){
      system("sed -i 's/^/chr/' $working_dir/$temp_file_prefix.gtf");
    }

    system("$gffcompare_path -r $reference -o $working_dir/$temp_file_prefix $working_dir/$temp_file_prefix.gtf");
    if((-e "$working_dir/$temp_file_prefix.$temp_file_prefix.gtf.tmap")){
      my $auc = `$gtfcuff_path auc $working_dir/$temp_file_prefix.$temp_file_prefix.gtf.tmap $reference_length`;
      die("AUC command failed on $config_file\n") if(!($auc =~ /.*auc =/));
      $auc =~ s/.*auc = //;
      chomp $auc;
      print LOGFILE "$config_file\t$auc\n" if $logfname ne "";
      if($best_auc < $auc){
        system("mv $working_dir/$temp_file_prefix.gtf $output_gtf.temp");
        $best_auc = $auc;
      }
      system("rm $working_dir/$temp_file_prefix.*");
    }else{
      die("GFFCompare command failed on configuration file $config_file\n");
    }
  }else{
    die("Scallop command failed on configuration file $config_file\n");
  }
}

print "Best AUC found: $best_auc\n";
close LOGFILE if $logfname ne "";

system("mv $output_gtf.temp $output_gtf");
